#!/bin/bash
input_file=$1
output_file=$2
region=$3

if [[ -z "$region" ]]; then
    cp "$input_file" "$output_file"
else
    odgi extract -i "$input_file" -o "$output_file" -r "CHM13#$region" -O -t16 -P -c100
fi


