# HyprServ

**HyprServ** is a minimalistic tool for developers using Linux (especially with Wayland + Waybar + Hyprland) to monitor and manage local development services directly from your status bar.

It consists of two simple Bash scripts:
- `dev-status.sh`: displays the current status of selected services (used in Waybar widget)
- `dev-mode.sh`: interactive toggle menu to start/stop services via Wofi

---

## ✨ Features

- ✅ Show real-time status of essential development services (e.g. Docker, PostgreSQL, Apache)
- 🔄 Start/stop services from a convenient dmenu/wofi popup
- 🖥️ Designed for integration with Waybar on Hyprland (but works with any systemd-based distro)
- ⚡ Lightweight — pure Bash with no external dependencies except systemd & dmenu/wofi
- 💡 Easily extendable with custom services, labels, and icons

---

## 🔧 Requirements

- Linux with `systemd`
- Bash
- `waybar`
- `wofi` (or `rofi`, with minor modifications)
- `systemctl` available to the user (via sudo or user services)
- `polkit`

---

## 🚀 Installation

1. Clone this repository:

```bash
git clone https://github.com/alexvice02/hyprserv.git
cd hyprserv/scripts
chmod +x dev-status.sh dev-mode.sh
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
        "on-click": "/path/to/dev-mode.sh",
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
