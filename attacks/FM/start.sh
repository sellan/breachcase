#!/bin/bash
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

freq_mic=11500
freq_fm=100

freq_choice()
{
    options=(
    "91.3" "Fun Radio"
    "103.3" "Gold FM"
    "87.7" "LE MOUV'"
    "88.5" "MFM Radio"
    "97.3" "Nostalgie"
    "102.4" "NRJ"
    "88.1" "Radio Campus"
    "98.2" "Rire et Chansons"
    "104.2" "RMC"
    "105.1" "RTL"
    "102.8" "Skyrock"
    "106" "Sud Radio"
    "94.3" "Virgin Radio"
    "100.8" "WIT FM"
    "other" ""
    )
	
	cmd=(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --menu "FM frequency" 13 40 30)
    
    result=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	
    status=$?
    
    case ${status} in
        ${DIALOG_OK})
            if [ ${result} == "other" ]
            then
                other_freq
            else
                freq_fm=${result}
                voice
            fi
        ;;
        ${DIALOG_CANCEL})
            bash $(dirname $0)/../../attacks.sh
        ;;
        ${DIALOG_ESC})
            bash $(dirname $0)/../../attacks.sh
        ;;
    esac
}

other_freq()
{
    result=$(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --inputbox "FM frequency" 10 40 ${freq_fm} 2>&1 >/dev/tty)
    status=$?
    case ${status} in
        ${DIALOG_OK})
            freq_fm=${result}
            voice
        ;;
        ${DIALOG_CANCEL})
            freq_choice
        ;;
        ${DIALOG_ESC})
            bash $(dirname $0)/../../attacks.sh
        ;;
    esac
}

voice()
{
	
	options=(
    "11500" "Normal"
    "5000" "Strange"
    "17000" "Evil"
    )
	
	cmd=(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --menu "Voice frequency" 13 40 30)
	
	freq_mic=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    
    status=$?
    
    case ${status} in
        ${DIALOG_OK})

            sudo arecord -d0 -c2 -f S16_LE -r ${freq_mic} -twav -D sysdefault:CARD=1 | sudo $(dirname $0)/PiFmRds/src/pi_fm_rds -audio - -freq ${freq_fm}
        ;;
        ${DIALOG_CANCEL})
            freq_choice
        ;;
        ${DIALOG_ESC})
            bash $(dirname $0)/../../attacks.sh
        ;;
    esac
	
}

freq_choice
