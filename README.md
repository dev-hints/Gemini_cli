# Gemini CLI - Futuristic Bash Chatbot

A lightweight, purely terminal-based AI chatbot built entirely in Bash. It features a sleek "hacker/cosmic" aesthetic with neon colors, typing animations, and custom UI components right in your console, all powered by the Google Gemini API.

## Features

- **Hacker Aesthetic:** Enjoy matrix-style text loading, cosmic background animations, and custom terminal frames.
- **Context-Aware:** Maintains conversational history for multi-turn dialogues with the AI.
- **Zero Heavy Dependencies:** Written in Bash, utilizing only `curl` and `jq`.
- **Fast & Responsive:** Powered by the `gemini-2.5-flash` model for high-speed inferences.

## Prerequisites

Before running the chatbot, ensure you have the following installed on your system:
- `bash`
- `curl`
- `jq`

You will also need a **Gemini API Key**. You can get one from [Google AI Studio](https://aistudio.google.com/).

## Installation & Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/dev-hints/Gemini_cli.git
   cd Gemini_cli
   ```

2. **Make the script executable:**
   ```bash
   chmod +x chatbot.sh
   ```

3. **Set your API Key:**
   Export your Gemini API key as an environment variable:
   ```bash
   export GEMINI_API_KEY="your_api_key_here"
   ```

4. **Boot the Neural System:**
   ```bash
   ./chatbot.sh
   ```

## Commands

While inside the chatbot session, you can use the following commands:
- `/exit`  - Terminate the session cleanly.
- `/clear` - Wipe the terminal and replay the startup sequence.
- `/help`  - Display the list of available commands.

## License

This project is open-source and free to use.
