#!/bin/bash


ERROR_LOG="errors.log"

show_help() {
cat <<EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>   Directory to search recursively
  -f <file>        File to search directly
  -k <keyword>     Keyword to search
  -h               Display this help menu

Examples:
  $0 -d logs -k error
  $0 -f script.sh -k TODO
EOF
}

search_directory() {
    local dir="$1"
    local keyword="$2"

    for item in "$dir"/*; do
        if [ -f "$item" ]; then
            grep -H "$keyword" "$item" 2>>"$ERROR_LOG"
        elif [ -d "$item" ]; then
            search_directory "$item" "$keyword"
        fi
    done
}


directory=""
file=""
keyword=""


while getopts ":d:f:k:h" opt; do
    case $opt in
        d) directory="$OPTARG" ;;
        f) file="$OPTARG" ;;
        k) keyword="$OPTARG" ;;
        h) show_help; exit 0 ;;
        \?) echo "Invalid option: -$OPTARG" | tee -a "$ERROR_LOG"; exit 1 ;;
    esac
done


echo "Script name: $0"
echo "Total arguments: $#"
echo "All arguments: $@"


if [[ -z "$keyword" || ! "$keyword" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Invalid or empty keyword" | tee -a "$ERROR_LOG"
    exit 1
fi


if [ -n "$file" ]; then
    if [ ! -f "$file" ]; then
        echo "File not found: $file" | tee -a "$ERROR_LOG"
        exit 1
    fi

    
    grep "$keyword" <<< "$(cat "$file")"



elif [ -n "$directory" ]; then
    if [ ! -d "$directory" ]; then
        echo "Directory not found: $directory" | tee -a "$ERROR_LOG"
        exit 1
    fi

    search_directory "$directory" "$keyword"

else
    echo "Either -d or -f must be provided" | tee -a "$ERROR_LOG"
    show_help
    exit 1
fi


echo "Last command exit status: $?"

