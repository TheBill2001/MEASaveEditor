# SPDX-FileCopyrightText: 2025 Trần Nam Tuấn <tuantran1632001@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

qt_add_executable(mease
    main.cpp

    mease/ui/mainwindow.cpp
    mease/ui/mainwindow.hpp
)

set_target_properties(mease PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

target_link_libraries(mease PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets

    KF6::CoreAddons
    KF6::I18n
    KF6::IconThemes
)

install(TARGETS mease ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

if(WIN32)
    set(deploy_tool_options
    ${deploy_tool_options}
        # --skip-plugin-types iconengines,imageformats
        --no-system-d3d-compiler
        --no-system-dxc-compiler
        --no-network
        --no-opengl-sw
    )
endif()

qt_generate_deploy_app_script(
    TARGET mease
    OUTPUT_SCRIPT deploy_script
    NO_UNSUPPORTED_PLATFORM_ERROR
    DEPLOY_TOOL_OPTIONS ${deploy_tool_options}
)
