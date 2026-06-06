
<div align="center">

<img src="Assets/app_icon_1024.png" width="128" height="128" alt="SidecarSnap Icon">

# SidecarSnap

**Your mouse touches the screen edge → iPad Sidecar snaps to that side. Automatically.**



> *Apple didn't build this, so I got frustrated and built it myself.*

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue?logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Release](https://img.shields.io/badge/Release-v1.1-purple)](https://github.com/Kimsharrrk/SidecarSnap/releases/latest)
[![Language](https://img.shields.io/badge/Language-EN%20%7C%20KO%20%7C%20JA-blueviolet)](#)

**🇺🇸 English** | [🇰🇷 한국어](README_ko.md) | [🇯🇵 日本語](README_ja.md)

https://github.com/user-attachments/assets/757eaeb9-01a1-434d-98f6-846f94811ad4


</div>

---

## 🇺🇸 English

### The Problem

You're using your iPad as a second screen with Sidecar. You pick it up and move it to the other side of your MacBook. Now you have to manually open **System Settings → Displays → Arrange** and drag the little display icon. Every. Single. Time.

This is 2026. That's unacceptable.

### The Solution

SidecarSnap watches your mouse cursor. When you push it against the **left or right edge** of your screen for half a second, the Sidecar display **automatically jumps** to that side.

```
Push mouse →  LEFT  edge (0.5s)  =  iPad arranges to the LEFT  ◀
Push mouse →  RIGHT edge (0.5s)  =  iPad arranges to the RIGHT ▶
```

You'll also see a **Dynamic Island-style black blob** emerge from the bezel. As you hold the mouse, it grows, giving you a smooth visual timer.

### Features

| Feature | Description |
|---|---|
| 🖱️ Auto-Arrange | Mouse edge detection → instant Sidecar repositioning |
| 💧 Dynamic Blob | Smooth, bezel-attached indicator shows timer progress |
| 🌐 3 Languages | English, 한국어, 日本語 — switchable from menu |
| 👻 Hide Icon | Hide the ugly menu bar icon with one click! |
| 🚀 Launch at Login | Starts automatically with your Mac |
| ⚙️ Adjustable Delay | 0.3s / 0.5s (default) / 1.0s |
| 📱 Manual Control | `[` and `]` keyboard shortcuts |

### Installation

**Option A — Direct Download** *(recommended)*

<a href="https://github.com/Kimsharrrk/SidecarSnap/raw/main/SidecarSnap_v1.1.dmg">
  <img src="Assets/download_badge.png" width="220" alt="Download app for macOS">
</a>

1. Open the DMG file and drag `SidecarSnap.app` to `/Applications`
2. Open it and follow the setup guide

> [!IMPORTANT]
> **First-time Launch Security Warning**
> Since this is a free open-source project and not signed with a paid Apple Developer Account ($99/year), macOS will show a warning: **"SidecarSnap is damaged and can't be opened."**
> 
> **Don't worry, the app is not damaged!** You can easily open it in 10 seconds without any terminal commands:
> 1. Click **Cancel** on the warning popup.
> 2. Open **System Settings ➔ Privacy & Security**.
> 3. Scroll down to the **Security** section.
> 4. Click **"Open Anyway"** next to the blocker message.
> 5. Authenticate with your password / Touch ID. You're good to go! (You only need to do this once).

**Option B — Build from Source**
```bash
git clone https://github.com/Kimsharrrk/SidecarSnap.git
cd SidecarSnap
./build.sh
open SidecarSnap.app
```

### Setup (takes 30 seconds)

> **Step 1** — Connect your iPad via Sidecar (Control Center → Screen Mirroring → your iPad)
>
> **Step 2** — Grant Accessibility permission when prompted *(required for mouse tracking)*
>
> **Step 3** — That's it. Push your mouse to the screen edge.

---

### Hiding the Menu Bar Icon

SidecarSnap lives in your menu bar as a small icon.

**To hide it:**
Just click the SidecarSnap menu bar icon and select **"Hide Menu Bar Icon"**.

> *Honestly? We recommend hiding it. The icon is kind of ugly.  
> We tried. We're developers, not designers. 🤷*

*Note: If you hide the icon and need to change settings later, just re-open the SidecarSnap app from your Applications folder. The icon will reappear!*

---

### Requirements

- macOS 13 (Ventura) or later
- An iPad that supports Sidecar (iPad Pro, iPad Air, iPad mini 5+, iPad 6th gen+)
- Both devices logged in with the same Apple ID

### How It Works

```
NSEvent.addGlobalMonitorForEvents(.mouseMoved)
    ↓  mouse reaches ≤2px from screen edge
    ↓  0.5s debounce timer + edge glow progress
    ↓  CGBeginDisplayConfiguration()
       CGConfigureDisplayOrigin(sidecarID, newX, 0)
       CGCompleteDisplayConfiguration(.forSession)
    ↓  HUD overlay animation
```

Uses **only public CoreGraphics APIs**. No private frameworks. No kernel extensions. No magic.

---

## License

Copyright © 2026 Kimsharrrk. All rights reserved.  
Free for personal use. Modification and redistribution without permission are strictly prohibited.

---

<div align="center">

Built by a MacBook + iPad user who was tired of clicking through System Settings.

**If this saved you time → ⭐ Star it. It means a lot.**

</div>
