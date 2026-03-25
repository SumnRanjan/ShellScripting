#!/bin/bash

# Functions

is_loyal() {
    #read -p "Enter the name: " bandi
    #read -p "Enter love %: " pyar
    local bandi=$1
    local pyar=$2
    if [[ $bandi == "tanvi" && $pyar -ge 100 ]]
    then
        echo "True love 💖 (both conditions matched)"

    elif [[ $bandi == "tanvi" || $pyar -ge 100 ]]
    then
        echo "suman is loyal (one condition matched)"

    else
        echo "suman is not loyal"
    fi
}

# calling the function
is_loyal "$1" "$2"
