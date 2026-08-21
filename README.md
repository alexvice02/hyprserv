# HyprServ

[![CI](https://github.com/alexvice02/hyprserv/actions/workflows/ci.yml/badge.svg)](https://github.com/alexvice02/hyprserv/actions/workflows/ci.yml)

**HyprServ** is a minimalistic tool for developers using Linux (especially with Wayland + Waybar + Hyprland) to monitor and manage local development services directly from your status bar.

It consists of three Bash scripts:
- `dev-status.sh`: displays the current status of selected services (used in Waybar widget)
- `dev-menu.sh`: interactive toggle menu to start/stop services via Rofi | Wofi
- `dev-action.sh`: script for starting/stopping services via `systemctl`

---

## ✨ Features

- ✅ Show real-time status of essential development services (e.g. Docker, PostgreSQL, Apache)
- 🔄 Start/stop services from a convenient dmenu/wofi popup
- 🖥️ Designed for integration with Waybar on Hyprland (but works with any systemd-based distro)
- ⚡ Lightweight — pure Bash with no external dependencies except systemd & dmenu/wofi
- 💡 Easily extendable with custom services, labels, and icons
- 🔍 Tooltip breaks down which tracked services are up and which are down

---

## 🔧 Requirements

- Linux with `systemd`
- Bash
- `waybar`
- `rofi` or `wofi`
- `systemctl` available to the user (via sudo or user services)
- `polkit` for sudo

---

## 🚀 Installation

1. Clone this repository:

```bash
git clone https://github.com/alexvice02/hyprserv.git
cd hyprserv/scripts
chmod +x dev-status.sh dev-action.sh dev-menu.sh
```

2. Copy the scripts somewhere in your $PATH or reference them directly from Waybar config.

3. Update your Waybar config:

```json
{
    "custom/hyprserv": {
        "format": "{icon} dev",
        "format-icons": {
            "running": "",
            "partial": "",
            "stopped": "\uF120"
        },
        "interval": 5,
        "on-click": "/path/to/dev-menu.sh",
        "exec": "/path/to/dev-status.sh",
        "tooltip": true,
        "return-type": "json"
    }
}
```

4. Add styles

```css
#custom-hyprserv {
    padding: 0 10px;
    border-radius: 15px;
}

#custom-hyprserv:hover {
    background: rgba(26, 27, 38, 0.9);
}

#custom-hyprserv.running {
    color: #90ee90;
}

#custom-hyprserv.stopped {
    color: #ff6b6b;
}

#custom-hyprserv.partial {
    color: #ffe46b;
}
```

5. (Optional) Set up a keybinding in Hyprland(hyprland.conf):

```
bind = SUPER + F5, exec, ~/path/to/dev-mode.sh
```

---

## ⚙️ Configuration

Services are declared in `config/services.conf`:

    # unit | icon | label | tracked
    postgresql | <glyph> | PostgreSQL | yes

`tracked = yes` means the service counts toward the bar's running / partial / stopped
state. Untracked services still appear in the menu.

To customise without touching the repo, copy it to
`~/.config/hyprserv/services.conf` — that file wins if present.

**One caveat:** the privileged action script deliberately ignores your personal config
and reads only `/etc/hyprserv/services.conf` (or the bundled default). Root should not
take its list of what-it-may-touch from a file inside `$HOME`. So a service you add
*only* to your user config will show in the menu but be refused when you click it. To
make it actionable, add it to the system config as well.

Services listed in the registry but not installed on the machine are shown in the
tooltip as `· Name (not installed)` and excluded from the running/stopped count, so a
generous default registry doesn't leave the bar permanently amber.
