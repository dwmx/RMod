# RBase
RBase is the top-level package for RMod, with no dependencies other than what comes with the base install of Rune.

This package does not provide any direct game modification, it only includes useful utility functions and data structures not originally included in UnrealScript.

## Naming conventions
- All classes are prefixed with `R_`
- Utility class are further prefixed with `U`, i.e. `R_UCanvasUtilities`
    - These classes are abstract utility classes providing static functions and should not be extended