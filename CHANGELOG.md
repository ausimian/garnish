# Changelog

<!-- %% CHANGELOG_ENTRIES %% -->

## [0.2.2] - 2025-05-08

### Fixed

-  Fix box rendering overflow [cr: ggwpez]

## [0.2.1] - 2025-01-22

### Fixed

-  Replace List.zip with Enum.zip

## [0.2.0] - 2024-11-25

### New features

-  Added support for xterm, linux and rxvt consoles

## [0.1.2] - 2024-08-12

### Fixed

-  Fixed version in mix file.

## [0.1.1] - 2024-08-12

### Fixed

-  Added description to Mix project definition.

## [0.1.1] - 2024-08-12

### Fixed

-  Added description to Mix project definition.

## [0.1.0] - 2024-08-12

### Known issues

- The logical rendering process is relatively expensive. For views that change
  substantially and on a frequent basis, it is _not_ web-scale.
- Only xterm-256color is supported in this release.
