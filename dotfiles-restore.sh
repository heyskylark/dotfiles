#!/usr/bin/env bash
set -Eeuo pipefail

# Post-install bootstrap for an existing Arch Linux installation.
# Run as the target user; the script uses sudo only for pacman.

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/heyskylark/dotfiles.git}"
REPO_DIR="${DOTFILES_REPO_DIR:-$HOME/dotfiles}"
PACKAGE_LIST="${1:-$HOME/pkglist-nvidia.txt}"
BACKUP_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backup"

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

dotgit() {
  git --git-dir="$REPO_DIR" --work-tree="$HOME" "$@"
}

clone_if_missing() {
  local url=$1
  local destination=$2

  if [[ -d "$destination/.git" ]]; then
    return
  fi
  if [[ -e "$destination" ]]; then
    printf 'warning: leaving existing non-Git path untouched: %s\n' "$destination" >&2
    return
  fi

  git clone --depth 1 "$url" "$destination"
}

bootstrap_dotfiles() {
  local backup_dir path

  if [[ -d "$REPO_DIR" ]]; then
    dotgit rev-parse --git-dir >/dev/null 2>&1 ||
      die "$REPO_DIR exists but is not the dotfiles Git directory"
  else
    git clone --bare "$REPO_URL" "$REPO_DIR"

    backup_dir="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
    while IFS= read -r -d '' path; do
      if [[ -e "$HOME/$path" || -L "$HOME/$path" ]]; then
        mkdir -p "$backup_dir/$(dirname "$path")"
        mv "$HOME/$path" "$backup_dir/$path"
      fi
    done < <(dotgit ls-tree -rz --name-only HEAD)

    dotgit checkout
    if [[ -d "$backup_dir" ]]; then
      printf 'Existing files backed up under %s\n' "$backup_dir"
    fi
  fi

  dotgit config --local status.showUntrackedFiles yes
  if dotgit config --local --get-all core.excludesFile >/dev/null; then
    dotgit config --local --unset-all core.excludesFile
  fi
}

install_yay() {
  local build_root

  if command -v yay >/dev/null 2>&1; then
    return
  fi

  build_root=$(mktemp -d)
  trap 'rm -rf -- "$build_root"' EXIT
  git clone --depth 1 https://aur.archlinux.org/yay.git "$build_root/yay"
  (
    cd "$build_root/yay"
    makepkg -si --needed --noconfirm
  )
  rm -rf -- "$build_root"
  trap - EXIT
}

install_packages() {
  local -a packages

  [[ -r "$PACKAGE_LIST" ]] || die "package list is not readable: $PACKAGE_LIST"
  mapfile -t packages < <(sed -E '/^[[:space:]]*(#|$)/d' "$PACKAGE_LIST")
  ((${#packages[@]} > 0)) || die "package list is empty: $PACKAGE_LIST"

  yay -S --needed -- "${packages[@]}"
}

install_shell_files() {
  local custom_dir="$HOME/.oh-my-zsh/custom"

  clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  clone_if_missing https://github.com/romkatv/powerlevel10k.git \
    "$custom_dir/themes/powerlevel10k"
  clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git \
    "$custom_dir/plugins/zsh-autosuggestions"
  clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$custom_dir/plugins/zsh-syntax-highlighting"
}

main() {
  ((EUID != 0)) || die "run this script as your regular user, not root"
  command -v pacman >/dev/null 2>&1 || die "this bootstrap supports Arch Linux only"
  command -v sudo >/dev/null 2>&1 || die "sudo is required"

  sudo -v
  sudo pacman -Syu --needed git base-devel

  bootstrap_dotfiles
  install_yay
  install_packages
  install_shell_files

  printf '\nBootstrap complete.\n'
  printf 'Manual checks:\n'
  printf '  - Run: chsh -s %s\n' "$(command -v zsh)"
  printf '  - Run: gh auth login (for HTTPS Git pushes)\n'
  printf '  - Enable only the system services this machine needs.\n'
  printf '  - Put machine-local secrets in ~/.config/dotfiles/private.zsh.\n'
  printf 'Log out or reboot after configuring services and the login shell.\n'
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  main "$@"
fi
