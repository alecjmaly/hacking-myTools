#!/bin/bash

function greppass {
	# perl
  # grep -ri -e "pass" . --exclude-dir=lib --exclude-dir=debconf 2>/dev/null |cut -c -500 | GREP_COLOR="01;36" grep --color=always -P "('.*?')|(\".*?\")" | grep pass --color=always | sort -u
  grep -ri -e "pass" . --exclude-dir=lib --exclude-dir=debconf 2>/dev/null |cut -c -500 | GREP_COLOR="01;36" grep --color=always -e "^" -e "'[^']*'" -e '"[^"]*"' | grep pass --color=always | sort -u
  echo "...DONE..."
}

function grepb64 {
  grep -ri -E '^[A-Za-z0-9+_/]{50,1000}$|^[A-Za-z0-9+_/]{50,}{3}=$|^[A-Za-z0-9+_/]{50,}{2}=$' . --color=always 2>/dev/null
  echo "...DONE..."
}

function grepb64d {
  grep -ri -E '^[A-Za-z0-9+_/]{50,1000}$|^[A-Za-z0-9+_/]{50,}{3}=$|^[A-Za-z0-9+_/]{50,}{2}=$' . --color=never 2>/dev/null | xargs -I{} sh -c "echo '{}' | cut -d':' -f2 | base64 -d" | grep -i -e "^" -e pass --color=always
  echo "...DONE..."
}


