#!/bin/bash
#nbStmts - Count the number of statements and code lines for C/C++ program
#Copyright (C) 2005  Daniel Werner and Jean-Christophe Berthon
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

clVERSION="1.1.3"
clDirectory="."
bIsDir="True"


# Sub-function to obtain the version of this script
function version() {
    echo "`basename $0`: version ${clVERSION}"
}


# Sub-function to obtain the usage of this script
function usage() {
    version
    echo "Usage of this script"
    echo ""
    echo "   `basename $0` [ [-h|--help] | [-v|--version] ] | [ [filename] | [directory] ]"
    echo "   Options:"
    echo "     - -v | --version: Print the version of the program"
    echo "     - -h | --help:    Print this help message"
    echo ""
    echo "The program analyses the current directory and all sub-directories"
    echo "and is looking for C or C++ files."
    echo "It then compute the number of statements of the analysed files."
    echo "See the User Manual for an explanation of the counting method and"
    echo "its close approximation."
    echo ""
    echo "Examples:"
    echo "Analysing all C/C++ file in the current directory and sub directories:"
    echo "    `basename $0`"
    echo ""
    echo "Analysing the C++ file named /home/project/src/SYS/SYS_ls.C:"
    echo "    `basename $0` /home/project/src/SYS_ls.C"
    echo ""
    echo "Analysing all C/C++ file under a certain directory:"
    echo "    `basename $0` src/SYS"
}



if [ $# == 1 ]; then
    if [ "$1" == "--version" ] || [ "$1" == "-v" ]; then
        version
        exit 0

    elif [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        usage
        exit 1

    elif [ -f $1 ] && [ -r $1 ]; then
    	bIsDir="False"
    	clFilename=$1

    elif [ -d $1 ]; then
    	bIsDir="True"
    	clDirectory=$1

    else
        echo "`basename $0`: Error - Unrecognise parameter '$1'"
        usage
        exit 1
    fi

elif [ $# -gt 1 ]; then
    echo "`basename $0`: Error - Maximum number of argument is 1"
    usage
    exit 1
fi


# Checking mktemp OS capabilities
tcTempFile=`mktemp 2>/dev/null`
if [ $? -ne 0 ]; then
    tcTempFile=`mktemp -t $(basename $0).XXXXXX 2>/dev/null`
    if [ $? -ne 0 ]; then
        tcTempFile=`mktemp $(basename $0).XXXXXX 2>/dev/null`
        if [ $? -ne 0 ]; then
            # this OS has really not a single mktemp facility!!!
            if [ -d /tmp ] && [ -w /tmp ]; then
                tcTempFile="/tmp/$(basename $0).tmp.`date +%j%H%M%S`" || exit 2
                tcListOfFiles="/tmp/$(basename $0).list.`date +%j%H%M%S`" || exit 2
            else
                tcTempFile="$(basename $0).tmp.`date +%j%H%M%S`" || exit 2
                tcListOfFiles="$(basename $0).list.`date +%j%H%M%S`" || exit 2
            fi
        else
            tcListOfFiles=`mktemp $(basename $0).XXXXXX 2>/dev/null`
        fi
    else
        tcListOfFiles=`mktemp -t $(basename $0).XXXXXX 2>/dev/null`
    fi
else
    tcListOfFiles=`mktemp 2>/dev/null`
fi

if [ "${bIsDir}" == "True" ]; then
    find ${clDirectory} -type f -name "*.cpp" -o -name "*.h" -o -name "*.c" -o -name "*.C" \
        -o -name "*.H" -o -name "*.hpp" -o -name "*.cxx" -o -name "*.hxx" -o -name "*.cc" \
        | egrep -v "\.moc|\.ui" > ${tcListOfFiles}
    cat ${tcListOfFiles} | xargs -n 1 perl -x $0 -sloc >> ${tcTempFile}
    tcNbLoC=`cat ${tcListOfFiles} | xargs -n 1 perl -x $0 | wc -l`

elif [ "${bIsDir}" == "False" ]; then
    perl -x $0 -sloc ${clFilename} > ${tcTempFile}
    tcNbLoC=`perl -x $0 ${clFilename} | wc -l`

else
    echo "I should not get here, or I did wrote something wrong in my code..."
    echo "ERROR! ;-p"
    exit 127
fi

if [ $(ls -s ${tcTempFile} | awk '{ print $1 }') -eq 0 ]; then
    echo "`basename $0`: Error - No file were found or there is no C/C++ LoC"
    exit 126
fi

echo "Rough number of statements (approx. logical SLOC):"
cat ${tcTempFile} | tr -cd ';}' | wc -c | awk '{ printf("%7d\n", $1) }'

echo "Number of non blank or comment lines (physical SLOC):"
wc -l ${tcTempFile} | awk ' { printf("%7d\n", $1) }'

echo "Number of lines of code (including comments):"
echo ${tcNbLoC} | awk ' { printf("%7d\n", $1) }'

rm -f ${tcTempFile} ${tcListOfFiles}

exit 0

## END OF BASH SCRIPT


##=============================


## START OF PERL SCRIPT
#!/usr/bin/perl -s

$/ = undef;
$_ = <>;
if ($sloc) {
    s#/\*[^*]*\*+([^/*][^*]*\*+)*/|//[^\n]*|("(\\.|[^"\\])*"|'(\\.|[^'\\])*'|.[^/"'\\]*)#$2#gs;
}
s#\n\s*\n#\n#gs;
s#^\s*\n##gs;
print;

## END OF PERL SCRIPT
__END__

