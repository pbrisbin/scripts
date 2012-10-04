#!/bin/bash
#
# pbrisbin 2012
#
###
(( $# )) || { echo 'usage: hb [ rip <name> | convert <file> ]' >&2; exit 1; }

case "$1" in
  rip)     src='/dev/sr0'
           dst="$1.mp4" ;;
  convert) src="$1"
           dst="$(basename "${in%.*}").mp4" ;;
esac

shift
HandBrakeCLI -Z iPad "$@" -i "$src" -o "$HOME/Movies/$dst"