function mgrep {
  # find all files
  # grep those files for GREP_REGEX match
  # for matching files, grep n lines from START_REGEX
  # print if inside contains MATCH_REGEX

  POSITIONAL=()
  unset START_REGEX
  unset MATCH_REGEX
  unset GREP_COLOR_REGEX
  unset EXCLUDE_HIDDEN
  unset EXCLUDE_DIRECTORIES
  DIRECTORIES="."
  NUM_LINES=10




  while [[ $# -gt 0 ]]
  do
  key="$1"

  case $key in
      -sd|--search-directories)
      DIRECTORIES="$2"
      shift
      shift
      ;;
      -n|--num-lines)
      # NUM_LINES="$2"
      LINE_ESCAPES=$(printf "\\\n.*%.0s" `seq $2`)
      shift # past argument
      shift # past value
      ;;
      -sr|--start-regex)
      START_REGEX="$2"
      shift # past argument
      shift # past value
      ;;
      -mr|--match-regex)
      MATCH_REGEX="$2"
      shift # past argument
      shift # past value
      ;;
      -gc|--grep-color-regex)
      GREP_COLOR_REGEX="$2"
      shift
      shift
      ;;
      -xh|--exclude-hidden)
      EXCLUDE_HIDDEN=(-not -path "*/\.*")
      shift
      ;;
      -xd|--exclude-directories)
      DIRS=($(printf $2 | tr ',' ' '))
      printf "${DIRS[@]}"
      pos=$(( ${#DIRS[*]} - 1 ))
      LAST=${DIRS[$pos]} 
      
      EXCLUDE_DIRECTORIES=( \( )
      for i in $(echo $2 | sed "s/,/ /g")
      do
          if [ $i == $LAST ]; then
            break
          fi

          # call your procedure/other scripts here below
          EXCLUDE_DIRECTORIES+=(-path "*/$i/*" -o )
      done
      
      EXCLUDE_DIRECTORIES+=(-path "*/$LAST/*" \) -prune -false -o )

      echo "${EXCLUDE_DIRECTORIES[@]}"

      # \( -path "*/SharePoint-JSON-Helper/*" -o -path "*/hacking-myTools/*" \) -prune -o
      shift
      shift
      ;;
      -h|--help)
      echo '
DISPLAYING HELP

-sd|--search-directories      : starting directories to search in (e.x.:  -sd ". /var /etc" .. default = ".")
-n|--num-lines                : numbers of lines to match after START_REGEX (default = 10)
-sr|--start-regex             : pattern to start matching on
-mr|--match-regex             : pattern to match on (returned in output)
-gc|--grep-color-regex        : pattern to highlight in output
-xh|--exclude-hidden          : exclude hidden files/directories (start with .)
-xd|--exclude-directories     : exclude directories  (e.x.:  -xd "node_modules,folder2")

Example usage:
mgrep -sr "[sS][qQ][lL]" -n 10 -mr '"'"'0.0.0.0.*\n.*\n\|localhost.*\n.*\n\|127.0.0.1.*\n.*\n'"'"' -gc '"'"'sql\|localhost\|127.0.0.1\|0.0.0.0'"'"' -xh -xd "node_modules"

      '

      return
      ;;
      --default)
      DEFAULT=YES
      shift # past argument
      ;;
      *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
  done
  set -- "${POSITIONAL[@]}" # restore positional parameters


  # # PRINT ARGUMENTS
  # echo $LINE_ESCAPES
  # echo "num lines  = ${NUM_LINES}"
  # echo "grep regex  = ${GREP_REGEX}"
  # echo "start regex  = ${START_REGEX}"
  # echo "match regex = ${MATCH_REGEX}"
  echo "${EXCLUDE_DIRECTORIES[@]}"

  # Start regex is not set
  if [[ -z ${START_REGEX} ]]; then
    echo "START REGEX NOT SET"
    return 
  fi

  # Match  regex is not set
  if [[ -z ${MATCH_REGEX} ]]; then
    echo "MATCH REGEX NOT SET"
    return
  fi

  
  if [[ -n $1 ]]; then
      echo "Last line of file specified as non-opt/last argument:"
      tail -1 "$1"
  fi

  red=`tput setaf 1`
  orange=`tput setaf 3`
  reset=`tput sgr0`

  # find . -type f -not -path '*/\.*' -readable -exec grep -i $GREP_REGEX '{}' -s -l -I \; 2>/dev/null  | xargs -n 1 -P 8 -L1 -I{} sh -c 'echo; echo "'"$green"'EVALUATING: {}'"$reset"'"; sed -n "/'"$START_REGEX"'/{:start /'"$LINE_ESCAPES"'\|'"$MATCH_REGEX"'/!{N;b start};/'"$MATCH_REGEX"'/Ip}" "{}" | cut -c -500 | grep -i -e "^" -e "'"$GREP_COLOR_REGEX"'"  --color=always'


  # TODO: 
  # 1. omit hidden files flag
  # 2. MATCH_REGEX CASE INSENSITIVE
  # find ${DIRECTORIES[@]} "${EXCLUDE_DIRECTORIES[@]}" "${EXCLUDE_HIDDEN[@]}" -type f -readable | grep -e "^" -e git
  # find ${DIRECTORIES[@]} "${EXCLUDE_DIRECTORIES[@]}" "${EXCLUDE_HIDDEN[@]}" -type f -readable

  # echo "find ${DIRECTORIES[@]} "${EXCLUDE_DIRECTORIES[@]}" "${EXCLUDE_HIDDEN[@]}" -type f -readable | grep -e "^" -e git"
  ## REAL
  find ${DIRECTORIES[@]} "${EXCLUDE_DIRECTORIES[@]}" "${EXCLUDE_HIDDEN[@]}" -type f -readable -exec grep -i $START_REGEX '{}' -s -l -I \; 2>/dev/null  | xargs -L1 -I{} sh -c 'tmp=$(sed -n "/'"$START_REGEX"'/{:start /'"$LINE_ESCAPES"'\|'"$MATCH_REGEX"'/!{N;b start};/'"$MATCH_REGEX"'/Ip}" "{}" | cut -c -500 | grep -i -e "^" -e "'"$GREP_COLOR_REGEX"'" --color=always); if [ ! -z "$tmp" ]; then echo; echo "'"$green"'EVALUATING: {}'"$reset"'"; echo "${tmp}" ; fi'


  printf "\n\n..DONE..\n"
}

## ---------- USAGE --------
## grep passwords from current directory
# greppass

function grepdb {
  ## grepdb: sql followed by host
  mgrep -sr "[sS][qQ][lL]" -n 10 -mr '0.0.0.0.*\n.*\n.*\|localhost.*\n.*\n.*\|127.0.0.1.*\n.*\n.*' -gc 'sql\|localhost\|127.0.0.1\|0.0.0.0' -xd "node_modules" # -xh
}


function grepdbr {
  ## grepdb: host followed by sql
  mgrep -sr '0.0.0.0\|localhost\|127.0.0.1' -n 10 -mr "[sS][qQ][lL]" -gc 'qsql\|localhost\|127.0.0.1\|0.0.0.0' -xd "node_modules" # -xh
}