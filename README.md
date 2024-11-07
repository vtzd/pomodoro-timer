# Terminal Pomodoro Timer

A minimalist Pomodoro timer that runs directly in your terminal. It features a visual progress bar and automatic session management.

## Features

- 25-minute work sessions
- 5-minute short breaks
- 15-minute long breaks after 4 work sessions
- Visual progress bar
- Centered display in terminal
- Audio alert when sessions end

## Requirements

- zsh shell
- Terminal with support for basic cursor control (most modern terminals)

## Installation

1. Create `quotes.txt`
2. Make script executable:
```bash
chmod +x pomodoro.zsh
```

## Usage
Simply run the script:
```bash
./pomodoro.zsh
```

To exit at any time, press `Ctrl+C`.

## Customization

You can modify the following variables at the top of the script to adjust the timer durations:
- `DURATION_WORK`: Length of work sessions (default: 25 minutes)
- `DURATION_SHORT_BREAK`: Length of short breaks (default: 5 minutes)
- `DURATION_LONG_BREAK`: Length of long breaks (default: 15 minutes)
- `SESSION_TOTAL`: Number of work sessions before a long break (default: 4)