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

`eval "$(curl -s 'https://raw.githubusercontent.com/luciferavada/satan-shell/master/install-github.sh')"`

## General

### Usage

User configuration goes in `~/.zlogin` which is not managed by __satan-shell__.

Primary configuration files are in the `~/.zsh.d` directory.

  - `~/.zsh.d/directories.conf`
  - `~/.zsh.d/modules.conf`
  - `~/.zsh.d/repositories.conf`
  - `~/.zsh.d/settings.conf`

Modules are installed to the `~/.zsh.d.modules` directory.

Modules can create, store and use configuration files in the `~/.zsh.d.conf` directory.

### Manager

The __satan-shell__ module manager, `satan` has the following options.

`satan`

  - `-S` Install a list of modules.
  - `-R` Uninstall a list of modules.
  - `-Q` Search for available modules.
  - `-X` Search for installed modules.
  - `-y` Update the repository index.
  - `-l` Load a list of modules.
  - `-a` Use the `SATAN_MODULES` array as the list of modules.

### Documentation

The __satan-shell__ documentation viewer, `satan-info` can display *README.md* files for a module.

If no module is specified, `satan-info` displays the __satan-shell__ *README.md*.

If `mdv` is available on the system, it is used to display *README.md* files.

  - [mdv (Terminal Markdown Viewer)](https://github.com/axiros/terminal_markdown_viewer#installation)

### Variables

#### Directories

`SATAN_INSTALL_DIRECTORY`

  - The path to the installation directory.

`SATAN_CONFIGURATION_DIRECTORY`

  - The path to the configuration directory.

`SATAN_MODULES_DIRECTORY`

  - The path to the modules directory.

#### Settings

`SATAN_DISPLAY_ASCII_ART`

  - Display ASCII artwork on load.

`SATAN_DISPLAY_ASCII_TITLE`

  - Display ASCII title on load.

`SATAN_DISPLAY_MODULE_LOAD`

  - Display loaded modules.

### Functions

`satan-reload`

  - Read *zshenv*, *zprofile*, *zshrc* and *zprofile*.

`satan-update`

  - Update __satan-shell__ and activated modules then reload the environment with *satan-reload*.

## Repositories

### Usage

Repositories are managed by the `SATAN_REPOSITORIES` array in `~/.zsh.d/repositories.conf`.

Module repositories are indexed in `~/.zsh.d/.index.available` and installed modules are tracked in `~/.zsh.d/.index.installed`.

### Variables

`SATAN_REPOSITORIES`

  - An ordered list of github organizations containing __satan-shell__ modules as git repositories.

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

### Variables

`SATAN_MODULES`

  - An array of __satan-shell__ modules to load on start.

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
