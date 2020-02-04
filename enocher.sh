#!/bin/sh

# Simplified assertion
die() {
	printf 'FATAL: %s\n' "$2"
	exit "$1"
}

# uniminincheckerino to avoid plebs breaking their systems
[ "$USER" != uniminin ] && die 1 "What the fuck? You are not uniminin! you are $USER -> Refusing to run"

# KREYPI_INIT
if command -v kreypi_init 2>/dev/null; then die 1 "kreypi_init is not available on this system, unable to source required libs to avoid me wasting time with shit"; fi

# Checkroot
checkroot

# Vars
myname="enocher"
targetDir="$1"
	td="$tarderDir"

# CACHEDIR check
[ -z "$CACHEDIR" ] && CACHEDIR="$HOME/.cache"

if [ ! -d "$CACHEDIR" ]; then
	mkdir "$CACHEDIR" || die 1 "Unable to make CACHEDIR in $CACHEDIR"
elif [ -d "$CACHEDIR" ]; then
	true
else
	die 256 "CACHEDIR check"
fi

if [ ! -d "$CACHEDIR/$myname" ]; then
	mkdir "$CACHEDIR/$myname" || die 1 "Unable to make a new directory in '$CACHEDIR/$myname'"
elif [ -d "$CACHEDIR/$myname" ]; then
	true
else
	die 256 "CACHEDIR/myname check"
fi

# Fetch Gentoo
## Returns '20200129T214502Z/stage3-amd64-20200129T214502Z.tar.xz' or alike
gentoo_tarball="$(curl http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64.txt 2>/dev/null | grep -oP "(^[0-9][^xz]+xz)")"

case "$gentoo_tarball" in *.tar.xz) die 1 "Unable to fetch gentoo_tarball variable"; esac

if [ ! -e "$CACHEDIR/$myname/$gentoo_tarball" ]; then
	downloader "http://distfiles.gentoo.org/releases/amd64/autobuilds/$gentoo_tarball" "$CACHEDIR/${gentoo_tarball##?????????????????}"
elif [ -e "$CACHEDIR/$myname/$gentoo_tarball" ]; then
	true
else
	die 256 "tarball download"
fi

# Make a new chrootdir
if [ ! -d "$td" ]; then
	mkdir "$td" || die 1 "Unable to make a new directory in $td"
elif [ -d "$td" ]; then
	edebug "Expected directory '$td' already exists"
else
	die 256 "Checking for td"
fi

# Extract tarball
if [ ! -d "$td/etc/portage" ]; then
	extractor "$CACHEDIR/$myname/${gentoo_tarball##?????????????????}" "$td"
elif [ -d "$td/etc/portage" ]; then
	true
else
	die 256 "extracting tarball"
fi

# Action
## Chrooter check
if command -v chrooter 2>/dev/null; then die 126 "Command 'chrooter' is not executable on this system"; fi

## lazy resolvconf
fixme "sanitize resolvconf checking"
printf 'nameserver %s\n' "1.1.1.1" "2606:4700:4700::1111" "1.0.0.1" "2606:4700:4700::1001" > "$td/etc/resolv.conf"

## Get uni's repo
[ ! -f "$td/etc/portage/.git" ] && { rm -r "$td/etc/portage" || die 1 "Unable to remove the old portage configdir" ;}

egit clone https://github.com/Uniminin/portage-config.git "$td/etc/portage"

## sync repos
chrooter "$td" emerge --sync || die 1

## THE GRAND EMERGE!
chrooter "$td" emerge -vuDN @world || die 1

einfo "Your gentoo finished crunching, enjoy"