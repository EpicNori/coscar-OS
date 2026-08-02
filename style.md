# coscar-OS visual system

## Direction

The selected direction is a calm glass dashboard canvas inspired by CasaOS's
frosted-glass surfaces and modular widgets, adapted for a driver-facing
infotainment screen. The original OCTAVE behavior and navigation remain the
source of truth; this document records the new visual layer.

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
