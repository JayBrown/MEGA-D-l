![MEGAdl-platform-macos](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![MEGAdl-code-shell](https://img.shields.io/badge/code-shell-yellow.svg)
[![MEGAdl-depend-megatools](https://img.shields.io/badge/dependency-megatools%201.9.98-green.svg)](https://github.com/megous/megatools)
[![MEGAdl-depend-tnote](https://img.shields.io/badge/dependency-terminal--notifier%201.7.1-green.svg)](https://github.com/alloy/terminal-notifier)
[![MEGAdl-license](http://img.shields.io/badge/license-MIT+-blue.svg)](https://github.com/JayBrown/MEGA-D-l/blob/master/license.md)

# MEGA D/l <img src="https://github.com/JayBrown/MEGA-D-l/blob/master/img/jb-img.png" height="20px"/>
**macOS workflow and shell script to download files from public mega.nz shares using the megatools**

Minimum OS: **OS X 10.8**

* click on a MEGA URL (or select a bunch of MEGA URLs), and select **Download from MEGA** from **Services** in the contextual menu
* on first run, **MEGA D/l** will ask you to select the location of your MEGA download folder
* you can reset your choice by running the command `rm -rf $HOME/Library/Preferences/local.lcars.MEGAdl.plist`; after that you can select a different folder

## Installations
### megatools [prerequisite]
More information: [megatools](https://github.com/megous/megatools)

* install using [Homebrew](http://brew.sh) with `brew install megatools` (or with a similar manager)

### Main installation
* [Download the latest DMG](https://github.com/JayBrown/MEGA-D-l/releases) and open

#### Workflow
* Double-click on the workflow file to install
* If you encounter problems, open it with Automator and save/install from there
* Standard Finder integration in the Services menu

#### Main shell script [optional]
Only necessary if for some reason you want to run this from the shell or another shell script. For normal use the workflow will be sufficient.

* Move the script `megadl.sh` to e.g. `/usr/local/bin`
* In your shell enter `chmod +x /usr/local/bin/megadl.sh`
* Run the script with `megadl.sh '<URL>'` (it has to be in your $PATH)

### terminal-notifier [optional, recommended]
More information: [terminal-notifier](https://github.com/alloy/terminal-notifier)

You need to have Spotlight enabled for `mdfind` to locate the terminal-notifier.app on your volume; if you don't install terminal-notifier, or if you have deactivated Spotlight, the MEGA D/l scripts will call notifications via AppleScript instead

* install using [Homebrew](http://brew.sh) with `brew install terminal-notifier` (or with a similar manager)
* move or copy `terminal-notifier.app` from the Homebrew Cellar to a suitable location, e.g. to `/Applications`, `/Applications/Utilities`, or `$HOME/Applications`

## Uninstall
Remove the following files or folders:

```
/path/to/your/MEGADownloadFolder/MEGAdupes
$HOME/Library/Caches/local.lcars.MEGAdl
$HOME/Library/Preferences/local.lcars.MEGAdl.plist
$HOME/Library/Services/Download\ from\ MEGA.workflow
/usr/local/bin/megadl.sh
```
