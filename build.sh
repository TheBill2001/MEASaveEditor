#!/bin/bash

NO_MSYS=0

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--prefix)
            PREFIX="$2"
            shift
            shift
            ;;
        --no-msys)
            NO_MSYS=1
            shift
            shift
            ;;
    esac
done

if ! [[ "$NO_MSYS" -eq 1 ]]; then
    if ! [[  "$(uname -s)" =~ ^MSYS_NT.* ]]; then
        echo "Not in MSYS"
        exit 1
    fi
fi
