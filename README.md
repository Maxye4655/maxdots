<img src="https://img.shields.io/badge/OS-Arch_Linux-blue?style=flat-square&logo=arch-linux" alt="OS">
<img src="https://img.shields.io/badge/WM-Hyprland-6d8dbe?style=flat-square&logo=hyprland" alt="WM">
<img src="https://img.shields.io/badge/Shell-Bash-4EAA25?style=flat-square&logo=gnu-bash" alt="Shell">
<img src="https://img.shields.io/badge/Editor-Neovim-57A143?style=flat-square&logo=neovim" alt="Editor">

# maxdots

my personal linux config — hyprland, waybar, kitty, nvim, and everything else i touch daily.

## contents

| thing                                  | what                                                  |
| -------------------------------------- | ----------------------------------------------------- |
| `.bashrc`, `.bash_profile`             | shell setup — starship, zoxide, fzf                   |
| `.gitconfig`                           | git identity & gh credential helper                   |
| `.config/hypr/`                        | hyprland wm config, keybinds, window rules            |
| `.config/waybar/`                      | status bar with 4 themes                              |
| `.config/kitty/`                       | terminal emulator config                              |
| `.config/nvim/`                        | neovim setup with lazy.nvim, lsp, treesitter, copilot |
| `.config/dunst/`                       | notification daemon                                   |
| `.config/wofi/`                        | app launcher                                          |
| `.config/wlogout/`                     | logout/lock screen                                    |
| `.config/swaync/`                      | notification center                                   |
| `.config/pypr/`                        | hyprland layout engine                                |
| `.config/fuzzel/`                      | app launcher (alt)                                    |
| `.config/cava/`                        | audio visualizer                                      |
| `.config/bottom/`                      | system monitor                                        |
| `.config/htop/`                        | process viewer                                        |
| `.config/gtk-3.0/`, `.config/gtk-4.0/` | gtk theme overrides                                   |
| `.config/clock-rs/`                    | lockscreen clock                                      |
| `.config/dunst/`                       | notification daemon                                   |
| `.local/bin/drip`                      | realistic text typer for wayland                      |

## screenshots

![desktop](https://github.com/user-attachments/assets/screenshots/desktop.png)

_(screenshot placeholder — add one!)_

## usage

```bash
git clone https://github.com/Maxye4655/maxdots.git ~/maxdots
```

symlink what you want:

```bash
stow -t ~ -d ~/maxdots .
```

or cherry-pick with ln:

```bash
ln -sf ~/maxdots/.config/hypr ~/.config/hypr
ln -sf ~/maxdots/.config/kitty ~/.config/kitty
```
