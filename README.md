# Sony WH-1000XM4 Hammerspoon mute control

This is a macOS workaround that makes the Sony WH-1000XM4 right-earcup double-tap send **Command+Control+Space** during Teams or Slack calls.

## Why this exists

Outside calls, the headset sends a normal play/pause command and macOS handles it directly. During a call, the headset switches to its Bluetooth hands-free profile and macOS interprets the same gesture as a Siri command.

The Hammerspoon configuration watches for the narrow Bluetooth log signal produced when that headset gesture starts Siri. It then:

1. Sends Command+Control+Space to the foreground app.
2. Hides Siri immediately.
3. Sends one Escape 40 milliseconds later to end Siri cleanly.

The delay was tuned interactively on a Mac with a WH-1000XM4. It produced no error sound in the final test.

## Behavior

- In a call: double-tap toggles mute through Command+Control+Space.
- Outside a call: double-tap keeps its normal play/pause behavior.
- The workaround only runs when the default microphone name contains `WH-1000XM4`.
- A 1.5-second guard prevents one gesture from toggling mute more than once.

## Install

For a clean Mac with no existing Hammerspoon configuration:

```sh
chmod +x install.sh
./install.sh
```

If `~/.hammerspoon/init.lua` already exists, the installer makes a backup and stops instead of overwriting it. Merge this repository's `init.lua` into the existing file, then choose **Reload Config** from the Hammerspoon menu.

Hammerspoon must have macOS Accessibility permission and must remain running. Enable **Launch Hammerspoon at login** in its preferences.

For a model-assisted setup on another Mac, follow [WORK-MAC-INSTALL.md](WORK-MAC-INSTALL.md).

## Configure the Teams mute shortcut

The Hammerspoon configuration sends **Command+Control+Space**, so Teams must use the same combination for **Toggle mute**:

1. Open the Microsoft Teams desktop app.
2. Press **Command+Period (.)** to open **Keyboard shortcuts**.
3. Find **Toggle mute** and choose **Edit shortcut**.
4. Press **Command+Control+Space**, then save the change.
5. Join a test meeting and confirm that Command+Control+Space toggles mute before testing the headset.

The model-assisted work-Mac procedure includes this setup and verification. It uses Teams' own shortcut editor instead of modifying Teams' internal account data.

## Audio feedback through the headphones

In macOS System Settings, open **Sound** and set **Play sound effects through** to `WH-1000XM4`. Teams or Slack should also use the headset for its speaker and microphone.

## Test checklist

1. Disconnect the headset from any phone during the initial test. Multipoint connections can send the gesture to the phone instead of the Mac.
2. Pause Spotify manually. Outside a call, double-tap the right earcup; Spotify should resume.
3. In Teams, first confirm that Command+Control+Space toggles mute. For Slack, confirm the equivalent shortcut is configured.
4. Join a test Teams or Slack call and keep that app in front.
5. Double-tap twice, several seconds apart. Each gesture should toggle mute once, Siri should disappear quickly, and there should be no macOS error sound.

## Notes

- This depends on an undocumented macOS Bluetooth log message and may need adjustment after a macOS update.
- Do not map `NSSystemDefined` subtype `7`; on the tested Mac those events were auxiliary mouse-button events, not the headset.
- The destination shortcut is near the top of `init.lua` in `handleSonyCallGesture()`. Change `{ "cmd", "ctrl" }, "space"` if the work Mac uses a different mute shortcut.
