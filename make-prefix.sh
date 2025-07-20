#!/bin/bash

set -e

PREFIX="$PWD/prefix"

QT_VERSION=6.9.1
QT_DIR=""

KF_VERSION=6.16.0
CLEAN_UP=0

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--prefix)
            PREFIX="$2"
            shift
            shift
            ;;
        --qt-version)
            QT_VERSION="$2"
            shift
            shift
            ;;
        --qt-dir)
            QT_DIR="$2"
            shift
            shift
            ;;
        --kf-version)
            KF_VERSION="$2"
            shift
            shift
            ;;
        --clean-up)
            CLEAN_UP=1
            shift
            ;;
    esac
done

TEMP_DIR="$PREFIX/.temp"
mkdir -p "$TEMP_DIR"

IS_LINUX=0
IS_WINDOWS=0

case "$(uname -s)" in
    Linux*)
        IS_LINUX=1
        ;;
    MINGW64_NT*|MSYS_NT*)
        IS_WINDOWS=1
        ;;
    *)
        echo "UNSUPPORTED: $(uname -s)"
        exit 1
        ;;
esac

if ! [[ $(type -P python3) ]]; then
    echo "Python 3 is not installed"
    exit 1
fi

echo "######### Setting up Python environment"

if [[ "$IS_LINUX" -eq 1 ]]; then
    if ! [[ -d "$TEMP_DIR/venv" ]]; then
        python3 -m venv "$TEMP_DIR/venv"
    fi

    source "$TEMP_DIR/venv/bin/activate"
    PYTHON="$(type -P python3)"
    deactivate
elif [[ "$IS_WINDOWS" -eq 1 ]]; then
    PYTHON="$(type -P python3)"
fi

PYTHON_PREFIX="$("$PYTHON" -c "import sys; print(sys.prefix)")"

echo "- Python executable: '$PYTHON'"
echo "- Python install dir: '$PYTHON_PREFIX'"

if [[ -z "$QT_DIR" ]]; then
    echo "######### Install Qt $QT_VERSION"

    if [[ "$IS_LINUX" -eq 1 ]]; then
        if ! [[ -d "$PREFIX/$QT_VERSION/gcc_64" ]]; then
            echo "- Install aqtinstall"
            "$PYTHON" -m pip install --ignore-installed -q aqtinstall

            echo "- Install Qt to '$PREFIX'"
            "$PYTHON" -m aqt install-qt -O "$PREFIX" linux desktop "$QT_VERSION" linux_gcc_64
        fi

        QT_DIR="$PREFIX/$QT_VERSION/gcc_64"

    elif [[ "$IS_WINDOWS" -eq 1 ]]; then
        if ! [[ -f "$TEMP_DIR/aqt.exe" ]]; then
            curl -JL "https://github.com/miurahr/aqtinstall/releases/download/v3.3.0/aqt_x64.exe" -o "$TEMP_DIR/aqt.exe"
        fi

        if ! [[ -d "$PREFIX/$QT_VERSION/llvm-mingw_64" ]]; then
            echo "- Install Qt to '$PREFIX'"
            "$TEMP_DIR/aqt.exe" install-qt -O "$PREFIX" windows desktop "$QT_VERSION" win64_llvm_mingw
        fi

        QT_DIR="$PREFIX/$QT_VERSION/llvm-mingw_64"
    fi
fi

BUILD_EXTRA_ARGS=(-DPython_ROOT_DIR="$PYTHON_PREFIX" -DPYTHON_EXECUTABLE="$PYTHON" -DPython3_ROOT_DIR="$PYTHON_PREFIX")
if [[ "$IS_WINDOWS" -eq 1 ]]; then
    BUILD_EXTRA_ARGS+=(-DUSE_DBUS=OFF)
fi

CC="$(type -P clang)"
export CC

CXX="$(type -P clang++)"
export CXX

export PATH="$QT_DIR/bin:$PATH"

