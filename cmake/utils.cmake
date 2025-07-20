# SPDX-FileCopyrightText: 2025 Trần Nam Tuấn <tuantran1632001@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

function(mease_pad_text arg_TEXT arg_PAD arg_COUNT arg_OUTPUT)
    cmake_parse_arguments(PARSE_ARGV 4 arg
        "PREPEND" "" ""
    )

    string(LENGTH "${arg_TEXT}" TEXT_LENGTH)

    if(TEXT_LENGTH GREATER "${arg_COUNT}")
        message(FATAL_ERROR "Text is larger than max length")
    endif()

    math(EXPR PADDING_NEEDED "${arg_COUNT} - ${TEXT_LENGTH}")

    set(PAD_CHARS "")
    if(PADDING_NEEDED GREATER 0)
        foreach(i RANGE 1 ${PADDING_NEEDED})
            string(APPEND PAD_CHARS "${arg_PAD}")
        endforeach()
    endif()

    if(arg_PREPEND)
        string(CONCAT OUTPUT "${PAD_CHARS}${arg_TEXT}")
    elseif()
        string(CONCAT OUTPUT "${arg_TEXT}${PAD_CHARS}")
    endif()

    set("${arg_OUTPUT}" "${OUTPUT}" PARENT_SCOPE)
endfunction()

function(mease_version_hex arg_OUTPUT)
    if(NOT ARGV1)
        message(FATAL_ERROR "Missing version major")
    endif()

    mease_pad_text("${ARGV1}" "0" 2 VERSION_MAJOR PREPEND)

    set(VERSION_MINOR "00")
    if(ARGV2)
        mease_pad_text("${ARGV2}" "0" 2 VERSION_MINOR PREPEND)
    endif()

    set(VERSION_PATCH "00")
    if(ARGV3)
        mease_pad_text("${ARGV3}" "0" 2 VERSION_PATCH PREPEND)
    endif()

    set("${arg_OUTPUT}" "0x${VERSION_MAJOR}${VERSION_MINOR}${VERSION_PATCH}" PARENT_SCOPE)
endfunction()
