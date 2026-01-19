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
INVALID_NUM_CODE=207 #Will change
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
	local db_name=$1
	local validation_res

	validation_res=$(input_validation "$db_name")

	if [[ "$validation_res" != "$SUCCESS" ]]; then
		echo "$validation_res"
		return
	fi

	if [[ -d ~/.DBMS/"$db_name" ]]; then
		echo "$SUCCESS"
	else
		echo "$NOT_FOUND"
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

################################# TABLES #################################

# 1-
################################# Create Table #################################
create_data_file() {
	local tableName=$1

	if [[ -f "$tableName" ]]; then
		echo "$EXISTS"
	else
		touch "$tableName"
		chmod 644 "$tableName"
		echo "$SUCCESS"
	fi
}

create_metadata_file() {
	local tableName=$1
	local cols=$2
	local types=$3
	local pk=$4

	echo "$cols" >".$tableName.meta"
	echo "$types" >>".$tableName.meta"
	echo "$pk" >>".$tableName.meta"

	echo "$SUCCESS"
}

create_table() {
	local tableName=$1
	local colsMetadata=$2
	local typesMetadata=$3
	local pkName=$4

	result=$(input_validation "$tableName")

	if [[ $result == "$SUCCESS" ]]; then
		result=$(create_data_file "$tableName")
		if [[ $result == "$SUCCESS" ]]; then
			result=$(create_metadata_file "$tableName" "$colsMetadata" "$typesMetadata" "$pkName")
			echo "$result"
		else
			echo "$result"
		fi
	else
		echo "$result"
	fi

}

# 2-
################################# List Table #################################

list_table() {
	:
}

# 3-
################################# Drop Table #################################

drop_table() {
	:
}

# 4-
################################# Insert Into Table #################################

insert_into_table() {
	:
}

# 5-
################################# Update Table #################################

update_from_table() {
	:
}

# 6-
################################# Select Table #################################

select_from_table() {
	:
}

# 7-
################################# Delete From Table #################################

delete_from_table() {
	:
}

tables_menu() {
	local db_name=$1

	echo -e "${YELLOW}Entered Database: $db_name${RESET}"

	PS3="DB($db_name)> " # Change the propmt

	select choice in "Create Table" "List Tables" "Drop Table" "Insert" "Select" "Update" "Delete" "Back to Main Menu"; do
		case $choice in
		1 | "create table")
			read -r -p "Enter Table Name: " tName

			result=$(create_table "$tName")

			if [[ $result == "$SUCCESS" ]]; then
				echo -e "${GREEN}Table created successfully.${RESET}"
			elif [[ $result == "$EXISTS" ]]; then
				echo -e "${RED}Table already exists.${RESET}"
			else
				print_error "$result"
			fi
			;;
		2 | "list tables")
			list_table
			;;
		3 | "drop table")
			drop_table
			;;
		4 | "insert")
			insert_into_table
			;;
		5 | "select")
			select_from_table
			;;
		6 | "update")
			update_from_table
			;;
		7 | "delete")
			delete_from_table
			;;
		0 | "back to tain menu")
			export PS3="Database> "
			break
			;;
		*)
			echo -e "${RED}Invalid option.${RESET}"
			;;
		esac
	done
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
		read -r -p "Enter Database Name to Connect: " dbNameInput

		result=$(connect_db "$dbNameInput")

		if [[ "$result" == "$SUCCESS" ]]; then
			cd ~/.DBMS/"$dbNameInput" 2>/dev/null || exit

			tables_menu "$dbNameInput"

			cd ../.. 2>/dev/null # Back to the menu of databaes after user finish

			echo -e "${YELLOW}Back to Main Menu.${RESET}"
		else
			print_error "$result"
		fi
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
