# Arrêter la simulation précédente s'il y en a une
catch {quit -sim}

if {![file exists work]} {
    vlib work
}
vmap work work

# Compilation des fichiers (Ordre important : dépendances d'abord)
vcom -93 telemetre_us.vhd
vcom -93 telemetre_us_avalon.vhd
vcom -93 tb_telemetre_us_avalon.vhd

# Lancement de la simulation
vsim -voptargs=+acc tb_telemetre_us_avalon

# Ajout des signaux importants
add wave -noupdate -divider "Avalon Interface"
add wave -noupdate -radix binary /tb_telemetre_us_avalon/clk
add wave -noupdate -radix binary /tb_telemetre_us_avalon/rst_n
add wave -noupdate -radix binary /tb_telemetre_us_avalon/chipselect
add wave -noupdate -radix binary /tb_telemetre_us_avalon/read_n
add wave -noupdate -radix unsigned /tb_telemetre_us_avalon/readdata

add wave -noupdate -divider "Sensor Interface"
add wave -noupdate -radix binary /tb_telemetre_us_avalon/trig
add wave -noupdate -radix binary /tb_telemetre_us_avalon/echo

add wave -noupdate -divider "Internal UUT"
add wave -noupdate -radix unsigned /tb_telemetre_us_avalon/uut/dist_export
add wave -noupdate -radix unsigned /tb_telemetre_us_avalon/uut/u0/cnt_global
add wave -noupdate -radix unsigned /tb_telemetre_us_avalon/uut/u0/cnt_echo
add wave -noupdate -radix unsigned /tb_telemetre_us_avalon/uut/u0/distance_buffer

# Configuration de l'affichage
view structure
view signals
configure wave -namecolwidth 250
configure wave -valuecolwidth 100

# Lancement
run -all
wave zoom full
