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

_download() {
  local max_retries=3
  local retry_count=0
  local wait_time=5

  local target_file=~/$1
  local target_dir=$(dirname "$target_file")
  if [ "$target_dir" != "$HOME" ] && [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
  fi

  if [ -f ~/.env/${2:-$1} ]; then
    if [ -f ~/$1 ]; then
      if [ "$(md5sum ~/.env/${2:-$1} | awk '{print $1}')" != "$(md5sum ~/$1 | awk '{print $1}')" ]; then
        _backup ~/$1
        cp ~/.env/${2:-$1} ~/$1
      fi
    else
      cp ~/.env/${2:-$1} ~/$1
    fi
  else
    _backup ~/$1
    while [ $retry_count -lt $max_retries ]; do
      if curl -fsSL --connect-timeout 10 -o ~/$1 https://raw.githubusercontent.com/timurgaleev/env/main/${2:-$1}; then
        break
      else
        retry_count=$((retry_count + 1))
        if [ $retry_count -eq $max_retries ]; then
          _error "Failed to download ${2:-$1} after $max_retries attempts"
        fi
        _echo "Download failed, retrying in $wait_time seconds..." 3
        sleep $wait_time
        wait_time=$((wait_time * 2))
      fi
    done
  fi

  # Set appropriate permissions for sensitive files
  case "$1" in
    .ssh/* | .aws/* | *.backup)
      chmod 600 ~/$1
      ;;
  esac
}

_install_npm_package() {
  local package_name="$1"
  local package_spec="$2"

  # Check if package is installed
  if npm list -g "$package_spec" >/dev/null 2>&1; then
    local installed_version=$(npm list -g "$package_spec" --depth=0 2>/dev/null | grep "$package_name" | sed 's/.*@\([0-9.]*\).*/\1/')
    local latest_version=$(npm view "$package_spec" version 2>/dev/null)

    if [ -n "$installed_version" ] && [ -n "$latest_version" ]; then
      if [ "$installed_version" != "$latest_version" ]; then
        _command "Updating $package_name from $installed_version to $latest_version"
        npm update -g "$package_spec"
      # else
      #   _result "$package_name is already up to date ($installed_version)"
      fi
    else
      _command "Installing $package_name (version check failed)"
      npm install -g "$package_spec"
    fi
  else
    _command "Installing $package_name"
    npm install -g "$package_spec"
  fi
}

_install_pip_package() {
  local package_name="$1"

  command -v python3 >/dev/null || HAS_PYTHON=false
  if [ ! -z ${HAS_PYTHON} ]; then
    _result "Python3 not found, skipping pip package installation"
    return 1
  fi

  # Check if package is installed
  if python3 -m pip show "$package_name" >/dev/null 2>&1; then
    local installed_version=$(python3 -m pip show "$package_name" 2>/dev/null | grep "Version:" | awk '{print $2}')
    local latest_version=$(python3 -m pip index versions "$package_name" 2>/dev/null | grep "LATEST:" | awk '{print $2}')

    if [ -n "$installed_version" ] && [ -n "$latest_version" ]; then
      if [ "$installed_version" != "$latest_version" ]; then
        _command "Updating $package_name from $installed_version to $latest_version"
        python3 -m pip install --upgrade "$package_name"
      # else
      #   _result "$package_name is already up to date ($installed_version)"
      fi
    else
      _command "Installing $package_name (version check failed)"
      python3 -m pip install "$package_name"
    fi
  else
    _command "Installing $package_name"
    python3 -m pip install "$package_name"
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
curl -fsSL -o /tmp/.brewpackages https://raw.githubusercontent.com/timurgaleev/env/main/brewpackages

_command "brew bundle..."
brew bundle --file=/tmp/.brewpackages

_command "brew cleanup..."
brew cleanup

# NPM
_install_npm_package "npm" "npm"
_install_npm_package "corepack" "corepack"
_install_npm_package "serverless" "serverless"
_install_npm_package "claude-code" "@anthropic-ai/claude-code"
_install_npm_package "ccusage" "ccusage"


# Claude AI 설정
_download .claude/CLAUDE.md
_download .claude/settings.json

# Cursor AI 설정
_download .cursor/mcp.json

_done
