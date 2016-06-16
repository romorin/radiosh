#!/bin/bash

source "./radio-cmd.cfg"

_radio-cmd () 
{
	local cur prev opts
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	opts="kill list mute pause play start stop volume"
	
	case "${prev}" in
		"play" )
			local last=$(echo -n "${cur}" | tail -c -1)
			
			local chanDir
			
			if [ "${last}" = '/' ]; then
				chanDir="${cur}"
			else
				chanDir=$(dirname "${cur}")
			fi
			
			local fullDir
			
			if [ "${chanDir}" != '.' ]; then
				fullDir="${RADIO_HOME}${chanDir}"
			else
				fullDir="${RADIO_HOME}"
			fi

			local files=$(find "${fullDir}" -maxdepth 1 -type d  ! -path "${fullDir}" -printf "%p/\n" | sed -e "s?${RADIO_HOME}??" &&
				find "${fullDir}" -maxdepth 1 -type f -printf "%p \n" | sed -e "s?${RADIO_HOME}??" )		

			COMPREPLY=( $(compgen -W "${files}" -- "${cur}") )
			compopt -o nospace
			
			return 0;
			;;
	esac

	COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
}

complete -F _radio-cmd -o filenames ./radio-cmd.sh
