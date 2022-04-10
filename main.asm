
# ATIVIDADE 2 - ORGANIZAÇÃO E ARQUITETURA DE COMPUTADORES

# Integrantes:
# Adrio Oliveira Alves - 11796830
# Eduardo Vinicius Barbosa Rossi - 10716887
# Guilherme Ramos Costa Paixão - 11796079
# Lucas Ferreira de Almeida - 11262063

	
		
	# Segmento de dados
	
	.data
	.align 0

str_base_entrada:
	.asciiz "\nEntre com a base de entrada (B, H ou D): "
str_base_saida:
	.asciiz "\nEntre com a base de saída (B, H ou D): "
str_resultado:
	.asciiz "\nO resultado da conversão é: "
str_sem_conversao:
	.asciiz "\nNão é possível fazer essa conversão!\n"

	# Segmento de texto
	
	.text
	.globl main
	
main:

	# REGISTRADORES SALVOS UTILIZADOS NESSE SEGMENTO DE CÓDIGO
	
	# s0 -> guarda o caractere correspondente da base de ENTRADA (B, H ou D)
	# s1 -> guarda o caractere correspondente da base de SAÍDA (B, H ou D)


	# LER BASE DE ENTRADA
loop_base_entrada:
	# Imprimindo a string para entrar com base
	li $v0, 4
	la $a0, str_base_entrada
	syscall
	
	# Lendo o caractere
	li $v0, 12
	syscall
	move $s0, $v0
	
	# Chamando função para checar se é caractere válido e caso não seja, voltar o início do loop
	move $a0, $s0
	jal entrada_valida
	beqz $v0, loop_base_entrada
	
	
	# LER BASE DE SAÍDA
loop_base_saida:
	# Imprimindo a string para entrar com base
	li $v0, 4
	la $a0, str_base_saida
	syscall
	
	#Lendo o caractere
	li $v0, 12
	syscall
	move $s1, $v0
	
	# Chamando função para checar se é caractere válido e caso não seja, voltar o início do loop
	move $a0, $s1
	jal entrada_valida
	beqz $v0, loop_base_saida
	
	
	# CHAMANDO A FUNÇÃO CORRESPONDENTE
	beq $s0, 'B', base_entrada_bin
	beq $s0, 'H', base_entrada_hex
	beq $s0, 'D', base_entrada_dec

base_entrada_bin:
	beq $s1, 'B', sem_conversao
	beq $s1, 'H', chamar_bin_to_hex
	beq $s1, 'D', chamar_bin_to_dec

base_entrada_hex:
	beq $s1, 'B', chamar_hex_to_bin
	beq $s1, 'H', sem_conversao
	beq $s1, 'D', chamar_hex_to_dec

base_entrada_dec:
	beq $s1, 'B', chamar_dec_to_bin
	beq $s1, 'H', chamar_dec_to_hex
	beq $s1, 'D', sem_conversao


chamar_bin_to_hex:
	jal bin_in
	# Ocorreu um erro na leitura
	beqz $v0, chamar_bin_to_hex
	
	# Colocar como parâmetro o endereço da string a ser convertida para decimal
	move $a0, $v0
	jal str_bin_to_dec
	
	# Colocar como parâmetro o valor em decimal
	move $a0, $v0
	jal dec_to_hex
	
	# A função dec_to_hex imprime internamente
	
	j fim_do_programa

chamar_bin_to_dec:
	jal bin_in
	# Ocorreu um erro na leitura
	beqz $v0, chamar_bin_to_dec
	
	# Colocar como parâmetro o endereço da string a ser convertida para decimal
	move $a0, $v0
	jal str_bin_to_dec
	
	# Imprimir o valor resultante como unsigned
	move $a0, $v0
	jal print_dec
	
	j fim_do_programa

chamar_hex_to_dec:
	jal hex_in
	# Ocorreu um erro na leitura
	beqz $v0, chamar_hex_to_dec
	
	# Colocar como parâmetro o endereço da string a ser convertida para decimal
	move $a0, $v0
	jal str_hex_to_dec
	
	# Imprimir o valor resultante como unsigned
	move $a0, $v0
	jal print_dec
	
	j fim_do_programa
	
chamar_hex_to_bin:
	jal hex_in
	# Ocorreu um erro na leitura
	beqz $v0, chamar_hex_to_bin
	
	# Colocar como parâmetro o endereço da string a ser convertida para decimal
	move $a0, $v0
	jal str_hex_to_dec
	
	# Colocar como parâmetro o valor em decimal
	move $a0, $v0
	jal dec_to_bin
	
	# A função dec_to_bin imprime internamente
	
	j fim_do_programa	

chamar_dec_to_bin:
	jal dec_in
	# Ocorreu um erro na leitura
	beqz $v0, chamar_dec_to_bin
	
	# Colocar como parâmetro o endereço da string a ser convertida para decimal
	move $a0, $v0
	jal str_dec_to_intdec
	
	# Colocar como parâmetro o valor em decimal
	move $a0, $v0
	jal dec_to_bin
	
	# A função dec_to_bin imprime internamente
	
	j fim_do_programa

chamar_dec_to_hex:
	jal dec_in
	# Ocorreu um erro na leitura
	beqz $v0, chamar_dec_to_hex
	
	# Colocar como parâmetro o endereço da string a ser convertida para decimal
	move $a0, $v0
	jal str_dec_to_intdec
	
	# Colocar como parâmetro o valor em decimal
	move $a0, $v0
	jal dec_to_hex
	
	# A função dec_to_hex imprime internamente
	
	j fim_do_programa

sem_conversao:
	li $v0, 4
	la $a0, str_sem_conversao
	syscall
	j fim_do_programa


	# FIM DO PROGRAMA
fim_do_programa:
	li $v0, 10
	syscall


	# Checa se o caractere passado como parâmetro (em $a0) é 'B', 'H' ou 'D'
	# Retorna 1 caso verdadeiro e 0 caso falso (em $v0)
entrada_valida:
	seq $t0, $a0, 'B'
	seq $t1, $a0, 'H'
	seq $t2, $a0, 'D'
	or $v0, $t0, $t1
	or $v0, $v0, $t2
	
	jr $ra
