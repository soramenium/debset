#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(pwd)

# ---------------------------
# ROOT CHECK
# ---------------------------
if [[ $EUID -ne 0 ]]; then
    echo "Ten skrypt musi być uruchomiony jako root."
    exit 1
fi

# ---------------------------
# TRYB URUCHOMIENIA
# ---------------------------

declare -a EXECUTED_SECTIONS=()

run_section() {
    local name="$1"
    shift
    echo
    echo "===== $name ====="
    "$@"
    EXECUTED_SECTIONS+=("$name")
}

ask_yes_no() {
    local prompt="$1"
    read -rp "$prompt (y/n): " choice
    [[ "$choice" == "y" || "$choice" == "Y" ]]
}

# ---------------------------
# FUNKCJE SEKCJI
# ---------------------------

set_grub_param() {
    local param="$1"
    local value="$2"
    if grep -q "^$param=" "$GRUB_FILE"; then
        sed -i "s|^$param=.*|$param=$value|" "$GRUB_FILE"
    else
        echo "$param=$value" >> "$GRUB_FILE"
    fi
}

install_packages() {

    REQUIRED_PACKAGES=(
        linux-image-rt-amd64
        linux-headers-rt-amd64
        libsocketcan2
        libsocketcan-dev
        dconf-cli
    )

    MISSING_PACKAGES=()
    echo "Sprawdzanie pakietów..."
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            MISSING_PACKAGES+=("$pkg")
        fi
    done

    if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
        echo "Instalowanie: ${MISSING_PACKAGES[*]}"
        apt update
        apt install -y "${MISSING_PACKAGES[@]}"
    else
        echo "Wszystkie pakiety są już zainstalowane."
    fi
}

configure_grub() {

    GRUB_FILE="/etc/default/grub"
    BACKUP_FILE="/etc/default/grub.bak.$(date +%Y%m%d%H%M%S)"

    echo "Backup GRUB -> $BACKUP_FILE"
    cp "$GRUB_FILE" "$BACKUP_FILE"

    set_grub_param "GRUB_TIMEOUT" "0"
    set_grub_param "GRUB_TIMEOUT_STYLE" "hidden"
    set_grub_param "GRUB_CMDLINE_LINUX_DEFAULT" "quiet"
    set_grub_param "GRUB_SAVEDEFAULT" "true"
    set_grub_param "GRUB_DEFAULT" "saved"
    set_grub_param "GRUB_DISABLE_OS_PROBER" "true"
    sed -i '/^GRUB_FORCE_HIDDEN_MENU=/d' "$GRUB_FILE"

    GRUB_BG_DIR="/boot/grub/backgrounds"
    mkdir -p "$GRUB_BG_DIR"

    WALLPAPER_FILE="tapeta_automex.png"
    WALLPAPER_PATH="$SCRIPT_DIR/$WALLPAPER_FILE"

    if [[ -f "$WALLPAPER_PATH" ]]; then
        echo "Ustawiam tło GRUB."
        cp "$WALLPAPER_PATH" "$GRUB_BG_DIR/grubbg.png"
        set_grub_param "GRUB_BACKGROUND" "$GRUB_BG_DIR/grubbg.png"
    else
        echo "Nie znaleziono tapety dla GRUB."
    fi

    RT_ENTRY=$(grep "menuentry 'Debian GNU/Linux" /boot/grub/grub.cfg | grep "rt" | head -n1 | sed -E "s/menuentry '([^']+)'.*/\1/")
    if [[ -n "$RT_ENTRY" ]]; then
        echo "Ustawiam RT kernel jako domyślny."
        sudo grub-set-default "$RT_ENTRY"
    else
        echo "Nie znaleziono wpisu RT."
    fi

    sudo update-grub
}

configure_autologin() {

    DEFAULT_USER=$(logname 2>/dev/null || echo "${SUDO_USER:-}")

    if [[ -z "$DEFAULT_USER" ]]; then
        echo "Nie wykryto użytkownika."
        return
    fi

    GDM_CONF="/etc/gdm3/daemon.conf"
    if [[ -f "$GDM_CONF" ]]; then
        echo "Ustawiam autologowanie dla $DEFAULT_USER"
        sed -i 's/^#  AutomaticLoginEnable =.*/AutomaticLoginEnable=true/' "$GDM_CONF" || true
        sed -i 's/^#  AutomaticLogin =.*/AutomaticLogin='"$DEFAULT_USER"'/' "$GDM_CONF" || true
        grep -q "^AutomaticLoginEnable=" "$GDM_CONF" || echo "AutomaticLoginEnable=true" >> "$GDM_CONF"
        grep -q "^AutomaticLogin=" "$GDM_CONF" || echo "AutomaticLogin=$DEFAULT_USER" >> "$GDM_CONF"
    else
        echo "Nie znaleziono GDM3."
    fi
}

