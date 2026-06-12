{
    lib,
    stdenv,
    cmake,
    extra-cmake-modules,
    qt6,
    plasma-desktop,
    libplasma,
    plasma-activities,
    plasma-activities-stats,
    kconfig,
    kcoreaddons,
    ki18n,
    kio,
    knotifications,
    kservice,
    kwayland,
    kwindowsystem,
    libksysguard,
    plasma-workspace,
}:

stdenv.mkDerivation {
    pname = "plasma-applet-taskmanagerordered";
    version = plasma-desktop.version;

    src = ./.;

    dontWrapQtApps = true;
    dontUseCmakeConfigure = true;

    nativeBuildInputs = [
        cmake
        extra-cmake-modules
        qt6.qtdeclarative
    ];

    buildInputs = [
        qt6.qtbase
        qt6.qtdeclarative
        qt6.qttools
        libplasma
        plasma-activities
        plasma-activities-stats
        kconfig
        kcoreaddons
        ki18n
        kio
        knotifications
        kservice
        kwayland
        kwindowsystem
        libksysguard
        plasma-workspace
    ];

    buildPhase = ''
        runHook preBuild

        mkdir -p upstream
        tar xf ${plasma-desktop.src} -C upstream --strip-components=1 \
            plasma-desktop-${plasma-desktop.version}/applets/taskmanager \
            plasma-desktop-${plasma-desktop.version}/kcms/recentFiles/kactivitymanagerd_plugins_settings.kcfg \
            plasma-desktop-${plasma-desktop.version}/kcms/recentFiles/kactivitymanagerd_plugins_settings.kcfgc

        cp -r upstream/applets/taskmanager applet
        mkdir -p applet/kcms/recentFiles
        cp upstream/kcms/recentFiles/kactivitymanagerd_plugins_settings.kcfg \
            applet/kcms/recentFiles/
        cp upstream/kcms/recentFiles/kactivitymanagerd_plugins_settings.kcfgc \
            applet/kcms/recentFiles/

        chmod -R +w applet

        cp $src/plasmoid/metadata.json applet/metadata.json

        substituteInPlace \
            applet/qml/ContextMenu.qml \
            applet/qml/GroupDialog.qml \
            applet/qml/MouseHandler.qml \
            applet/qml/Task.qml \
            applet/qml/TaskList.qml \
            applet/qml/TaskProgressOverlay.qml \
            applet/qml/main.qml \
            --replace-fail 'plasma.applet.org.kde.plasma.taskmanager' \
                           'plasma.applet.org.kde.plasma.taskmanagerordered'

        if grep -RE 'plasma[.]applet[.]org[.]kde[.]plasma[.]taskmanager([^[:alnum:]_]|$)' applet/qml; then
            echo 'Found stale stock taskmanager QML imports after substitution' >&2
            exit 1
        fi

        # Use a TaskManager.TasksModel subclass so the stock QML keeps using
        # the real task model API while ordering is handled in lessThan().
        substituteInPlace applet/qml/main.qml \
            --replace-fail 'import org.kde.taskmanager as TaskManager' 'import org.kde.taskmanager as TaskManager
import OrderedTaskManager 1.0 as OrderedTaskManager' \
            --replace-fail 'readonly property TaskManager.TasksModel tasksModel: TaskManager.TasksModel {' \
                           'readonly property OrderedTaskManager.OrderedTasksModel tasksModel: OrderedTaskManager.OrderedTasksModel {' \
            --replace-fail '        id: tasksModel' \
                           '        id: tasksModel
        orderedAppIds: Plasmoid.configuration.sortingStrategy === 7 ? (Plasmoid.configuration.orderedAppIds || []) : []' \
            --replace-fail '        sortMode: sortModeEnumValue(Plasmoid.configuration.sortingStrategy)' \
                           '        sortMode: Plasmoid.configuration.sortingStrategy === 7 ? TaskManager.TasksModel.SortAlpha : sortModeEnumValue(Plasmoid.configuration.sortingStrategy)'

        substituteInPlace applet/main.xml \
            --replace-fail '<label>Values from TaskManager::TasksModel::SortMode</label>
      <default>1</default>' '<label>Values from TaskManager::TasksModel::SortMode. 7 = OrderedAppIds</label>
      <default>7</default>' \
            --replace-fail '    <entry name="separateLaunchers" type="Bool">' '    <entry name="orderedAppIds" type="StringList">
      <label>Ordered WM_CLASS values, app ids, launcher urls, app names, or display names used by ordered sorting.</label>
      <default></default>
    </entry>
    <entry name="separateLaunchers" type="Bool">'

        # Fix ConfigBehavior.qml: add orderedAppIds UI
        patch -d applet/qml -p1 < $src/patches/ConfigBehavior.qml.patch

        # Copy ordered model sources into applet build tree.
        cp $src/src/orderedtaskmanagerproxy.h applet/
        cp $src/src/orderedtaskmanagerproxy.cpp applet/

        # Build main applet via plasma_add_applet
        cp $src/plasmoid/CMakeLists.txt applet/

        cmake -S applet -B build \
            -DCMAKE_INSTALL_PREFIX=$out \
            -DKDE_INSTALL_PLUGINDIR=lib/qt-6/plugins \
            -DCMAKE_BUILD_TYPE=Release
        cmake --build build

        runHook postBuild
    '';

    installPhase = ''
        runHook preInstall
        cmake --install build
        runHook postInstall
    '';

    meta = {
        description = "Standalone Plasma task manager built from Plasma's current taskmanager applet source";
        homepage = "https://github.com/anomalyco/nixos-config";
        license = lib.licenses.gpl2Plus;
        platforms = lib.platforms.linux;
        maintainers = [ ];
    };
}
