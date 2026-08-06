# coscar-OS visual system

## Direction

The selected direction is a calm glass dashboard canvas inspired by CasaOS's
frosted-glass surfaces and modular widgets, adapted for a driver-facing
infotainment screen. The original OCTAVE behavior and navigation remain the
source of truth; this document records the new visual layer.

The project is a redesign and continuation of [RobDeGeorge/OCTAVE](https://github.com/RobDeGeorge/OCTAVE). Original attribution and licensing are preserved in `NOTICE`, `LICENSE`, and `ORIGINAL-CREDITS.md`.

## Tokens

- Background asset: `frontend/assets/glass-dashboard-bg.png`
- Glass panel: `#7A173348`
- Strong glass panel: `#A8234A5D`
- Soft glass panel: `#4D8CA8B8`
- Glass border: `#66E7F4FA`
- Divider: `#4DE8F2F7`
- Primary text: `#F7FBFF`
- Muted text: `#C7D8E2`
- Accent: `#4DE0F3`
- Success: `#9BE878`
- Main radius: `24px`
- Small radius: `16px`

## Usage rules

- Use the image as a quiet, full-bleed atmosphere; never place text directly
  over high-detail areas without a glass surface behind it.
- Use translucent panels for grouping, not for every individual row.
- Keep primary actions large enough for touch and use the cyan accent only for
  active state, playback, connection, and the most important telemetry.
- Keep vehicle values glanceable: show fewer values with more whitespace before
  expanding into the dedicated OBD pages.
- Preserve the original OCTAVE attribution and MIT license.

## Kiosk and startup surface

- The production one-liner opts into a fullscreen kiosk mode and per-user
  autostart; normal development launches remain windowed and closable.
- In kiosk mode, the close action is intentionally available only at Settings
  > Display > Window > Exit coscar-OS, so accidental window-manager closes do
  not interrupt an in-car session.
- Keep the exit action clearly labeled and touch-sized. It is a functional
  control, not a decorative glass card.

## Display rotation

- The complete logical dashboard canvas supports 0°, 90°, 180°, and 270°
  rotation for mounted touchscreens, especially portrait Pi displays.
- Keep rotation in Settings > Display > Window as large, touch-friendly chips.
- Preserve the logical screen dimensions while swapping the physical window
  dimensions for quarter-turn rotations, so layouts do not reflow unexpectedly.
- Use the same degree labels and persisted `displayRotation` value in both the
  Python and C++ backends.

## Wi-Fi update surface

- The update control lives in Settings > Device > Home Wi-Fi Update.
- Show the active SSID, Wi-Fi readiness, update progress, errors, and restart
  action using the existing settings-card and status-color tokens.
- Keep updates manual and clearly communicate that the car must have internet
  access; do not start downloads automatically while driving.