kf_build() {
    local SOURCE_DIR="$TEMP_DIR/$1"
    local GIT_SOURCE="$2"
    shift 2

    if ! [[ -d "$SOURCE_DIR" ]]; then
        git clone -b "v$KF_VERSION" "$GIT_SOURCE" "$SOURCE_DIR"
    fi

    cmake --fresh -S "$SOURCE_DIR" -B "$SOURCE_DIR/build" -G Ninja \
        -DBUILD_TESTING=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$QT_DIR" \
        -DCMAKE_PREFIX_PATH="$QT_DIR" \
        -DBUILD_PYTHON_BINDINGS=OFF \
        -DBUILD_DESIGNERPLUGIN=OFF \
        -DBUILD_WITH_QML=OFF \
        "${BUILD_EXTRA_ARGS[@]}" \
        "$@"

    cmake --build "$SOURCE_DIR/build" --parallel
    cmake --install "$SOURCE_DIR/build"
}

echo "######### Build KCoreAddons"

kf_build "kcoreaddons" "https://github.com/KDE/kcoreaddons"

echo "######### Build KI18n"

kf_build "ki18n" "https://github.com/KDE/ki18n" \
    -DPython_ROOT_DIR="$PYTHON_PREFIX"

echo "######### Build KArchive"

kf_build "karchive" "https://github.com/KDE/karchive" \
    -DWITH_BZIP2=OFF \
    -DWITH_LIBLZMA=OFF \
    -DWITH_OPENSSL=OFF \
    -DWITH_LIBZSTD=OFF

echo "######### Build KWidgetsAddons"

kf_build "kwidgetsaddons" "https://github.com/KDE/kwidgetsaddons"

echo "######### Build KConfig"

kf_build "kconfig" "https://github.com/KDE/kconfig" \
    -DKCONFIG_USE_GUI=ON \
    -DKCONFIG_USE_QML=OFF

echo "######### Build KGuiAddons"

kf_build "kguiaddons" "https://github.com/KDE/kguiaddons" \
    -DKCONFIG_USE_GUI=ON \
    -DKCONFIG_USE_QML=OFF

echo "######### Build KColorScheme"

kf_build "kcolorscheme" "https://github.com/KDE/kcolorscheme" \
    -DKF6Config_DIR="$QT_DIR/cmake/KF6Config" \
    -DKF6GuiAddons_DIR="$QT_DIR/lib/cmake/KF6GuiAddons" \
    -DKF6I18n_DIR="$QT_DIR/lib/cmake/KF6I18n"

echo "######### Build Breeze Icons"

WITH_ICON_GENERATION=OFF
if [[ "$IS_LINUX" -eq 1 ]]; then
    WITH_ICON_GENERATION=ON
fi

if [[ "$WITH_ICON_GENERATION" = "ON" ]]; then
    "$PYTHON" -m pip install -q lxml
fi

kf_build "breeze-icons" "https://github.com/KDE/breeze-icons" \
    -DPython_ROOT_DIR="$PYTHON_PREFIX" \
    -DSKIP_INSTALL_ICONS=ON \
    -DWITH_ICON_GENERATION="$WITH_ICON_GENERATION" \
    -DBINARY_ICONS_RESOURCE=OFF

echo "######### Build KIconThemes"

kf_build "kiconthemes" "https://github.com/KDE/kiconthemes" \
    -DKF6Config_DIR="$QT_DIR/lib/cmake/KF6Config" \
    -DKF6Archive_DIR="$QT_DIR/lib/cmake/KF6Archive" \
    -DKF6I18n_DIR="$QT_DIR/lib/cmake/KF6I18n" \
    -DKF6WidgetsAddons_DIR="$QT_DIR/lib/cmake/KF6WidgetsAddons" \
    -DKF6ColorScheme_DIR="$QT_DIR/lib/cmake/KF6ColorScheme" \
    -DKF6BreezeIcons_DIR="$QT_DIR/lib/cmake/KF6BreezeIcons" \
    -DKICONTHEMES_USE_QTQUICK=OFF \
    -DUSE_BreezeIcons=ON

echo "######### Cleanup"

if [[ "$CLEAN_UP" -eq 1 ]]; then
    rm -rf "$TEMP_DIR"
fi
