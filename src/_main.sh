
. colours.sh

export SB_BULLET="${SB_CYAN}-${SB_RESET}"

# default log file
export SB_LOG_FILE=${SB_LOG_FILE:-~/sb.log}

# grab cpu architecture
export SB_CPU_ARCH=$(uname -m)

# simple single line to stdout
# sb.error
# sb.warn
# sb.info
# sb.debug

# # pretty box to stdout
# # first arg is header, others are description
# # if only 1 arg then first line of it is header?
# sb.panel <colour> <title> <body>
# sb.panel.error
# sb.panel.warn
# sb.panel.info
# sb.panel.debug

# # timestamped log line with process id
# sb.log.error
# sb.log.warn
# sb.log.info
# sb.log.debug


# if executed (as opposed to sourced) then
# if no args, display help/info/usage
# else first arg is function without the sb. prefix so try and execute that
. core.sh
. is.sh
. log.sh
. session.sh
. prompt.sh
. input.sh

. spinner.sh
. install.sh



sb.error foo bar
sb.warn foo bar
sb.info foo bar
sb.debug foo bar
sb.fail foo bar
sb.success foo bar
