# macOS Battery for KDE Plasma 6

A macOS-style battery widget for Plasma 6, with the percent on the glyph, connected devices, power profiles, and a sleep-block toggle.

Fork of [rifkiaz/macos-battery-kde](https://github.com/rifkiaz/macos-battery-kde) (v1.1.2), updated for Plasma 6.7's battery APIs. The panel glyph is the same drawing. The popup talks to the same private plugins as stock Power & Battery.

![Preview](docs/preview.png)

*Preview. Font and colors follow your Plasma theme.*

## Features

- Thin macOS battery outline, nub on the right, fill that tracks charge.
- Percent **inside** the battery (knockout where it overlaps the fill), to the **left** or **right**, or hidden.
- Height, width, and percent text size are adjustable.
- Green while charging, red when low (can be turned off), lightning bolt while charging.
- Popup: large percent, remaining time with pack health in brackets when UPower reports it (`2 h 10 min remaining (82% health)`), power source, and other batteries (mouse, keyboard, headset, and so on). Device health sits next to that row's percent when the device publishes it.
- Power profile slider: Power Save, Balanced, Performance. Scroll the panel icon to change it.
- Sleep-block switch, plus apps that are blocking sleep or screen locking, with Unblock / Allow.
- Middle-click the panel icon to block or allow sleep. A small crescent sits on the battery nub while that block is on.
- Horizontal or vertical panel, or the desktop.
- Follows Plasma light and dark themes.

## Compatibility

- **KDE Plasma 6.2+** (Qt 6). Tested on Plasma 6.7. Not for Plasma 5.
- Pure QML. No C++ to compile. Runs on Plasma 6 distros: openSUSE Tumbleweed, openSUSE Leap 16, Fedora KDE, Arch, KDE neon, Kubuntu 24.10+, Debian 13, and others.
- Battery, inhibitions, and power profiles come from the same plugins as the stock applet: `org.kde.plasma.private.battery` (`BatteryControlModel`) and `org.kde.plasma.private.batterymonitor` (`InhibitionControl`, `PowerProfilesControl`).

openSUSE Leap 15.x is still Plasma 5, so this widget needs Leap 16 or Tumbleweed.

## Install

### From a `.plasmoid` file

1. Download `macos-battery-<version>.plasmoid`, or build one with `./build.sh`.
2. Right-click the desktop or panel, **Add Widgets…**
3. **Get New…** → **Install Widget From Local File…**, pick the `.plasmoid`.
4. Search for **macOS Battery** and drag it onto the panel or desktop.

Or from a terminal:

```bash
kpackagetool6 --type Plasma/Applet --install macos-battery-1.2.4.plasmoid
```

### From source

```bash
git clone https://github.com/shubham-cpp/macos-battery-kde.git
cd macos-battery-kde
./install.sh
```

`install.sh` upgrades if the widget is already installed. If `kpackagetool6` is missing:

| Distro | Command |
| --- | --- |
| openSUSE Tumbleweed / Leap 16 | `sudo zypper install kf6-kpackage` |
| Fedora | `sudo dnf install kf6-kpackage` |
| Arch / Manjaro | `sudo pacman -S kpackage` |
| Debian / Ubuntu / KDE neon | `sudo apt install kpackagetool6` |

After an upgrade, reload Plasma so it picks up the new QML:

```bash
systemctl --user restart plasma-plasmashell
```

### Uninstall

```bash
./uninstall.sh
# or
kpackagetool6 --type Plasma/Applet --remove com.github.rifkiaz.macosbattery
```

## Settings

Right-click the widget → **Configure macOS Battery…**

- **Percentage:** Hidden / Left of the battery / Inside the battery / Right of the battery
- **Percentage text size:** size of the percent to the left or right (50–200%)
- **Battery height:** relative to the automatic panel size (50–250%, never thicker than the panel)
- **Battery width:** percent of height (140–350%, default 215%)
- **Reset size:** back to those defaults
- **Colors:** green while charging, red when low
- **Low battery level:** the "low" cutoff (default 20%)
- **Popup:** connected devices, power profile slider, sleep-block toggle and inhibitors

To match macOS more closely, hide Plasma's own battery in the system tray: right-click System Tray → Configure → Entries → Power and Battery → *Disabled* or *Always hidden*.

## KDE Store ("Get New Widgets")

**Add Widgets → Get New… → Download New Plasma Widgets** lists items from [store.kde.org](https://store.kde.org). To publish there:

1. Run `./build.sh` to make `macos-battery-<version>.plasmoid`.
2. Sign in at <https://store.kde.org>.
3. **Add Product**.
4. Category must be a **Plasma 6** applet category. Plasma 6's Get New Widgets dialog hides Plasma 5 items.
5. Title `macOS Battery`, license GPL-2.0-or-later, link this GitHub repo, upload `docs/preview.png`.
6. On the **Files** tab, upload the `.plasmoid`.

For a later release, bump `Version` in `package/metadata.json`, run `./build.sh`, and upload the new file on the same product page.

## Layout

```
package/
├── metadata.json                    # Plasma 6 applet id
└── contents/
    ├── config/
    │   ├── main.xml                 # settings
    │   └── config.qml               # settings pages
    └── ui/
        ├── main.qml                 # BatteryControlModel, inhibitions, profiles
        ├── CompactRepresentation.qml# panel glyph, middle-click, scroll
        ├── FullRepresentation.qml   # popup / desktop
        ├── DeviceRow.qml            # mouse / headset / keyboard
        ├── PowerProfileRow.qml      # Power Save / Balanced / Performance
        ├── SleepBlock.qml           # toggle + app inhibitors
        ├── Moon.qml                 # crescent on the nub while sleep is blocked
        ├── BatteryIcon.qml          # macOS battery drawing
        ├── BatteryLabel.qml         # percent + bolt inside the battery
        ├── Bolt.qml                 # charging bolt
        └── configGeneral.qml        # settings form
```

Try it without installing: `plasmoidviewer -a package` (from `plasma-sdk`).

## License

GPL-2.0-or-later
