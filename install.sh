#!/usr/bin/env bash
set -euo pipefail

# ── colors ──
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
M='\033[0;35m'
C='\033[0;36m'
W='\033[1;37m'
D='\033[0;90m'
N='\033[0m'

ok()  { echo -e "  ${G}✓${N} $1"; }
warn(){ echo -e "  ${Y}!${N} $1"; }
err() { echo -e "  ${R}✗${N} $1"; }
info(){ echo -e "  ${C}→${N} $1"; }

# ── paths ──
DOTDIR="$(cd "$(dirname "$0")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
LOCAL_BIN="$HOME/.local/bin"

# ── ascii logo ──
logo() {
  echo -e "${M}╔═════════════════════════════════════════════════════════════════╗"
  echo -e "${M}║${W}  ███╗   ███╗ █████╗ ██╗  ██╗██████╗  ██████╗ ████████╗███████╗ ${M}║"
  echo -e "${M}║${W}  ████╗ ████║██╔══██╗╚██╗██╔╝██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝ ${M}║"
  echo -e "${M}║${W}  ██╔████╔██║███████║ ╚███╔╝ ██║  ██║██║   ██║   ██║   ███████╗ ${M}║"
  echo -e "${M}║${W}  ██║╚██╔╝██║██╔══██║ ██╔██╗ ██║  ██║██║   ██║   ██║   ╚════██║ ${M}║"
  echo -e "${M}║${W}  ██║ ╚═╝ ██║██║  ██║██╔╝ ██╗██████╔╝╚██████╔╝   ██║   ███████║ ${M}║"
  echo -e "${M}║${W}  ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝    ╚═╝   ╚══════╝ ${M}║"
  echo -e "${M}║${D}        hyprland · waybar · kitty · nvim · and more              ${M}║"
  echo -e "${M}╚═════════════════════════════════════════════════════════════════╝${N}"
}

# ── helpers ──

aur_helper() {
  if command -v yay &>/dev/null; then echo yay
  elif command -v paru &>/dev/null; then echo paru
  else echo ""
  fi
}

confirm() {
  echo -en "  ${Y}?${N} $1 ${D}[y/N]${N} "
  read -r ans
  [[ "$ans" =~ ^[yY] ]]
}

pause() {
  echo -en "  ${D}press Enter to continue...${N}"
  read -r
}

clear_screen() { printf "\033[2J\033[H"; }

# ── install steps ──

