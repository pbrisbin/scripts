#!/bin/bash
# thes - command line thesaurus

# Program name from it's filename
prog=${0##*/}

# Text color variables
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldwht=${txtbld}$(tput setaf 7) #  white
txtrst=$(tput sgr0)             # Reset
warn=${bldred}!${txtrst}

# Display usage if full argument isn't given
if [[ -z "$@" ]]; then
  echo " $prog <word> - command line thesaurus"
  exit
fi

# Suggest possible words if not in dictionary, otherwise define
wordchecknum=$(echo "$1" | aspell -a | sed '1d' | wc -m)
wordcheckprnt=$(echo "$1" | aspell -a | sed '1d' | sed 's/^.*: //')

if [[ $wordchecknum -gt "3" ]]; then
  echo -e "$warn ${bldwht}"$1"${txtrst} is not in the dictionary.  Possible alternatives:"
  echo -e "\n$wordcheckprnt" | fmt -w 76 | sed 's/^/  /g'
  echo
  exit
fi

# Lookup word and reformat/highlight
sdcv -u "Moby Thesaurus II" $1 | \
# lookup, delete extrenous first lines, delete last empty line
sed '1,3d' | sed '2d' | sed '/^*$/d' | \
# delete indent to reformat, add newlines at 76th character, and reident
sed 's/^   //g' | fmt -w 76 | sed 's/^/  /g'
