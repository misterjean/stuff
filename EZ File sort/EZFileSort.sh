#!/bin/bash
cd "/mnt/hdd"
for filename in *; do
  # this syntax emits the value in lowercase: ${var,,*}  (bash version 4)
  case "${filename,,*}" in
    mp3*)    mv "$filename" "/mnt/hdd/newMusic" ;;
    mkv*) mv "$filename" "/mnt/hdd/Videos" ;;
    *) echo "don't know where to put $filename";;
  esac
done