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
START_WITH_NUM_INPUT=-4
EXISTS=-5
NOT_FOUND=-6

# Codes
EMPTY_CODE=101
INVALID_CHARS_CODE=102
UNDERSCORE_ONLY_CODE=103
START_WITH_NUM_CODE=104
EXISTS_CODE=105
NOT_FOUND_CODE=106
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

# Print Errors
print_error() {
	local code=$1
	case $code in
	"$EMPTY_INPUT")
		echo -e "${RED}Error ${EMPTY_CODE}: Input cannot be empty.${RESET}"
		;;
	"$START_WITH_NUM_INPUT")
		echo -e "${RED}Error ${START_WITH_NUM_CODE}: Cannot start with a number.${RESET}"
		;;
	"$UNDERSCORE_ONLY_INPUT")
		echo -e "${RED}Error ${UNDERSCORE_ONLY_CODE}: Cannot be underscore only.${RESET}"
		;;
	"$INVALID_INPUT")
		echo -e "${RED}Error ${INVALID_CHARS_CODE}: Invalid characters detected.${RESET}"
		;;
	"$EXISTS")
		echo -e "${RED}Error ${EXISTS_CODE}: Database already exists.${RESET}"
		;;
	"$NOT_FOUND")
		echo -e "${RED}Error ${NOT_FOUND_CODE}: Database not found.${RESET}"
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

	local db_name=$1
    local validation_res

    validation_res=$(input_validation "$db_name")

    if [[ "$validation_res" != "$SUCCESS" ]]; then
        echo "$validation_res"
        return
    fi

    if [[ -d ~/.DBMS/"$db_name" ]]; then
        rm -r ~/.DBMS/"$db_name"
        echo "$SUCCESS"
    else
        echo "$NOT_FOUND"
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
		read -r -p "Enter Database Name: " dbNameInput

		result=$(create_db "$dbNameInput")

		if [[ $result == "$SUCCESS" ]]; then
			echo -e "${GREEN}Database created successfully.${RESET}"
		else
			print_error "$result"
		fi
		;;

	2 | "list database")

		list_db dbs status

		if [[ $status == "$SUCCESS" ]]; then
			echo -e "${BLUE}Databases:${RESET}"
			for db in "${dbs[@]}"; do
				echo "- $db"
			done
		else
			print_error "$status"
		fi
		;;
	3 | "connect database")
		# connect_db
		;;
	4 | "drop database")
		read -r -p "Enter Database Name to drop: " dbNameInput
        
        read -r -p "Are you sure you want to delete '$dbNameInput'? (y/n): " confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        
            result=$(drop_db "$dbNameInput")
            
            if [[ "$result" == "$SUCCESS" ]]; then
                echo -e "${GREEN}Database Dropped Successfully.${RESET}"
            else
                print_error "$result"
            fi
            
        else
            echo -e "${YELLOW}Operation Cancelled.${RESET}"
        fi
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
