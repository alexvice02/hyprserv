# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- Status script now declares bash explicitly instead of relying on /bin/sh being bash
- Bulk start/stop no longer stops at the first service that fails
- Scripts locate each other automatically; no more editing a hardcoded path after cloning

## [0.1.0] - 2025-07-29

### Added
- Waybar status module reporting aggregate dev-service state
- Rofi/wofi toggle menu for starting and stopping services
- Privileged action script driving `systemctl` via `pkexec`
- Start-all and stop-all bulk actions
