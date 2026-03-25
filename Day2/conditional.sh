#!/bin/bash

<<comment
if else elif
then
fi
comment

read -p "Enter the name: " bandi
read -p "Enter love %: " pyar

if [[ $bandi == "tanvi" && $pyar -ge 100 ]]
then
    echo "True love 💖 (both conditions matched)"

elif [[ $bandi == "tanvi" || $pyar -ge 100 ]]
then
    echo "Suman is loyal (one condition matched)"

else
    echo "Suman is not loyal"
fi

