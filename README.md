# zshell-configuration

A modular ZShell configuration.

## Requirements

  - zsh
  - curl
  - git

## Install

`zsh -c $(curl "https://raw.githubusercontent.com/luciferavada/zshell-configuration/master/install-github.sh")`

## Modules

### Configuration

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

  - Updates installed modules. Not used in `~/.zshrc`.

`modules-load`

  - Loads modules in the `MODULES` arary.

### Variables

The following variables are available to modules.

`ZSHELL_MODULES_DIRECTORY`

  - The path to the modules directory.

`ZSHELL_CONFIGURATION_DIRECTORY`

  - The path to the configuration directory.

### Boilerplate

The following example is from [zshell-ssh](https://github.com/luciferavada/zshell-ssh).

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
