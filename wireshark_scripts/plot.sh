#!/bin/bash

infile=$1

# Ignore probe entries (second part of airodump outfile)
sed -e '/^,/,$d' $infile > intermediate_1
tail -n +2 intermediate_1 > intermediate_2
rm intermediate_1

# Get number of occurances
awk -F',' '{print $6}' intermediate_2 | sort | uniq -c > intermediate_1
cat intermediate_1 | awk '{print $2","$1}' > intermediate_2
sed -e 's/^,/none,/g' intermediate_2 > plotData
rm intermediate_1
rm intermediate_2

gnuplot plotOccurances.gp 
#rm plotData