install_packages() {
  clear_screen
  logo
  echo -e "\n${W}  Package Installation${N}\n"

  local helper
  helper=$(aur_helper)
  if [[ -z "$helper" ]]; then
    warn "no AUR helper found (install yay or paru first)"
    pause
    return
  fi

  local core=(hyprland waybar kitty neovim dunst wofi wlogout pyprland hypridle
              swaync swayosd-git hyprshot swappy grim)
  local tools=(starship zoxide fzf fastfetch bottom htop cava fuzzel thunar
               waypaper wtype python python-gobject wl-clipboard imagemagick awww)

  echo -e "${W}  core packages${N}"
  if confirm "install core packages?"; then
    "$helper" -S --needed "${core[@]}"
    ok "core packages installed"
  fi

  echo
  echo -e "${W}  shell & tools${N}"
  if confirm "install shell & tools?"; then
    "$helper" -S --needed "${tools[@]}"
    ok "tools installed"
  fi

  local extras=()
  echo
  echo -e "${W}  optional extras${N}"
  confirm "install spotify (spicetify)?" && extras+=(spotify spicetify-cli)
  confirm "install vscode?" && extras+=(visual-studio-code-bin)
  confirm "install discord?" && extras+=(discord)
  confirm "install zen-browser?" && extras+=(zen-browser-bin)
  if [[ ${#extras[@]} -gt 0 ]]; then
    "$helper" -S --needed "${extras[@]}"
    ok "extras installed"
  fi
  pause
}

install_configs() {
  clear_screen
  logo
  echo -e "\n${W}  Config Installation${N}\n"
  echo -e "  ${D}this will symlink configs from the repo to ~/.config/${N}\n"

  if ! confirm "proceed with symlinking?"; then
    return
  fi

  local method="ln"
  if command -v stow &>/dev/null && confirm "use stow (more control)?"; then
    method="stow"
  fi

  local dirs=(bottom cava clock-rs dunst fuzzel gtk-3.0 gtk-4.0 htop hypr
              kitty nvim nwg-look pypr swaync waybar waypaper wlogout wofi
              xsettingsd)

  if [[ "$method" == "stow" ]]; then
    cd "$DOTDIR"
    stow -t "$HOME" .
    ok "all configs symlinked via stow"
  else
    for d in "${dirs[@]}"; do
      local src="$DOTDIR/.config/$d"
      local dst="$XDG_CONFIG_HOME/$d"
      if [[ -d "$src" ]]; then
        if [[ -e "$dst" ]] && [[ ! -L "$dst" ]]; then
          warn " backing up existing $d → ${d}.bak"
          mv "$dst" "${dst}.bak"
        fi
        ln -sfn "$src" "$dst"
        ok "linked $d"
      fi
    done
    local dotfiles=(.bashrc .bash_profile .gitconfig .gtkrc-2.0)
    for f in "${dotfiles[@]}"; do
      local sf="$DOTDIR/$f"
      if [[ -f "$sf" ]]; then
        ln -sf "$sf" "$HOME/$f"
        ok "linked $f"
      fi
    done
    mkdir -p "$LOCAL_BIN"
    for f in "$DOTDIR"/.local/bin/*; do
      ln -sf "$f" "$LOCAL_BIN/$(basename "$f")"
      ok "linked .local/bin/$(basename "$f")"
    done
  fi

  echo
  info "configs installed. you may want to reboot or restart hyprland."
  pause
}

install_wallpapers() {
  clear_screen
  logo
  echo -e "\n${W}  Wallpaper Installation${N}\n"

  local wp_src="$DOTDIR/wallpapers"
  local wp_dst="$HOME/wallpapers"

  if [[ ! -d "$wp_src" ]]; then
    warn "no wallpapers directory found in repo"
    pause
    return
  fi

  if [[ -L "$wp_dst" ]] || [[ -d "$wp_dst" ]]; then
    ok "wallpapers already exist at $wp_dst"
  else
    ln -sf "$wp_src" "$wp_dst"
    ok "symlinked wallpapers → $wp_dst"
  fi

  local count
  count=$(find "$wp_src" -type f | wc -l)
  info "$count wallpapers available"

  if confirm "set a random wallpaper now?"; then
    if command -v awww &>/dev/null; then
      awww set "$(find "$wp_src" -type f | shuf -n1)"
      ok "wallpaper set"
    elif command -v swaybg &>/dev/null; then
      warn "awww not found; install it or set wallpaper manually"
    fi
  fi
  pause
}

install_fonts() {
  clear_screen
  logo
  echo -e "\n${W}  Font Installation${N}\n"

  local font_dir="$XDG_DATA_HOME/fonts"
  mkdir -p "$font_dir"

  if [[ -f "$font_dir/wqy-microhei.ttc" ]]; then
    ok "wqy-microhei already installed"
  else
    info "downloading wqy-microhei CJK font..."
    curl -L -o /tmp/wqy-microhei.pkg.tar.zst \
      "https://archive.archlinux.org/packages/w/wqy-microhei/wqy-microhei-0.2.0_beta-10-any.pkg.tar.zst"
    tar --zstd -xf /tmp/wqy-microhei.pkg.tar.zst -C /tmp/
    cp /tmp/usr/share/fonts/wenquanyi/wqy-microhei/wqy-microhei.ttc "$font_dir/"
    rm -rf /tmp/wqy-microhei.pkg.tar.zst /tmp/usr/share/fonts
    ok "wqy-microhei installed"
  fi

  local nerd_fonts=false
  local nerd_src="$DOTDIR/fonts"
  if [[ -d "$nerd_src" ]]; then
    cp -r "$nerd_src"/* "$font_dir/"
    ok "copied fonts from repo"
    nerd_fonts=true
  fi

  fc-cache -f
  ok "font cache rebuilt"

  info "nerd fonts may need manual install:"
  echo -e "  ${D}  CodeNewRoman Nerd Font → https://www.nerdfonts.com/${N}"
  echo -e "  ${D}  Hurmit Nerd Font       → https://www.nerdfonts.com/${N}"
  pause
}

select_waybar_theme() {
  clear_screen
  logo
  echo -e "\n${W}  Waybar Theme Selector${N}\n"

  local themes_dir="$DOTDIR/.config/waybar/themes"
  if [[ ! -d "$themes_dir" ]]; then
    warn "no themes directory found"
    pause
    return
  fi

  local themes=()
  for t in "$themes_dir"/*/; do
    themes+=("$(basename "$t")")
  done

  if [[ ${#themes[@]} -eq 0 ]]; then
    warn "no themes found"
    pause
    return
  fi

  PS3="  enter number: "
  select theme in "${themes[@]}"; do
    if [[ -n "$theme" ]]; then
      local style="$themes_dir/$theme/style-$theme.css"
      local cfg="$themes_dir/$theme/config-$theme"
      if [[ -f "$style" ]] && [[ -f "$cfg" ]]; then
        cp "$style" "$XDG_CONFIG_HOME/waybar/style.css"
        cp "$cfg" "$XDG_CONFIG_HOME/waybar/config"
        ok "theme '$theme' applied"
        if confirm "restart waybar now?"; then
          pkill waybar 2>/dev/null || true
          waybar &
          ok "waybar restarted"
        fi
      else
        warn "theme '$theme' has incomplete files"
      fi
      break
    fi
  done
  pause
}

show_about() {
  clear_screen
  logo
  echo -e "\n${W}  about maxdots${N}\n"
  echo -e "  ${C}version:${N}  1.0.0"
  echo -e "  ${C}author:${N}   Maxye4655"
  echo -e "  ${C}repo:${N}     https://github.com/Maxye4655/maxdots"
  echo -e "  ${C}wm:${N}       hyprland"
  echo -e "  ${C}shell:${N}    bash"
  echo -e "  ${C}term:${N}     kitty"
  echo -e "  ${C}editor:${N}   neovim"
  echo
  echo -e "  ${D}maxdots is a personal linux config focused on a cohesive,${N}"
  echo -e "  ${D}visually consistent experience. everything is themed via${N}"
  echo -e "  ${D}pywal dynamic colors — from the wm to the terminal to the${N}"
  echo -e "  ${D}notification center.${N}"
  echo
  pause
}

# ── main ──

main_menu() {
  while true; do
    clear_screen
    logo
    echo ""
    echo -e "  ${W}MAXDOTS INSTALLER${N}"
    echo -e "  ${D}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo ""
    echo -e "  ${W}1${N}  full install  ${D}(everything)${N}"
    echo -e "  ${W}2${N}  install packages"
    echo -e "  ${W}3${N}  install configs  ${D}(symlink)${N}"
    echo -e "  ${W}4${N}  install wallpapers"
    echo -e "  ${W}5${N}  install fonts"
    echo -e "  ${W}6${N}  select waybar theme"
    echo -e "  ${W}7${N}  about"
    echo -e "  ${W}0${N}  exit"
    echo ""
    echo -en "  ${Y}→${N} choose: "
    read -r opt
    case "$opt" in
      1)
        install_packages
        install_configs
        install_wallpapers
        install_fonts
        echo
        ok "full install complete!"
        echo -e "  ${D}restart hyprland or log out to apply everything.${N}"
        pause
        ;;
      2) install_packages ;;
      3) install_configs ;;
      4) install_wallpapers ;;
      5) install_fonts ;;
      6) select_waybar_theme ;;
      7) show_about ;;
      0) clear_screen; exit 0 ;;
      *) ;;
    esac
  done
}

# ── entry ──
main_menu
