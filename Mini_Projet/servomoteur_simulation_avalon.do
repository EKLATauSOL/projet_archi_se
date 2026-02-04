# Créer la bibliothèque de travail
vlib work

# Compiler les fichiers source
# L'IP Avalon dépend du composant servomoteur
vcom -reportprogress 300 -work work ./peripherique/servomoteur.vhd
vcom -reportprogress 300 -work work ./peripherique/IP_Servo_Avalon.vhd
vcom -reportprogress 300 -work work ./peripherique/tb_IP_Servo_Avalon.vhd

# Lancer la simulation
vsim -voptargs="+acc" work.tb_IP_Servo_Avalon

# Configurer l'affichage des ondes
add wave -noupdate -divider {Bus Avalon}
add wave -noupdate -format Logic -radix binary /tb_IP_Servo_Avalon/clk
add wave -noupdate -format Logic -radix binary /tb_IP_Servo_Avalon/reset_n
add wave -noupdate -format Logic -radix binary /tb_IP_Servo_Avalon/chipselect
add wave -noupdate -format Logic -radix binary /tb_IP_Servo_Avalon/write_n
add wave -noupdate -format Literal -radix binary /tb_IP_Servo_Avalon/writedata

add wave -noupdate -divider {Sortie PWM}
add wave -noupdate -format Logic -radix binary /tb_IP_Servo_Avalon/commande

add wave -noupdate -divider {Registres Internes IP}
add wave -noupdate -format Literal -radix binary /tb_IP_Servo_Avalon/uut/reg_position
add wave -noupdate -format Literal -radix decimal /tb_IP_Servo_Avalon/uut/u_pwm_servo/counter
add wave -noupdate -format Literal -radix decimal /tb_IP_Servo_Avalon/uut/u_pwm_servo/duty_cycle

# Ajuster la vue
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ms

# Lancer la simulation pour 70 ms
run 70 ms

# Zoom automatique
wave zoom full
