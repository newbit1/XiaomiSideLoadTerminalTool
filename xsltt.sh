#!/usr/bin/env bash

partfile="partitions.txt"
rawpartfile="rawpartitions.txt"

checkfile() {
	#echo "checkfile $1"
	if [ -r "$1" ]; then
		#echo "File exists and is readable"
		if [ -s "$1" ]; then
			#echo "and has a size greater than zero"
			if [ -w "$1" ]; then
				#echo "and is writable"
				if [ -f "$1" ]; then
					#echo "and is a regular file."
					return 1
				fi
			fi
		fi
	fi
	return 0
}

checkadbversion(){
	adbpresent=false
	adbver=$(adb version)
	#echo $?
	if [ $? -gt 0 ] ; then
		echo "[!] cannot find ADB, abort script"
		exit 1
	fi
	adbpresent=true
	echo "[*] Informations about installed ADB:"

	exec 3< <(printf '%s\n' "$adbver")
	while read -u 3 line; do
		echo "[-] $line"
	done
}

printsplash(){
	echo "##############################|##############################"
	echo "#                                                           #"
	echo "#       Xiaomi SideLoad Terminal Tool by NewBit @ XDA       #"
	echo "#                                                           #"
	echo "#             Read and Write your Partitions                #"
	echo "#                  In Xiomi Recovery 5.0                    #"
	echo "#                                                           #"		
	echo "##############################|##############################"
}

export noir='\e[0;30m'
export gris='\e[1;30m'
export rougefonce='\e[1;31m'
export rouge='\e[0;31m'
export rose='\e[1;31m'
export vertfonce='\e[0;32m'
export vertclair='\e[1;32m'
export orange='\e[0;33m'
export jaune='\e[1;33m'
export bleufonce='\e[0;34m'
export bleuclair='\e[1;34m'
export violetfonce='\e[0;35m'
export violetclair='\e[1;35m'
export cyanfonce='\e[0;36m'
export cyanclair='\e[1;36m'
export grisclair='\e[0;37m'
export blanc='\e[1;37m'
export neutre='\e[0;m'

function checkwinsize {
    local __items=$1
    local __lines=$2
#local __err=$3

    if [ $__items -ge $__lines ]; then
#       echo "The size of your window does not allow the menu to be displayed correctly..."
        return 1
    else
#       echo "Your window size is $__lines lines, compatible with the menu of $__items items..."
        return 0
    fi
}

