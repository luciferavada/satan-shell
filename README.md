# santa-shell

A modular ZShell environment.

## Module Repositories

  - [santa-core](https://github.com/santa-core)
  - [santa-extra](https://github.com/santa-extra)
  - [santa-community](https://github.com/santa-community)

## Requirements

  - zsh
  - curl
  - git

## Install

`eval "$(curl -s 'https://raw.githubusercontent.com/lucifersears/santa-shell/master/install-github.sh')"`

## General

### Screen Shots

![Dark Tmux Theme](screenshots/tmux-theme-dark.png?raw=true "Dark Tmux Theme")

---

![Light Tmux Theme](screenshots/tmux-theme-light.png?raw=true "Light Tmux Theme")

### Usage

User configuration goes in `~/.zuser`.

### Module Manager

The __santa-shell__ module manager, `santa` has the following options.

`santa [flags] [module] <module...>`

  - `-S` Install a list of modules.
  - `-R` Uninstall a list of modules.
  - `-U` Update a list of modules.
  - `-L` Load a list of modules.
  - `-Q` Search for available modules.
  - `-X` Search for installed modules.
  - `-y` Update the repository index.
  - `-a` Use the `SANTA_MODULES` array as the list of modules.
  - `-i` Use all installed modules as the list of modules.
  - `-f` Force uninstall of modules with modifications.
  - `-r` Reload __santa-shell__.
  - `-h` Display help.

### Functions

`santa-ascii-skull` `skull`

  - Display ascii art.

`santa-ascii-title`

  - Display ascii title.

`santa-ascii-header`

  - Display ascii art, title and credit.

`santa-credit`

  - Display credit.

`santa-reload` `reload`

  - Replace the current shell with a new login shell.

`santa-update` `update`

  - Update __santa-shell__.
  - Update enabled modules.
  - Reload the shell with *santa-reload*.

`santa-message [type] [message]`

  - Display a formatted *message* of *type*:

    - `title` *Green   -->* `[message]`
    - `bold`  *Magenta ==>* `[message]`
    - `info`  *White   -->* `[message]`
    - `error` *Red     -->* `[message]`

`@santa-load [function]`

  - Add a function to be called when the shell is loaded.

### Configuration

The __santa-shell__ configuration files are located in the `~/.zsh.d` directory.

  - `~/.zsh.d/directories.conf`
  - `~/.zsh.d/modules.conf`
  - `~/.zsh.d/repositories.conf`
  - `~/.zsh.d/settings.conf`

### Variables

#### Directories

`SANTA_INSTALL_DIRECTORY`

  - The path to the installation directory.

`SANTA_CONFIGURATION_DIRECTORY`

  - The path to the configuration directory.

`SANTA_MODULES_DIRECTORY`

  - The path to the modules directory.

#### Modules

`SANTA_MODULES`

  - An array of __santa-shell__ modules to load on start.

#### Repositories

`SANTA_REPOSITORIES`

  - An ordered list of github organizations containing __santa-shell__ modules as git repositories.

#### Settings

`SANTA_DISPLAY_ASCII_ART`

  - Display ASCII artwork on load.

`SANTA_DISPLAY_ASCII_TITLE`

  - Display ASCII title on load.

`SANTA_DISPLAY_MODULE_LOAD`

  - Display loaded modules.

## Modules

### Usage

Modules can be enabled, installed, uninstalled, updated and loaded by *name* or *repository/name*.

Enabled modules are handled by the `SANTA_MODULES` array in `~/.zsh.d/modules.conf`.

Modules are installed to the `~/.zsh.d.modules` directory.

Modules can create, store and use configuration files in the `~/.zsh.d.conf` directory.

### Functions

`santa-module-install [module]`

  - Install an available module.

`santa-module-uninstall [module] <force>`

  - Uninstall a module.
  - Optionally *force* uninstall a module with modifications.

`santa-module-update-check`

  - Check a module for updates.

`santa-module-update [module]`

  - Update a module.

`santa-module-load [module]`

  - Load a module.

`santa-modules-install [module] <module...>`

  - Install a list of modules.

`santa-modules-uninstall [module] <module...>`

  - Uninstall a list of modules.

`santa-modules-update-check [module] <module...>`

  - Check a list of modules for updates.

`santa-modules-update [module] <module...>`

  - Update a list of modules.

`santa-modules-load [module] <module...>`

  - Load a list of modules.

`santa-modules-enabled-install`

  - Install modules in the enabled modules array.

`santa-modules-enabled-update-check`

  - Check modules in the enabled modules array for updates.

`santa-modules-enabled-update`

  - Update modules in the enabled modules array.

`santa-modules-enabled-load`

  - Load modules in the enabled modules array.

`santa-modules-installed-update-check`

  - Check installed modules for updates.

`santa-modules-installed-update`

  - Update installed modules.

`santa-modules-installed-load`

  - Load installed modules.

## Repositories

### Usage

Modules can be found by *name* or *repository/name*.

Modules can be searched for by *pattern*.

Repositories are managed by the `SANTA_REPOSITORIES` array in `~/.zsh.d/repositories.conf`.

Module repositories are indexed in `~/.zsh.d/.index.available` and installed modules are tracked in `~/.zsh.d/.index.installed`.

### Functions

`santa-repository-index`

  - Index repositories in the repositories array.

`santa-module-available-find [module]`

  - Find an available module.

`santa-module-available-search [pattern]`

  - Search through available modules.

`santa-module-installed-find [module]`

  - Find an installed module.

`santa-module-installed-search [pattern]`

  - Search through installed modules.

`santa-modules-available-find [module] <module...>`

  - Find a list of available module.

`santa-modules-available-search [pattern] <pattern...>`

  - Search through a list of available modules.

`santa-modules-installed-find [module] <module...>`

  - Find a list of installed module.

`santa-modules-installed-search [pattern] <pattern...>`

  - Search through a list of installed modules.
