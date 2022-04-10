	
	# Segmento de dados
	
	.data
	.align 0

entrada:
	.space 33
string_entrada_bin:
	.asciiz "\nDigite um número inteiro positivo em binário [0-1] (máximo 32 bits): "
string_entrada_hex:
	.asciiz "\nDigite um número inteiro positivo em hexadecimal [0-9a-f] (máximo 32 bits): "
string_entrada_dec:
	.asciiz "\nDigite um número inteiro positivo em decimal [0-9] (máximo 32 bits): "
string_entrada_erro:
	.asciiz "\nOcorreu um erro na entrada!\n"

	# Segmento de texto
	
	.text
	.globl bin_in
	.globl hex_in
	.globl dec_in



	# Função main utilizada apenas para testes 
main:
	jal ler_string
	
	la $a0, entrada
	jal dec_valido
	
	move $a0, $v0
	li $v0, 1
	syscall
	
	li $v0, 10
	syscall



	# Lê uma string de até 32 caracteres e armazena no segmento de dados
	# Retorna o tamanho da string
ler_string:
	# Espaço para $a0, $a1 e $ra na stack
	addi $sp, $sp, -12
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $ra, 8($sp)
	
	# Ler até no máximo 32 caracteres de entrada
	li $v0, 8
	la $a0, entrada
	li $a1, 33
	syscall
	
	# Removendo '\n' ao final se necessário
	
	# $t0 <- Tamanho da string
	la $a0, entrada
	jal strlen
	move $t0, $v0
	
	# $t0 <- Endereço do "possível" caractere '\n' da string
	# $t1 <- Valor contido no endereço de $t0
	addu $t0, $t0, $a0
	addi $t0, $t0, -1
	lb $t1, ($t0)
	
	# Se $t1 == '\n', armazenar o valor '\0' no lugar na string
	# e alterar o valor de saída
	bne $t1, '\n', ler_string_fim
	sb $zero, ($t0)
	addi $v0, $v0, -1
	
ler_string_fim:
	# Recuperando $a0, $a1 e $ra
	lw $ra, 8($sp)
	lw $a1, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 12
	
	jr $ra



	# Verifica o tamanho de uma string (endereço em $a0) sem contar o indicador '\0'
	# Retorna em $v0 esse tamanho
strlen:
	# Endereço inicial
	move $t0, $a0
	
	# Endereço atual
	move $t1, $a0
			
strlen_loop:
	# Carregando o caractere no endereço atual
	# Checar se é igual a '\0' e ir pro próximo caractere
	lb $t2, ($t1)
	beqz $t2, strlen_fim
	addi $t1, $t1, 1		
	j strlen_loop

strlen_fim:
	# Retorno
	sub $v0, $t1, $t0
	jr $ra



	# Verifica se a string (em $a0) é um número binário de no máximo 32 bits (unsigned)
	# Retorna (em $v0) o valor 1 se é um binário válido e 0 se não for
bin_valido:
	# Endereço inicial
	move $t0, $a0
	
	# Endereço atual
	move $t1, $a0
	
	# Contador de tamanho
	li $t5, 0
	
	# Consideramos inicialmente que é falso (string vazia) 
	li $v0, 0
	
bin_valido_loop:
	# Carregando o caractere no endereço atual
	# Checar se é igual a '\0'
	lb $t2, ($t1)
	beqz $t2, bin_valido_fim
	
	# Checar se o caractere é '0' ou '1'
	seq $t3, $t2, '0'
	seq $t4, $t2, '1'
	or $v0, $t3, $t4
	beqz $v0, bin_valido_fim
	
	# Checar tamanho (máximo 32 bits)
	addi $t5, $t5, 1
	sle $v0, $t5, 32
	beqz $v0, bin_valido_fim
	
	# Próximo caractere
	addi $t1, $t1, 1
	j bin_valido_loop

bin_valido_fim:
	# Retorno
	jr $ra
	


	# Verifica se a string (em $a0) é um número hexadecimal de no máximo 32 bits (unsigned)
	# Retorna (em $v0) o valor 1 se é um hexadecimal válido e 0 se não for
hex_valido:
	# Endereço inicial
	move $t0, $a0
	
	# Endereço atual
	move $t1, $a0
	
	# Contador de tamanho
	li $t5, 0
	
	# Consideramos inicialmente que é falso (string vazia) 
	li $v0, 0
	
hex_valido_loop:
	# Carregando o caractere no endereço atual
	# Checar se é igual a '\0'
	lb $t2, ($t1)
	beqz $t2, hex_valido_fim
	
	# Checar se o caractere está em "0-9a-f"
	sge $t3, $t2, '0'
	sle $t4, $t2, '9'
	and $t6, $t3, $t4
	
	sge $t3, $t2, 'a'
	sle $t4, $t2, 'f'
	and $t7, $t3, $t4
	
	or $v0, $t6, $t7
	beqz $v0, hex_valido_fim
	
	# Checar tamanho (máximo 32 bits)
	addi $t5, $t5, 1
	sle $v0, $t5, 8
	beqz $v0, hex_valido_fim
	
	# Próximo caractere
	addi $t1, $t1, 1
	j hex_valido_loop

