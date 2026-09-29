# Instructions for a model session on the work Mac

Give the model session the URL of this repository and the prompt below.

## Prompt to paste

> Install and configure the Hammerspoon setup from the GitHub repository I provided. The goal is for a Sony WH-1000XM4 right-earcup double-tap to toggle mute in Teams and Slack, close Siri quickly, and preserve normal play/pause outside calls. Inspect any existing `~/.hammerspoon/init.lua` before changing it. Back it up and merge the repository configuration instead of overwriting unrelated settings. Install Hammerspoon if needed, help me approve the required macOS permissions, enable launch at login, reload the configuration, and test interactively with me. In the Microsoft Teams desktop app, open Keyboard shortcuts with Command+Period, find Toggle mute, edit it to Command+Control+Space, save it, and verify the shortcut in a test meeting. Do this through Teams' supported shortcut editor rather than modifying private Teams data. For Slack, use the desktop app and verify its fixed Command+Shift+Space huddle-mute shortcut; Slack does not support custom keyboard shortcuts, so do not try to remap it. The Hammerspoon configuration detects Slack in the foreground and sends its built-in shortcut automatically. Keep the headset disconnected from my phone during the first test. Do not map `NSSystemDefined` subtype 7 because it may be an auxiliary mouse event. If the Bluetooth trigger differs on this Mac, temporarily inspect the filtered Bluetooth/Siri log, adapt the narrow trigger, and remove the temporary logger after testing. Also set macOS “Play sound effects through” to the WH-1000XM4 so mute feedback is heard in the headphones.

## Expected installation procedure

1. Clone or download this repository on the work Mac.
2. Inspect whether Hammerspoon is installed. If it is not, install it from the official Hammerspoon release or Homebrew.
3. Inspect `~/.hammerspoon/init.lua` before writing.
4. If no configuration exists, run `install.sh` from this repository.
5. If a configuration exists, make a timestamped backup and merge `init.lua` without deleting unrelated settings.
6. Launch Hammerspoon and enable **Launch Hammerspoon at login**.
7. In **System Settings → Privacy & Security → Accessibility**, allow Hammerspoon. If macOS asks for Input Monitoring or access needed to read the filtered system log, approve it as well.
8. Reload the Hammerspoon configuration and confirm the console contains:

   ```text
   XM4_SIRI_REMAP active: Teams Cmd+Ctrl+Space; Slack Cmd+Shift+Space; fast Siri cancel
   ```

9. Open the Microsoft Teams desktop app and press **Command+Period (.)** to open **Keyboard shortcuts**.
10. Find **Toggle mute**, choose **Edit shortcut**, press **Command+Control+Space**, and save the change. If Teams reports a conflict, resolve it in the shortcut editor instead of silently choosing a different combination.
11. Join a Teams test meeting and verify that Command+Control+Space toggles mute from the keyboard. Do not continue to the headset test until this works.
12. Open the Slack desktop app, join a test huddle, and verify its built-in **Command+Shift+Space** shortcut toggles mute. Do not try to assign a custom Slack shortcut because Slack does not support that.
13. In **System Settings → Sound**, set **Play sound effects through** to `WH-1000XM4`.
14. In Teams and Slack, select the WH-1000XM4 for both microphone and speaker.
15. Test normal play/pause outside a call, then test mute in a Teams meeting and a Slack huddle. Keep the relevant app in front and use two headset double-taps several seconds apart.

## Success criteria

- Outside a call, the right-earcup double-tap still plays or pauses media.
- During a Teams or Slack call, each double-tap toggles mute once.
- In Teams, **Toggle mute** is saved as Command+Control+Space and the keyboard shortcut works before the headset is tested.
- In a Slack desktop huddle, the built-in Command+Shift+Space shortcut and the headset double-tap both toggle mute.
- Siri disappears quickly and does not remain listening.
- There is no macOS error sound.
- Mute/unmute feedback is heard through the headphones.
- The setup continues working after restarting Hammerspoon or logging out and back in.

## Troubleshooting boundary

The working setup detects this filtered log text:

```text
Start advertising for process SiriNCService
```

If it is absent on the work Mac, first verify that the headset is the default input device and that it is not simultaneously handling the gesture on a connected phone. Only then capture a short, temporary log around one deliberate double-tap and adjust the narrow trigger. Preserve normal media behavior for all nonmatching events.
