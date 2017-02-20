#!/bin/bash

# MEGA D/l v1.1.0
# MEGA D/l (shell script version)

# download public mega.nz shares
# prerequisite: megatools, terminal-notifier (install with Homebrew)
# optional: terminal-notifier (install with Homebrew)

# to reset the MEGA download folder, run the following command:
# rm -rf $HOME/Library/Preferences/local.lcars.MEGAdl.plist

LANG=en_US.UTF-8
export PATH=/usr/local/bin:$PATH
ACCOUNT=$(/usr/bin/id -un)
CURRENT_VERSION="1.1"

# notify function
notify () {
 	if [[ "$NOTESTATUS" == "osa" ]] ; then
		/usr/bin/osascript &>/dev/null << EOT
tell application "System Events"
	display notification "$2" with title "MEGA D/l [" & "$ACCOUNT" & "]" subtitle "$1"
end tell
EOT
	elif [[ "$NOTESTATUS" == "tn" ]] ; then
		"$TERMNOTE_LOC/Contents/MacOS/terminal-notifier" \
			-title "MEGA D/l [$ACCOUNT]" \
			-subtitle "$1" \
			-message "$2" \
			-appIcon "$ICON_LOC" \
			>/dev/null
	fi
}

# check for update
updater () {
	echo "Checking for update..."
	NEWEST_VERSION=$(/usr/bin/curl --silent https://api.github.com/repos/JayBrown/Checksums/releases/latest | /usr/bin/awk '/tag_name/ {print $2}' | xargs)
	if [[ "$NEWEST_VERSION" == "" ]] ; then
		NEWEST_VERSION="0"
	fi
	NEWEST_VERSION=${NEWEST_VERSION//,}
	if (( $(echo "$NEWEST_VERSION > $CURRENT_VERSION" | /usr/bin/bc -l) )) ; then
		notify "⚠️ Update available" "MEGA D/l v$NEWEST_VERSION"
		/usr/bin/open "https://github.com/JayBrown/MEGA-D-l/releases/latest"
	fi
}

# check compatibility
MACOS2NO=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $2}')
if [[ "$MACOS2NO" -le 7 ]] ; then
	echo "Error! Exiting…"
	echo "MEGA D/l needs at least OS X 10.8 (Mountain Lion)"
	INFO=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set userChoice to button returned of (display alert "Error! Minimum OS requirement:" & return & "OS X 10.8 (Mountain Lion)" ¬
		as critical ¬
		buttons {"Quit"} ¬
		default button 1 ¬
		giving up after 60)
end tell
EOT)
	exit
fi

# icon & cache dir
ICON64="iVBORw0KGgoAAAANSUhEUgAAAIwAAACMEAYAAAD+UJ19AAACYElEQVR4nOzUsW1T
URxH4fcQSyBGSPWQrDRZIGUq2IAmJWyRMgWRWCCuDAWrGDwAkjsk3F/MBm6OYlnf
19zqSj/9i/N6jKenaRpjunhXV/f30zTPNzePj/N86q9fHx4evi9j/P202/3+WO47
D2++3N4uyzS9/Xp3d319+p3W6+fncfTnqNx3Lpbl3bf/72q1+jHPp99pu91sfr4f
43DY7w+fu33n4tVLDwAul8AAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzAABmBATIC
A2QEBsgIDJARGCAjMEBGYICMwAAZgQEyAgNkBAbICAyQERggIzBARmCAjMAAGYEB
MgIDZAQGyAgMkBEYICMwQEZggIzAABmBATICA2QEBsgIDJARGCAjMEBGYICMwAAZ
gQEyAgNkBAbICAyQERggIzBARmCAjMAAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzA
ABmBATICA2QEBsgIDJARGCAjMEBGYICMwAAZgQEyAgNkBAbICAyQERggIzBARmCA
jMAAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzAABmBATICA2QEBsgIDJARGCAjMEBG
YICMwAAZgQEyAgNkBAbICAyQERggIzBARmCAjMAAGYEBMgIDZAQGyAgMkBEYICMw
QEZggIzAABmBATICA2QEBsgIDJARGCAjMEBGYICMwAAZgQEyAgNkBAbICAyQERgg
IzBARmCAjMAAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzAABmBATICA2QEBsgIDJAR
GCAjMEBGYICMwAAZgQEy/wIAAP//nmUueblZmDIAAAAASUVORK5CYII="
CACHE_DIR="$HOME/Library/Caches/local.lcars.MEGAdl"
mkdir -p "$CACHE_DIR"
ICON_LOC="$CACHE_DIR/lcars.png"
if [[ ! -e "$ICON_LOC" ]] ; then
	echo "$ICON64" > "$CACHE_DIR/lcars.base64"
	/usr/bin/base64 -D -i "$CACHE_DIR/lcars.base64" -o "$ICON_LOC" && rm -rf "$CACHE_DIR/lcars.base64"
fi
if [[ -e "$CACHE_DIR/lcars.base64" ]] ; then
	rm -rf "$CACHE_DIR/lcars.base64"
fi

# look for terminal-notifier
TERMNOTE_LOC=$(/usr/bin/mdfind "kMDItemCFBundleIdentifier == 'nl.superalloy.oss.terminal-notifier'" 2>/dev/null | /usr/bin/awk 'NR==1')
if [[ "$TERMNOTE_LOC" == "" ]] ; then
	NOTESTATUS="osa"
else
	NOTESTATUS="tn"
fi

