#!/usr/bin/env bash
#
# dev - tmux project launcher with custom multi-session/window templates
#
# Usage:
#   dev run <path> [template]    open a project (default template: "default")
#   dev new <template>           create a new template interactively
#   dev edit <template>          edit an existing template in $EDITOR
#   dev delete <template>        delete a template
#
# Templates live in $DEV_TEMPLATE_DIR (default: ~/.config/devtmux/templates).
# Each is a plain text file with this syntax (# comments and blank lines ok):
#
#   session "name"
#   window "name"
#   window "name" "command to run"
#
# Sessions appear in tmux as "<parent>-<project>-<session>", e.g.
# "projects-nextapp-main", keeping same-named projects from colliding.

set -euo pipefail

TEMPLATE_DIR="${DEV_TEMPLATE_DIR:-$HOME/.config/devtmux/templates}"
LOCK_DIR="${TMPDIR:-/tmp}/devtmux/locks"
mkdir -p "$TEMPLATE_DIR" "$LOCK_DIR"

# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

resolve_path() {
  if command -v realpath &>/dev/null; then
    realpath "$1"
  else
    (cd "$1" 2>/dev/null && pwd) || {
      echo "cannot resolve path: $1" >&2
      exit 1
    }
  fi
}

# Strip accidental .sh suffix so both "fullstack" and "fullstack.sh" work
normalize_name() {
  echo "${1%.sh}"
}

# Keep only alphanumeric, dash, underscore — safe for tmux target syntax
sanitize() {
  echo "$1" | tr -cs 'a-zA-Z0-9_-' '-' | sed 's/^-*//;s/-*$//'
}

# Use parent-dir + project-dir to avoid same-basename collisions
project_id() {
  local proj_path="$1"
  local parent base
  parent=$(basename "$(dirname "$proj_path")")
  base=$(basename "$proj_path")
  sanitize "${parent}-${base}"
}

usage() {
  echo "usage:"
  echo "  $(basename "$0") run <path> [template]    open a project (default: default)"
  echo "  $(basename "$0") new <template>           create a new template"
  echo "  $(basename "$0") edit <template>          edit an existing template"
  echo "  $(basename "$0") delete <template>        delete a template"
  echo ""
  local files
  files=$(find "$TEMPLATE_DIR" -maxdepth 1 -name '*.sh' 2>/dev/null || true)
  if [ -n "$files" ]; then
    echo "available templates:"
    echo "$files" | xargs -I{} basename {} .sh | sed 's/^/  /'
  fi
}

# ---------------------------------------------------------------------------
# Template parser — NO source, no arbitrary code execution.
# Regex patterns stored in variables to avoid quoting issues in [[ =~ ]].
# Emits one token per stdout line:
#   SESSION:<name>
#   WINDOW:<name>:<cmd>          (cmd may be empty)
#   PARSE_ERROR:<lineno>:<line>
# ---------------------------------------------------------------------------
parse_template() {
  local file="$1"
  local lineno=0 line
  local re_session='^session[[:space:]]+"([^"]+)"[[:space:]]*$'
  local re_window2='^window[[:space:]]+"([^"]+)"[[:space:]]+"([^"]*)"[[:space:]]*$'
  local re_window1='^window[[:space:]]+"([^"]+)"[[:space:]]*$'

  while IFS= read -r line || [[ -n "$line" ]]; do
    ((lineno++)) || true
    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue

    if [[ "$line" =~ $re_session ]]; then
      echo "SESSION:${BASH_REMATCH[1]}"
    elif [[ "$line" =~ $re_window2 ]]; then
      echo "WINDOW:${BASH_REMATCH[1]}:${BASH_REMATCH[2]}"
    elif [[ "$line" =~ $re_window1 ]]; then
      echo "WINDOW:${BASH_REMATCH[1]}:"
    else
      echo "PARSE_ERROR:${lineno}:${line}"
    fi
  done <"$file"
}

# Validate template before touching tmux.
# Prints errors to stderr, returns 1 if any found.
validate_template() {
  local tmpl_file="$1"
  local errors=0
  local current_session="" window_count=0
  declare -A seen_windows=()

  _finish_session_check() {
    if [ -n "$current_session" ] && [ "$window_count" -eq 0 ]; then
      echo "  session '$current_session' has no windows" >&2
      ((errors++)) || true
    fi
  }

  while IFS= read -r token; do
    case "$token" in
    PARSE_ERROR:*)
      local rest="${token#PARSE_ERROR:}"
      local lnum="${rest%%:*}"
      local bad="${rest#*:}"
      echo "  syntax error at line $lnum: $bad" >&2
      ((errors++)) || true
      ;;
    SESSION:*)
      _finish_session_check
      current_session="${token#SESSION:}"
      window_count=0
      unset seen_windows
      declare -A seen_windows=()
      if [ -z "$current_session" ]; then
        echo "  empty session name" >&2
        ((errors++)) || true
      fi
      ;;
    WINDOW:*)
      local rest="${token#WINDOW:}"
      local wname="${rest%%:*}"
      if [ -z "$wname" ]; then
        echo "  empty window name in session '$current_session'" >&2
        ((errors++)) || true
      elif [ -n "${seen_windows[$wname]+x}" ]; then
        echo "  duplicate window '$wname' in session '$current_session'" >&2
        ((errors++)) || true
      else
        seen_windows[$wname]=1
        ((window_count++)) || true
      fi
      ;;
    esac
  done < <(parse_template "$tmpl_file")

  _finish_session_check

  [ "$errors" -gt 0 ] && return 1
  return 0
}

