# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Service registry at `config/services.conf` defining each service's unit, icon and label in one place
- Per-user service registry at `~/.config/hyprserv/services.conf`, overriding the bundled one

### Changed
- Waybar status now reads its service list from `config/services.conf`
- Menu and action scripts read their service list from `config/services.conf`

### Fixed
- Status script now declares bash explicitly instead of relying on /bin/sh being bash
- Bulk start/stop no longer stops at the first service that fails
- Scripts locate each other automatically; no more editing a hardcoded path after cloning
- Service names containing quotes or backslashes no longer produce invalid Waybar output

### Security
- The privileged action script now only operates on services declared in the registry

## [0.1.0] - 2025-07-29

### Added
- Waybar status module reporting aggregate dev-service state
- Rofi/wofi toggle menu for starting and stopping services
- Privileged action script driving `systemctl` via `pkexec`
- Start-all and stop-all bulk actions
