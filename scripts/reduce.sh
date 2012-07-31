#!/bin/bash
#reduce - Create smaller images and thumbnails ready to upload for PhpWebGallery
#Copyright (C) 2006 Jean-Christophe Berthon
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#

clVERSION="1.0.1"
clSIZE="800"
clTHMB="128"
bTHB="true"


# Sub-function to obtain the version of this script
function version() {
    echo "`basename $0`: version ${clVERSION}"
}


# Sub-function to obtain the usage of this script
function usage() {
    version
    echo "Usage of this script"
    echo ""
    echo "   `basename $0` [ [-h|--help] | [-v|--version] ] | [ -size n ] | [ -thb [ no | n ] ]"
    echo "   Options:"
    echo "     - -v | --version: Print the version of the program"
    echo "     - -h | --help:    Print this help message"
    echo "     - -size n: 'n' represents a number like 800 or 1024,"
    echo "              size of the reduced image, default 800"
    echo "     - -thb [ no | n]: 'n' represents a number like 128 or 256,"
    echo "              size of the thumbnail, default 128,"
    echo "              'no': do not generate thumbnails"
    echo ""
}

if [ $# == 1 ]; then
    if [ "$1" == "--version" ] || [ "$1" == "-v" ]; then
        version
        exit 0

    elif [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        usage
        exit 1

    else
        echo "`basename $0`: Error - Unrecognise parameter '$1'"
        usage
        exit 1
    fi

elif [ $# == 2 ]; then
    if [ "$1" == "-size" ]; then
        clSIZE="$2"

    elif [ "$1" == "-thb" ]; then
        if [ "$2" == "no" ]; then
            bTHB="false"

        else
            clTHMB="$2"

        fi

    else
        echo "`basename $0`: Error - Unrecognise parameter '$1'"
        usage
        exit 1
    fi

elif [ $# == 4 ]; then
    if [ "$1" == "-size" ]; then
        clSIZE="$2"
        if [ "$3" == "-thb" ]; then
            if [ "$2" == "no" ]; then
                bTHB="false"

            else
                clTHMB="$2"
            fi

        else
            echo "`basename $0`: Error - Unrecognise parameter '$3'"
            usage
            exit 1
        fi

    elif [ "$1" == "-thb" ]; then
        if [ "$2" == "no" ]; then
            bTHB="false"

        else
            clTHMB="$2"

        fi
        if [ "$1" == "-size" ]; then
            clSIZE="$2"
        else
            echo "`basename $0`: Error - Unrecognise parameter '$3'"
            usage
            exit 1
        fi

    else
        echo "`basename $0`: Error - Unrecognise parameter '$1'"
        usage
        exit 1
    fi

elif [ $# == 3 ] || [ $# -gt 4 ]; then
    echo "`basename $0`: Error - invalid command line"
    usage
    exit 1
fi


if [ "$bTHB" == "false" ]; then
    for img in `ls *.jpg`
        do
            convert -resize "${clSIZE}x${clSIZE}" -unsharp "1x0.7+1+0" -density 72 -quality 81 $img $img
            echo $img
        done

else
    mkdir -p thumbnail
    for img in `ls *.jpg`
        do
            convert -thumbnail "${clTHMB}x${clTHMB}" -unsharp "1x0.7+1+0" -density 72 -quality 78 $img thumbnail/TN-$img
            convert -resize "${clSIZE}x${clSIZE}" -unsharp "1x0.7+1+0" -density 72 -quality 81 $img $img
            echo $img
        done
fi

chmod 0444 {thumbnail/,}*.jpg

exit 0
