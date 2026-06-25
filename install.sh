#!/bin/bash

DEPS_PKGS=(base-devel git)
CORE_PKGS=(hyprland xdg-desktop-portal-hyprland qt5-wayland qt6-wayland xorg-xwayland)
AUDIO_PKGS=(pipewire pipewire-alsa pipewire-pulse wireplumber pamixer)
UTILS_PKGS=(waybar kitty grim slurp wl-clipboard stow nautilus)
AUR_PKGS=(swww rofi-lbonn-wayland-git hyprlock hypridle)
AUR_HELPERS=(paru yay)
REINTENTOS=3
AUR_HELPER=""
DOTFILES_DIR="$HOME/dotfiles/config"
CONFIG_DIR="$HOME/.config"

if ! sudo -v; then
	echo "error de autorización, vuelve a ejecutar el script"
	exit 1
fi

while true; do
	sudo -n true
	sleep 60
	kill -0 "$$" 2>/dev/null || exit
done &

###############################
#    FUNCIONES FUNCIONALES    #
###############################

is_installed() {
	pacman -Qq "$1" &> /dev/null
}

install() {
	case "$1" in
		pacman)
		echo "instalando $2"
		sudo pacman -S "$2" --noconfirm
		;;
		yay|paru)
		$1 -S "$2" --noconfirm
		;;
		*)
		return 1
		;;
	esac
}

install_loop() {
	for package in "${@:2}"; do
		if ! is_installed "$package"; then
			if install "$1" "$package"; then
				echo "$package instalado correctamente"
			else
				echo "reintentando"
				for try in $(seq 1 $REINTENTOS); do
					sleep 1
					if install "$1" "$package"; then
						echo "$package instalado correctamente luego de $try intentos"
						break
					fi
					echo "falló el intento $try, reintentando..."
					if [[ "$try" -eq "$REINTENTOS" ]]; then
						echo "error al instalar $package, abortando"
						exit 1
					fi
				done
			fi
		else
			echo "$package ya ha sido instalado"
		fi
	done
}

link_config() {
	local origen="$1"
	local destino="$2"

	if [ -L "$destino" ]; then
		rm "$destino"
	elif [ -e "$destino" ]; then
		echo "Hay un archivo existente en $destino, creando backup..."
		mv "$destino" "$destino_$(date "+%a-%d_%h_%H-%M-%S-%N").bak"
	fi

	mkdir -p "$(dirname "$destino")"

	ln -s "$origen" "$destino"
	echo "enlace creado $destino -> $origen"
}

##############################
#       INICIO INICIAL       #
##############################

echo "instalando dependencias del script..."
install_loop "pacman" "${DEPS_PKGS[@]}"

echo "Cual AUR helper prefieres usar?"
echo "1) Yay"
echo "2) Paru"
read opcion

case "$opcion" in
	1)
	if ! is_installed "yay"; then
		echo "instalando Yay"
		git clone https://aur.archlinux.org/yay.git && (cd yay && makepkg -si)
	else
		echo "Yay ya está instalado"
	fi
	AUR_HELPER=yay
	;;
	2)
	if ! is_installed "paru"; then
		echo "instalando Paru"
		git clone https://aur.archlinux.org/paru.git && (cd paru && makepkg -si)
	else
		echo "Paru ya está instalado"
	fi
	AUR_HELPER=paru
	;;
	*)
	echo "esa opción no existe, abortando"
	exit 1
	;;
esac

echo "instalando paquetes escenciales"
install_loop "pacman" "${CORE_PKGS[@]}"

echo "instalando paquetes de utilidades generales"
install_loop "pacman" "${UTILS_PKGS[@]}"

###############################
# ENLAZAMIENTO DE LAS CONFIGS #
###############################

link_config "$DOTFILES_DIR/hypr" "$CONFIG_DIR/hypr"
