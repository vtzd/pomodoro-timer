#!/bin/zsh

# Settings
DURATION_WORK=25
DURATION_SHORT_BREAK=5
DURATION_LONG_BREAK=15
SESSION_TOTAL=4

# Setup
COLUMNS=$(tput cols)
trap 'tput cnorm; echo "\n\nExiting..."; exit 0' INT
tput civis

center_text() {
    local text="$1"
    local width=$(( ($COLUMNS - ${#text}) / 2 ))
    printf "%${width}s%s" "" "$text"
}

display_timer() {
    local elapsed=$1
    local total=$2
    
    tput cup 0 0
    clear
    
    local middle_line=$(($(tput lines) / 2))
    
    tput cup $((middle_line - 2)) 0
    center_text "$(printf "%02d/%02d" $elapsed $total)"
    
    tput cup $((middle_line)) 0
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
    local elapsed=0
    
    while [ $elapsed -le $duration ]; do
        display_timer $elapsed $duration
        sleep 60
        ((elapsed++))
    done
    echo -e '\a'
}

# Main loop
session_count=1
while true; do
    run_timer $DURATION_WORK
    
    if [[ $session_count -eq $SESSION_TOTAL ]]; then
        run_timer $DURATION_LONG_BREAK
        session_count=1
    else
        run_timer $DURATION_SHORT_BREAK
        ((session_count++))
    fi
done