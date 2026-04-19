#!/bin/bash

# --- COLORS & STYLING ---
NEON_GREEN="\033[38;2;0;255;159m"
CYAN="\033[38;2;0;234;255m"
DARK_BG="\033[48;2;10;10;15m"
RESET="\033[0m"
DIM="\033[2m"
BOLD="\033[1m"

# Handle exit cleanly (reset colors and ensure cursor is visible)
trap "echo -ne '${RESET}'; tput cnorm; echo ''" EXIT

# Ensure jq and curl are installed
if ! command -v jq &> /dev/null || ! command -v curl &> /dev/null; then
    echo -e "${NEON_GREEN}Error: curl and jq are required. Please install them.${RESET}"
    exit 1
fi

if [[ -z "${GEMINI_API_KEY}" ]]; then
    echo -e "${NEON_GREEN}Error: GEMINI_API_KEY is not set.${RESET}"
    echo -e "Run: export GEMINI_API_KEY=\"your_key_here\""
    exit 1
fi

# Conversation history array
HISTORY="[]"

# --- FUNCTIONS ---

# Typing effect (no newline)
typing_effect() {
    local text="$1"
    local speed=${2:-0.03}
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${text:$i:1}"
        sleep "$speed"
    done
}

# Matrix effect
matrix_effect() {
    local chars="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*"
    for i in {1..20}; do
        local rand_char=${chars:$((RANDOM % ${#chars})):1}
        local rand_x=$((RANDOM % $(tput cols) + 1))
        echo -ne "\033[s\033[1;${rand_x}H${DIM}${NEON_GREEN}${rand_char}${RESET}\033[u"
        sleep 0.01
    done
}

# Cosmic effect
cosmic_effect() {
    local stars=".*+"
    for i in {1..10}; do
        local rand_star=${stars:$((RANDOM % ${#stars})):1}
        local rand_x=$((RANDOM % $(tput cols) + 1))
        local rand_y=$((RANDOM % 5 + 1))
        echo -ne "\033[s\033[${rand_y};${rand_x}H${DIM}${CYAN}${rand_star}${RESET}\033[u"
        sleep 0.02
    done
}

# Fake processing messages
fake_processing() {
    local messages=("Analyzing input..." "Accessing knowledge core..." "Synthesizing response..." "Quantum routing...")
    local msg=${messages[$((RANDOM % ${#messages[@]}))]}
    
    # Hide cursor
    tput civis
    
    echo -ne "${DIM}${CYAN}${msg}${RESET}\r"
    matrix_effect
    cosmic_effect
    sleep 0.4
    
    # Clear line and restore cursor
    echo -ne "\033[K"
    tput cnorm
}

# Print response in a box
print_box() {
    local ai_text="$1"
    local width=70
    local border=$(printf '━%.0s' $(seq 1 $width))
    echo -e "${CYAN}┏${border}┓${RESET}"
    
    # Use fold to wrap text. 
    local wrapped_text=$(echo "$ai_text" | fold -w $((width - 2)) -s)
    
    while IFS= read -r line; do
        printf "${CYAN}┃${RESET} ${NEON_GREEN}"
        typing_effect "$line" 0.005
        
        # pad remaining space
        local current_len=${#line}
        local pad_len=$((width - 3 - current_len))
        if ((pad_len > 0)); then
            printf "%${pad_len}s" " "
        fi
        printf " ${CYAN}┃${RESET}\n"
    done <<< "$wrapped_text"
    
    echo -e "${CYAN}┗${border}┛${RESET}"
}

# Startup Intro
show_intro() {
    echo -ne "${DARK_BG}"
    clear
    tput civis # Hide cursor
    typing_effect "${BOLD}${CYAN}Booting Neural System...${RESET}\n" 0.04
    sleep 0.2
    typing_effect "${BOLD}${CYAN}Connecting to AI Core...${RESET}\n" 0.04
    matrix_effect
    sleep 0.2
    typing_effect "${BOLD}${NEON_GREEN}System Online${RESET}\n" 0.04
    cosmic_effect
    echo -e "\n${DIM}Type /help for commands${RESET}\n"
    tput cnorm # Show cursor
}

# Call Gemini API
api_call() {
    local user_input="$1"
    
    # Append to history securely
    local new_msg=$(jq -n --arg txt "$user_input" '{role: "user", parts: [{text: $txt}]}')
    HISTORY=$(echo "$HISTORY" | jq --argjson msg "$new_msg" '. + [$msg]')
    
    local api_url="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}"
    
    # Using jq to assemble payload securely
    local payload=$(jq -n --argjson hist "$HISTORY" '{contents: $hist}')
    
    fake_processing
    
    local response=$(curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$api_url")
    
    local error_check=$(echo "$response" | jq -r '.error.message // empty')
    if [[ -n "$error_check" ]]; then
        echo -e "${CYAN}System Error: ${error_check}${RESET}"
        # Revert history if failed
        HISTORY=$(echo "$HISTORY" | jq 'del(.[-1])')
        return
    fi
    
    local ai_text=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text // empty')
    
    if [[ -z "$ai_text" ]]; then
        ai_text="[No signal from AI Core]"
    fi
    
    print_box "$ai_text"
    
    # Append AI response to history
    local ai_msg=$(jq -n --arg txt "$ai_text" '{role: "model", parts: [{text: $txt}]}')
    HISTORY=$(echo "$HISTORY" | jq --argjson msg "$ai_msg" '. + [$msg]')
}

# --- MAIN LOOP ---
show_intro

while true; do
    echo -ne "${BOLD}${CYAN}USER > ${RESET}${NEON_GREEN}"
    read -e user_input
    echo -ne "${RESET}"
    
    if [[ -z "$user_input" ]]; then
        continue
    fi
    
    case "$user_input" in
        /exit)
            tput civis
            echo ""
            typing_effect "${CYAN}Disconnecting Neural Link... Goodbye.${RESET}\n" 0.05
            sleep 0.5
            tput cnorm
            break
            ;;
        /clear)
            show_intro
            ;;
        /help)
            echo -e "\n${CYAN}┏━━━━━━━━━━ COMMANDS ━━━━━━━━━━┓${RESET}"
            echo -e "${CYAN}┃${RESET} ${NEON_GREEN}/exit${RESET}  - Terminate session   ${CYAN}┃${RESET}"
            echo -e "${CYAN}┃${RESET} ${NEON_GREEN}/clear${RESET} - Wipe terminal       ${CYAN}┃${RESET}"
            echo -e "${CYAN}┃${RESET} ${NEON_GREEN}/help${RESET}  - Show directives     ${CYAN}┃${RESET}"
            echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"
            ;;
        *)
            api_call "$user_input"
            echo ""
            ;;
    esac
done
