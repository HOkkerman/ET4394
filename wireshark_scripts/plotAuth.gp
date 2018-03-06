set datafile separator ","
set xlabel 'Encryption'
set ylabel '# of access points"

set auto x
set yrange [0:*]

set style fill solid 0.1
set boxwidth 0.45 

set style histogram clustered

set terminal png
set output 'plotAuthBus.png'
set title "Authorisation distribution per Encryption type measured on a bus in Eindhoven"
plot 'AuthDataBus' using 2:xticlabels(1) title col with boxes, \
            '' using 3 title col with boxes
