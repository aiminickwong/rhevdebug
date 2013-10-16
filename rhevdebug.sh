#!/bin/bash

# FUNCTION: yankThread() is meant to take all commands of a specified ID and present them
function yankThread() {

	#echo "DEBUG: User has requested all members of thread $1 from file $2"
	# grepping for the thread
	#echo "DEBUG: Yanked `grep $1 $2 | wc -l` lines"
	threadTrace=thread_$1.log
	
	xzgrep $1 $2.1-* > $threadTrace
	
	# Prepping output 
	startTime=$(cut -d':' -f2- $threadTrace | head -n 1 | awk '{print $1,$2}' | cut -c 1-19)
	endTime=$(cut -d':' -f2- $threadTrace | tail -n 1 | awk '{print $1,$2}' | cut -c 1-19)
	#echo "DEBUG: Start time from log: $startTime"
	#echo "DEBUG: End time from log: $endTime"
	
	commandRun=$(cut -d':' -f2- $threadTrace | head -n 1 | awk '{print $4}')
	#echo "DEBUG: This thread was for the command: $commandRun"
	entity=$(cut -d':' -f2- $threadTrace | head -n 1 | awk '{print $16}')
	#echo "DEBUG: The entity affected was: $entity"	
	
	numErr=$(grep 'ERROR' $threadTrace | wc -l)
	#echo "DEBUG: Number of errors is $numErr"
	errMessage=$(grep 'ERROR' $threadTrace | tail -n 1 | cut -d' ' -f8-)

	## Next steps: compare UUID returned as $entity to database???

	## Make the output pretty and legible
	echo -e "\e[1;34m----------[Overview of thread $1]----------\e[0m"
	echo -e "\e[1;34mStart Time: \e[0m\e[33m$startTime \e[0m"
	echo -e "\e[1;34mEnd Time: \e[0m\e[33m$endTime \e[0m"
	echo ""
	echo -e "\e[1;34mCommand Run: \e[0m\e[33m$commandRun\e[0m"
	echo -e "\e[1;34mEntity UUID Affected: \e[0m\e[33m$entity\e[0m"
 	echo "DEBUG: Look into dynamically generating psql commands based upon the above UUID and 'Command Run' context"
	echo ""
	
	### Error message processing
	### Any reason to think there are multiple messages to be listed here?
	#echo "DEBUG: Should add the time of the error message below"
	echo -e "\e[1;34mNumber of errors in this thread: \e[0m\e[33m$numErr\e[0m"
	# check to see if there are error message to print
	if [ $numErr != 0 ]
	then
	        echo -e "\e[1;34mError Time: \e[0m\e[33m$(grep 'ERROR' $threadTrace | tail -n 1 | cut -d':' -f2- | cut -d' ' -f1,2)\e[0m"
		echo -e "\e[1;34mError Message: \e[0m\e[33m$errMessage\e[0m"
	fi
	echo ""
	echo -e "\e[1;34mAll members have been placed in thread_$1.log in your current directory\e[0m"
        echo -e "\e[1;34m------------------------------------------------\e[0m"
	if  [ "$3" != "" ]
	then
		echo "DEBUG: Calling yank VDSM with $startTime and $endTime"
		yankVDSM "$startTime" "$endTime" $3
	else
		echo "No vdsm.log file specified" 

	fi
}


## database function that pulls most necessary UUIDs from database that would correspond to log messages
## NOTE: This function assumes that we have root access

function loadDatabase(){

	if [ $1 == "" ]
	then
		echo "DEBUG: No database specified."
		exit 1
	fi

ssh root@$1 "export PGPASSFILE=/etc/ovirt-engine/.pgpass; psql -U engine engine -c "select vm_name,vm_guid from vm_static;" > test_vm_guids.txt; psql -U engine engine -c "select vds_name,vds_id from vds_static;" > test_vds_guids.txt; psql -U engine engine -c "select id,storage,storage_name,storage_type,storage_domain_type from storage_domain_static;" > test_storage_ids.txt;" && rsync -Phavr root@$1:/root/test_* ./


}

