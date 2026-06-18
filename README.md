# Twilight Switch

A polished animated day/night toggle switch for Flutter. `TwilightSwitch` is built with `CustomPainter`, supports tap and drag interactions, and lets you customize the day, twilight, and night gradients.

## Features

- Animated transition from day to twilight to night
- Tap and horizontal drag support
- Customizable size, animation duration, and gradient colors
- Accessible semantics for switch/toggle usage
- No third-party runtime dependencies beyond Flutter

## Package Preview
<p>
  <img src="example/assets/video/vid.gif" width="250" />
</p>


## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  twilight_switch: ^1.0.1
```

Then import it:

```dart
import 'package:twilight_switch/twilight_switch.dart';
```

## Usage

```dart
class ThemeToggleExample extends StatefulWidget {
  const ThemeToggleExample({super.key});

  @override
  State<ThemeToggleExample> createState() => _ThemeToggleExampleState();
}

class _ThemeToggleExampleState extends State<ThemeToggleExample> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return TwilightSwitch(
      value: isDark,
      onChanged: (value) {
        setState(() => isDark = value);
      },
    );
  }
}
```

### Custom colors

```dart
TwilightSwitch(
  value: isDark,
  onChanged: (value) => setState(() => isDark = value),
  dayColors: const [Color(0xFF9BE7FF), Color(0xFF2EA7F2)],
  twilightColors: const [Color(0xFFFFB86B), Color(0xFF7C3AED)],
  nightColors: const [Color(0xFF0F172A), Color(0xFF312E81)],
)
```

## Additional information

This package is useful for theme toggles, settings screens, onboarding flows, and any UI that needs a playful day/night switch.

Contributions and issue reports are welcome through the package repository once configured.


⭐ Star the project on GitHub:

https://github.com/Sakshi-2508/twilight_switch

# Package URL
https://pub.dev/packages/twilight_switch
