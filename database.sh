#!/bin/bash

# change prompt environment
export PS3="Database>"

# declare the colors
RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[34m"

# Enable extended pattern matching for advanced data validation
shopt -s extglob

# create DBMS
if [[ ! -d ~/.DBMS ]]; then
	echo "Create .DBMS Directory .............."
	mkdir ~/.DBMS
	sleep 1
fi

# validate the input of database name
read_input() {
	read -r -p "Enter Name of DS: " input
	echo "$input"
}

################### DATABASES ###################

# create database
create_db() {
	input=$(read_input)

	# Check if empty
	if [[ -z "$input" ]]; then
		echo -e "${RED}Error 106: Database name cannot be empty.${RESET}"
		return 1
	fi

	case $input in
	[0-9]*)
		echo -e "${RED}Error 101: Name of Directory Start with numbers.${RESET}"
		;;
	_)
		echo -e "${RED}Error 102: Name of Directory Can't be_.${RESET}"
		;;
	+([a-zA-Z0-9_]))
		if [[ -d ~/.DBMS/$input ]]; then
			echo -e "${RED}Error 103: Name of DB is already exists.${RESET}"
		else
			echo -e "${GREEN}Creating DB... ${RESET}"
			mkdir ~/.DBMS/"$input"
			sleep 1

			echo -e "${GREEN}${input}Created!!!${RESET}"
		fi
		;;
	*)
		echo -e "${RED}Error 104: Name of Directory contains Special Characters.${RESET}" "$input"
		;;
	esac
}

# List databases
list_db() {
	if [[ -z "$(ls -A ~/.DBMS)" ]]; then
		echo "No databases found."
		return
	fi
	echo -e "${YELLOW}List Of Databases:${RESET}"
	for db in ~/.DBMS/*/; do
		if [[ -d "$db" ]]; then
			basename "$db"
		fi
	done
}

# connect to database
connect_db() {
	input=$(read_input)

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
	input=$(read_input)

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
	:
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

update_from_table(){
	:
}

select_from_table() {
	:
}

delete_from_table() {
	:
}

# put the menu of database options
menu=("create_db" "list_db" "connect_db" "drop_db" "exit")
select _ in "${menu[@]}"; do

	case $REPLY in
	1 | "create database")
		create_db
		;;
	2 | "list database")
		list_db
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
