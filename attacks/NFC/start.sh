#!/bin/bash
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

source_tag=""

action_choice()
{
    cmd=(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --menu "NFC" 10 70 16)
    options=("Crack" ""
             "Write" "")
    selection=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    status=$?
    case ${status} in
        ${DIALOG_OK})
            case ${selection} in
                Crack)
                    read_tag
                ;;
                Write)
                    set_source
                ;;
            esac
        ;;
        ${DIALOG_CANCEL})
            bash $(dirname $0)/../../attacks.sh
        ;;
        ${DIALOG_ESC})
            bash $(dirname $0)/../../attacks.sh
        ;;
    esac
}

read_tag()
{
    result=$(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --inputbox "Name of tag" 10 40 "tag" 2>&1 >/dev/tty)
    status=$?
    case ${status} in
        ${DIALOG_OK})
            sudo mfoc -O $(dirname $0)/tags/${result};bash $(dirname $0)/start.sh
        ;;
        ${DIALOG_CANCEL})
            action_choice
        ;;
        ${DIALOG_ESC})
            bash $(dirname $0)/../../attacks.sh
        ;;
    esac
}

set_source()
{
	
	options=()
	for tags_path in $(dirname $0)/tags/*
	do
        tag=$(basename "${tags_path}")
		options+=(${tag})
        options+=( "" )
	done
	
	options+=("---Clear---")
	options+=( "" )
	
	cmd=(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --menu "Source" 15 70 15)
	selection=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	status=$?
	case ${status} in
	    ${DIALOG_OK})
		if [ ${selection} == "---Clear---" ]
		then
			sudo rm -f $(dirname $0)/tags/* ; $(dirname $0)/tags/${source_tag};bash $(dirname $0)/start.sh
		else
	        	source_tag=${selection}
			write_tag
		fi
	    ;;
	    ${DIALOG_CANCEL})
	        action_choice
	    ;;
	    ${DIALOG_ESC})
	        bash $(dirname $0)/../../menu.sh
	    ;;
	esac
	
}

write_tag()
{
	
	options=()
	for tags_path in $(dirname $0)/tags/*
	do
        tag=$(basename "${tags_path}")
		options+=(${tag})
        options+=( "" )
	done
    
	cmd=(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --menu "Target" 15 70 15)
	selection=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	status=$?
	case ${status} in
	    ${DIALOG_OK})
	        sudo nfc-mfclassic w a $(dirname $0)/tags/${selection} $(dirname $0)/tags/${source_tag};bash $(dirname $0)/start.sh
	    ;;
	    ${DIALOG_CANCEL})
	        set_source
	    ;;
	    ${DIALOG_ESC})
	        bash $(dirname $0)/../../menu.sh
	    ;;
	esac
	
}

action_choice
