# Deterministic Task Manager

Standalone Plasma applet that subclasses the stock `TaskManager.TasksModel` to
provide deterministic app ordering - no patches to `plasma-workspace` or
`plasma-desktop` required.

## How it works

1. A C++ `OrderedTasksModel` subclasses the stock `TasksModel` and overrides
   `lessThan()` to sort tasks by a configured priority list.
2. The plasmoid (`org.kde.plasma.taskmanagerordered`) copies all QML from the
   stock task manager, patches `main.qml` to instantiate `OrderedTasksModel`,
   and patches `ConfigBehavior.qml` plus upstream `main.xml` to add the ordered
   sorting config entries.
3. Ordered mode uses config value `7`. The subclass applies configured app
   priorities first, then delegates equal-priority and unknown apps to the
   configured `orderedSecondarySortingStrategy` sort mode.

Matching first tries the raw Wayland `app_id` reported by KWin, then model roles
`AppId`, `LauncherUrlWithoutIcon`, `LauncherUrl`, `AppName`, and `DisplayRole`.
PID-based app IDs are used only as an unambiguous fallback. Values are
normalized by lowercasing and stripping `applications:` and `.desktop`. Unknown
apps sort after known ones, using the configured secondary sort mode.

## Files

- `src/` - C++ ordered task model
- `plasmoid/` - metadata and CMake wiring for the copied plasmoid
- `patches/` - patches applied to the stock QML at build time
- `default.nix` - build derivation (callPackage-style)

## Use

Call with `kdePackages.callPackage ./default.nix {}`, install into your home
packages, then configure your panel with:

```nix
{
    name = "org.kde.plasma.taskmanagerordered";
    config.General = {
        sortingStrategy = 7;
        orderedSecondarySortingStrategy = 2; # Alphabetically; 0 keeps source order
        orderedAppIds = [
            "thunderbird"
            "org.mozilla.Firefox.layout"
            "org.kde.dolphin"
            "org.kde.konsole"
        ];
    };
}
```
