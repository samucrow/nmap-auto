#!/bin/bash

# Settarget
function settarget(){
        if [ $# -eq 1 ]; then
        	echo $1 > ~/.config/polybar/shapes/scripts/target
        elif [ $# -gt 2 ]; then
        	echo "settarget [IP] [NAME] | settarget [IP]"
        else
        	echo $1 $2 > ~/.config/polybar/shapes/scripts/target
        fi
} 
