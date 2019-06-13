#!/bin/zsh

networks=(
    "Auditory"
    "DMN"
    "ExecutiveControl"
    "FrontoparietalLeft"
    "FrontoparietalRight"
    "Sensorymotor"
    "V1"
    "V2"
    "V3"
)

for network in ${networks};
do
	if [ -f Row_$network.png]
		rm Row_$network.png

    montage -geometry +0+0 -tile 4x0 $(ls *$network*) Row_$network.png
done

rm networks.png
montage $(ls Row*) -geometry +0+0 -tile 0x9 networks.png
rm Row*

