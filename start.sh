#!/usr/bin/env bash

OS_NAME="$(uname | awk '{print tolower($0)}')"
OS_ARCH_NAME="$(uname -m)"

if [ "${OS_NAME}" == "darwin" ]; then
  INSTALLER="brew"
fi

################################################################################
################################################################################
################################################################################

command -v tput > /dev/null && TPUT=true

_result() {
  _echo "# $@" 4
}

_command() {
  _echo "$ $@" 3
}

_success() {
  _echo "+ $@" 2
  exit 0
}

_error() {
  _echo "- $@" 1
  exit 1
}

_echo() {
  if [ "${TPUT}" != "" ] && [ "$2" != "" ]; then
    echo -e "$(tput setaf $2)$1$(tput sgr0)"
  else
    echo -e "$1"
  fi
}

_backup() {
  if [ -f $1 ] && [ ! -f $1.backup ]; then
    cp $1 $1.backup
  fi
}

_done() {
  echo "================================================================================"
  echo "================================================================================"
  echo "Finished"
  echo "================================================================================"
}

echo "================================================================================"
echo "================================================================================"
echo "${OS_NAME} [${INSTALLER}]"
echo "================================================================================"

if [ "${INSTALLER}" == "" ]; then
  _error "Not supported OS."
fi

mkdir -p ~/.aws
mkdir -p ~/.ssh

# ssh config
if [ ! -f ~/.ssh/config ]; then
cat <<EOF > ~/.ssh/config
Host *
    StrictHostKeyChecking no
EOF
fi
chmod 400 ~/.ssh/config

####### xcode
if [ "${OS_NAME}" == "darwin" ]; then
  command -v xcode-select >/dev/null || HAS_XCODE=false
  if [ ! -z ${HAS_XCODE} ]; then
    _command "xcode-select --install"
    sudo xcodebuild -license
    xcode-select --install

    if [ "${OS_ARCH}" == "arm64" ]; then
      sudo softwareupdate --install-rosetta --agree-to-license
    fi
  fi
fi

######## .aliases
_backup ~/.aliases
curl -fsSL -o ~/.aliases https://raw.githubusercontent.com/timurgaleev/env/main/.aliases


####### Install Brew
command -v brew >/dev/null || HAS_BREW=false
if [ ! -z ${HAS_BREW} ]; then
  _command "brew install..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -d /opt/homebrew/bin ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -d /home/linuxbrew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    eval "$(brew shellenv)"
  fi
fi

_command "brew update..."
brew update

_command "brew upgrade..."
brew upgrade

#######  Brew packages
_backup ~/.brewpackages
curl -fsSL -o ~/.brewpackages https://raw.githubusercontent.com/timurgaleev/env/main/brewpackages

_command "brew bundle..."
brew bundle --file=~/.brewpackages

_command "brew cleanup..."
brew cleanup

_done
