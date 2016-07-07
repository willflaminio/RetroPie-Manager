#!/bin/bash
# rpmanager.sh
###############
#
# An easier way to manage the RetroPie-Manager.
#
# This script is intended to use when RetroPie-Manager is installed via
# retropie_setup. It happens because of the hardcoded path in the 
# rpmanager_dir variable.

rpmanager_dir="/opt/retropie/supplementary/retropie-manager"

usage="$0 OPTIONS"

help_message="Usage: $usage

The OPTIONS are:

-h|--help           print this message and exit
--start             start the RetroPie-Manager
--stop              stop the RetroPie-Manager
--isrunning         check if RetroPie-Manager is running and exit
--log               save the log messages (optional, default: not save log
                    messages, only works with --start)
-p|--port NUMBER    make RetroPie-Manager listen at port NUMBER (optional,
                    default: 8000, only works with --start)

The --start and --stop options are, obviously, mutually exclusive. If the
user uses both, only the first works.
"

# default TCP port to listen
port=8000

# the default is not save log files
log_command="&> /dev/null"


function is_running() {
    pgrep -f 'python.*manage\.py.*runserver' &>/dev/null
    return $?
}


function start_service() {
    if is_running; then
        echo "Nothing done. RetroPie-Manager is already running." >&2
        return 1
    fi

startcmd="${rpmanager_dir}/bin/python \
            ${rpmanager_dir}/manage.py \
            runserver 0.0.0.0:$port \
            --settings=project.settings_production \
            --noreload \
            $log_command"

    # TODO: check if the service really started
    eval $startcmd &>/dev/null &
}


function stop_service() {
    if is_running; then
        sudo kill -9 $(pgrep -f 'python.*manage\.py.*runserver')
        return 0
    fi

    echo "Nothing done. RetroPie-Manager wasn't running." >&2
    return 1
}


##############################################################################
# start point
##############################################################################

# because of the hardcoded paths, it only works if installed
# via retropie_setup.sh
[[ -d "$rpmanager_dir" ]] || {
    echo "Error: this script is intended to use when RetroPie-Manager is installed via retropie_setup.sh" >&2
    exit 1
}


[[ "$1" ]] || {
    echo -e "\nError: missing arguments\n" >&2
    echo "$help_message" >&2
    exit 1
}


# the following variables work like flags. they are used to deal with 
# the command line options.
f_start=0
f_stop=0

while [[ "$1" ]]; do
    case "$1" in

    -h|--help)
        echo "$help_message"
        exit 0
    ;;

    --isrunning)
        # TODO: provide more information, example: the port number
        if is_running; then
            echo "RetroPie-Manager is running"
            exit 0
        else
            echo "RetroPie-Manager is not running"
            exit 1
        fi
    ;;

    --start)
        if [[ "$f_stop" = "0" ]]; then
            f_start=1
        else
            echo "Warning: ignoring '--start' option" >&2
            f_start=0
        fi
    ;;

    --stop)
        if [[ "$f_start" = "0" ]]; then
            f_stop=1
        else
            echo "Warning: ignoring '--stop' option" >&2
            f_stop=0
        fi
    ;;

    --log)
        if [[ "$f_start" = "0" ]]; then
            echo "Warning: ignoring '--log' option" >&2
            shift
            continue
        fi

        log_dir="${rpmanager_dir}/logs"
        mkdir -p "$log_dir"
        log_command="&> ${log_dir}/rpmanager-$(date +%Y-%m-%d-%H%M%S).log"
    ;;

    -p|--port)
        if [[ "$f_start" = "0" ]]; then
            echo "Error: the '--port' option is used with '--start' only" >&2
            exit 1
        fi

        shift
        port="$1"

        # checking if $port is a number and is a valid non-privileged port
        echo "$port" | grep '^[0-9]\{1,\}$' >/dev/null &&
          [ $port -ge 1024 -a $port -lt 65535 ] || {
            echo "Error: invalid port number: $port"
            echo "The port must be a number between 1024 and 65535, inclusive" >&2
            exit 1
        }
    ;;

    *)  echo "Invalid option: $1" >&2
        exit 1
    ;;
    esac

    # shifting for the next option
    shift
done

[[ "$f_start" = "1" ]] && {
    start_service
    # TODO: exit with 0 only if the service really started
    exit
}

[[ "$f_stop" = "1" ]] && {
    stop_service
    exit
}
