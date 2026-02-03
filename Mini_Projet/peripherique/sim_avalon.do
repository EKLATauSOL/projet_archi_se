# Simulation de l'IP Servomoteur Avalon

# Création de la librairie de travail
if [file exists work] { vdel -all }
vlib work

# Compilation des fichiers (l'ordre est important)
vcom servomoteur.vhd
vcom IP_Servo_Avalon.vhd
vcom tb_IP_Servo_Avalon.vhd

# Lancement de la simulation avec résolution en ns
vsim -t ns work.tb_IP_Servo_Avalon

# Ouvrir la fenêtre de chronogrammes
view wave

# Ajout des signaux importants
add wave -divider "BUS AVALON"
add wave -position insertpoint sim:/tb_IP_Servo_Avalon/clk
add wave -position insertpoint sim:/tb_IP_Servo_Avalon/reset_n
add wave -color "Yellow" sim:/tb_IP_Servo_Avalon/chipselect
add wave -color "Yellow" sim:/tb_IP_Servo_Avalon/write_n
add wave -color "Orange" -radix hexadecimal sim:/tb_IP_Servo_Avalon/writedata

add wave -divider "SORTIE PWM"
add wave -color "Cyan" sim:/tb_IP_Servo_Avalon/commande

# Forcer l'unité d'affichage de la règle en ms
configure wave -timelineunits ms

# Exécution pour voir les trois cycles (0, 90 et 180 degrés)
run 65 ms

# Zoom sur la totalité
wave zoom full
