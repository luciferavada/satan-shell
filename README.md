# satan-shell<br>

A modular ZShell configuration.

## Module Repositories<br>

  - [satan-core](https://github.com/satan-core)
  - [satan-extra](https://github.com/satan-extra)
  - [satan-community](https://github.com/satan-community)

## Requirements<br>

  - zsh
  - curl
  - git

## Recommended<br>

  - [mdv (Terminal Markdown Viewer)](https://github.com/axiros/terminal_markdown_viewer#installation)

## Install<br>

`eval "$(curl -s 'https://raw.githubusercontent.com/luciferavada/satan-shell/master/install-github.sh')"`

## General

### Usage<br>

User configuration goes in `~/.zlogin` which is not managed by __satan-shell__.

### Manager<br>

The __satan-shell__ module manager, `satan` has the following options.<br>

`satan [flags] [module] <module...>`

  - `-S` Install a list of modules.
  - `-R` Uninstall a list of modules.
  - `-Q` Search for available modules.
  - `-X` Search for installed modules.
  - `-y` Update the repository index.
  - `-l` Load a list of modules.
  - `-a` Use the `SATAN_MODULES` array as the list of modules.

### Documentation<br>

The __satan-shell__ documentation viewer, `satan-info` can be used as follows.<br>

`satan-info [module] <pattern>`

  - Display documentation for a *module*.
  - Optionally search for a *pattern* in the documentation.
  - If no module is specified, the __satan-shell__ documentation is displayed.
  - If [mdv (Terminal Markdown Viewer)](https://github.com/axiros/terminal_markdown_viewer#installation) is available on the system, it is used to display documentation.

### Functions<br>

`satan-ascii-art`

  - Display ascii art.<br>

`satan-ascii-title`

  - Display ascii title.<br>

`satan-ascii-header`

  - Display ascii art, title and credit.<br>

`satan-credit`

  - Display credit.<br>

`satan-reload`

  - Replace the current shell with a new login shell.<br>

`satan-update`

  - Update __satan-shell__.
  - Update activated modules.
  - Reload the shell with *satan-reload*.<br>

`satan-message [type] [message]`

  - Display a formatted *message* of *type*:

    - `title` *Green   -->* `[message]`
    - `bold`  *Magenta ==>* `[message]`
    - `info`  *White   -->* `[message]`
    - `error` *Red     -->* `[message]`

### Configuration<br>

The __satan-shell__ configuration files are located in the `~/.zsh.d` directory.<br>

  - `~/.zsh.d/directories.conf`
  - `~/.zsh.d/modules.conf`
  - `~/.zsh.d/repositories.conf`
  - `~/.zsh.d/settings.conf`

### Variables

#### Directories<br>

`SATAN_INSTALL_DIRECTORY`

  - The path to the installation directory.<br>

`SATAN_CONFIGURATION_DIRECTORY`

  - The path to the configuration directory.<br>

`SATAN_MODULES_DIRECTORY`

  - The path to the modules directory.

#### Modules<br>

`SATAN_MODULES`

  - An array of __satan-shell__ modules to load on start.

#### Repositories<br>

`SATAN_REPOSITORIES`

  - An ordered list of github organizations containing __satan-shell__ modules as git repositories.

#### Settings<br>

`SATAN_DISPLAY_ASCII_ART`

  - Display ASCII artwork on load.<br>

`SATAN_DISPLAY_ASCII_TITLE`

  - Display ASCII title on load.<br>

`SATAN_DISPLAY_MODULE_LOAD`

  - Display loaded modules.<br>

`SATAN_USE_MARKDOWN_VIEWER`

  - Display documentation with *mdv (Terminal Markdown Viewer)*.<br>

`SATAN_MARKDOWN_VIEWER_THEME`

  - The *mdv (Terminal Markdown Viewer)* theme to use.

## Modules

### Usage<br>

Modules can be activated, installed, uninstalled, updated and loaded by *name* or *repository/name*.<br>

Activated modules are handled by the `SATAN_MODULES` array in `~/.zsh.d/modules.conf`.<br>

Modules are installed to the `~/.zsh.d.modules` directory.<br>

Modules can create, store and use configuration files in the `~/.zsh.d.conf` directory.

### Functions<br>

`satan-module-install [module]`

  - Install an available module.<br>

`satan-module-uninstall [module]`

  - Uninstall a module.<br>

`satan-module-update [module]`

  - Update a module.<br>

`satan-module-load [module]`

  - Load a module.<br>

`satan-modules-install [module] <module...>`

  - Install a list of modules.<br>

`satan-modules-uninstall [module] <module...>`

  - Uninstall a list of modules.<br>

`satan-modules-update [module] <module...>`

  - Update a list of modules.<br>

`satan-modules-load [module] <module...>`

  - Load a list of modules.<br>

`satan-modules-active-install`

  - Install modules in the activated modules array.<br>

`satan-modules-active-update`

  - Update modules in the activated modules array.<br>

`satan-modules-active-load`

  - Load modules in the activated modules array.

## Repositories

### Usage<br>

Modules can be found by *name* or *repository/name*.<br>

Modules can be searched for by *pattern*.<br>

Repositories are managed by the `SATAN_REPOSITORIES` array in `~/.zsh.d/repositories.conf`.<br>

Module repositories are indexed in `~/.zsh.d/.index.available` and installed modules are tracked in `~/.zsh.d/.index.installed`.

### Functions<br>

`satan-repository-index`

  - Index repositories in the repositories array.<br>

`satan-module-available-find [module]`

  - Find an available module.<br>

`satan-module-available-search [pattern]`

  - Search through available modules.<br>

`satan-module-installed-find [module]`

  - Find an installed module.<br>

`satan-module-installed-search [pattern]`

  - Search through installed modules.<br>

`satan-modules-available-find [module] <module...>`

  - Find a list of available module.<br>

`satan-modules-available-search [pattern] <pattern...>`

  - Search through a list of available modules.<br>

`satan-modules-installed-find [module] <module...>`

  - Find a list of installed module.<br>

`satan-modules-installed-search [pattern] <pattern...>`

  - Search through a list of installed modules.

## Developer

### Usage<br>

Developer state for a module can be managed by *name* or *repository/name*.<br>

Files of the format `*.sh` in the root of the module are loaded by default.<br>

The following variables are available inside module files.

### Variables<br>

`MODULE_NAME`

  - The name of the module.<br>

`MODULE_REPOSITORY`

  - The name of the module the repository.<br>

`MODULE_DIRECTORY`

  - The path to the module.

### Functions<br>

`satan-module-developer-init [module]`

  - Initialize a new module.<br>

`satan-module-developer-enable [module]`

  - Set the git origin url for a module to use the SSH protocol.<br>

`satan-module-developer-disable [module]`

  - Set the git origin url for a module to use the HTTPS protocol.<br>

`satan-module-developer-status [module]`

  - Report if a module has any modified files.<br>

`satan-modules-developer-init [module] <module...>`

  - Initialize a list of new modules.<br>

`satan-modules-developer-enable [module] <module...>`

  - Set the git origin url for a list of modules.<br>

`satan-modules-developer-disable [module] <module...>`

  - Set the git origin url for a list of modules.<br>

`satan-modules-developer-status [module] <module...>`

  - Report if a list of modules have any modified files.<br>

`satan-modules-developer-active-enable`

  - Set the git origin url for activated modules to use the SSH protocol.<br>

`satan-modules-developer-active-disable`

  - Set the git origin url for activated modules to use the HTTPS protocol.<br>

`satan-modules-developer-active-status`

  - Report if any activated modules have modified files.<br>

`satan-modules-developer-installed-enable`

  - Set the git origin url for installed modules to use the SSH protocol.<br>

`satan-modules-developer-installed-disable`

  - Set the git origin url for installed modules to use the HTTPS protocol.<br>

`satan-modules-developer-installed-status`

  - Report if any installed modules have modified files.
