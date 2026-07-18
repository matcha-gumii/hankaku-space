# Hankaku Space

[日本語](README.md) | [English](README_EN.md)

Hankaku Space is a macOS menu bar app that lets you enter a half-width space by simply pressing `Space`, even while using a Japanese input method.

It reduces the need to switch between Japanese and alphanumeric input, while leaving modified Space key presses and spaces entered during alphanumeric input unchanged.

## Features

- Converts an unmodified `Space` press to a half-width space during Japanese input
- Leaves Space unchanged during English or alphanumeric input
- Leaves Space unchanged when used with Shift, Command, Option, Control, or Fn
- Lets you turn conversion on or off instantly from the menu bar
- Shows the current input source, permission status, and monitoring status
- Can launch automatically when you log in to your Mac
- Pauses conversion while Secure Input is active

## Privacy

Hankaku Space does not store or transmit the keys you type.

- No network communication
- No key input logging
- No external libraries
- No VirtualHID or kernel extensions
- Keeps up to 100 status log entries in memory only

## System Requirements

- macOS 26 Tahoe or later
- Mac with Apple silicon (M1 or later, arm64)

Intel Macs and macOS 25 or earlier are not currently supported.

## Download

Once distribution begins, you can download `HankakuSpace.dmg` from the latest GitHub Release.

> The current beta release is not signed with a Developer ID certificate or notarized by Apple. macOS may display a security prompt when you launch it for the first time.

## Installation

1. Double-click `HankakuSpace.dmg` to open it.
2. Drag `HankakuSpace` into the `Applications` folder shown in the same window.
3. Eject the DMG after the copy finishes.
4. Open Hankaku Space from the Applications folder in Finder.

### If macOS blocks the app from opening

1. Open System Settings.
2. Select Privacy & Security.
3. Find the message about Hankaku Space and select Open Anyway.
4. Select Open again in the confirmation dialog.

If the warning says the app is damaged and cannot be opened, rather than saying that the developer cannot be verified, do not bypass the warning. Please report it in an Issue.

## First-Time Setup

Hankaku Space requires macOS Accessibility permission to transform keyboard events.

1. Select Request Permission on the welcome screen.
2. Open System Settings > Privacy & Security > Accessibility.
3. Allow Hankaku Space.
4. Quit Hankaku Space once, then relaunch it from the Applications folder.

When the app is working correctly, `H` appears in the menu bar and the menu shows the following status:

- Accessibility: Granted
- Monitoring

### If the app does not work after permission is granted

The old permission entry may remain after updating the app.

1. Quit Hankaku Space.
2. In the Accessibility list in System Settings, select Hankaku Space and remove it with the `−` button.
3. Select `+` and add the current copy of Hankaku Space from the Applications folder.
4. Allow Hankaku Space and relaunch the app.

## Usage

Hankaku Space does not appear in the Dock. It stays in the menu bar.

- `H`: Conversion is enabled
- `H–`: Conversion is disabled
- `H!`: Accessibility permission is required

Click the menu bar item to turn conversion on or off, view the input source, permission status, and monitoring status, enable launch at login, open Settings, or quit the app.

### Conversion Rules

| State | Behavior |
| --- | --- |
| Japanese input + unmodified Space | Converts to a half-width space |
| English or alphanumeric input + Space | No change |
| Shift + Space | No change |
| Command, Option, Control, or Fn + Space | No change |
| Secure Input is active | No change |
| Conversion is off | No keys are changed |

## Updating

1. Select Quit from the Hankaku Space menu bar menu.
2. Open the new DMG.
3. Drag Hankaku Space into Applications.
4. Select Replace in the confirmation dialog.
5. Launch the app.

If conversion does not work after updating, remove the old entry from the Accessibility list and add the current app again.

## Uninstallation

1. Turn off Launch at Login if it is enabled.
2. Quit Hankaku Space from the menu bar.
3. Move `HankakuSpace.app` from the Applications folder to the Trash.
4. Remove Hankaku Space from the Accessibility list in System Settings.

To remove the saved preferences as well, run the following command in Terminal:

```zsh
defaults delete jp.local.HankakuSpace
```

## Known Limitations

- The app recognizes Apple's built-in Japanese input method and common IMEs whose input source IDs contain Japanese, Kotoeri, ATOK, or GoogleJapaneseInput.
- IMEs that use a custom input source ID may require additional support.
- macOS may require Accessibility permission to be registered again when the app's signature or location changes.
- The current release is not signed with a Developer ID certificate or notarized by Apple.

## For Developers

### Requirements

- macOS 26 or later
- Apple silicon
- Xcode 26 or later

### Build

```zsh
chmod +x scripts/*.sh
./scripts/build_release.sh
```

Generated app:

```text
build/DerivedData/Build/Products/Release/HankakuSpace.app
```

### Create a DMG

```zsh
./scripts/create_dmg.sh
```

Generated DMG:

```text
dist/HankakuSpace.dmg
```

The current scripts use ad hoc code signing for local testing. For formal distribution, replace it with signing using a Developer ID Application certificate, notarization, and stapling.

## License

This project is available under the [MIT License](LICENSE).

Copyright (c) 2026 Matcha Gumii
