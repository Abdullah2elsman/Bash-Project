#!/bin/bash

# change prompt environment
export PS3="Database>"

# declare the colors
RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"

# Success Status
SUCCESS=1

# Error Status
EMPTY_INPUT=-1
INVALID_INPUT=-2
UNDERSCORE_ONLY_INPUT=-3
START_WITH_NUM_INPUT=-5
EXISTS=-4
NOT_FOUND=-5

# Codes
EMPTY_CODE=101
INVALID_CHARS_CODE=102
UNDERSCORE_ONLY_CODE=103
START_WITH_NUM_CODE=104

# Enable extended pattern matching for advanced data validation
shopt -s extglob

# create DBMS
if [[ ! -d ~/.DBMS ]]; then
	echo "Create .DBMS Directory .............."
	sleep 1
	mkdir ~/.DBMS
fi

# validate the input of database name
input_validation() {
	local input=$1

	case "$input" in
	"")
		echo "$EMPTY_INPUT"
		;;
	[0-9]*)
		echo "$START_WITH_NUM_INPUT"
		;;
	"_")
		echo "$UNDERSCORE_ONLY_INPUT"
		;;
	*([a-zA-Z0-9_]))
		echo "$SUCCESS"
		;;
	*)
		echo "$INVALID_INPUT"
		;;
	esac
}

################### DATABASES ###################

# create database
create_db() {
	local db_name=$1
	local validation_res

	validation_res=$(input_validation "$db_name")

	if [[ "$validation_res" == "$SUCCESS" ]]; then
		if [[ -d ~/.DBMS/"$db_name" ]]; then
			echo "$EXISTS"
		else
			mkdir -p ~/.DBMS/"$db_name"
			echo "$SUCCESS"
		fi
	else
		echo "$validation_res"
	fi
}

# List databases
list_db() {
	local -n arr=$1
	local -n status=$2

	if [[ ! -d ~/.DBMS ]] || [[ -z "$(ls -A ~/.DBMS 2>/dev/null)" ]]; then
		status="$NOT_FOUND"
	else
		arr=()
		for db in ~/.DBMS/*/; do
			if [[ -d "$db" ]]; then
				arr+=("$(basename "$db")")
			fi
		done
		status="$SUCCESS"
	fi
}

# connect to database
connect_db() {
	input=$(read_db_input)

	# Check if empty
	if [[ -z "$input" ]]; then
		echo -e "${RED}Error 106: Database name cannot be empty.${RESET}"
		return 1
	fi

	if [[ -d ~/.DBMS/$input ]]; then
		echo -e "${YELLOW}Connecting to $input... ${RESET}"
		sleep 1
		echo -e "${GREEN}Connected to $input Successfully ${RESET}"
		# change directory to the selected DB
		cd ~/.DBMS/"$input" || exit
	else
		echo -e "${RED}Error 105: DB doesn't exist.${RESET}"
	fi
}

# drop database
drop_db() {
	input=$(read_db_input)

	# Check if empty
	if [[ -z "$input" ]]; then
		echo -e "${RED}Error 106: Database name cannot be empty.${RESET}"
		return 1
	fi

	if [[ -d ~/.DBMS/$input ]]; then
		echo -e "${GREEN}Deleting DB... ${RESET}"
		rm -r ~/.DBMS/"$input"
		sleep 1
		echo -e "${GREEN}$input Deleted!!!${RESET}"
	else
		echo -e "${RED}Error 105: DB doesn't exist.${RESET}"
	fi
}

################### TABLES ###################

create_table() {
	tname=$(read_table_input)
	if [[ -f $tname ]]; then
		echo -e "${RED} Error 201: table ${tname} is already exists! ${RESET}"
		return
	fi

}

list_table() {
	:
}

drop_table() {
	:
}

insert_into_table() {
	:
}

update_from_table() {
	:
}

select_from_table() {
	:
}

delete_from_table() {
	:
}

# put the menu of database options
menu=("create database" "list database" "connect database" "drop database" "exit")
select _ in "${menu[@]}"; do

	case $REPLY in
	1 | "create database")
		# create_db
		;;
	2 | "list database")
		# list_db
		;;
	3 | "connect database")
		connect_db
		;;
	4 | "drop database")
		drop_db
		;;
	5 | "exit")
		echo -e "${GREEN}Exiting...!${RESET}"
		break
		;;
	*)
		echo -e "${RED}Invalid option. Please select 1-5.${RESET}"
		;;
	esac

done
