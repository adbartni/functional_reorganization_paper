#!/bin/sh

inputData=$1

## Strip quotes and brackets from HC partial correlation database
## so that our data can be read as numeric
sed "s/'//g" $inputData > $inputData
sed "s/\[//g" $inputData > $inputData
sed "s/\]//g" $inputData > $inputData
