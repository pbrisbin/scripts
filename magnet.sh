#!/bin/bash
watch_folder=~/Downloads

if [[ "$1" =~ xt=urn:btih:([^&/]+) ]]; then
  echo "d10:magnet-uri${#1}:${1}e" > "$watch_folder/meta-${BASH_REMATCH[1]}.torrent"
  echo 'added.'
else
  echo 'invalid link'
  exit 1
fi
