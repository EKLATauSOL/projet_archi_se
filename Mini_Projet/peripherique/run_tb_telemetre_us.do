# Arrêter la simulation précédente s'il y en a une
catch {quit -sim}

if {![file exists work]} {
    vlib work
}
# vmap pas toujours nécessaire si vlib fait dans le dossier courant, mais on le garde
vmap work work

# Compilation des fichiers
vcom -93 telemetre_us.vhd
vcom -93 tb_telemetre_us.vhd

# Lancement de la simulation
vsim -voptargs=+acc tb_telemetre_us

# Ajout des signaux importants
add wave -noupdate -divider "UUT Inputs"
add wave -noupdate -radix binary /tb_telemetre_us/clk
add wave -noupdate -radix binary /tb_telemetre_us/rst_n
add wave -noupdate -radix binary /tb_telemetre_us/echo

add wave -noupdate -divider "UUT Outputs"
add wave -noupdate -radix binary /tb_telemetre_us/trig
add wave -noupdate -radix unsigned /tb_telemetre_us/dist_cm

add wave -noupdate -divider "Internal Counters"
add wave -noupdate -radix unsigned /tb_telemetre_us/uut/cnt_global
add wave -noupdate -radix unsigned /tb_telemetre_us/uut/cnt_echo
add wave -noupdate -radix unsigned /tb_telemetre_us/uut/distance_buffer

# Configuration de l'affichage
view structure
view signals
configure wave -namecolwidth 200
configure wave -valuecolwidth 100

# Lancement
run -all
wave zoom full