function multiselect {
    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()   { printf "$ESC[?25h"; }
    cursor_blink_off()  { printf "$ESC[?25l"; }
    cursor_to()         { printf "$ESC[$1;${2:-1}H"; }
    print_inactive()    { printf "$2   $1 "; }
    print_active()      { printf "$2  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()    { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    get_cursor_col()    { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${COL#*[}; }
    execute_script() 	{ exec $BASH_SOURCE; }
    appendhistory()		{ historylog="$historylog\n$1"; }

	checkphonestate(){
		phonestate=$(adb get-state)
		if [ $? -gt 0 ] ; then
			phonestate="offline"
		fi
		
		if [[ "$phonestate" == *"device"* ]]; then
			DeviceMode=true
			SideLoadMode=false
			OfflineMode=false
		fi
	
		if [[ "$phonestate" == *"sideload"* ]]; then
			DeviceMode=false
			SideLoadMode=true
			OfflineMode=false
		fi

		if [[ "$phonestate" == *"offline"* ]]; then
			DeviceMode=false
			SideLoadMode=false
			OfflineMode=true
		fi
	}
	
	get_optimal_terminal_size(){
		local optimal_col=""
		optimal_col=$(echo "$PARTITIONS" | awk '{print length}' | sort -nr| head -1)
		optimal_col=$(( ( optimal_col + 6 ) * 4 ))
		echo "[*] optimal column size=$optimal_col"
	}
	
	buildDeviceMenuEntrys(){
		local entrys=""
		
		if $SideLoadMode;then
			read_part_layout_partitions
			entrys=$PARTITIONS	
			if [[ "$entrys" == "" ]]; then
				printf "$historylog"
				exit
			fi
			get_optimal_terminal_size
		else	
			entrys="Read Partition Layout from Device"
			$DeviceMode && entrys="Read Partition Layout from \\\e[38;5;46mDevice\\\e[0m"
		
			checkfile $partfile
			if [ $? -eq 1 ] ; then
				entrys="$entrys
				Read Partition Layout from \\\e[38;5;46m$partfile\\\e[0m"
			else
				entrys="$entrys
				Read Partition Layout from $partfile"
			fi
	
			checkfile $rawpartfile
			if [ $? -eq 1 ] ; then
				entrys="$entrys
				Read Partition Layout from \\\e[38;5;46m$rawpartfile\\\e[0m"
			else
				entrys="$entrys
				Read Partition Layout from $rawpartfile"
			fi
		
			entrys="$entrys
			Reboot to SideLoad Mode"
		fi
		count=0
		exec 3< <(printf '%s\n' "$entrys")
		while read -u 3 option; do	
			options[count]="$option"
			count=$(( count + 1 ))
		done < <(printf '%s\n' "$entrys")	
	}
	
    read_part_layout_device(){
			appendhistory "[*] reading raw partition symlinks and its names"
			RAW_PARTITIONS=$(adb shell ls -al $(adb shell toybox find /dev/block/platform -type d -name by-name))
    }
    
    read_part_layout_partitions(){
		checkfile $partfile
		if [ $? -eq 1 ] ; then
			appendhistory "[*] reading $partfile file"
			PARTITIONS=$(cat $partfile) 
		else
			appendhistory "[*] no $partfile file found"
			appendhistory "[*] Read Partition Layout first"
		fi	   	
    }
    
    read_part_layout_rawpartitions(){
		checkfile $rawpartfile
		if [ $? -eq 1 ] ; then
			appendhistory "[*] reading $rawpartfile file"
			RAW_PARTITIONS=$(cat $rawpartfile)
			convert_rawpartitions
		else
			appendhistory "[*] no $rawpartfile file found"
		fi
    }
    
    convert_rawpartitions(){
		rm -f $partfile
		appendhistory "[!] converting raw partitions to proper format and save it to $partfile"
		exec 3< <(printf '%s\n' "$RAW_PARTITIONS")
		while read -u 3 line; do
			if [[ "$line" == *"->"* ]]; then
				echo "$line" | awk '{for (I=1;I<NF;I++) if ($I == "->") print $(I-1) " " $(I+1)}' >> $partfile
			fi
		done
		read_part_layout_partitions  
    }
    
    reboot_sideload_mode(){
		local ADBREBOOTECHO=""
		checkfile $partfile
		if [ $? -eq 1 ] ; then
			appendhistory "[*] rebooting and waiting for Device to be in SideLoad Mode"		
			{ ADBREBOOTECHO=$(adb reboot sideload | tee /dev/fd/3); } 3>&1
			printf "$historylog"
			{ ADBREBOOTECHO=$(adb wait-for-sideload | tee /dev/fd/3); } 3>&1
			execute_script
		else
			appendhistory "[*] no $partfile file found"
			appendhistory "[*] Read Partition Layout first"
		fi
    }
    
    reboot_device_mode(){
    	local ADBREBOOTECHO=""
		appendhistory "[*] rebooting and waiting for ADB Device Mode"		
		{ ADBREBOOTECHO=$(adb reboot | tee /dev/fd/3); } 3>&1
		printf "$historylog"
		{ ADBREBOOTECHO=$(adb wait-for-device | tee /dev/fd/3); } 3>&1
		execute_script
    }

    backup_exists(){
		local part_name="./backup/${1% *}.bin"
		return `checkfile "$part_name"`	
    }
        
    check_backups(){
    	local option=""      
		for ((i=0;i<${#options[@]};i++)); do
			option=${options[i]}
			backup_exists "$option"
			if [ $? -eq 1 ] ; then
				backups[i]=true
			else
				backups[i]=false
			fi			
		done
    }

    local colmax=""
    local offset=""
    local title=""
    local linesmax=""
	local count=0
    options=""  
	local historylog=""
	local DeviceMode=false
	local SideLoadMode=false
	local OfflineMode=false
	local exec_script=false

	checkphonestate
	title="ADB $phonestate Mode"
	
	buildDeviceMenuEntrys

	local KEYLEGEND="select : [space] | toggle select [a]ll | [q]uit | [r]ead / [w]rite Partition(s) | reboot [d]evice"
	local KEYLEGEND_DM="execute command: [enter] | [q]uit"
    local COLS=$( tput cols )
    local LINES=$( tput lines )
	
	linesmax=$(( $LINES - 2 ))
	colmax=$(( $count / $linesmax ))
	
	# Ceiling( X / Y ) = ( X + Y – 1 ) / Y
	colmax=$(( ( $count + $linesmax - 1 ) / $linesmax ))
	offset=$(( $COLS / $colmax ))
	
	clear
	! $SideLoadMode && KEYLEGEND="$KEYLEGEND_DM"

#   checkwinsize $(( ${#options[@]}/$colmax )) $LINES
    err=`checkwinsize $(( ${#options[@]}/$colmax )) $(( $LINES - 2)); echo $?`

    if [[ ! $err == 0 ]]; then
        echo "Your window size is $LINES lines, incompatible with the menu of ${#_liste[@]} items..."
            cursor_to $lastrow
        exit
    fi 

    local selected=()
    local backups=()
    local allselected=false
    for ((i=0; i<${#options[@]}; i++)); do
        selected+=("false")
        backups+=("false")
    done
	
	check_backups
	
	if $SideLoadMode;then
		cursor_to $(( $LINES - 2 ))
	else
		cursor_to 6
	fi
    
    printf "_%.s" $(seq $COLS)
    
    echo -e "$bleuclair $title | $vertfonce $KEYLEGEND $neutre\n" | column  -t -s '|'

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local lastcol=`get_cursor_col`
    local startrow=1
    local startcol=1

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    key_input() {
        local key
        IFS= read -rsn1 key 2>/dev/null >&2
        if [[ $key = ""      ]]; then echo enter; fi;
        if [[ $key = $'\x20' ]]; then echo space; fi;
        if [[ $key = "a" ]]; then echo all; fi;
        if [[ $key = "q" ]]; then echo quit; fi;
        if [[ $key = "s" ]]; then echo skipall; fi;       
        if [[ $key = "r" ]]; then echo pullpartitions; fi;
        if [[ $key = "n" ]]; then echo no; fi;
        if [[ $key = "w" ]]; then echo pushpartitions; fi;
        if [[ $key = "d" ]]; then echo rebootdevicemode; fi;
		if [[ $key = $'\x1b' ]]; then
			read -rsn2 key
			if [[ $key = [A ]]; then echo up;    fi;
			if [[ $key = [B ]]; then echo down;  fi;
			if [[ $key = [C ]]; then echo right;  fi;
			if [[ $key = [D ]]; then echo left;  fi;
		fi
    }

    toggle_option() {
        local option=$1
        if [[ ${selected[option]} == true ]]; then
            selected[option]=false
        else
            selected[option]=true
        fi
    }

    toggle_option_multicol() {
        local option_row=$1
        local option_col=$2
		# select all
		if [[ $option_row -eq -10 ]] && [[ $option_row -eq -10 ]]; then
		
			if [[ $allselected == false ]]; then
				allselected=true
			else
				allselected=false
			fi
			for ((option=0;option<${#selected[@]};option++)); do
				selected[option]=$allselected
			done
		else
			# select one
			option=$(( $option_col + $option_row * $colmax )) 
			if [[ ${selected[option]} == true ]]; then
					selected[option]=false
			else
				selected[option]=true
			fi
		fi
    }

    print_options_multicol() {
        # print options by overwriting the last lines
        local curr_col=$1
        local curr_row=$2
        local curr_idx=0

        local idx=0
        local row=0
        local col=0
        
        local prefix="[ ]"
        ! $SideLoadMode && prefix=""

    	curr_idx=$(( $curr_col + $curr_row * $colmax ))
        for option in "${options[@]}"; do
           	if $SideLoadMode; then
				if [[ ${selected[idx]} == true ]]; then
				  	prefix="[\e[38;5;46m✔\e[0m]"
				else
					prefix="[ ]"
				fi

				if [[ ${backups[idx]} == true ]]; then
				  	option="\e[38;5;46m$option\e[0m"
				fi
			fi
			
            row=$(( $idx/$colmax ))
        	col=$(( $idx - $row * $colmax ))

            cursor_to $(( $startrow + $row + 1)) $(( $offset * $col + 1))
            if [ $idx -eq $curr_idx ]; then
                print_active "$option" "$prefix"
            else
                print_inactive "$option" "$prefix"
            fi
            ((idx++))
        done
    }
    
	pullfromSideLoad() {
		local REMOTE="$1"
		local LOCAL="$2"
		local ADBPULLECHO=""
		local pulling=true

		echo "[*] adb pull $REMOTE $LOCAL"
		echo "$REMOTE" > "$LOCAL"
		sleep 0.1
		while $pulling; do
			{ ADBPULLECHO=$(adb pull $REMOTE $LOCAL | tee /dev/fd/3); } 3>&1
			if [ $? -eq 0 ] ; then
				pulling=false
			fi
			echo "[*] adb pull $REMOTE $LOCAL"
			case "$ADBPULLECHO" in
				*"file pulled"*)
					pulling=false;;
				*"?"*)
					echo "[!] adb connection got interrupted, replug device to continue"
					ADBPULLECHO=$(adb wait-for-sideload 2>/dev/null);;
				*"devices/emulators"*)
					exit 0;;
				*)
					echo "[-] $ADBPULLECHO";;
			esac			
		done	
	}
	
	pushtoSideLoad() {
		local LOCAL="$1"
		local REMOTE="$2"
		local ADBPUSHECHO=""
		local pushing=true
		sleep 0.1
		while $pushing; do
			{ ADBPULLECHO=$(adb push $LOCAL $REMOTE | tee /dev/fd/3); } 3>&1
			if [ $? -eq 0 ] ; then
				pushing=false
			fi
			echo "[*] adb push $LOCAL $REMOTE"
			case "$ADBPUSHECHO" in
				*"file pushed"*)
					pushing=false;;
				*"?"*)
					echo "[!] adb connection got interrupted, replug device to continue"
					exit 0;;
				*"devices/emulators"*)
					exit 0;;
				*)	
					if [[ ! "$entrys" == "" ]]; then
						echo "[-] $ADBPUSHECHO"
					fi
					;;
			esac			
		done	
	}
    
    read_partitions() {
    	clear
		
    	local idx=0
    	local overwriteall=false
    	local overwrite=true
    	local skipoverwrite=false
    	local part_name=""
    	local part_target=""
    		
		for option in "${options[@]}"; do
			if  [[ ${selected[idx]} == true ]]; then
				part_name="./backup/${option% *}.bin"
				part_target=${option#* }
				overwrite=true
			
				if [[ $overwriteall == false ]]; then
					checkfile "$part_name"
					if [ $? -eq 1 ] ; then
						if [[ $skipoverwrite == false ]]; then			
							echo "[!] backup exists, do you want to overwrite it? [enter|yes] [n|no] [a|all] [q|quit] [s|skip all]"
							while $overwrite; do
								case `key_input` in
									enter)  break;;
									no) overwrite=false;;
									all) overwriteall=true
										break;;
									quit) exit 0;;
									skipall) skipoverwrite=true
										overwrite=false
										break;;
								esac
							done
						else
							overwrite=false
						fi
					fi
				fi
				
				if [[ $overwrite == false ]]; then
					continue
				else
					pullfromSideLoad "$part_target" "$part_name"
				fi
			fi
			((idx++))
		done
		exit
    }
    
    write_partitions() {
    	clear
		
    	local idx=0
    	local part_name=""
    	local part_target=""
    		
		for option in "${options[@]}"; do
			if  [[ ${selected[idx]} == true ]]; then
				part_name="./backup/${option% *}.bin"
				part_target=${option#* }
			
				checkfile "$part_name"
				if [ $? -eq 1 ] ; then
					pushtoSideLoad "$part_name" "$part_target"
				fi
			fi
			((idx++))
		done
		exit
    }
    
    exec_cmd(){
    	local CMD="$1"
    	cursor_to $lastrow
        case "$CMD" in
			"0")	if $DeviceMode;then
						read_part_layout_device
            			convert_rawpartitions
            		else
            			appendhistory "[-] ADB is in Offline Mode"
            			appendhistory "[*] No Device is connected"
            		fi
            		;;
            		
            "1")	read_part_layout_partitions;; 
            
            "2")	read_part_layout_rawpartitions;;
            		
            "3")	if $DeviceMode;then
						reboot_sideload_mode
            		else
            			appendhistory "[-] ADB is in Offline Mode"
            			appendhistory "[*] No Device is connected"
            			appendhistory "[-] Can not switch to SideLoad Mode"
            		fi
            		;; 
        esac
        printf "$historylog"        
    }
        
    local active_row=0
    local active_col=0

    while true; do
        print_options_multicol $active_col $active_row 
		
        case `key_input` in
            space)  toggle_option_multicol $active_row $active_col;;
            enter)  print_options_multicol -1 -1
            		if ! $SideLoadMode; then
            			exec_cmd $active_row
            			buildDeviceMenuEntrys
            		else
            			break
            		fi
            		;;
            up)     ((active_row--));
                    if [ $active_row -lt 0 ]; then active_row=0; fi;;
            down)   ((active_row++));
                    if [ $active_row -ge $(( ${#options[@]} / $colmax ))  ]; then active_row=$(( ${#options[@]} / $colmax )); fi;;
            left)     ((active_col=$active_col - 1));
                    if [ $active_col -lt 0 ]; then active_col=0; fi;;
            right)     ((active_col=$active_col + 1));
                    if [ $active_col -ge $colmax ]; then active_col=$(( $colmax -1 )) ; fi;;
            all)    toggle_option_multicol -10 -10 ;;
            quit)   phonestate=""
            		break ;;
            pullpartitions)		print_options_multicol -1 -1; read_partitions;;
            pushpartitions)		print_options_multicol -1 -1; write_partitions;;
            rebootdevicemode)	print_options_multicol -1 -1;
								if $SideLoadMode; then
									reboot_device_mode
								fi
								;;           					
        esac
    done

    # cursor position back to normal
	cursor_to $lastrow
	
	if ! $SideLoadMode;then		
		printf "$historylog"
	fi
	
	printf "\n"
	cursor_blink_on
    #eval $return_value='("${selected[@]}")'
    #clear
}

