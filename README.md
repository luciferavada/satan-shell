# zshell-configuration

A modular ZShell configuration.

## Requirements

  - zsh
  - curl
  - git

## Install

`zsh -c $(curl "https://raw.githubusercontent.com/luciferavada/zshell-configuration/master/install-github.sh")`

## General

### Usage

User configuration goes in `~/.zlogin`.

### Functions

`reload`

  - Reloads the shell configuration.

## Modules

### Usage

Installed modules are managed by the `MODULES` array in `~/.zsh.d/modules.conf`.

### Functions

Most of the following functions are used in `~/.zshrc` and are available in the shell.

`modules-available`

  - Lists the available modules.

`modules-install`

  - Installs modules in the `MODULES` array.

`modules-uninstall`

  - Uninstalls modules removed from the `MODULES` array.

`modules-update`

  - Updates installed modules.

`modules-load`

  - Loads modules in the `MODULES` arary.

### Variables

The following variables are available to modules.

`ZSHELL_MODULES_DIRECTORY`

  - The path to the modules directory.

`ZSHELL_CONFIGURATION_DIRECTORY`

  - The path to the configuration directory.

### Boilerplate

If a module requires configuration, it should include an adaptation of the example below.

The following example is from [zshell-ssh](https://github.com/luciferavada/zshell-ssh/blob/master/ssh.sh).

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

The following example is from [zshell-git](https://github.com/luciferavada/zshell-git/blob/master/prompt.sh).

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
