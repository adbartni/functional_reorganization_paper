#!/bin/sh

## Strip quotes and brackets from HC partial correlation database
## so that our data can be read as numeric
sed "s/'//g" data/control_part_cor.csv > data/control_part_cor.csv
sed "s/\[//g" data/control_part_cor.csv > data/control_part_cor.csv
sed "s/\]//g" data/control_part_cor.csv > data/control_part_cor.csv