hex_valido_fim:
	# Retorno
	jr $ra



	# Verifica se a string (em $a0) é um número decimal de no máximo 32 bits (unsigned)
	# Retorna (em $v0) o valor 1 se é um decimal válido e 0 se não for
dec_valido:
	# Endereço inicial
	move $t0, $a0
	
	# Endereço atual
	move $t1, $a0
	
	# Valor no formato inteiro
	li $t5, 0
	
	# Consideramos inicialmente que é falso (string vazia) 
	li $v0, 0
	
dec_valido_loop:
	# Carregando o caractere no endereço atual
	# Checar se é igual a '\0'
	lb $t2, ($t1)
	beqz $t2, dec_valido_fim
	
	# Checar se o caractere está em "0-9"
	sge $t3, $t2, '0'
	sle $t4, $t2, '9'
	and $v0, $t3, $t4
	beqz $v0, dec_valido_fim
	
	# Checar tamanho (máximo 32 bits)
	
	# Atualizando o valor do inteiro
	mulu $t5, $t5, 10
	# Checando se não houve overflow
	mfhi $t7
	seq $v0, $t7, $zero
	
	# Colocar em $t6 o valor inteiro do caractere lido
	subu $t6, $t2, '0'
	# Atualizando o valor do inteiro
	addu $t5, $t5, $t6
	# Checando se não houve overflow
	sgeu $t7, $t5, $t6
	and $v0, $v0, $t7

	beqz $v0, dec_valido_fim

	# Próximo caractere
	addi $t1, $t1, 1
	j dec_valido_loop

dec_valido_fim:
	# Retorno
	jr $ra


	# Lê um número em binário da entrada e faz todos os tratamentos de erro.
	# Retorna (em $v0) o endereço da string de entrada caso nenhum erro tenha ocorrido
	# No caso em que ocorreu um erro, imprime uma mensagem e retorna o valor 0
bin_in:
	# Guardando os valores de $a0 e $ra
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	
	# Imprimindo a string para receber do usuário
	li $v0, 4
	la $a0, string_entrada_bin
	syscall
	
	# Lendo a string e armazenando na entrada
	jal ler_string
	
	# Verificando se a string lida é válida
	la $a0, entrada
	jal bin_valido

	beqz $v0, bin_in_ocorreu_erro
	
	# Não ocorreu erro -> retornar o endereço da string e finalizar
	move $v0, $a0
	j bin_in_fim

bin_in_ocorreu_erro:

	# Ocorreu erro -> imprimir mensagem de erro e retornar o valor 0
	li $v0, 4
	la $a0, string_entrada_erro
	syscall
	li $v0, 0

bin_in_fim:
	# Carregando de volta os valores de $a0 e $ra e retornando
	lw $ra, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 8
		
	jr $ra



	# Lê um número em hexadecimal da entrada e faz todos os tratamentos de erro.
	# Retorna (em $v0) o endereço da string de entrada caso nenhum erro tenha ocorrido
	# No caso em que ocorreu um erro, imprime uma mensagem e retorna o valor 0
hex_in:
	# Guardando os valores de $a0 e $ra
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	
	# Imprimindo a string para receber do usuário
	li $v0, 4
	la $a0, string_entrada_hex
	syscall
	
	# Lendo a string e armazenando na entrada
	jal ler_string
	
	# Verificando se a string lida é válida
	la $a0, entrada
	jal hex_valido

	beqz $v0, hex_in_ocorreu_erro
	
	# Não ocorreu erro -> retornar o endereço da string e finalizar
	move $v0, $a0
	j hex_in_fim

hex_in_ocorreu_erro:

	# Ocorreu erro -> imprimir mensagem de erro e retornar o valor 0
	li $v0, 4
	la $a0, string_entrada_erro
	syscall
	li $v0, 0

hex_in_fim:
	# Carregando de volta os valores de $a0 e $ra e retornando
	lw $ra, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 8
		
	jr $ra



	# Lê um número em decimal da entrada e faz todos os tratamentos de erro.
	# Retorna (em $v0) o endereço da string de entrada caso nenhum erro tenha ocorrido
	# No caso em que ocorreu um erro, imprime uma mensagem e retorna o valor 0
dec_in:
	# Guardando os valores de $a0 e $ra
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	
	# Imprimindo a string para receber do usuário
	li $v0, 4
	la $a0, string_entrada_dec
	syscall
	
	# Lendo a string e armazenando na entrada
	jal ler_string
	
	# Verificando se a string lida é válida
	la $a0, entrada
	jal dec_valido

	beqz $v0, dec_in_ocorreu_erro
	
	# Não ocorreu erro -> retornar o endereço da string e finalizar
	move $v0, $a0
	j dec_in_fim

dec_in_ocorreu_erro:

	# Ocorreu erro -> imprimir mensagem de erro e retornar o valor 0
	li $v0, 4
	la $a0, string_entrada_erro
	syscall
	li $v0, 0

dec_in_fim:
	# Carregando de volta os valores de $a0 e $ra e retornando
	lw $ra, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 8
		
	jr $ra


