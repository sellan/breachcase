#!/bin/bash
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

menu()
{
	options=()
	for attack_path in $(dirname $0)/attacks/*
	do
        attack=$(basename "${attack_path}")
		options+=(${attack})
		if [ -e $(dirname $0)/attacks/${attack}/simple_description.txt ]
		then
			options+=( "$(cat $(dirname $0)/attacks/${attack}/simple_description.txt)" )
		else
			options+=( "x" )
		fi
	done
    
	cmd=(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --menu "Attacks" 15 70 15)
	selection=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	status=$?
	case ${status} in
	    ${DIALOG_OK})
	        bash $(dirname $0)/attacks/${selection}/start.sh
	    ;;
	    ${DIALOG_CANCEL})
	        bash $(dirname $0)/menu.sh
	    ;;
	    ${DIALOG_ESC})
	        bash $(dirname $0)/menu.sh
	    ;;
	esac
}

menu