showMenu(){
	LINES=$( tput lines )
	COLS=$( tput cols )
	local OPTIONS="$1"
	local title="$2" 
	
	clear
	
	local count=0
	exec 3< <(printf '%s\n' "$OPTIONS")
	while read -u 3 option; do
		_liste[count]="$option"
		count=$(( count + 1 ))	
	done < <(printf '%s\n' "$OPTIONS")
	
	linesmax=$(( $LINES - 2 ))
	colmax=$(( $count / $linesmax ))	
	
	# Ceiling( X / Y ) = ( X + Y – 1 ) / Y
	colmax=$(( ( $count + $linesmax - 1 ) / $linesmax ))
	offset=$(( $COLS / $colmax ))
	multiselect result $colmax $offset _liste "$title" 
}

checkbashversion(){
	minBashVersion="4.3"
	VERSION=`echo $BASH_VERSION | awk -F\( '{print $1}' | awk -F. '{print $1"."$2}'`
	if [ $(echo "$VERSION >= $minBashVersion" | bc -l) -eq 0 ]; then
		echo "[!] Bash Version >= $minBashVersion is required"
		exit 1
	fi
	echo "[*] Bash Version= $BASH_VERSION"
}

printsplash
checkbashversion
checkadbversion

if [[ $adbpresent == true ]]; then
	multiselect
fi
