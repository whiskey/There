#!/bin/bash

PROJECT="There.xcodeproj"
languages=(en de)

xliff_import=

function usage
{
    echo "usage: xliff.sh [[-i] | [-h]]"
	echo "  i : import XLIFFs"
}

while [ "$1" != "" ]; do
    case $1 in
        -i | --import )		     xliff_import=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done


if [ $xliff_import ]; then
	echo "Sorry, it seems Apple does not support '-importLocalizations' yet :("
	exit 1
	
	for lang in "${languages[@]}"; do	
		echo "importing $lang"
	    xcodebuild \
			-importLocalizations \
			-localizationPath ./translations \
			-project $PROJECT
	done
else
	for lang in "${languages[@]}"; do	
		echo "exporting $lang"
	    xcodebuild \
			-exportLocalizations \
			-localizationPath ./translations \
			-project $PROJECT \
			-exportLanguage $lang
	done
fi