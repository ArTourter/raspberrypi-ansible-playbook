#!/usr/bin/env sh
#
# vim: ts=2 sw=2 et sr

######################################################################
# @author      : Gregory J. L. Tourte (g.j.l.tourte@bristol.ac.uk)
# @file        : piOS_iso_conf
# @created     : Thursday Jun 01, 2023 18:37:10 BST
#
# @description : 
#
######################################################################

RED='\e[0;31m'
ORANGE='\e[0;33m'
NC='\e[0m'

function die {
  [[ ! -z $1 ]] && echo -e "${RED}ERROR:$NC $1" > /dev/stderr
  [[ $2 == "usage" ]] && pod2usage $0
  exit 1
}

function warn {
  (( $VERBOSE || $DEBUG )) && echo -e "${ORANGE}WARNING:$NC $1"
}

function info {
  (( $VERBOSE || $DEBUG )) && echo -ne "$1"
}

function debug {
  (( $DEBUG )) && echo -e "${ORGANGE}DEBUG:$NC $1"
}

VERBOSE=1
DEBUG=0
FORCE=${FORCE:-0}

[[ $(whoami) != "root" ]] && die "Permission denied. Can only be run as root"

NEWUSER=''
NEWPASS=''
TMPMOUNT=$(mktemp -d)
MOUNTOPTS=''


while getopts "u:i:p:H:o:qdf" options; do
  case "${options}" in
    q ) VERBOSE=0 ;;
    d ) DEBUG=1
        warn "Running in DEBUG mode, nothing will actually be done"
        MOUNTOPTS='-f -v'
        ;;
    f ) FORCE=1;;
    u ) NEWUSER=$OPTARG ;;
    p ) NEWPASS=$(echo $OPTARG | openssl passwd -6 -stdin) ;;
    H ) NEWHOST=$OPTARG ;;
    o ) OUTPUT=$OPTARG ;;
    i ) IMGFILE=$OPTARG 
        [[ ! -f "$IMGFILE" ]] && die "The image file $IMGFILE cannot be found"
        ;;
    #h ) pod2man -c "UoB BRIDGE Documentation" -u $0 | nroff -man -Tutf8 -  -Kutf8| ${PAGER:-less -XFR}
    #    exit 0;;
    * ) die "" "usage" ;;
  esac
done

if [[ -z $OUTPUT ]]; then
  warn "No output device provided. Resulting image will only be saved and not written to SD card"
fi

[[ -z $NEWHOST ]] && die "A hostname must be given. Use '-H' flag."
[[ -z $IMGFILE ]] && die "An image file must be given. Use '-f' flag."
NEWFILE="${IMGFILE%.img}-$NEWHOST.img"

if [[ -f $NEWFILE ]]; then
  (( ! $FORCE )) && die "An image has already been created for $NEWHOST. Use -f to overwrite."
fi

[[ -z $NEWUSER ]] && die "A user must be specified. Use '-u' flag."
if [[ -z $NEWPASS ]] ; then
  while true; do
    read -sp "Password for ${NEWUSER}: " PASS1
    echo
    read -sp "Verify password for ${NEWUSER}: " PASS2
    echo
    [[ $PASS1 == $PASS2 ]] && break || warn "Passwords do not match. Please enter password again..."
  done
  NEWPASS=$(echo $PASS1 | openssl passwd -6 -stdin)
fi
echo

info "Creating $NEWHOST specific image from input file\n"
(( ! $DEBUG )) && (cp "$IMGFILE" "$NEWFILE" ||
  die "Cannot create new image file")

info "Mounting image file\n"
(( ! $DEBUG )) && (/sbin/losetup -P /dev/loop0 $NEWFILE ||
  die "Couldn't create loop partition devices")

mount $MOUNTOPTS /dev/loop0p2 $TMPMOUNT ||
  die "Couldn't mount root partition"

mount $MOUNTOPTS /dev/loop0p1 $TMPMOUNT/boot ||
  die "Couldn't mount boot partition"

info "Enabling SSH access\n"
(( ! $DEBUG )) && touch $TMPMOUNT/boot/ssh

info "Adding new user\n"
if (( $DEBUG )); then
  echo "$NEWUSER:$NEWPASS"
else
  echo "$NEWUSER:$NEWPASS" > $TMPMOUNT/boot/userconf
fi

info "Setting up hostname\n"
if (( $DEBUG )); then
  echo "$NEWHOST"
else
  echo "$NEWHOST" > $TMPMOUNT/etc/hostname
fi

info "Umounting image partitions\n"
if (( ! $DEBUG )); then
  umount $TMPMOUNT/boot $TMPMOUNT
  /sbin/losetup -d /dev/loop0
fi


