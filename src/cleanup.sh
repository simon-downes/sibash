
function _sb.cleanup {

    # cleanup the command timer
    _sb.prompt.cmd_timer reset > /dev/null

    # clean up any spinner process
    _sb.spinner.kill

}

# now we're booted, make sure we run our cleanup function when the current shell exits
trap "_sb.cleanup" EXIT
