	
	.data
	.align 0
saida_hex:	.asciiz "\nSeu número em hexadecimal é: "
saida_bin:	.asciiz "\nSeu número em binário é: "
saida_dec:	.asciiz "\nSeu número em decimal é: "

	.text
	.globl str_dec_to_intdec
	.globl str_bin_to_dec
	.globl str_hex_to_dec
	.globl dec_to_hex
	.globl dec_to_bin
	.globl print_dec

print_dec:
	# Guardando valores de $a0 e $ra
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	
	# Colocando em $t0 o valor decimal a ser impresso
	move $t0, $a0

	# Imprimir a string de saida
	la $a0, saida_dec
	li $v0, 4
	syscall

	# Imprimir o valor como unsigned
	move $a0, $t0
	li $v0, 36
	syscall

	# Carregando valores de $a0 e $ra
	lw $ra, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 8

	jr $ra

str_dec_to_intdec:
	# Posição na string
	move $t0, $a0

	# Valor final, que será iterado
	li $t1, 0
	
	str_to_dec_loop:
		# Valor do caractere atual da string 
		lb $t2, ($t0)

		# Checa se chegou no fim da sting
		beqz $t2, str_to_dec_fim

		# Pega o valor em int subtraindo '0' do char
		sub $t2, $t2, '0'
		# Multiplica o valor anterior por 10
		mul $t1, $t1, 10
		# Acrescenta o valor atual (nova campo de unidade)
		add $t1, $t1, $t2
		
		# Avança na string
		addi $t0, $t0, 1
		
		j str_to_dec_loop
		
	str_to_dec_fim:
	
	# Guarda o valor final no registrador de retorno
	move $v0, $t1
	# Sai da função
	jr $ra

str_bin_to_dec:
	# Posição na string
	move $t0, $a0

	# Valor final, que será iterado
	li $t1, 0
	
	bin_to_dec_loop:
		# Valor do caractere atual da string 
		lb $t2, ($t0)

		# Checa se chegou no fim da sting
		beqz $t2, bin_to_dec_fim

		# Pega o valor em int subtraindo '0' do char
		sub $t2, $t2, '0'
		# Multiplica o valor anterior por 2
		mul $t1, $t1, 2
		# Acrescenta o valor atual (nova campo de unidade)
		add $t1, $t1, $t2
		
		# Avança na string
		addi $t0, $t0, 1
		
		j bin_to_dec_loop
		
	bin_to_dec_fim:
	
	# Guarda o valor final no registrador de retorno
	move $v0, $t1
	# Sai da função
	jr $ra

str_hex_to_dec:
	# Posição na string
	move $t0, $a0

	# Valor final, que será iterado
	li $t1, 0
	
	hex_to_dec_loop:
		# Valor do caractere atual da string 
		lb $t2, ($t0)

		# Checa se chegou no fim da sting
		beqz $t2, hex_to_dec_fim

		# Pega o valor em int subtraindo '0' do char
		sub $t2, $t2, '0'
		
		# Se o caractere era um digito, tudo ok
		blt $t2, 10, eh_digito
			# Se era uma letra deve-se subtrair mais ainda
			sub $t2, $t2, 39

		eh_digito:
		
		# Multiplica o valor anterior por 16
		mul $t1, $t1, 16
		# Acrescenta o valor atual (nova campo de unidade)
		add $t1, $t1, $t2
		
		# Avança na string
		addi $t0, $t0, 1
		
		j hex_to_dec_loop
		
	hex_to_dec_fim:
	
	# Guarda o valor final no registrador de retorno
	move $v0, $t1
	# Sai da função
	jr $ra

###########  Fim das conversões de string para dec  #############

itoa_na_pilha:
	# Trasformando o n° em string, basta somar 48 ao n°
	addi $t3, $t3, 48

	ble $t3, '9', empilhar
		
	# Se for maior que 9 deve transformar em letra, para isso soma-se 39
	addi $t3, $t3, 39
		
	empilhar:
		# Guardando na pilha
		addi $sp, $sp, -4
		sw $t3, 4($sp)
	
	jr $ra

##########################

dec_to_hex:
	# Posicao do vetor aux
	li $t9, 0
	
	# O valor de parametro e guardado em $t0, que será iterado
	move $t0, $a0

	# Armazena o $a0 e $ra na pilha
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	
	loop:
		# Salva no registrador t1 o resultado da divisao do número de entrada por 16 (quociente)
		divu $t1, $t0, 16
		
		# Encontrando o resto:   resto = dividendo - (divisor * quociente)
		# Salva em $t2 o divisor * quociente
		mulu $t2, $t1, 16
		
		# Obtendo o resto
		subu $t3, $t0, $t2
		
		# Altera o $t0
		move $t0, $t1

		# itoa_na_pilha -> Transforma o decimal em caractere e empilha o caractere
		jal itoa_na_pilha

		#incrementando a posicao do vetor aux
		addi $t9, $t9, 1
		
	bge $t0, 16, loop
	
	move $t3, $t0
	jal itoa_na_pilha

	###### Inicio da desempilhagem ######	
	#Imprime a string de saída
	la $a0, saida_hex
	li $v0, 4
	syscall
	
	loop_desempilha:
		lw $t3, 4($sp)
		addi $sp, $sp, 4
		
		# Printa o n° em hexa, char por char
		li $v0, 11
		move $a0, $t3
		syscall
	
		# Decrementa o valor do n° de posições
		subi $t9, $t9, 1
		bge $t9, 0, loop_desempilha
	
	# Desempilha $a0 e $ra	
	lw $a0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8

	# Sai da função
	jr $ra


dec_to_bin:
	# Armazena o $a0 e $ra na pilha
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)

	# Guarda $a0 em $a1 que será iterado
	move $a1, $a0

	li $v0, 4
	la $a0, saida_bin
	syscall

	jal decbin_loop

	# Desempilha $a0 e $ra	
	lw $a0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8

	# Sai da função
	jr $ra
	
decbin_loop:
	# Verifica se o n° chegou a zero
	# Se chegou, branch para decbin_end
	beqz $a1, decbin_end
	
	# Empilha
	addi $sp, $sp, -12
	sw $a1, 8($sp)
	sw $ra, 4($sp)

	li $t2, 2
	
	# Divide a1 por 2
	divu $a1, $t2
	mfhi $v0 # a1 % 2
	mflo $a1 # a1 / 2
	
	# Guarda a resto da div na pilha (será o dígito do binário)
	sw $v0, 0($sp)
	
	jal decbin_loop
	
decbin_end:
	# Pega o último resto[dígito] da pilha
	lw $v0, 0($sp)
	# Imprime o resto coletado
	jal decbin_print
	
	# desempilha
	lw $a1, 8($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 12
	
	jr $ra

decbin_print:
	move $a0, $v0
	li $v0, 1
	syscall
	jr $ra

