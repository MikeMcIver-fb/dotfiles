#!/bin/sh
set -ex

GITHUB_USERNAME="Carlton-Perkins"

# If nix is installed use nixdotfiles instead
echo "[CHECK] Is Nix installed?"
if command -v nix &>/dev/null; then
  echo "[SETUP] Nix dotfiles"
  gh repo clone Carlton-Perkins/nix-dotfiles ~/nix-dotfiles
  cd ~/nix-dotfiles

  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update

  nix-shell '<home-manager>' -A install
  home-manager switch --flake ./

  echo "[INSTALL] Nix dotfiles complete"
  exit 0
fi

echo "[INSTALL] Ohmyzsh"
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

echo "[INSTALL] Powerlevel10k"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo "[INSTALL] cargo-binstall"
curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

echo "[INSTALL] cargo deps"
cargo binstall -y bat du-dust bandwhich fd-find ripgrep exa git-delta

echo "[INSTALL] Chezmoi"
export BINDIR=$HOME/.local/bin
sh -c "$(curl -fsLS chezmoi.io/get)"

echo "[SETUP] Chezmoi"
$BINDIR/chezmoi init $GITHUB_USERNAME

echo "[APPLY] apply dotfiles"
$BINDIR/chezmoi apply
