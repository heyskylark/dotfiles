#!/bin/sh
# Warning: This will work for skylark only!
# Run as regular user, not root!
# Before proceeding you need to restore SSH and GPG keys.
# SSH config must point to the GitHub's private key.

# Function to ask for user confirmation
confirm() {
	PROMPT="$1"
	while true; do
		echo "$PROMPT [y/n]"
		read -r response
		case $response in
			[Yy]*) return 0 ;;
			[Nn]*) return 1 ;;
			*) echo "$PROMPT [y/n]" ;;
		esac
	done
}

REPO="$HOME/dotfiles"

if [ -d "$REPO" ]; then
	echo "Dotfiles repo already exists."
	confirm "Do you want to proceed?" || exit
else
	# enable colors for pacman
	sudo sed -i 's/#Color/Color/' /etc/pacman.conf
	# install git and openssh to clone repo via git ssh
	# base-devel is for yay setup
	sudo pacman --needed --noconfirm -Sy git openssh base-devel
	# make sure that key permissions are correct
	chmod 600 ~/key/ssh/*
	# clone repo
	git clone --bare git@github.com:heyskylark/dotfiles.git || exit 1
	# configure work tree path
	git --git-dir="$REPO" --work-tree="$HOME" config --local core.worktree "$HOME"
	# checkout files into $HOME
	git --git-dir="$REPO" --work-tree="$HOME" checkout -f
	# enable GPG sign for dotfiles repo (commit signature verification)
	~/.local/bin/github-enable-gpg
	# set custom gitingore path
	git --git-dir="$REPO" --work-tree="$HOME" config --local core.excludesFile "$HOME/dotfiles.gitignore"
fi

# install yay if not installed
if ! command -v yay; then
	# install yay
	git clone https://aur.archlinux.org/yay.git
	cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
	yay -Y --gendb
fi

pkglist_file1="$HOME/pkglist-intel.txt"
pkglist_file2="$HOME/pkglist-nvidia.txt"
pkglist_file3="$HOME/pkglist-nvidia-xorg.txt"

echo "Available package lists:"
echo "1) $pkglist_file1"
echo "2) $pkglist_file2"
echo "3) $pkglist_file3"
echo "Please select a package list (1-3):"

# Read user input
read selection

# Determine the selected file
case "$selection" in
    1) PKG_FILE="$pkglist_file1" ;;
    2) PKG_FILE="$pkglist_file2" ;;
    3) PKG_FILE="$pkglist_file3" ;;
    *) echo "Invalid selection. Exiting." >&2; exit 1 ;;
esac

confirm "Do you want to install packages from $PKG_FILE?" || exit

# install packages
# Note: --noconfirm can't be used, because you need to resolve conflicts
# use /tmp/yay as build directory
mkdir -p /tmp/yay
# repeat command until it succeeds
until yay -S --builddir /tmp/yay --needed --cleanmenu=false --diffmenu=false --editmenu=false --removemake=false - < "$PKG_FILE"; do
	echo "Failed to install packages."
	confirm "Do you want to retry?" || exit
	yay -Syu
done

echo "Packages installed successfully."

echo "Installing ohmyzsh..."
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/main/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/tom-doerr/zsh_codex.git ~/.oh-my-zsh/custom/plugins/zsh_codex

# gtk theme options
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gtk.Settings.FileChooser startup-mode cwd
gsettings set org.gtk.gtk4.Settings.FileChooser startup-mode cwd
# gtk cursor and icon themes
gsettings set org.gnome.desktop.interface cursor-theme BreezeX-RosePine-Linux
gsettings set org.gnome.desktop.interface icon-theme 'bloom-classic'
gsettings set org.gnome.desktop.interface cursor-size 32

echo "Done. Consider re-login or reboot to apply all changes."

