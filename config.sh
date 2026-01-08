#!/bin/bash
set -euo pipefail
clear

# 🔷 Blue header lines
header=(
"-----------------------------------------------------------"
"           PTERODACTYL+ - BY DYNAMIND"
"-----------------------------------------------------------"
)

# 🟢 Menu options (green)
menu=(
"1 : Blueprint Extensions"
"2 : Python 24/7 Code"
"3 : Firewall Protection"
"4 : CloudFlare Tunnel Setup"
"5 : Neofetch Installer"
"6 : PLAYIT plugin"
"7 : SSHX.io setup"
"8 : Tailscale setup + up"
"9 : DDoS Protection"
"0 : Exit"
)

# Colors
PURPLE="\e[35m"   # errors
GREEN="\e[32m"    # menu options
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"     # press enter prompt
RESET="\e[0m"

# 🔹 Function to show UI with animation
show_ui() {
  clear
  for line in "${header[@]}"; do
    echo -e "\e[38;5;208;1m$line\e[0m"  # header orange
    sleep 0.08
  done
  echo ""
  for option in "${menu[@]}"; do
    echo -e "${GREEN}$option${RESET}"   # menu options green
    sleep 0.05
  done
  echo ""
}

# 🔹 Safe command runner
run_command() {
  if ! eval "$1"; then
    echo -e "${PURPLE}An Unexpected Error Occured While Starting The Manager${RESET}"
  fi
  echo -e "\n${BLUE}Press Enter To Return To Menu${RESET}"
  read -r
}

# ============================
# Functions for each option
# ============================

blueprint_extension() {
  rm -rf /tmp/blueprint_ext
  mkdir -p /tmp/blueprint_ext
  cd /tmp/blueprint_ext || return 1

  git clone https://github.com/rasingamerzop/1.git || return 1
  cd 1 || return 1

  mv nebula.blueprint /var/www/pterodactyl
  blueprint -install nebula.blueprint || return 1

  mv huxregister.blueprint /var/www/pterodactyl
  blueprint -install huxregister.blueprint || return 1

  mv loader.blueprint /var/www/pterodactyl
  blueprint -install loader.blueprint || return 1

  mv simplefavicons.blueprint /var/www/pterodactyl
  blueprint -install simplefavicons.blueprint || return 1

  mv simplefooters.blueprint /var/www/pterodactyl
  blueprint -install simplefooters.blueprint || return 1

  mv snowflakes.blueprint /var/www/pterodactyl
  blueprint -install snowflakes.blueprint || return 1

  mv mcplugin.blueprint /var/www/pterodactyl
  blueprint -install mcplugin.blueprint || return 1

  mv minecraftplayermanager.blueprint /var/www/pterodactyl
  blueprint -install minecraftplayermanager.blueprint || return 1

  mv versionchanger.blueprint /var/www/pterodactyl
  blueprint -install versionchanger.blueprint || return 1

  mv nightadmin.blueprint /var/www/pterodactyl
  blueprint -install nightadmin.blueprint || return 1

  return 0
}


