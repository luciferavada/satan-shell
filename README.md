# sugar-shell

A modular ZShell environment.

## Module Repositories

  - [sugar-core](https://github.com/sugar-core)
  - [sugar-extra](https://github.com/sugar-extra)
  - [sugar-community](https://github.com/sugar-community)

## Requirements

  - zsh
  - curl
  - git

## Install

`eval "$(curl -s 'https://raw.githubusercontent.com/sugarush/sugar-shell/master/install-github.sh')"`

## General

### Screen Shots

![Dark Tmux Theme](screenshots/tmux-theme-dark.png?raw=true "Dark Tmux Theme")

---

![Light Tmux Theme](screenshots/tmux-theme-light.png?raw=true "Light Tmux Theme")

### Usage

User configuration goes in `~/.zlogin` which is not managed by __sugar-shell__.

### Module Manager

The __sugar-shell__ module manager, `sugar` has the following options.

`sugar [flags] [module] <module...>`

  - `-S` Install a list of modules.
  - `-R` Uninstall a list of modules.
  - `-U` Update a list of modules.
  - `-L` Load a list of modules.
  - `-Q` Search for available modules.
  - `-X` Search for installed modules.
  - `-y` Update the repository index.
  - `-a` Use the `SUGAR_MODULES` array as the list of modules.
  - `-i` Use all installed modules as the list of modules.
  - `-f` Force uninstall of modules with modifications.
  - `-r` Reload __sugar-shell__.
  - `-h` Display help.

### Functions

`sugar-ascii-art`

  - Display ascii art.

`sugar-ascii-title`

  - Display ascii title.

`sugar-ascii-header`

  - Display ascii art, title and credit.

`sugar-credit`

  - Display credit.

`sugar-reload`

  - Replace the current shell with a new login shell.

`sugar-update`

  - Update __sugar-shell__.
  - Update enabled modules.
  - Reload the shell with *sugar-reload*.

`sugar-message [type] [message]`

  - Display a formatted *message* of *type*:

    - `title` *Green   -->* `[message]`
    - `bold`  *Magenta ==>* `[message]`
    - `info`  *White   -->* `[message]`
    - `error` *Red     -->* `[message]`

`@sugar-load [function]`

  - Add a function to be called when the shell is loaded.

### Configuration

The __sugar-shell__ configuration files are located in the `~/.zsh.d` directory.

  - `~/.zsh.d/directories.conf`
  - `~/.zsh.d/modules.conf`
  - `~/.zsh.d/repositories.conf`
  - `~/.zsh.d/settings.conf`

### Variables

#### Directories

`SUGAR_INSTALL_DIRECTORY`

  - The path to the installation directory.

`SUGAR_CONFIGURATION_DIRECTORY`

  - The path to the configuration directory.

`SUGAR_MODULES_DIRECTORY`

  - The path to the modules directory.

#### Modules

`SUGAR_MODULES`

  - An array of __sugar-shell__ modules to load on start.

#### Repositories

`SUGAR_REPOSITORIES`

  - An ordered list of github organizations containing __sugar-shell__ modules as git repositories.

#### Settings

`SUGAR_DISPLAY_ASCII_ART`

  - Display ASCII artwork on load.

`SUGAR_DISPLAY_ASCII_TITLE`

  - Display ASCII title on load.

`SUGAR_DISPLAY_MODULE_LOAD`

  - Display loaded modules.

## Modules

### Usage

Modules can be enabled, installed, uninstalled, updated and loaded by *name* or *repository/name*.

Enabled modules are handled by the `SUGAR_MODULES` array in `~/.zsh.d/modules.conf`.

Modules are installed to the `~/.zsh.d.modules` directory.

Modules can create, store and use configuration files in the `~/.zsh.d.conf` directory.

### Functions

`sugar-module-install [module]`

  - Install an available module.

`sugar-module-uninstall [module] <force>`

  - Uninstall a module.
  - Optionally *force* uninstall a module with modifications.

`sugar-module-update-check`

  - Check a module for updates.

`sugar-module-update [module]`

  - Update a module.

`sugar-module-load [module]`

  - Load a module.

`sugar-modules-install [module] <module...>`

  - Install a list of modules.

`sugar-modules-uninstall [module] <module...>`

  - Uninstall a list of modules.

`sugar-modules-update-check [module] <module...>`

  - Check a list of modules for updates.

`sugar-modules-update [module] <module...>`

  - Update a list of modules.

`sugar-modules-load [module] <module...>`

  - Load a list of modules.

`sugar-modules-enabled-install`

  - Install modules in the enabled modules array.

`sugar-modules-enabled-update-check`

  - Check modules in the enabled modules array for updates.

`sugar-modules-enabled-update`

  - Update modules in the enabled modules array.

`sugar-modules-enabled-load`

  - Load modules in the enabled modules array.

`sugar-modules-installed-update-check`

  - Check installed modules for updates.

`sugar-modules-installed-update`

  - Update installed modules.

`sugar-modules-installed-load`

  - Load installed modules.

## Repositories

### Usage

Modules can be found by *name* or *repository/name*.

Modules can be searched for by *pattern*.

Repositories are managed by the `SUGAR_REPOSITORIES` array in `~/.zsh.d/repositories.conf`.

Module repositories are indexed in `~/.zsh.d/.index.available` and installed modules are tracked in `~/.zsh.d/.index.installed`.

### Functions

`sugar-repository-index`

  - Index repositories in the repositories array.

`sugar-module-available-find [module]`

  - Find an available module.

`sugar-module-available-search [pattern]`

  - Search through available modules.

`sugar-module-installed-find [module]`

  - Find an installed module.

`sugar-module-installed-search [pattern]`

  - Search through installed modules.

`sugar-modules-available-find [module] <module...>`

  - Find a list of available module.

`sugar-modules-available-search [pattern] <pattern...>`

  - Search through a list of available modules.

`sugar-modules-installed-find [module] <module...>`

  - Find a list of installed module.

`sugar-modules-installed-search [pattern] <pattern...>`

  - Search through a list of installed modules.
