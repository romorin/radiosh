#!/bin/sh

# Put your fun stuff here.

# todo :	autocompletion
# 			adding/removing channels
#			adding/removing categories
#			auto fetch channels?
#			openbox menu creation
#			check valid channels structure?
#			backup/restore

# useful later : http://wiki.bash-hackers.org/howto/getopts_tutorial

# configuration
RADIO_HOME="$HOME/.radio-cmd/"
RADIO_PID="/tmp/radio-cmd.pid"
RADIO_FIFO="/tmp/radio-cmd.fifo"

# constants
HELP_MESSAGE="Usage : radio-cmd.sh start | stop | kill | play category station"

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
		return ;
	fi

	local radio="$RADIO_HOME$1"

	if [ ! -f "$radio" ]; then
		echo "Invalid radio name." ;
		return ;
	fi

	local url=$(head -n 1 $radio)

	echo "loadfile $url" >"$RADIO_FIFO"
	echo "played $radio"
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
	"list" )
		radio_list ;;
	"play" )
		radio_play "$2" ;;
	* )
		echo "$HELP_MESSAGE" ;;
esac

