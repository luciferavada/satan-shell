# satan-shell

A modular ZShell configuration.

## Repositories

  - [satan-core](https://github.com/satan-core)
  - [satan-extra](https://github.com/satan-extra)
  - [satan-community](https://github.com/satan-community)

## Requirements

  - zsh
  - curl
  - git

## Install

`zsh -c $(curl -s "https://raw.githubusercontent.com/luciferavada/satan-shell/master/install-github.sh")`

## General

### Usage

User configuration goes in `~/.zlogin`.

### Functions

`reload`

  - Reload the shell configuration.

## Modules

### Usage

Installed modules are managed by the `MODULES` array in `~/.zsh.d/modules.conf`.

### Functions

Most of the following functions are used in `~/.zshrc` and are available in the shell.

`satan-index`

  - Index satan core, extra and community repositories.

### Variables

The following variables are available to modules.

`ZSHELL_INSTALL_DIRECTORY`

  - The path to the installation directory.

`ZSHELL_CONFIGURATION_DIRECTORY`

  - The path to the configuration directory.

`ZSHELL_MODULES_DIRECTORY`

  - The path to the modules directory.

### Boilerplate

If a module requires configuration, it should include an adaptation of the example below.

The following example is from [satan-extra/ssh](https://github.com/satan-extra/ssh/blob/master/ssh.sh).

```
#  Module configuration
local MODULE_CONF="${ZSHELL_CONFIGURATION_DIRECTORY}/ssh.conf"

#  Write default module configuration
if [ ! -f "${MODULE_CONF}" ]; then
  echo "#  SSH keys" > "${MODULE_CONF}"
  echo "#  SSH_KEYS=(\"luciferavada\")" >> "${MODULE_CONF}"
  echo "SSH_KEYS=()" >> "${MODULE_CONF}"
fi

#  Source module configuration
source "${MODULE_CONF}"
```

### Prompt

The prompt can be configured from within a module, see the example below.

The following example is from [satan-core/git](https://github.com/satan-core/git/blob/master/prompt.sh).

```
local BRANCH="$(git-branch)"
local STATUS="$(git-status)"

local BRANCH_COLOR
BRANCH_COLOR="%F{red}%B${BRANCH}%b%f"
BRANCH_COLOR="%F{yellow}%Bgit:(%b%f${BRANCH_COLOR}%F{yellow}%B)%b%f"

local STATUS_COLOR="%F{yellow}%Bx%b%f"

local GIT_BRANCH="%(${BRANCH}: ${GIT_COLOR}:)"
local GIT_STATUS="%(${STATUS}: ${STATUS_COLOR}:)"

export PROMPT="${PROMPT}${GIT_BRANCH}${GIT_STATUS}"
```
