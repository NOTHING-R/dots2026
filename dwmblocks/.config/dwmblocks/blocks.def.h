/* Colors defined once — all blocks use these */
#define BG "#020101"
#define FG "#a7a7a6"
// #define FG "#40403F"

static const Block blocks[] = {
    /*Icon*/  /*Command*/                                                                                                                                                                                         /*Interval*/  /*Signal*/

    /* Memory */
    { "", "echo \"^c" FG "^^b" BG "^  $(free -h | awk '/^Mem/{print $3\"/\"$2}' | sed 's/i//g') ^d^\"",                                                                                                         1,            0 },

    /* Disk */
    { "", "echo \"^c" FG "^^b" BG "^  $(df -h / | awk 'NR==2{print $3\"/\"$2}') ^d^\"",                                                                                                                         60,           0 },

    /* Battery — fully inlined, shows Charging / Discharging / Full */
    { "", "[ -d /sys/class/power_supply/BAT0 ] && echo \"^c" FG "^^b" BG "^  BAT $(cat /sys/class/power_supply/BAT0/capacity)% [$(cat /sys/class/power_supply/BAT0/status)] ^d^\"",                             10,           0 },

    /* Date */
    { "", "echo \"^c" FG "^^b" BG "^  $(date '+%b %d (%a) %I:%M:%S%p') ^d^\"",                                                                                                                                  1,            0 },
};

/* No delimiter — each block handles its own spacing */
static char delim[] = "";
static unsigned int delimLen = 0;
