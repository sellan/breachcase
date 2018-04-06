#!/bin/bash
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

query()
{
    dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

    if [ "$1" != "" ]; then
    	letter1=$(echo ${1,,}|cut -b1)
    	if [[ ${letter1} == [a-zA-Z0-9] ]]; then
    		if [ -f "$dir/data/$letter1" ]; then
    			result=$(grep -ai "^$1" "$dir/data/$letter1")
    			finish
    		else
    			letter2=$(echo ${1,,}|cut -b2)
    			if [[ ${letter2} == [a-zA-Z0-9] ]]; then
    				if [ -f "$dir/data/$letter1/$letter2" ]; then
    					result=$(grep -ai "^$1" "$dir/data/$letter1/$letter2")
    					finish
    				else
    					letter3=$(echo ${1,,}|cut -b3)
    					if [[ ${letter3} == [a-zA-Z0-9] ]]; then
    						if [ -f "$dir/data/$letter1/$letter2/$letter3" ]; then
    							result=$(grep -ai "^$1" "$dir/data/$letter1/$letter2/$letter3")
    							finish
    						fi
    					else
    						if [ -f "$dir/data/$letter1/$letter2/symbols" ]; then
    							result=$(grep -ai "^$1" "$dir/data/$letter1/$letter2/symbols")
    							finish
    						fi
    					fi
    				fi
    			else
    				if [ -f "$dir/data/$letter1/symbols" ]; then
    					result=$(grep -ai "^$1" "$dir/data/$letter1/symbols")
    					finish
    				fi
    			fi
    		fi
    	else
    		if [ -f "$dir/data/symbols" ]; then
    			result=$(grep -ai "^$1" "$dir/data/symbols")
    			finish
    		fi
    	fi
    else
    	result=""
    	finish
    fi

}

finish()
{
    mkdir $(dirname $0)/../../logs/$(date +%d_%m_%Y)
    if [ -n "${result}" ]; then
        echo ${result} > $(dirname $0)/../../logs/$(date +%d_%m_%Y)/dbleaks
        dialog --backtitle "BREACH_CASE" --title "Result" --msgbox "$(echo ${result})" 40 50 2>&1 >/dev/tty
        bash $(dirname $0)/../../attacks.sh
    elif [ -z "${result}" ]; then
        dialog --backtitle "BREACH_CASE" --title "Error" --msgbox "You must enter something..." 5 35 2>&1 >/dev/tty
        bash $(dirname $0)/../../attacks.sh
    else
        echo "Pass for ${email} not found in the dbleaks" > $(dirname $0)/../../logs/$(date +%d_%m_%Y)/dbleaks
        dialog --backtitle "BREACH_CASE" --title "Error" --msgbox "$(echo "Pass for ${email} not found in the dbleaks...")" 5 50 2>&1 >/dev/tty
        bash $(dirname $0)/../../attacks.sh
    fi
}

email=$(dialog --backtitle "BREACH_CASE" --cancel-label "Back" --inputbox "Email" 10 40 2>&1 >/dev/tty)
status=$?
case ${status} in
    ${DIALOG_OK})
        query ${email}
    ;;
    ${DIALOG_CANCEL})
        bash $(dirname $0)/../../attacks.sh
    ;;
esac

