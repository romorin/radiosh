#!/bin/bash

if [ -r ~/.config/radiosh/config ]; then
	source ~/.config/radiosh/config
elif [ -r /usr/local/etc/radiosh.cfg ]; then
	source /usr/local/etc/radiosh.cfg
elif [ -r /etc/radiosh.cfg ]; then
	source /etc/radiosh.cfg
elif [ -r ../etc/radiosh.cfg ]; then
	source ../etc/radiosh.cfg
else
	return 1
fi

function completeChannel() {
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
}

_radiosh ()
{
	COMPREPLY=()
	local cur="${COMP_WORDS[COMP_CWORD]}"

	if [ "${COMP_CWORD}" -gt 1 ]; then
		local op="${COMP_WORDS[1]}"

		case "${op}" in
			"play" | "add" | "add-category" | "rm" | "rm-category" )
				if [ "${COMP_CWORD}" -eq 2 ]; then
					completeChannel "${cur}"
				fi
				;;
		esac
	else
		local opts="add add-category kill list ls mute pause play rm rm-category start stop volume"

		COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
	fi
}

complete -F _radiosh -o filenames ./radiosh
