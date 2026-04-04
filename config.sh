#!/bin/bash
set -euo pipefail
clear

header=(
"-------------------------------------------------------"
"           WEB MANAGER - BY DYNAMIXNODES™"
"-------------------------------------------------------"
)

menu=(
"1  : Blueprint Extensions (Hosting Developement Plan)"
"2  : Python 24/7 Code"
"3  : Firewall Protection"
"4  : CloudFlare Tunnel Setup"
"5  : PLAYIT plugin"
"6  : SSHX.io setup"
"7  : Tailscale setup + up"
"8  : DDoS Protection"
"9  : XRDP + (Mozila Extension)"
"10 : System Information"
"11 : Create Pterodactyl User"
"0  : Exit"
)

PURPLE="\e[35m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"
RESET="\e[0m"

show_ui() {
  clear
  for line in "${header[@]}"; do
    echo -e "\e[38;5;208;1m$line\e[0m"
    sleep 0.05
  done
  echo ""
  for option in "${menu[@]}"; do
    echo -e "${GREEN}$option${RESET}"
    sleep 0.03
  done
  echo ""
}

run_command() {
  if ! eval "$1"; then
    echo -e "${PURPLE}An Unexpected Error Occured While Starting The Manager${RESET}"
  fi
  echo -e "\n${BLUE}Press Enter To Return To Menu${RESET}"
  read -r
}

# ================= FUNCTIONS =================

blueprint_extension() {
  echo -e "${YELLOW}Sorry, this requires permission of the owner!${RESET}"
  return 0
}

python_runner() {
  python3 <(curl -s https://raw.githubusercontent.com/JishnuTheGamer/24-7/refs/heads/main/24)
}

firewall_protection() {
  apt update -y || true
  apt install -y ufw >/dev/null 2>&1
  ufw allow 22/tcp
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw allow 25565/tcp
  ufw allow 19100:19200/tcp
  ufw --force enable
  echo -e "${GREEN}✅ UFW enabled and ports opened${RESET}"
}

cloudflared_setup() {
  if ! command -v cloudflared >/dev/null; then
    curl -fsSL https://pkg.cloudflare.com/gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list >/dev/null
    apt update && apt install -y cloudflared
  fi

  echo ""
  echo "Paste your tunnel install command:"
  read -rp ">> " CMD
  eval "$CMD"

  echo -e "${GREEN}✅ Tunnel installed${RESET}"
}

playit_plugin() {
  bash <(curl -fsSL https://raw.githubusercontent.com/hopingboyz/playit/main/playit.sh)
}

sshx_setup() {
  curl -sSf https://sshx.io/get | sh
  sshx
}

tailscale_setup() {
  curl -fsSL https://tailscale.com/install.sh | sh
  tailscale up
}

ddos_protection() {
  apt update -y || true
  apt install -y iptables
  iptables -A INPUT -p tcp --dport 22 -j ACCEPT
  echo -e "${GREEN}✅ Basic protection enabled${RESET}"
}

xrdp_mozila() {
  apt update
  apt install -y firefox-esr xfce4 xfce4-goodies xrdp
  echo "startxfce4" > ~/.xsession
  systemctl enable xrdp
  systemctl restart xrdp
  curl ipconfig.io
}

system_info() {
  free -h
  curl ipconfig.io
}

create_user() {
  cd /var/www/pterodactyl || return

  echo "Admin? (yes/no)"
  read ADMIN

  echo "Email:"
  read EMAIL

  echo "Username:"
  read USERNAME

  echo "First name:"
  read FIRST

  echo "Last name:"
  read LAST

  echo "Password:"
  read -s PASS
  echo ""

  [[ "$ADMIN" == "yes" ]] && FLAG="--admin" || FLAG=""

  php artisan p:user:make \
    --email="$EMAIL" \
    --username="$USERNAME" \
    --name-first="$FIRST" \
    --name-last="$LAST" \
    --password="$PASS" \
    $FLAG

  echo -e "${GREEN}✅ User created${RESET}"
}

# ================= LOOP =================

while true; do
  show_ui
  read -rp $'\e[36mEnter choice: \e[0m' choice
  clear

  case "$choice" in
    1) run_command blueprint_extension ;;
    2) run_command python_runner ;;
    3) run_command firewall_protection ;;
    4) run_command cloudflared_setup ;;
    5) run_command playit_plugin ;;
    6) run_command sshx_setup ;;
    7) run_command tailscale_setup ;;
    8) run_command ddos_protection ;;
    9) run_command xrdp_mozila ;;
    10) run_command system_info ;;
    11) run_command create_user ;;
    0)
      echo -e "${PURPLE}Exiting...${RESET}"
      exit 0
      ;;
    *)
      echo -e "${PURPLE}Invalid option${RESET}"
      sleep 1
      ;;
  esac
done