# check if megadl binary is present
MEGADOWN=$(which megadl 2>/dev/null)
if [[ "$MEGADOWN" != "/"*"/megadl" ]] ; then
	notify "✖️ Aborted!" "Please install megatools!"
	open https://github.com/megous/megatools
	exit
fi

# check for preferences file
PREFS="local.lcars.MEGAdl"
if [[ ! -f "$HOME/Library/Preferences/$PREFS.plist" ]] ; then
	touch "$HOME/Library/Preferences/$PREFS.plist"
	/usr/bin/defaults write $PREFS dlDir ""
fi

# set download directory
DL_DIR=$(/usr/bin/defaults read $PREFS dlDir 2>/dev/null)
if [[ "$DL_DIR" == "" ]] ; then
	DL_DIR=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theStartDirectory to ((path to downloads folder from user domain) as text) as alias
	set theMegaFolder to choose folder with prompt "Please select your MEGA download folder…" default location theStartDirectory
	set theMegaFolderPath to (POSIX path of theMegaFolder)
end tell
theMegaFolderPath
EOT)
	if [[ "$DL_DIR" == "" ]] || [[ "$DL_DIR" == "false" ]] ; then
		exit
	fi
	/usr/bin/defaults write $PREFS dlDir "$DL_DIR"
	notify "☑️ Download folder set" "${DL_DIR/$HOME/~}"
fi

for URL in "$@"
do

# check & convert URL
if [[ $URL == "http://www.nullrefer.com"* ]] ; then
	URL=$(echo $URL | /usr/bin/awk -F? '{print $2}')
fi
if [[ $URL != *"mega.nz/"* ]] && [[ $URL != *"mega.co.nz/"* ]] ; then
	notify "❌ Error!" "Not a MEGA URL!"
	continue
elif [[ $URL == *" ... "* ]] ; then
	notify "☠️ Error!" "Poor URL formatting"
	continue
else
	if [[ $URL == *"mega.co.nz/"* ]] ; then
		URL=$(echo $URL | /usr/bin/awk '{gsub("mega.co.nz","mega.nz"); print}')
	fi
	MEGA_URL=$(echo $URL | /usr/bin/awk '{gsub("\#","_"); gsub("\!","+"); print}')
	CODE=$(echo "$MEGA_URL" | /usr/bin/awk -F+ '{print $2}')
	SECRET=$(echo "$MEGA_URL" | /usr/bin/awk -F+ '{print $3}')
	SEC_COUNT=$(echo "$SECRET" | /usr/bin/wc -c | /usr/bin/xargs)
	if [[ "$SEC_COUNT" -lt 44 ]] ; then
		notify "☠️ Error!" "Poor URL formatting"
		continue
	fi
fi

# check if file online or offline
STATUS=$(/usr/bin/curl --silent --data-ascii '[{"a":"g", "g":1, "ssl":0, "p":"'$CODE'"}]' https://eu.api.mega.co.nz/cs)
if [[ "$STATUS" == "[-9]" ]] ; then
	notify "❌ File offline $STATUS" "mega.nz: $CODE"
	continue
elif [[ "$STATUS" == "[-"?"]" ]] ; then
	notify "❓ File status unknown $STATUS" "mega.nz: $CODE"
	/usr/bin/open $URL
	continue
fi

# download
notify "⚠️ Please wait…" "Downloading file with ID $CODE"
DUPED=""
DOWN=$("$MEGADOWN" "$URL" --no-progress --print-names --path "$DL_DIR" 2>&1)
if [[ $(echo "$DOWN" | /usr/bin/grep "File exists") != "" ]] ; then
	# if file exists, move it to dupes
	PREVIOUS=$(echo "$DOWN" | rev | /usr/bin/awk -F\' '{print $2}' | rev)
	PREV_NAME=$(/usr/bin/basename "$PREVIOUS")
	mkdir -p "$DL_DIR/MEGAdupes" && mv "$PREVIOUS" "$DL_DIR/MEGAdupes/$PREV_NAME" && DUPED="true"
	# download for real this time
	DOWN=$("$MEGADOWN" "$URL" --no-progress --print-names --path "$DL_DIR" 2>&1)
fi

if [[ $(echo "$DOWN" | /usr/bin/grep "WARNING: ") != "" ]] || [[ $(echo "$DOWN" | /usr/bin/grep "ERROR: ") != "" ]] ; then
	WARN_INFO=$(echo "$DOWN" | rev | /usr/bin/awk -F" :" '{print $1}' | rev)
	notify "❌ Download error!" "$WARN_INFO [$CODE]"
	continue
elif [[ "$DOWN" == "" ]] ; then
	notify "✖️ Possible error!" "No d/l confirmation [$CODE]"
	continue
fi

# compare checksums
if [[ "$DUPED" == "true" ]] ; then
	OLDSUM=$(/sbin/md5 -q "$DL_DIR/MEGAdupes/$PREV_NAME")
	NEWSUM=$(/sbin/md5 -q "$DL_DIR/$DOWN")
	if [[ "$OLDSUM" == "$NEWSUM" ]] ; then
		# remove old file, then check if dupes dir is empty & delete if it is
		rm -rf "$DL_DIR/MEGAdupes/$PREV_NAME"
		ALL_DUPES=$(find "$DL_DIR/MEGAdupes" -type f -not -path '*/\.*' | /usr/bin/wc -l | /usr/bin/xargs)
		if [[ "$ALL_DUPES" == "0" ]] ; then
			rm -rf "$DL_DIR/MEGAdupes"
		fi
	fi
fi

notify "✅ Finished download" "$DOWN [$CODE]"

done