# ---------------------------------------------------------------------------
# Wizard helpers
# ---------------------------------------------------------------------------
read_nonempty() {
  local prompt="$1" val
  while true; do
    read -r -p "$prompt" val
    # trim whitespace
    val="${val#"${val%%[![:space:]]*}"}"
    val="${val%"${val##*[![:space:]]}"}"
    if [ -n "$val" ]; then
      echo "$val"
      return
    fi
    echo "    cannot be empty, try again" >&2
  done
}

read_int() {
  local prompt="$1" val
  while true; do
    read -r -p "$prompt" val
    if [[ "$val" =~ ^[0-9]+$ ]] && [ "$val" -gt 0 ]; then
      echo "$val"
      return
    fi
    echo "    please enter a positive number" >&2
  done
}

read_safe_name() {
  local prompt="$1"
  while true; do
    local raw san
    raw=$(read_nonempty "$prompt")
    san=$(sanitize "$raw")
    if [ -z "$san" ]; then
      echo "    name has no valid characters, try again" >&2
      continue
    fi
    if [ "$san" != "$raw" ]; then
      echo "    invalid characters — will be stored as: $san" >&2
      read -r -p "    accept? [y/N] " ok
      case "$ok" in y | Y)
        echo "$san"
        return
        ;;
      *) continue ;; esac
    else
      echo "$san"
      return
    fi
  done
}

# ---------------------------------------------------------------------------
# new
# ---------------------------------------------------------------------------
new_template() {
  local tmpl_name
  tmpl_name=$(normalize_name "$1")
  local tmpl_file="$TEMPLATE_DIR/$tmpl_name.sh"

  if [ -f "$tmpl_file" ]; then
    read -r -p "template '$tmpl_name' already exists, overwrite? [y/N] " confirm
    case "$confirm" in y | Y) ;; *)
      echo "cancelled"
      exit 0
      ;;
    esac
  fi

  : >"$tmpl_file"

  local session_count
  session_count=$(read_int "How many sessions? ")

  for ((s = 1; s <= session_count; s++)); do
    local session_name
    session_name=$(read_safe_name "  Session $s name: ")
    echo "session \"$session_name\"" >>"$tmpl_file"

    local window_count
    window_count=$(read_int "  How many windows in '$session_name'? ")
    declare -A seen_wins=()

    for ((w = 1; w <= window_count; w++)); do
      local window_name
      while true; do
        window_name=$(read_safe_name "    Window $w name: ")
        if [ -n "${seen_wins[$window_name]+x}" ]; then
          echo "      '$window_name' already exists in this session, pick another" >&2
          continue
        fi
        break
      done
      seen_wins[$window_name]=1

      local window_cmd
      read -r -p "    Command in '$window_name' (blank for plain shell): " window_cmd
      if [ -n "$window_cmd" ]; then
        echo "window \"$window_name\" \"$window_cmd\"" >>"$tmpl_file"
      else
        echo "window \"$window_name\"" >>"$tmpl_file"
      fi
    done
    unset seen_wins
    echo "" >>"$tmpl_file"
  done

  echo "saved: $tmpl_file"
}

# ---------------------------------------------------------------------------
# edit
# ---------------------------------------------------------------------------
edit_template() {
  local tmpl_name
  tmpl_name=$(normalize_name "$1")
  local tmpl_file="$TEMPLATE_DIR/$tmpl_name.sh"

  if [ ! -f "$tmpl_file" ]; then
    echo "no such template: $tmpl_name"
    echo "use '$(basename "$0") new $tmpl_name' to create it"
    exit 1
  fi

  "${EDITOR:-vi}" "$tmpl_file"
}

# ---------------------------------------------------------------------------
# delete
# ---------------------------------------------------------------------------
delete_template() {
  local tmpl_name
  tmpl_name=$(normalize_name "$1")
  local tmpl_file="$TEMPLATE_DIR/$tmpl_name.sh"

  if [ ! -f "$tmpl_file" ]; then
    echo "no such template: $tmpl_name"
    exit 1
  fi

  read -r -p "delete template '$tmpl_name'? [y/N] " confirm
  case "$confirm" in
  y | Y)
    rm "$tmpl_file"
    echo "deleted: $tmpl_file"
    ;;
  *) echo "cancelled" ;;
  esac
}

