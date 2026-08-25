#!/usr/bin/env bash
#
# herdr-dev — herdr project launcher with the same template system as dev.sh
#
# Usage:
#   herdr-dev run <path> [template]    open a project (default template: "default")
#   herdr-dev new <template>           create a new template interactively
#   herdr-dev edit <template>          edit an existing template in $EDITOR
#   herdr-dev delete <template>        delete a template
#
# Templates live in $HERDR_DEV_TEMPLATE_DIR (default: ~/.config/herdrdev/templates).
# Same syntax as dev.sh templates — your existing .sh templates work as-is:
#
#   session "name"
#   window "name"
#   window "name" "command to run"
#
# In herdr terms: session = workspace, window = tab.
# Workspaces are labelled "<project>-<session>", e.g. "nextapp-main".

set -euo pipefail

TEMPLATE_DIR="${HERDR_DEV_TEMPLATE_DIR:-$HOME/.config/herdrdev/templates}"
mkdir -p "$TEMPLATE_DIR"

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

normalize_name() { echo "${1%.sh}"; }

sanitize() {
  echo "$1" | tr -cs 'a-zA-Z0-9_-' '-' | sed 's/^-*//;s/-*$//'
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

check_deps() {
  if ! command -v jq &>/dev/null; then
    echo "jq is required: sudo apt install jq"
    exit 1
  fi
  if ! herdr status server &>/dev/null; then
    echo "herdr server is not running — start it with: herdr"
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Template parser — identical to dev.sh
# Emits one token per stdout line:
#   SESSION:<name>
#   WINDOW:<name>:<cmd>
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
      [ -z "$current_session" ] && {
        echo "  empty session name" >&2
        ((errors++)) || true
      }
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
    val="${val#"${val%%[![:space:]]*}"}"
    val="${val%"${val##*[![:space:]]}"}"
    [ -n "$val" ] && {
      echo "$val"
      return
    }
    echo "    cannot be empty, try again" >&2
  done
}

read_int() {
  local prompt="$1" val
  while true; do
    read -r -p "$prompt" val
    [[ "$val" =~ ^[0-9]+$ ]] && [ "$val" -gt 0 ] && {
      echo "$val"
      return
    }
    echo "    please enter a positive number" >&2
  done
}

read_safe_name() {
  local prompt="$1"
  while true; do
    local raw san
    raw=$(read_nonempty "$prompt")
    san=$(sanitize "$raw")
    [ -z "$san" ] && {
      echo "    name has no valid characters, try again" >&2
      continue
    }
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
  session_count=$(read_int "How many sessions (workspaces)? ")

  for ((s = 1; s <= session_count; s++)); do
    local session_name
    session_name=$(read_safe_name "  Session $s name: ")
    echo "session \"$session_name\"" >>"$tmpl_file"

    local window_count
    window_count=$(read_int "  How many windows (tabs) in '$session_name'? ")
    declare -A seen_wins=()

    for ((w = 1; w <= window_count; w++)); do
      local window_name
      while true; do
        window_name=$(read_safe_name "    Window $w name: ")
        [ -z "${seen_wins[$window_name]+x}" ] && break
        echo "      '$window_name' already exists in this session, pick another" >&2
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
  local tmpl_name tmpl_file
  tmpl_name=$(normalize_name "$1")
  tmpl_file="$TEMPLATE_DIR/$tmpl_name.sh"
  [ ! -f "$tmpl_file" ] && {
    echo "no such template: $tmpl_name"
    echo "use '$(basename "$0") new $tmpl_name' to create it"
    exit 1
  }
  "${EDITOR:-vi}" "$tmpl_file"
}

# ---------------------------------------------------------------------------
# delete
# ---------------------------------------------------------------------------
delete_template() {
  local tmpl_name tmpl_file
  tmpl_name=$(normalize_name "$1")
  tmpl_file="$TEMPLATE_DIR/$tmpl_name.sh"
  [ ! -f "$tmpl_file" ] && {
    echo "no such template: $tmpl_name"
    exit 1
  }
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

  [ ! -f "$tmpl_file" ] && {
    echo "no such template: $tmpl_name  (looked in $tmpl_file)"
    echo "use '$(basename "$0") new $tmpl_name' to create it"
    exit 1
  }

  echo "validating template '$tmpl_name'..."
  if ! validate_template "$tmpl_file"; then
    echo "fix the errors above then try again"
    exit 1
  fi

  check_deps

  local proj_name
  proj_name=$(basename "$proj_path")

  local current_ws_id="" first_ws_id=""
  local first_tab_in_ws=1
  local root_pane_id=""

  while IFS= read -r token; do
    case "$token" in

    SESSION:*)
      local s_name="${token#SESSION:}"
      local ws_label
      ws_label=$(sanitize "${proj_name}-${s_name}")

      echo "  workspace: $ws_label"
      local ws_json
      ws_json=$(herdr workspace create --cwd "$proj_path" --label "$ws_label" --no-focus)
      current_ws_id=$(echo "$ws_json" | jq -r '.result.workspace.workspace_id')
      root_pane_id=$(echo "$ws_json" | jq -r '.result.root_pane.pane_id')

      [ -z "$first_ws_id" ] && first_ws_id="$current_ws_id"
      first_tab_in_ws=1
      ;;

    WINDOW:*)
      local rest="${token#WINDOW:}"
      local w_name="${rest%%:*}"
      local w_cmd="${rest#*:}"
      local pane_id

      if [ "$first_tab_in_ws" -eq 1 ]; then
        # herdr auto-creates the first tab when the workspace is made — reuse it
        local first_tab_id
        first_tab_id=$(herdr tab list --workspace "$current_ws_id" |
          jq -r '.result.tabs[0].tab_id')
        herdr tab rename "$first_tab_id" "$w_name" 2>/dev/null || true
        pane_id="$root_pane_id"
        first_tab_in_ws=0
      else
        local tab_json
        tab_json=$(herdr tab create \
          --workspace "$current_ws_id" \
          --label "$w_name" \
          --no-focus)
        pane_id=$(echo "$tab_json" | jq -r '.result.root_pane.pane_id')
      fi

      echo "    tab: $w_name${w_cmd:+ → $w_cmd}"
      [ -n "$w_cmd" ] && herdr pane run "$pane_id" "$w_cmd"
      ;;

    esac
  done < <(parse_template "$tmpl_file")

  # focus the first workspace
  herdr workspace focus "$first_ws_id"
  echo "done"
}

run_cmd() {
  [ "$#" -lt 1 ] && {
    echo "usage: $(basename "$0") run <path> [template]"
    exit 1
  }
  local proj_path template
  proj_path=$(resolve_path "$1")
  template=$(normalize_name "${2:-default}")
  [ ! -d "$proj_path" ] && {
    echo "not a directory: $proj_path"
    exit 1
  }
  run_template "$proj_path" "$template"
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
[ "$#" -lt 1 ] && {
  usage
  exit 1
}

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