python_runner() {
  python3 <(curl -s https://raw.githubusercontent.com/JishnuTheGamer/24-7/refs/heads/main/24) || return 1
  return 0
}

firewall_protection() {
  apt update -y || true
  apt install -y ufw >/dev/null 2>&1 || return 1
  ufw allow 22/tcp
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw allow 25565/tcp
  ufw allow 19100:19200/tcp
  ufw --force enable
  echo -e "${GREEN}✅ UFW enabled and common ports allowed.${RESET}"
  return 0
}

ipv4_allocation() {
  echo -e "${YELLOW}Note: run this on the node host. Ensure IP is routed/owned by your VPS provider.${RESET}"
  echo ""
  echo "Detected network interfaces:"
  ip -o link show | awk -F': ' '{print " - " $2}'
  echo ""
  read -rp "Enter the physical interface to attach alias to (e.g. eth0): " IFACE
  [[ -n "$IFACE" ]] || { echo -e "${PURPLE}Invalid interface${RESET}"; return 1; }
  read -rp "Enter the IPv4 you want to allocate (e.g. 203.0.113.5): " NEW_IP
  [[ -n "$NEW_IP" ]] || { echo -e "${PURPLE}Invalid IP${RESET}"; return 1; }
  read -rp "Enter CIDR prefix (default 24): " PREFIX
  PREFIX=${PREFIX:-24}

  sudo ip addr add "${NEW_IP}/${PREFIX}" dev "${IFACE}" label "${IFACE}:1" || { echo -e "${PURPLE}Failed to add alias${RESET}"; return 1; }

  mkdir -p /etc/network/interfaces.d
  ALIAS_FILE="/etc/network/interfaces.d/${IFACE}:1.cfg"
  cat > "${ALIAS_FILE}" <<EOF
auto ${IFACE}:1
iface ${IFACE}:1 inet static
    address ${NEW_IP}
    netmask 255.255.255.0
EOF

  echo -e "${GREEN}✅ Alias ${IFACE}:1 with ${NEW_IP}/${PREFIX} created and persisted at ${ALIAS_FILE}.${RESET}"
  echo -e "${YELLOW}Now add ${NEW_IP} as an allocation in Pterodactyl.${RESET}"
  return 0
}

cloudflared_setup() {
  if ! command -v cloudflared >/dev/null 2>&1; then
    curl -fsSL https://pkg.cloudflare.com/gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list >/dev/null
    apt update && apt install -y cloudflared || return 1
  fi
  cloudflared tunnel login || return 1
  read -rp "Enter tunnel name: " TUNNEL_NAME
  [[ -n "$TUNNEL_NAME" ]] || { echo -e "${PURPLE}Tunnel name required${RESET}"; return 1; }
  cloudflared tunnel create "$TUNNEL_NAME" || return 1
  mkdir -p /etc/cloudflared
  TID=$(cloudflared tunnel list | awk -v tn="$TUNNEL_NAME" '$0 ~ tn {print $1; exit}')
  cat > /etc/cloudflared/config.yml <<EOF
tunnel: ${TID}
credentials-file: /root/.cloudflared/${TID}.json
ingress:
  - hostname: ${TUNNEL_NAME}.trycloudflare.com
    service: http://localhost:25565
  - service: http_status:404
EOF
  cloudflared service install || true
  echo -e "${GREEN}✅ Cloudflared tunnel ${TUNNEL_NAME} created and started.${RESET}"
  return 0
}

neofetch_install() {
  apt update -y || true
  apt install -y neofetch || return 1
  echo -e "${GREEN}✅ neofetch installed.${RESET}"
  return 0
}

playit_plugin() {
  bash <(curl -fsSL https://raw.githubusercontent.com/hopingboyz/playit/main/playit.sh) || return 1
  return 0
}

sshx_setup() {
  curl -sSf https://sshx.io/get | sh || return 1
  sshx || return 1
  return 0
}

tailscale_setup() {
  curl -fsSL https://tailscale.com/install.sh | sh || return 1
  tailscale up || return 1
  return 0
}

ddos_protection() {
  apt update -y || true
  apt install -y iptables || return 1
  iptables -A INPUT -p tcp --dport 22 -j ACCEPT || true
  echo -e "${GREEN}✅ iptables installed and basic SSH rule added.${RESET}"
  read -rp "Run remote DDoS script? (paste URL, leave empty to skip): " DDOS_URL
  if [[ -n "$DDOS_URL" ]]; then
    if ! curl -s "$DDOS_URL" | bash; then
      echo -e "${PURPLE}An Unexpected Error Occured While Starting The Manager${RESET}"
      return 1
    fi
    echo -e "${GREEN}✅ Remote DDoS script executed.${RESET}"
  fi
  return 0
}

# ============================
# Main loop
# ============================
while true; do
  show_ui
  read -rp $'\e[36mEnter your choice: \e[0m' choice
  clear
  case "$choice" in
    1) run_command "blueprint_extension" ;;
    2) run_command "python_runner" ;;
    3) run_command "firewall_protection" ;;
    4) run_command "cloudflared_setup" ;;
    5) run_command "neofetch_install" ;;
    6) run_command "playit_plugin" ;;
    7) run_command "sshx_setup" ;;
    8) run_command "tailscale_setup" ;;
    9) run_command "ddos_protection" ;;
    0)
      echo -e "${PURPLE}Exiting Manager...${RESET}"
      exit 0
      ;;
    *)
      echo -e "${PURPLE}An Unexpected Error Occured While Starting The Manager${RESET}"
      sleep 1.2
      ;;
  esac
done
