#!/bin/bash
#
# pbrisbin 2012
#
###
(( $# )) || { echo 'usage: hb [ rip <name> | convert <file> ] [ options ]' >&2; exit 1; }

case "$1" in
  rip)     src='/dev/sr0'
           dst="$2.mp4" ;;
  convert) src="$2"
           dst="$(basename "${src%.*}").mp4" ;;
esac

shift 2
HandBrakeCLI -Z iPad "$@" -i "$src" -o "/mnt/media/Movies/$dst"
