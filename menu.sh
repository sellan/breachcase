#!/bin/bash
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

menu()
{
        cmd=(dialog --backtitle "BREACH_CASE" --cancel-label "Shutdown" --menu "Menu" 10 70 16)
        options=("Attack" "Choose and launch an attack"
                 "Print" "Print session's logs with thermal printer"
                 "Information" "Various information and admin shell")
        selection=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        status=$?
        case ${status} in
            ${DIALOG_OK})
                case ${selection} in
                    Attack)
                        bash $(dirname $0)/attacks.sh
                    ;;
                    Print)
                        print
                    ;;
                    Information)
                        config
                    ;;
                esac
            ;;
            ${DIALOG_CANCEL})
                clear
                echo See ya
                sleep 3
                sudo shutdown now
            ;;
        esac

}

config(){
    cmd=(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --menu "Information" 13 70 16)
    options=("Screen" "See and set resolution of the screen"
             "Network" "Quick ip a, basic network's information"
             "Shell" "Access to classic admin shell (need password)"
             "Version" "Show your version of breach_case"
             "Update" "Update breach_case to the latest version"
             "RaspiConfig" "Enter in raspi-config for configuration")
    selection=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    status=$?
    case ${status} in
        ${DIALOG_OK})
            case ${selection} in
                    Screen)
                        dialog --backtitle "BREACH_CASE" --title "Screen" --msgbox "\n\nRésolution : $(cat /boot/config.txt | grep framebuffer_width= | sed "s/framebuffer_width=//")x$(cat /boot/config.txt | grep framebuffer_height= | sed "s/framebuffer_height=//")" 13 15
                        config
                    ;;

                    Network)
                        dialog --backtitle "BREACH_CASE" --title "Network" --msgbox "$(ip a)" 20 70
                        config
                    ;;
                    Shell)
                        clear
                        su root
                    ;;
                    Version)
                        dialog --backtitle "BREACH_CASE" --title "Version" --msgbox "$(cat $0/version)" 5 15
                        config
                    ;;
                    RaspiConfig)
                        clear
                        sudo raspi-config
                    ;;
                    Update)
                    
                        sudo umount $(dirname $0)/attacks/dbleaks/data
                        sudo apt update
                        sudo apt upgrade
                        sudo rm -rf $(dirname $0)
                        sudo git clone https://github.com/sellan/breach_case.git $(dirname $0)
                        sudo reboot
                    ;;
            esac
        ;;
        ${DIALOG_CANCEL})
        menu
        ;;
    esac
}

print()
{
    message=""
    options=()
	for date_path in $(dirname $0)/logs/*
	do
		options+=($(basename "${date_path}") "")
	done
	cmd=(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --menu "Print" 15 25 15)
	selection=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	status=$?
	case ${status} in
	    ${DIALOG_OK})
	        options=()
	       	for log in $(dirname $0)/logs/${selection}/*
	        do
		        options+=($(basename "${log}") "" off)
	        done
	        cmd=(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --separate-output --checklist "Print" 15 25 30)
	        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	        status=$?
	        case ${status} in
	            ${DIALOG_OK})
	                for choice in ${choices}
	                do
	                    message+="****${choice}****\n\n$(cat $(dirname $0)/logs/${selection}/${choice})\n\n"
	                done
	            ;;
	            ${DIALOG_CANCEL})
	                print
	            ;;
	            ${DIALOG_ESC})
	                print
	            ;;
	        esac
	    ;;
	    ${DIALOG_CANCEL})
	        menu
	    ;;
	    ${DIALOG_ESC})
	        menu
	    ;;
	esac

	if [ -n "${message}" ]; then
        stty -F /dev/serial0 19200
        echo -e "****IMPRESSION DES LOGS****\n\n${message}\n****DONE****\n\n\n" > /dev/serial0
	menu
    elif [ -z "${message}" ]; then
        dialog --backtitle "BREACH_CASE" --title "Error" --msgbox "You must select at least one attack's log" 5 50 2>&1 >/dev/tty
        menu
    fi
}

menu
