#!/bin/sh

# Put your fun stuff here.

source "./radio-cmd.cfg"

# todo :	auto fetch channels?
#			openbox menu creation
#			check valid channels structure + file content?
#			backup/restore
#			proper config

# useful later : http://wiki.bash-hackers.org/howto/getopts_tutorial

# constants
HELP_MESSAGE="Usage : radio-cmd.sh start | stop | kill | play category station"

# src: https://rushi.wordpress.com/2008/04/14/simple-regex-for-matching-urls/
URL_REGEX="(https?://([-\w\.]+)+(:\d+)?(/([\w/_\.]*(\?\S+)?)?)?)"

function pre_check {
	if [ ! -d "$RADIO_HOME" ]; then mkdir "$RADIO_HOME" ; fi

	# remove files if mplayer is not running
	if [ -e "$RADIO_PID" ]; then
		local pid=$(<"$RADIO_PID")
		if [ ! -e /proc/"$pid" ]; then
			rm "$RADIO_FIFO"
			rm "$RADIO_PID"
		fi
	fi
}

function check_running {
	local pid=$(<"$RADIO_PID")
	if [ ! -e /proc/"$pid" ]; then
		echo "Mplayer backend is not running. Please use start command."
		exit 1
	fi
}


function radio_start {
	mkfifo "$RADIO_FIFO"
	mplayer -idle -slave -input file="$RADIO_FIFO" 1&>/dev/null &
	echo $! > "$RADIO_PID"
	echo "started"
}

function radio_stop {
	check_running
	echo 'stop' >"$RADIO_FIFO"
	echo "stopped"
}

function radio_pause {
	check_running
	echo 'pause' >"$RADIO_FIFO"
	echo "pause toggled"
}

function radio_mute {
	check_running
	echo 'mute' >"$RADIO_FIFO"
	echo "mute toggled"
}

function radio_volume {
	check_running

	# check valid
	local re="^\([0-9]\?[0-9]$\)\|100$"
	echo "$1" | grep -q "$re"
	if [ $? -ne 0 ] ; then
		echo "volume must be between 0 and 100"
		exit 1
	fi

	echo "volume $1 1" >"$RADIO_FIFO"
	echo "volume set to $1"
}

function radio_kill {
	check_running

	local pid=$(<"$RADIO_PID")
	kill $pid
	rm "$RADIO_FIFO"
	rm "$RADIO_PID"
	echo "killed"
}

function radio_list {
	tree "$RADIO_HOME"
}

function radio_play () {
	check_running

	# check valid
	if [ -z "$1" ]; then
		echo "Missing radio name to play." ;
		exit 1;
	fi

	local radio="$RADIO_HOME$1"

	if [ ! -f "$radio" ]; then
		echo "Invalid radio name."
		exit 2
	fi

	local url=$(head -n 1 $radio)

	echo "loadfile $url" >"$RADIO_FIFO"
	echo "played $radio"
}

function check_vallid_add () {
	if [ -e "${1}" ]; then
		echo "something already exists at the same location"
		exit 1
	fi

	local dirPath=$(dirname "${1}")

	if [ ! -d "${dirPath}" ]; then
		echo "containing category does not exists"
		exit 2
	fi
}

function radio_add_category () {
	local fullPath="${RADIO_HOME}${1}"

	check_vallid_add "${fullPath}"

	mkdir "${fullPath}"

	echo "created category ${1}"
}

function radio_rm_category () {
	local fullPath="${RADIO_HOME}${1}"

	if [ ! $(find "${fullPath}" -maxdepth 0 -type d -empty 2>/dev/null) ]; then
		echo "Please check that the path is a category and it does not contains any channels or subcategories"
		exit 1
	fi

	rmdir "${fullPath}"

	echo "removed category ${1}"
}

function radio_add () {
	local fullPath="${RADIO_HOME}${1}"

	check_vallid_add "${fullPath}"

	echo "${2}" | grep --only-matching --perl-regexp -q "${URL_REGEX}"
	if [ $? -ne 0 ] ; then
		echo "channel must be a valid url"
		exit 3
	fi

	echo "${2}" > "${fullPath}"

	echo "created channel ${1}"
}

function radio_rm () {
	local fullPath="${RADIO_HOME}${1}"

	if [ ! -f "${fullPath}" ]; then
		echo "Please check that the path is a valid channel"
		exit 1
	fi

	rm "${fullPath}"

	echo "removed channel ${1}"
}

pre_check
cmd="$1"

case "$cmd" in
	"start" )
		radio_start ;;
	"stop" )
		radio_stop ;;
	"pause" )
		radio_pause ;;
	"mute" )
		radio_mute ;;
	"volume" )
		radio_volume "$2" ;;
	"kill" )
		radio_kill ;;
	"list" | "ls" )
		radio_list ;;
	"play" )
		radio_play "$2" ;;
	"add-category" )
		radio_add_category "$2" ;;
	"rm-category" )
		radio_rm_category "$2" ;;
	"add" )
		radio_add "$2" "$3" ;;
	"rm" )
		radio_rm "$2" ;;
	* )
		echo "$HELP_MESSAGE" ;;
esac

