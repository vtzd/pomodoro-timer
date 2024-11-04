#!/bin/zsh

# Get terminal width
COLUMNS=$(tput cols)

# Pomodoro settings
DURATION_WORK=25
DURATION_SHORT_BREAK=5
DURATION_LONG_BREAK=15
SESSION_COUNT=4

# Colors using zsh color codes
MAGENTA='%F{magenta}'
GREEN='%F{green}'
BLUE='%F{blue}'
NC='%f'  

trap '' TSTP TERM HUP  # Ignore suspend (Ctrl+Z), terminate, and hangup
trap 'tput cnorm; echo -e "\n\nExiting Pomodoro Timer..."; exit 0' INT 
tput civis

center_text() {
    local text="$1"
    local width=$(( ($COLUMNS - ${#text}) / 2 ))
    printf "%${width}s%s" "" "$text"
}

center_text_color() {
    local text="$1"
    # Strip color codes for width calculation
    local plain_text="${text//\%F\{*\}/}"  # Remove %F{color}
    plain_text="${plain_text//\%f/}"       # Remove %f
    
    local width=$(( ($COLUMNS - ${#plain_text}) / 2 ))
    local padding=""
    for ((i=0; i<width; i++)); do
        padding+=" "
    done
    print -P "${padding}${text}"
}

format_time() {
    local elapsed=$1
    local total=$2
    printf "%02d/%02d" $elapsed $total
}

# Function to display the timer
display_timer() {
    local elapsed=$1
    local total=$2
    local session_type=$3
    local pomodoro_count=$4
    local session_count=$5

    # Clear screen for each update
    tput cup 0 0
    clear
    
    # Center vertically
    LINES=$(tput lines)
    middle_line=$((LINES / 2))
    
    # Display timer
    tput cup $((middle_line - 2)) 0
    local time_display=$(format_time $elapsed $total)
    center_text "$time_display"
    
    # Display timer progress bar
    tput cup $((middle_line)) 0
    local progress="["
    local fill_count=$(( elapsed * 40 / total ))
    local empty_count=$(( 40 - fill_count ))
    
    for ((i=1; i<=fill_count; i++)); do
        progress+="="
    done
    for ((i=1; i<=empty_count; i++)); do
        progress+=" "
    done
    progress+="]"
    center_text "$progress"
}

# Function to run a timer session
run_timer() {
    local duration_minutes=$1
    local session_type=$2
    local pomodoro_count=$3
    local session_count=$4
    
    local elapsed=0
    
    while [ $elapsed -lt $duration_minutes ]; do
        display_timer $elapsed $duration_minutes $session_type $pomodoro_count $session_count
        sleep 60
        ((elapsed++))
    done
    
    # Display final state
    display_timer $duration_minutes $duration_minutes $session_type $pomodoro_count $session_count
    
    # Play alert sound (using terminal bell)
    echo -ne '\007'
}

# Trap Ctrl+C to exit cleanly
trap 'echo -e "\n\nExiting Pomodoro Timer..."; exit 0' INT

# Main Pomodoro loop
pomodoro_count=1
session_count=4

clear

while true; do
    # Work session
    run_timer $DURATION_WORK "work" $pomodoro_count $session_count
    
    # Determine and run break
    if [[ $pomodoro_count -eq $session_count ]]; then
        # Long break
        run_timer $DURATION_LONG_BREAK "long_break" $pomodoro_count $session_count
        pomodoro_count=1
    else
        # Short break
        run_timer $DURATION_SHORT_BREAK "short_break" $pomodoro_count $session_count
        ((pomodoro_count++))
    fi
done
