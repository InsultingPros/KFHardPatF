# Changelog

> Go back to [**README**](../README.md#documentation)

## [Version 3.6.0] - 2017.07.11

### Added

- Split some arrays and variables, to make modifications easier.
- Restored `Ammunition` class functionality, to make modifications easier.
- Version info in `mutate status`.

### Removed

- Dead code and variables.
- Huge chunk of TWI copy-paste garbage. Now most logic is in base zed class.
- All hardcoded class names, to make modifications easier.

### Fixed

- Invisible pat when you have seasonal events enabled (thanks [kendaix](https://steamcommunity.com/profiles/76561198070331164/)).
- Buggy code that could affect mutate chain.
- Buggy `PreBeginPlay()` super code call.
- Indentations tab -> 4x space.
- Code Formatting.

## [Version 3.1.0] - 2017.07.11

### Added

- Basic console commands. Type 'mutate PAT help' for additional info.
- Colored and fancy messages.
- Health information in console after team wipe.
- More logging for debug and curious admins.
- Increased 'ImpaleMeleeDamageRange' to 85 (was 45) and decreased 'ClawMeleeDamageRange' to 75 (was 85), to match the animations.

### Removed

- Zed guns and zap effect made almost useless. No more m1, v24.

### Fixed

- 'Accessed none 'MyAmmo'' when pat shoots rockets.
- Escape sound for seasonal variants.

## [Version 3.0.0] - 2017.06.11

### Added

- Xmas, Circus, Halloween variants, controlled from config and WebAdmin.

### Removed

- No more pipe detonation while escaping for heals.
- bHidden flag is removed.

### Fixed

- Freshly spawned Pat should reach to players faster.
- Onperk SS weapons deal headshot damage while Pat is shooting machinegun. I.E. No more 1200dmg from onperk xbow.
- Mutator doesnt affect default monstercollection and break the server after single usage. Optional config bool.