configure_ssh() {
	SSH_CONF="/etc/ssh/sshd_config"
if [[ -f "$SSH_CONF" ]]; then
    SSH_BACKUP="/etc/ssh/sshd_config.bak.$(date +%Y%m%d%H%M%S)"
    cp "$SSH_CONF" "$SSH_BACKUP"
    sed -i '/^#\?Port /d' "$SSH_CONF"
    echo "Port 2222" >> "$SSH_CONF"

    SSH_BIN=$(which sshd || echo "/usr/sbin/sshd")
    if sudo "$SSH_BIN" -t &>/dev/null; then
        systemctl restart ssh
        echo "SSH działa teraz na porcie 2222."
    else
        echo "Błąd konfiguracji SSH! Przywracam backup."
        cp "$SSH_BACKUP" "$SSH_CONF"
        systemctl restart ssh
        exit 1
    fi
fi
}

disable_de() {
    systemctl set-default multi-user.target
	echo "zmieniono domyślny tryb terminala na tekstowy"
}

enable_de() {
    systemctl set-default graphical.target
	echo "zmieniono domyślny tryb terminala na graficzny"
}

# kioskify() {

    # DEST_WALLPAPER="/home/automex/Pictures/tapeta_automex.png"
    # DEST_AUTOSTART="/home/automex/.config/autostart"
    # DEST_DESKTOP="$DEST_AUTOSTART/gnome-kiosk.desktop"

    # # Tapeta – tylko jeśli nie istnieje
    # if [ ! -f "$DEST_WALLPAPER" ]; then
        # cp tapeta_automex.png "$DEST_WALLPAPER"
		# echo "skopiowano tapetę do /Pictures"
    # fi

    # # chmod zawsze bezpieczny (nie crashuje jak już ma +x)
    # chmod +x gnome-kiosk.sh

    # # katalog autostart – bezpieczne tworzenie
    # mkdir -p "$DEST_AUTOSTART"

    # # plik desktop – tylko jeśli nie istnieje
    # if [ ! -f "$DEST_DESKTOP" ]; then
        # cp gnome-kiosk.desktop "$DEST_AUTOSTART/"
		# echo "skopiowano .desktop"
    # fi
# }

kioskify() {
WALLPAPER_PATH="/usr/share/backgrounds/tapeta_automex.png"
DCONF_DIR="/etc/dconf/db/local.d"

    # Tapeta – tylko jeśli nie istnieje
    if [ ! -f "$WALLPAPER_PATH" ]; then
        cp tapeta_automex.png "$WALLPAPER_PATH"
		echo "skopiowano tapetę do ścieżki systemowej"
    fi
echo "Konfiguracja profilu dconf..."
mkdir -p /etc/dconf/profile
echo -e "user-db:user\nsystem-db:local" > /etc/dconf/profile/user
echo "Tworzenie katalogów..."
mkdir -p "$DCONF_DIR"

echo "Tworzenie konfiguracji dconf..."

cat > "$DCONF_DIR/00-kiosk" <<EOF
[org/gnome/desktop/background]
picture-uri='file://$WALLPAPER_PATH'
picture-uri-dark='file://$WALLPAPER_PATH'
picture-options='fit'

[org/gnome/desktop/session]
idle-delay=uint32 0

[org/gnome/desktop/screensaver]
lock-enabled=false

[org/gnome/settings-daemon/plugins/power]
sleep-inactive-ac-type='nothing'
sleep-inactive-battery-type='nothing'
button-power='nothing'
EOF

echo "Aktualizacja bazy dconf..."
dconf update

echo "Gotowe. Wyloguj użytkownika lub zrestartuj system."

}

# ---------------------------
# MENU
# ---------------------------

show_menu() {
    echo
    echo "=========== MENU ==========="
    echo "1 - Wykonaj wszystko"
    echo "2 - Instalacja pakietów"
    echo "3 - Konfiguracja GRUB"
    echo "4 - Autologowanie"
    echo "5 - Konfiguracja SSH"
    echo "6 - Wyłączenie DE"
    echo "7 - Włączenie DE"
	echo "8 - kioskifikacja"
    echo "0 - Wyjście"
    echo "============================"
}

run_all() {
    run_section "Instalacja pakietów" install_packages
    run_section "Konfiguracja GRUB" configure_grub
    run_section "Autologowanie" configure_autologin
    run_section "Konfiguracja SSH" configure_ssh
	run_section "Kioskifikuj" kioskify
	run_section "Wyłącz DE" disable_de
}

# ---------------------------
# PĘTLA MENU
# ---------------------------

while true; do
    show_menu
    read -rp "Wybierz opcję: " choice

    case "$choice" in
        1)
            run_all
            break
            ;;
        2) run_section "Instalacja pakietów" install_packages ;;
        3) run_section "Konfiguracja GRUB" configure_grub ;;
        4) run_section "Autologowanie" configure_autologin ;;
        5) run_section "Konfiguracja SSH" configure_ssh ;;
        6) run_section "Wyłączenie DE" disable_de ;;
        7) run_section "Włącz DE" enable_de ;;
        8) run_section "Kioskifikuj" kioskify ;;
        0) break ;;
        *) echo "Nieprawidłowa opcja." ;;
    esac
done

# ---------------------------
# PODSUMOWANIE
# ---------------------------

echo
echo "===== PODSUMOWANIE ====="

if [[ ${#EXECUTED_SECTIONS[@]} -eq 0 ]]; then
    echo "Nie wykonano żadnej sekcji."
else
    for section in "${EXECUTED_SECTIONS[@]}"; do
        echo "✔ $section"
    done
fi

echo
echo "Skrypt zakończony."
