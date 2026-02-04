# Créer la bibliothèque de travail
vlib work

# Compiler les fichiers source
# Note : servomoteur.vhd doit être compilé avant le testbench
vcom -reportprogress 300 -work work ./peripherique/servomoteur.vhd
vcom -reportprogress 300 -work work ./peripherique/tb_servomoteur.vhd

# Lancer la simulation
vsim -voptargs="+acc" work.tb_servomoteur

# Configurer l'affichage des ondes
# On force le radix binaire pour tous les signaux
add wave -noupdate -divider {Entrees}
add wave -noupdate -format Logic -radix binary /tb_servomoteur/clk
add wave -noupdate -format Logic -radix binary /tb_servomoteur/reset_n
add wave -noupdate -format Literal -radix binary /tb_servomoteur/position

add wave -noupdate -divider {Sortie PWM}
add wave -noupdate -format Logic -radix binary /tb_servomoteur/commande

add wave -noupdate -divider {Signaux Internes UUT}
add wave -noupdate -format Literal -radix decimal /tb_servomoteur/uut/counter
add wave -noupdate -format Literal -radix decimal /tb_servomoteur/uut/duty_cycle

# Ajuster la vue
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms

# Lancer la simulation pour 70 ms (permet de voir 3 cycles PWM)
run 70 ms

# Zoom automatique sur les ondes
wave zoom full
