#!/bin/sh
printf '\033c\033]0;%s\a' Karlson_remaster
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Karlson_remaster.exe.x86_64" "$@"
