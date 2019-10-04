# candy

A modular ZShell environment.

## Module Repositories

  - [candy-core](https://github.com/candy-core)
  - [candy-extra](https://github.com/candy-extra)
  - [candy-community](https://github.com/candy-community)

## Requirements

  - zsh
  - curl
  - git

## Install

`eval "$(curl -s 'https://raw.githubusercontent.com/sugarush/candy/master/install-github.sh')"`

## General

### Screen Shots

![Dark Tmux Theme](screenshots/tmux-theme-dark.png?raw=true "Dark Tmux Theme")

---

![Light Tmux Theme](screenshots/tmux-theme-light.png?raw=true "Light Tmux Theme")

### Usage

User configuration goes in `~/.zuser`.

### Module Manager

The __candy__ module manager, `candy` has the following options.

`candy [flags] [module] <module...>`

  - `-S` Install a list of modules.
  - `-R` Uninstall a list of modules.
  - `-U` Update a list of modules.
  - `-L` Load a list of modules.
  - `-Q` Search for available modules.
  - `-X` Search for installed modules.
  - `-y` Update the repository index.
  - `-a` Use the `CANDY_MODULES` array as the list of modules.
  - `-i` Use all installed modules as the list of modules.
  - `-f` Force uninstall of modules with modifications.
  - `-r` Reload __candy__.
  - `-h` Display help.

### Functions

`candy-ascii-skull` `skull`

  - Display ascii art.

`candy-ascii-title`

  - Display ascii title.

`candy-ascii-header`

  - Display ascii art, title and credit.

`candy-credit`

  - Display credit.

`candy-reload` `reload`

  - Replace the current shell with a new login shell.

`candy-update` `update`

  - Update __candy__.
  - Update enabled modules.
  - Reload the shell with *candy-reload*.

`candy-message [type] [message]`

  - Display a formatted *message* of *type*:

    - `title` *Green   -->* `[message]`
    - `bold`  *Magenta ==>* `[message]`
    - `info`  *White   -->* `[message]`
    - `error` *Red     -->* `[message]`

`@candy-load [function]`

  - Add a function to be called when the shell is loaded.

### Configuration

The __candy__ configuration files are located in the `~/.zsh.d` directory.

  - `~/.zsh.d/directories.conf`
  - `~/.zsh.d/modules.conf`
  - `~/.zsh.d/repositories.conf`
  - `~/.zsh.d/settings.conf`

### Variables

#### Directories

`CANDY_INSTALL_DIRECTORY`

  - The path to the installation directory.

`CANDY_CONFIGURATION_DIRECTORY`

  - The path to the configuration directory.

`CANDY_MODULES_DIRECTORY`

  - The path to the modules directory.

#### Modules

`CANDY_MODULES`

  - An array of __candy__ modules to load on start.

#### Repositories

`CANDY_REPOSITORIES`

  - An ordered list of github organizations containing __candy__ modules as git repositories.

#### Settings

`CANDY_DISPLAY_ASCII_ART`

  - Display ASCII artwork on load.

`CANDY_DISPLAY_ASCII_TITLE`

  - Display ASCII title on load.

`CANDY_DISPLAY_MODULE_LOAD`

  - Display loaded modules.

## Modules

### Usage

Modules can be enabled, installed, uninstalled, updated and loaded by *name* or *repository/name*.

Enabled modules are handled by the `CANDY_MODULES` array in `~/.zsh.d/modules.conf`.

Modules are installed to the `~/.zsh.d.modules` directory.

Modules can create, store and use configuration files in the `~/.zsh.d.conf` directory.

### Functions

`candy-module-install [module]`

  - Install an available module.

`candy-module-uninstall [module] <force>`

  - Uninstall a module.
  - Optionally *force* uninstall a module with modifications.

`candy-module-update-check`

  - Check a module for updates.

`candy-module-update [module]`

  - Update a module.

`candy-module-load [module]`

  - Load a module.

`candy-modules-install [module] <module...>`

  - Install a list of modules.

`candy-modules-uninstall [module] <module...>`

  - Uninstall a list of modules.

`candy-modules-update-check [module] <module...>`

  - Check a list of modules for updates.

`candy-modules-update [module] <module...>`

  - Update a list of modules.

`candy-modules-load [module] <module...>`

  - Load a list of modules.

`candy-modules-enabled-install`

  - Install modules in the enabled modules array.

`candy-modules-enabled-update-check`

  - Check modules in the enabled modules array for updates.

`candy-modules-enabled-update`

  - Update modules in the enabled modules array.

`candy-modules-enabled-load`

  - Load modules in the enabled modules array.

`candy-modules-installed-update-check`

  - Check installed modules for updates.

`candy-modules-installed-update`

  - Update installed modules.

`candy-modules-installed-load`

  - Load installed modules.

## Repositories

### Usage

Modules can be found by *name* or *repository/name*.

Modules can be searched for by *pattern*.

Repositories are managed by the `CANDY_REPOSITORIES` array in `~/.zsh.d/repositories.conf`.

Module repositories are indexed in `~/.zsh.d/.index.available` and installed modules are tracked in `~/.zsh.d/.index.installed`.

### Functions

`candy-repository-index`

  - Index repositories in the repositories array.

`candy-module-available-find [module]`

  - Find an available module.

`candy-module-available-search [pattern]`

  - Search through available modules.

`candy-module-installed-find [module]`

  - Find an installed module.

`candy-module-installed-search [pattern]`

  - Search through installed modules.

`candy-modules-available-find [module] <module...>`

  - Find a list of available module.

`candy-modules-available-search [pattern] <pattern...>`

  - Search through a list of available modules.

`candy-modules-installed-find [module] <module...>`

  - Find a list of installed module.

`candy-modules-installed-search [pattern] <pattern...>`

  - Search through a list of installed modules.
