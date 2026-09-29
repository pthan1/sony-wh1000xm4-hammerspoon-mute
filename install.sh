#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
source_file="$script_dir/init.lua"
target_dir="$HOME/.hammerspoon"
target_file="$target_dir/init.lua"

if ! command -v open >/dev/null 2>&1; then
    echo "This installer must be run on macOS."
    exit 1
fi

if [ ! -d "/Applications/Hammerspoon.app" ]; then
    echo "Hammerspoon is not installed in /Applications. Install it first, then run this script again."
    exit 1
fi

mkdir -p "$target_dir"

if [ -f "$target_file" ]; then
    if cmp -s "$source_file" "$target_file"; then
        echo "The WH-1000XM4 configuration is already installed."
        open -a Hammerspoon
        exit 0
    fi

    backup_file="$target_file.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$target_file" "$backup_file"
    echo "An existing Hammerspoon configuration was found."
    echo "Backup created at: $backup_file"
    echo "No file was overwritten. Merge init.lua from this repository into $target_file, then reload Hammerspoon."
    exit 2
fi

cp "$source_file" "$target_file"
open -a Hammerspoon

echo "Installed the WH-1000XM4 configuration at $target_file"
echo "Grant Hammerspoon Accessibility permission, enable launch at login, and reload its configuration."
echo "Then open Teams, press Command+Period, edit Toggle mute to Command+Control+Space, save it, and test the shortcut in a meeting."
echo "In the Slack desktop app, join a huddle and test its built-in Command+Shift+Space mute shortcut; Slack does not support custom shortcuts."
