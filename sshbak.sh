#!/usr/bin/env bash

# terminal colors
CRED="\e[31m"
CGRN="\e[32m"
YELW="\e[33m"
CYAN="\e[36m"
BRED="\e[1;${CRED}"
BGRN="\e[1;${CGRN}"
RSTC="\e[0m"
SPCR="                      "
ARCHIVE_ROOT="/"

# show --banner
banner() {
    echo -e "\n\n${SPCR}   DJ Stomp 2024\n"
    curl https://banner.stomp.zone
    echo -e "${SPCR}\"No Rights Reserved\"\n\n"
}

# show --help
usage() {
  echo -e "Usage: ${CYAN}$0${RSTC} <${BGRN}target_machine${RSTC}> [${YELW}-d archive_root${RSTC} | ${YELW}--dir archive_root${RSTC}]\n"
  echo -e "${CGRN}Required arguments${RSTC}:"
  echo "  target_machine    should be a hostname, IP address, or host entry in the ssh config file"
  echo -e "\n${YELW}Optional arguments${RSTC}:"
  echo "  -h, --help        Show this help message and exit"
  echo "  -d, --dir         Specify the archive root directory (default is /)"
  exit 0
}

# parse args
PARSED_OPTIONS=$(getopt -o d:hv --long dir:,help,version,banner -- "$@")
if [ $? -ne 0 ]; then
  usage
fi

eval set -- "$PARSED_OPTIONS"

while true; do
  case "$1" in
    -v|--version|--banner)
      banner
      shift
      ;;
    -d|--dir)
      ARCHIVE_ROOT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Error parsing options."
      exit 1
      ;;
  esac
done

# parse target
shift $((OPTIND - 1))
if [ -z "$1" ]; then
  usage
fi
TARGET=$1

# setup preflight
DATE=$(date +'%m-%d-%y')
FILENAME="${TARGET}.backup.${DATE}.tar.gz"

# be courteous
if [ -f "$FILENAME" ]; then
  read -p "$FILENAME exists, overwrite? (Y/n) " choice
  if [[ "$choice" != "Y" && "$choice" != "y" ]]; then
    echo -e "${YELW}Backup canceled.${RSTC}"
    exit 1
  fi
fi

# light fires, kick tires, etc
ssh "$TARGET" "
  echo -e '\e[32mConnected\e[0m'
  if [[ \"$ARCHIVE_ROOT\" == \"/\" ]]; then
    sudo tar czf - --exclude-vcs --exclude=snap --exclude=proc --exclude=sys --exclude=dev \
      --exclude='*/venv' --exclude='*/.venv' --exclude='*/_cacache' --exclude='*/node_modules' \
      --exclude='*/.rustup' --exclude='*/site_packages' --exclude='*/__pycache__' --exclude='*/.pyenv' \
      --exclude='*/.cache' --exclude='*/miniconda3' -C / \$(ls /)
  else
    sudo tar czf - --exclude-vcs --exclude=snap --exclude=proc --exclude=sys --exclude=dev \
      --exclude='*/venv' --exclude='*/.venv' --exclude='*/_cacache' --exclude='*/node_modules' \
      --exclude='*/.rustup' --exclude='*/site_packages' --exclude='*/__pycache__' --exclude='*/.pyenv' \
      --exclude='*/.cache' --exclude='*/miniconda3' -C / \"${ARCHIVE_ROOT##/:-/}\"
  fi
" | pv -ptrbN "Backing up ${TARGET}" > "$FILENAME"


if [ $? -eq 0 ]; then
  echo -e "${BGRN}Backup successful: ${CGRN}${FILENAME}${RSTC}"
else
  echo -e "${BRED}Error: ${CRED}Backup failed!${RSTC}" >&2
  exit 1
fi
