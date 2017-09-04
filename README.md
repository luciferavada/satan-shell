# satan-shell

A modular ZShell configuration.

## Module Repositories

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

The __satan-shell__ primary configuration files are `~/.zsh.d/rc.conf` and `~/.zsh.d/modules.conf.`

User configuration goes in `~/.zlogin` which is not managed by __satan-shell__.

Modules are installed to the `~/.zsh.d.modules` directory.

Modules can create, store and use configuration files in the `~/.zsh.d.conf` directory.

### Variables

`SATAN_INSTALL_DIRECTORY`

  - The path to the installation directory.

`SATAN_CONFIGURATION_DIRECTORY`

  - The path to the configuration directory.

`SATAN_MODULES_DIRECTORY`

  - The path to the modules directory.

`SATAN_REPOSITORIES`

  - An ordered list of github organizations containing __satan-shell__ modules as git repositories.

### Functions

`satan-init`

  - Read *zshenv*, *zprofile*, *zshrc* and *zprofile*.

`satan-reload`

  - Synonymous with *satan-init*.

`satan-update`

  - Update __satan-shell__ and activated modules then reload the environment with *satan-reload*.

## Repositories

### Usage

Repositories are managed by the `SATAN_REPOSITORIES` array in `~/.zsh.d/rc.conf`.

Module repositories are indexed in `~/.zsh.d/.modules.available` and installed modules are tracked in `~/.zsh.d/.modules.installed`.

### Functions

`satan-repository-index`

  - Index repositories in the repositories array.

`satan-module-available-find`

  - Find an available module by *name* or *repository/name*.

`satan-module-available-search`

  - Search through available modules.

`satan-module-installed-find`

  - Find an installed module by *name* or *repository/name*.

`satan-module-installed-search`

  - Search through installed modules.

`satan-modules-available-find`

  - Find a list of available module by *name* or *repository/name*.

`satan-modules-available-search`

  - Search through a list of available modules.

`satan-modules-installed-find`

  - Find a list of installed module by *name* or *repository/name*.

`satan-modules-installed-search`

  - Search through a list of installed modules.

## Modules

### Usage

Activated modules are managed by the `SATAN_MODULES` array in `~/.zsh.d/modules.conf`.

### Functions

`satan-module-install`

  - Install an available module by *name* or *repository/name*.

`satan-module-uninstall`

  - Uninstall a module by *name* or *repository/name*.

`satan-module-update`

  - Update a module by *name* or *repository/name*.

`satan-module-load`

  - Load a module by *name* or *repository/name*.

`satan-modules-install`

  - Install a list of modules by *name* or *repository/name*.

`satan-modules-uninstall`

  - Uninstall a list of modules by *name* or *repository/name*.

`satan-modules-update`

  - Update a list of modules by *name* or *repository/name*.

`satan-modules-load`

  - Load a list of modules by *name* or *repository/name*.

`satan-modules-active-install`

  - Install modules in the activated modules array.

`satan-modules-active-update`

  - Update modules in the activated modules array.

`satan-modules-active-load`

  - Load modules in the activated modules array.

## Developer

### Usage

Files of the format `*.sh` in the root of the module are loaded by default.

### Variables

`MODULE_REPOSITORY`

  - The name of the repository in which the module resides.

`MODULE_NAME`

  - The name of the module.

`MODULE_DIRECTORY`

  - The path to the module.

### Functions

`satan-module-developer-enable`

  - Set the git origin url for a module by *name* or *repository/name* to use the SSH protocol.

`satan-module-developer-disable`

  - Set the git origin url for a module by *name* or *repository/name* to use the HTTPS protocol.

`satan-module-developer-status`

  - Report if a module by *name* or *repository/name* has any modified files.

`satan-modules-developer-enable`

  - Set the git origin url for a list of modules by *name* or *repository/name* to use the SSH protocol.

`satan-modules-developer-disable`

  - Set the git origin url for a list of modules by *name* or *repository/name* to use the HTTPS protocol.

`satan-modules-developer-status`

  - Report if a list of modules by *name* or *repository/name* have any modified files.

`satan-developer-enable`

  - Set the git origin url for activated modules to use the SSH protocol.

`satan-developer-disable`

  - Set the git origin url for activated modules to use the HTTPS protocol.

`satan-developer-status`

  - Report if any activated modules have modified files.