## vdsm scanner function
# Right now this is meant to be called only by the '-t' flag as a result of finding errors
function yankVDSM() {

	echo "DEBUG: cutting start time of $1"
	startTime=$(echo $1 | cut -c 1-16) 
	# trying sed to escape special characters as this will be used as regex for vdsm searching
	startTime=$(echo $startTime | sed -r 's/\-/\\\-/g' | sed -r 's/\ /\\ /g' | sed -r 's/\:/\\\:/g')
	echo "DEBUG: Will use $startTime as start"
	
	echo "DEBUG: cutting end time of $2"
	endTime=$(echo $2 | cut -c 1-16)
	endTime=$(echo $endTime | sed -r 's/\-/\\\-/g' | sed -r 's/\ /\\ /g' | sed -r 's/\:/\\\:/g')
	echo "DEBUG: Will use $endTime as end"
	
	echo "DEBUG: Finding first line to pull from vdsm log $3.* (includes compressed logs)"
	startFile=$(xzgrep -n "$startTime" $3\.* | head -n 1 | cut -f1 -d':')
	vdsmLogStart=$(xzgrep -n "$startTime" $3\.* | head -n 1 | cut -f2 -d':')
	echo "DEBUG: Starting line in $startFile: $vdsmLogStart"
	
	echo "DEBUG: Finding last line to pull from vdsm log $3.* (including compressed logs)"
	endFile=$(xzgrep -n "$startTime" $3\.* | tail -n 1 | cut -f1 -d':')
	vdsmLogEnd=$(xzgrep -n "$startTime" $3\.* | tail -n 1 | cut -f2 -d':')
	echo "DEBUG: Ending line in $endFile: $vdsmLogEnd"
	
	sameLog=false
	if [ $startFile == $endFile ]
	then
		echo "DEBUG: Lines will come from the file $startFile"
		sameLog=true
		decompressXZ $startFile
	else
		echo "DEBUG: Lines will span from file $startFile to $endFile"
		decompressXZ $startFile $endFile
	fi

	sleep 5

	# Attempting to find all messages in vdsm logs that pertain to the 'entity' from previous subroutine
	declare -a messages=""
	messIdx=0
	if $sameLog
	then
		# This is an embarassingly inefficient way of doing this, but it works for now
		echo "DEBUG: Detected sameLog = true"
		for i in $(cat $startFile);
		do
			echo "DEBUG: current line $messIdx";
			if [ $messIdx -gt $vdsmLogStart ] 
			then
				echo "DEBUG: Line $i from $startFile printed below"
				echo $i
				#messages[$messIdx]
			fi;
			messIdx=$(expr $messIdx + 1);
		done
		echo "DEBUG: $messIdx messages printed"
	else
		echo "DEBUG: Not same log files, placeholder"
	fi
	
}

function decompressXZ() {

declare -a files="$@"

if [ ${#files[@]} -eq 0 ]
then
	echo "DEBUG: No files passed to function"
else

	echo "DEBUG: Found file(s), decompressing.."
	for i in $(echo ${files[@]});
	do
		echo "DEBUG: Processing $i";
		#newFileName=$(echo $i | sed s/\.xz//);
		#echo "DEBUG: New file name is: $newFileName";
		xz -d $i;
		echo "DEBUG: File(s) decompressed";
		sleep 5;
	done
fi

}
#-------------------------------------------------------
### Playing with the 'getopts' function
### In this case I'm thinking:
### -t = 8 digit Thread ID (would pull all entries with said Thread ID from file)
### -d = database location URL, no leading 'http'

threadID=""
database=""
logFile=""
vdsmLog=""

###-----------------Main Loop-------------------

while getopts t:d:l: option

do
	case "${option}"
	in
		t) threadID=${OPTARG}
		   if [[ $threadID == '[a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9]' ]]
		   then
			echo "Please enter an 8 charater thread ID"
			exit 1
		   else
			#echo "DEBUG: function call hit"
			yankThread $threadID $3 $4 ## This should work out to -t 'threadID' engine.log vdsm.log <--- $3
		   fi
		   ;;
		   		   
		d) database=${OPTARG}
		   loadDatabase $database	
		   ;;
		   

		l) lcRoot=${OPTARG}
		   # This is assumed to be the LC root after the commonly used 'rhevx' tool has extracted the LC
		   echo "WARNING: This LC Root location should point to the 'sosreport..' dir resulting from the 'rhevx' tool"			  # function goes here
		   ;;

		#v) vdsmLog=${OPTARG}
		#   echo "DEBUG: vdsm log set to $vdsmLog"
		#   ;;
	

		:) echo "Option -$OPTARG requires an argument."
		   exit 1
		   ;;

		*) echo "Please specify an argument."
		   exit 1
		   ;;
	esac

done