# ---------------------------------------------------------------------------
# run
# ---------------------------------------------------------------------------
run_template() {
  local proj_path="$1"
  local tmpl_name
  tmpl_name=$(normalize_name "$2")
  local tmpl_file="$TEMPLATE_DIR/$tmpl_name.sh"

  if [ ! -f "$tmpl_file" ]; then
    echo "no such template: $tmpl_name  (looked in $tmpl_file)"
    echo "use '$(basename "$0") new $tmpl_name' to create it"
    exit 1
  fi

  echo "validating template '$tmpl_name'..."
  if ! validate_template "$tmpl_file"; then
    echo "fix the errors above then try again"
    exit 1
  fi

  local proj_id
  proj_id=$(project_id "$proj_path")

  # concurrency lock — prevent two simultaneous launches for the same project
  local lock_file="$LOCK_DIR/${proj_id}.lock"
  exec 9>"$lock_file"
  if ! flock -n 9; then
    echo "another 'dev run' for '$proj_id' is already in progress"
    exit 1
  fi

  # track what we create so we can roll back on error
  local created_sessions=()

  _cleanup() {
    echo "" >&2
    echo "error — rolling back partially created sessions..." >&2
    for sess in "${created_sessions[@]:-}"; do
      tmux kill-session -t "$sess" 2>/dev/null && echo "  killed: $sess" >&2
    done
    exit 1
  }
  trap _cleanup ERR

  local current_session="" session_exists=0 first_window="" attach_target=""
  declare -A cur_windows=()

  _wrap_session() {
    if [ -n "$current_session" ] && [ "$session_exists" -eq 0 ] && [ -n "$first_window" ]; then
      tmux select-window -t "$current_session:$first_window"
    fi
  }

  while IFS= read -r token; do
    case "$token" in
    SESSION:*)
      _wrap_session
      local s_name="${token#SESSION:}"
      current_session="$(basename "$proj_path")-${s_name}"
      first_window=""
      unset cur_windows
      declare -A cur_windows=()

      if tmux has-session -t "$current_session" 2>/dev/null; then
        session_exists=1
      else
        session_exists=0
      fi
      [ -z "$attach_target" ] && attach_target="$current_session"
      ;;

    WINDOW:*)
      local rest="${token#WINDOW:}"
      local w_name="${rest%%:*}"
      local w_cmd="${rest#*:}"

      if [ "$session_exists" -eq 1 ]; then
        # sync: add window if missing from existing session
        if ! tmux list-windows -t "$current_session" -F '#W' 2>/dev/null | grep -qx "$w_name"; then
          tmux new-window -t "$current_session" -n "$w_name" -c "$proj_path"
          [ -n "$w_cmd" ] && tmux send-keys -t "$current_session:$w_name" "$w_cmd" C-m
        fi
      else
        if [ -z "$first_window" ]; then
          tmux new-session -d -s "$current_session" -n "$w_name" -c "$proj_path"
          created_sessions+=("$current_session")
          first_window="$w_name"
        else
          tmux new-window -t "$current_session" -n "$w_name" -c "$proj_path"
        fi
        [ -n "$w_cmd" ] && tmux send-keys -t "$current_session:$w_name" "$w_cmd" C-m
      fi
      ;;
    esac
  done < <(parse_template "$tmpl_file")

  _wrap_session
  trap - ERR

  if [ -z "$attach_target" ]; then
    echo "template '$tmpl_name' produced no sessions"
    exit 1
  fi

  if [ -n "${TMUX:-}" ]; then
    tmux switch-client -t "$attach_target"
  else
    tmux attach -t "$attach_target"
  fi
}

run_cmd() {
  if [ "$#" -lt 1 ]; then
    echo "usage: $(basename "$0") run <path> [template]"
    exit 1
  fi

  local proj_path template
  proj_path=$(resolve_path "$1")
  template=$(normalize_name "${2:-default}")

  if [ ! -d "$proj_path" ]; then
    echo "not a directory: $proj_path"
    exit 1
  fi

  run_template "$proj_path" "$template"
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
if [ "$#" -lt 1 ]; then
  usage
  exit 1
fi

cmd="$1"
shift

case "$cmd" in
run) run_cmd "$@" ;;
new)
  [ "$#" -lt 1 ] && {
    echo "usage: $(basename "$0") new <template>"
    exit 1
  }
  new_template "$1"
  ;;
edit)
  [ "$#" -lt 1 ] && {
    echo "usage: $(basename "$0") edit <template>"
    exit 1
  }
  edit_template "$1"
  ;;
delete)
  [ "$#" -lt 1 ] && {
    echo "usage: $(basename "$0") delete <template>"
    exit 1
  }
  delete_template "$1"
  ;;
*)
  echo "unknown command: $cmd"
  usage
  exit 1
  ;;
esac
