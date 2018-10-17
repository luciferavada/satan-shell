# satan-shell

A modular ZShell environment.

## Module Repositories

  - [satan-core](https://github.com/satan-core)
  - [satan-extra](https://github.com/satan-extra)
  - [satan-community](https://github.com/satan-community)

## Requirements

  - zsh
  - curl
  - git

## Install

`eval "$(curl -s 'https://raw.githubusercontent.com/satanush/satan-shell/master/install-github.sh')"`

## General

### Screen Shots

![Dark Tmux Theme](screenshots/tmux-theme-dark.png?raw=true "Dark Tmux Theme")

---

![Light Tmux Theme](screenshots/tmux-theme-light.png?raw=true "Light Tmux Theme")

### Usage

User configuration goes in `~/.zlogin` which is not managed by __satan-shell__.

### Module Manager

The __satan-shell__ module manager, `satan` has the following options.

`satan [flags] [module] <module...>`

  - `-S` Install a list of modules.
  - `-R` Uninstall a list of modules.
  - `-U` Update a list of modules.
  - `-L` Load a list of modules.
  - `-Q` Search for available modules.
  - `-X` Search for installed modules.
  - `-y` Update the repository index.
  - `-a` Use the `SATAN_MODULES` array as the list of modules.
  - `-i` Use all installed modules as the list of modules.
  - `-f` Force uninstall of modules with modifications.
  - `-r` Reload __satan-shell__.
  - `-h` Display help.

### Functions

`satan-ascii-art`

  - Display ascii art.

`satan-ascii-title`

  - Display ascii title.

`satan-ascii-header`

  - Display ascii art, title and credit.

`satan-credit`

  - Display credit.

`satan-reload`

  - Replace the current shell with a new login shell.

`satan-update`

  - Update __satan-shell__.
  - Update enabled modules.
  - Reload the shell with *satan-reload*.

`satan-message [type] [message]`

  - Display a formatted *message* of *type*:

    - `title` *Green   -->* `[message]`
    - `bold`  *Magenta ==>* `[message]`
    - `info`  *White   -->* `[message]`
    - `error` *Red     -->* `[message]`

`@satan-load [function]`

  - Add a function to be called when the shell is loaded.

### Configuration

The __satan-shell__ configuration files are located in the `~/.zsh.d` directory.

  - `~/.zsh.d/directories.conf`
  - `~/.zsh.d/modules.conf`
  - `~/.zsh.d/repositories.conf`
  - `~/.zsh.d/settings.conf`

### Variables

#### Directories

`SATAN_INSTALL_DIRECTORY`

  - The path to the installation directory.

`SATAN_CONFIGURATION_DIRECTORY`

  - The path to the configuration directory.

`SATAN_MODULES_DIRECTORY`

  - The path to the modules directory.

#### Modules

`SATAN_MODULES`

  - An array of __satan-shell__ modules to load on start.

#### Repositories

`SATAN_REPOSITORIES`

  - An ordered list of github organizations containing __satan-shell__ modules as git repositories.

#### Settings

`SATAN_DISPLAY_ASCII_ART`

  - Display ASCII artwork on load.

`SATAN_DISPLAY_ASCII_TITLE`

  - Display ASCII title on load.

`SATAN_DISPLAY_MODULE_LOAD`

  - Display loaded modules.

## Modules

### Usage

Modules can be enabled, installed, uninstalled, updated and loaded by *name* or *repository/name*.

Enabled modules are handled by the `SATAN_MODULES` array in `~/.zsh.d/modules.conf`.

Modules are installed to the `~/.zsh.d.modules` directory.

Modules can create, store and use configuration files in the `~/.zsh.d.conf` directory.

### Functions

`satan-module-install [module]`

  - Install an available module.

`satan-module-uninstall [module] <force>`

  - Uninstall a module.
  - Optionally *force* uninstall a module with modifications.

`satan-module-update-check`

  - Check a module for updates.

`satan-module-update [module]`

  - Update a module.

`satan-module-load [module]`

  - Load a module.

`satan-modules-install [module] <module...>`

  - Install a list of modules.

`satan-modules-uninstall [module] <module...>`

  - Uninstall a list of modules.

`satan-modules-update-check [module] <module...>`

  - Check a list of modules for updates.

`satan-modules-update [module] <module...>`

  - Update a list of modules.

`satan-modules-load [module] <module...>`

  - Load a list of modules.

`satan-modules-enabled-install`

  - Install modules in the enabled modules array.

`satan-modules-enabled-update-check`

  - Check modules in the enabled modules array for updates.

`satan-modules-enabled-update`

  - Update modules in the enabled modules array.

`satan-modules-enabled-load`

  - Load modules in the enabled modules array.

`satan-modules-installed-update-check`

  - Check installed modules for updates.

`satan-modules-installed-update`

  - Update installed modules.

`satan-modules-installed-load`

  - Load installed modules.

## Repositories

### Usage

Modules can be found by *name* or *repository/name*.

Modules can be searched for by *pattern*.

Repositories are managed by the `SATAN_REPOSITORIES` array in `~/.zsh.d/repositories.conf`.

Module repositories are indexed in `~/.zsh.d/.index.available` and installed modules are tracked in `~/.zsh.d/.index.installed`.

### Functions

`satan-repository-index`

  - Index repositories in the repositories array.

`satan-module-available-find [module]`

  - Find an available module.

`satan-module-available-search [pattern]`

  - Search through available modules.

`satan-module-installed-find [module]`

  - Find an installed module.

`satan-module-installed-search [pattern]`

  - Search through installed modules.

`satan-modules-available-find [module] <module...>`

  - Find a list of available module.

`satan-modules-available-search [pattern] <pattern...>`

  - Search through a list of available modules.

`satan-modules-installed-find [module] <module...>`

  - Find a list of installed module.

`satan-modules-installed-search [pattern] <pattern...>`

  - Search through a list of installed modules.
