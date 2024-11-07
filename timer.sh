#!/bin/zsh

# Settings
DURATION_WORK=25
DURATION_SHORT_BREAK=5
DURATION_LONG_BREAK=15
SESSION_TOTAL=4
SCRIPT_DIR="${0:A:h}"
FILENAME="${SCRIPT_DIR}/quotes.txt"

# Setup
get_columns() {
    COLUMNS=$(tput cols)
    if [ "$COLUMNS" -eq 0 ]; then
        COLUMNS=54
    fi
}

get_columns
trap 'tput cnorm; echo "\n\nExiting..."; exit 0' INT
tput civis

truncate_text() {
    local text="$1"
    local max_width="$2"
    local line=""
    local result=""
    
    # Split into words
    local -a words
    words=(${=text})
    
    for word in $words; do
        # If adding this word would exceed max width
        if (( ${#line} + ${#word} + 1 > max_width )); then
            # Add current line to result
            [[ -n "$result" ]] && result+=$'\n'
            result+="$line"
            line="$word"
        else
            # Add word to current line
            if [[ -z "$line" ]]; then
                line="$word"
            else
                line="$line $word"
            fi
        fi
    done
    
    # Add last line if not empty
    [[ -n "$line" ]] && result+=$'\n'"$line"
    
    echo "$result"
}

center_text() {
    local text="$1"
    get_columns 
    local padding=$(( ($COLUMNS - ${#text}) / 2 ))
    if (( padding < 0 )); then
        padding=0
    fi
    printf "%${padding}s%s" "" "$text"
}

display_timer() {
    local elapsed=$1
    local total=$2
    local session_type=$3
    
    tput cup 0 0
    clear
    
    local middle_line=$(($(tput lines) / 2))

    if (( middle_line < 3 )); then
        middle_line=3
    fi

    tput cup $((middle_line)) 0
    # Count total lines in file
    local total_quote_lines=$(wc -l < "$FILENAME")
    local random_quote_line=$((RANDOM % total_quote_lines + 1))
    local random_quote=$(sed -n "${random_quote_line}p" "$FILENAME")
    
    local truncated_quote=$(truncate_text "$random_quote" 32)
    local line_num=$((middle_line))
    
    while IFS= read -r line; do
        tput cup $line_num 0
        center_text "$line"
        ((line_num++))
    done <<< "$truncated_quote"
    
    tput cup $((middle_line - 2)) 0
    local fill_count=$(( elapsed * 40 / total ))
    local empty_count=$(( 40 - fill_count ))
    
    
    local progress="["
    for ((i=1; i<=fill_count; i++)); do
        progress+="="
    done
    for ((i=1; i<=empty_count; i++)); do
        progress+=" "
    done
    progress+="]"
    
    center_text "$progress"
}

run_timer() {
    local duration=$1
    local session_type=$2
    local elapsed=0
    
    while (( elapsed <= duration )); do
        display_timer $elapsed $duration $session_type
        sleep 60
        ((elapsed++))
    done
    echo -e '\a'
}

# Main loop
session_count=1
while true; do
    run_timer $DURATION_WORK "work"
    
    if (( session_count == SESSION_TOTAL )); then
        run_timer $DURATION_LONG_BREAK "long_break"
        session_count=1
    else
        run_timer $DURATION_SHORT_BREAK "short_break"
        ((session_count++))
    fi
done