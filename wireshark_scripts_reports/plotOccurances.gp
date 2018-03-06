set datafile separator ","
set xlabel 'Encryption'
set ylabel '# of access points"
set style fill solid 0.1
set boxwidth 0.45 absolute
set style data boxes
set terminal png
set output 'plot.png'
set key off
set title "Encryption distribution measured on a bus in Eindhoven"
plot 'plotData' using 2:xticlabels(1) with boxes
