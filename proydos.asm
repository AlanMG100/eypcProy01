title "PROYECTO 2"
	.model small
	.386
	.stack 64

	.data
marcoEsqInfIzq 		equ 	200d 	;'╚'	VALOR ASCII DE CARACTERES PARA
marcoEsqInfDer 		equ 	188d	;'╝'	EL MARCO DEL PROGRAMA
marcoEsqSupDer 		equ 	187d	;'╗'
marcoEsqSupIzq 		equ 	201d 	;'╔'
marcoHor 			equ 	205d 	;'═'
marcoVer 			equ 	186d 	;'║'

cNegro 				equ		00h 	;VALORES DE COLOR PARA CARACTER
cAzul 				equ		01h
cVerde 				equ 	02h
cCyan 				equ 	03h
cRojo 				equ 	04h
cMagenta 			equ		05h
cCafe 				equ 	06h
cGrisClaro			equ		07h
cGrisOscuro			equ		08h
cAzulClaro			equ		09h
cVerdeClaro			equ		0Ah
cCyanClaro			equ		0Bh
cRojoClaro			equ		0Ch
cMagentaClaro		equ		0Dh
cAmarillo 			equ		0Eh
cBlanco 			equ		0Fh

bgNegro 			equ		00h 	;VALORES DE COLOR PARA FONDO DE CARACTER
bgAzul 				equ		10h
bgVerde 			equ 	20h
bgCyan 				equ 	30h
bgRojo 				equ 	40h
bgMagenta 			equ		50h
bgCafe 				equ 	60h
bgGrisClaro			equ		70h
bgGrisOscuro		equ		80h
bgAzulClaro			equ		90h
bgVerdeClaro		equ		0A0h
bgCyanClaro			equ		0B0h
bgRojoClaro			equ		0C0h
bgMagentaClaro		equ		0D0h
bgAmarillo 			equ		0E0h
bgBlanco 			equ		0F0h

menu 				db 		" B I E N V E N I D O ", 0Dh, 0Ah, "$"
menu2 				db 		"     REGRESAR ", 0Dh, 0Ah, "$"
menu3 				db 		"     RELOJ ", 0Dh, 0Ah, "$"
menu5 				db 		"     CRONOMETRO ", 0Dh, 0Ah, "$"
nombre1 			db 		"ESPARZA FUENTES JORGE LUIS", 0Dh, 0Ah, "$"
nombre2 			db 		"MORA GONZALEZ ALAN FRANCISCO", 0Dh, 0Ah, "$"

reloj 				db 		" LA HORA ACTUAL ES: ", 0Dh, 0Ah, "$"
time 				db 		"00:00:00:00 HRS", 0Dh, 0Ah, "$"

cronometro 			db 		" CRONOMETRO: ", 0Dh, 0Ah, "$"
timer 				db 		"00:00:000", 0Dh, 0Ah, "$"
tiempoInicial 		dw 		0, 0
tick_ms 			dw 		55
mil 				dw 		1000
cien 				db 		100
diez 				db 		10
sesenta 			db 		60
contador 			dw 		0
miliSegundos 		dw 		0
segundos 			db 		0
minutos 			db 		0
iniciar 			db 		"     INICIAR ", 0Dh, 0Ah, "$"
detener 			db 		"     PAUSAR ", 0Dh, 0Ah, "$"
reiniciar 			db 		"     RESETEAR ", 0Dh, 0Ah, "$"

col_aux 			db 		0
ren_aux 			db 		0
ocho 				db 		8
no_mouse			db 		'NO SE ENCUENTRA DRIVER DE MOUSE. PRESIONE [ENTER] PARA SALIR$'

exCode 				db 		0

;;;;;;;;;;;;;;
;;; MACROS ;;;
;;;;;;;;;;;;;;

clear macro 		;LIMPIA LA PANTALLA
	mov ax, 0003h	;AH = 00h, SELECCIONA MODO VIDEO
					;AL = 03h, MODO TEXTO, 16 COLORES
	int 10h 		;ESTABLECE MODO DE VIDEO LIMPIANDO PANTALLA
endm

posiciona_cursor macro renglon,columna	;CAMBIA LA POSICION DEL CURSOR A LA ESPECIFICADA
	mov dh, renglon						;DH = RENGLON 
	mov dl, columna						;DL = COLUMNA 
	mov bx, 0
	mov ax, 0200h
	int 10h 							;INTERRUPCION 10h Y OPCION 02h. CAMBIA LA POSICION.
endm

inicializa_ds_es macro 		;INICIALIZA EL VALOR DEL REGISTRO DS Y ES 
	mov ax, @data
	mov ds, ax
	mov es, ax 				;ESTE REGISTRO SE VA A USAR, JUNTO CON BP, PARA IMPRIMIR CADENAS
endm

muestra_cursor_mouse macro 	;ESTABLECE LA VISIBILIDAD DEL CURSOR DEL MOUSE 
	mov ax, 1 				;OPCION 0001h
	int 33h					;HABILITA LA VISIBILIDAD DEL CURSOR DEL MOUSE EN EL PROGRAMA
endm

oculta_cursor_teclado macro ;OCULTA LA VISIBILIDAD DEL CURSOR DEL TECLADO 
	mov ah, 01h 			;OPCION 01h
	mov cx, 2607h 			;PARAMETRO NECESARIO PARA OCULTAR CURSOR 
	int 10h 				;CAMBIA LA VISIBILIDAD DEL CURSOR DEL TECLADO
endm

apaga_cursor_parpadeo macro ;DESHABILITA EL PARPADEO DEL CURSOR
	mov ax, 1003h 			;OPCION 1003h
	xor bl, bl 				;BL = 0, PARAMETRO PARA INT 10h OPCION 1003h
	int 10h 				;CAMBIA LA VISIBILIDAD DEL CURSOR DEL TECLADO
endm

imprime_caracter_color macro caracter, color, bg_color
	mov ah, 09h 			;PREPARAR AH PARA INTERRUPCION, OPCION 09h
	mov al, caracter 		;DL = CARACTER a IMPRIMIR
	mov bh, 0 				;BH = NUMERO DE PAGINA
	mov bl, color
	or bl, bg_color 		;BL = COLOR DEL CARACTER

	mov cx, 1 				;CX = NUMERO DE VECES QUE SE IMPRIME EL CARACTER

	int 10h
endm

imprime_cadena_color macro cadena, long_cadena, color, bg_color
	mov ah, 13h 			;PREPARAR AH PARA INTERRUPCION, OPCION 13h 
	lea bp, cadena 			;BP COMO APUNTADOR A LA CADENA A IMPRIMIR
	mov bh, 0 				;BH = NUMERO DE PAGINA
	mov bl, color 			
	or bl, bg_color 		;BL = COLOR DEL CARACTER

	mov cx, long_cadena 	;CX = LONGITUD DE LA CADENA 
	int 10h 				;IMPRIME EL CARACTER EN AL CON EL COLOR BL
endm

lee_mouse macro 			;REVISA EL ESTADO DEL MOUSE
	mov ax, 0003h 
	int 33h
endm

comprueba_mouse macro 		;REVISA SI EL DRIVER DEL MOUSE EXISTE
	mov ax, 0 				;OPCION 0
	int 33h 				;SI AX = 0000h, NO EXISTE EL DRIVER
endm

;;;;;;;;;;;;;;;;;;
;;; FIN MACROS ;;;
;;;;;;;;;;;;;;;;;;

	.code 					;SEGMENTO DE CODIGO
main: 						;ETIQUETA main
	inicializa_ds_es 		
	comprueba_mouse 		;MACRO PARA REVISAR DRIVER DE MOUSE
	xor ax, 0FFFFh
	jz imprime_ui 			;SI EXISTE EL DRIVER DEL MOUSE, ENTONCES SALTA A 'imprime_ui'

	lea dx, [no_mouse]
	mov ax, 0900h 			;OPCION 9 PARA INTERRUPCION 21h
	int 21h 				;IMPRIME CADENA
	jmp teclado 			;SALTA A 'teclado'

imprime_ui:
	clear
	oculta_cursor_teclado 	;LIMPIA PANTALLA
	apaga_cursor_parpadeo	;DESHABILITA PARPADEO DEL CURSOR
	call DIBUJA_MARCO_EXT 	;PROCEDIMIENTO QUE DIBUJA MARCO DE LA INTERFAZ
	muestra_cursor_mouse 	;HACE VISIBLE EL CURSOR DEL MOUSE

	posiciona_cursor 3, 3 	;IMPRIME MENSAJE DE MENU3
	imprime_cadena_color [menu3], 11, cBlanco, bgGrisOscuro

	;IMPRIMIR [@] PARA IR A RELOJ
	posiciona_cursor 3, 4
	imprime_caracter_color '[', cRojoClaro, bgGrisOscuro
	posiciona_cursor 3, 5
	imprime_caracter_color '@', cRojoClaro, bgGrisOscuro
	posiciona_cursor 3, 6
	imprime_caracter_color ']', cRojoClaro, bgGrisOscuro

	posiciona_cursor 4, 3 	;IMPRIME MENSAJE DE MENU5
	imprime_cadena_color [menu5], 16, cBlanco, bgGrisOscuro

	;IMPRIMIR [@] PARA IR A CRONOMETRO
	posiciona_cursor 4, 4
	imprime_caracter_color '[', cRojoClaro, bgGrisOscuro
	posiciona_cursor 4, 5
	imprime_caracter_color '@', cRojoClaro, bgGrisOscuro
	posiciona_cursor 4, 6
	imprime_caracter_color ']', cRojoClaro, bgGrisOscuro

mouse_no_click: 			;SI EL BOTON NO ESTA SUELTO, NO CONTINUA
	lee_mouse
	test bx, 0001h
	jnz mouse_no_click

mouse: 						;LEE EL MOUSE Y AVANZA HASTA QUE SE HAGA CLICK IZQUIERDO (ADAPTA LAS COLUMNAS A DOSBOX)
	lee_mouse
	test bx, 0001h 			;PARA REVISAR SI EL BOTON IZQUIERDO DEL MOUSE FUE PRESIONADO
	jz mouse 				;SI EL BOTON IZQUIERDO NO FUE PRESIONADO, SALTA A 'mouse'

	mov ax, dx 				;COPIA DX EN AX, DX ES UN VALOR ENTRE 0 Y 199 (RENGLON)
	div [ocho] 				;DIVISION DE 8 BITS

	xor ah, ah 				;DESCARTA EL RESIDUO DE LA DIVISION ANTERIOR
	mov dx, ax 				;COPIA AX EN DX, AX ES UN VSLOR ENTRE 0 Y 24 (RENGLON)

	mov ax, cx 				;COPIA CX EN AX, CX ES UN VALOR ENTRE 0 Y 639 (COLUMNA)
	div [ocho] 				;DIVISION DE 8 BITS

	xor ah, ah 				;DESCARTA EL RESIDUO DE LA DIVISION ANTERIOR
	mov cx, ax 				;COPIA AX EN CX, AX ES UN VALOR ENTRE 0 Y 79 (COLUMNA)

;;;;;;;;;;;;;;;;;;;;;;;;
;;; LOGICA DEL MOUSE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

	cmp dx, 0 				;SI EL MOUSE FUE PRESIONADO EN EL RENGLON 0 (BOTON DE SALIR)
	je boton_x 				;SE VA A REVISAR SI FUE DENTRO DEL BOTON [X]

	cmp dx, 3 				;SI EL MOUSE FUE PRESIONADO EN EL RENGLON 3 (BOTON DE RELOJ)
	je boton_r 				;SE VA A REVISAR SI FUE DENTRO DE [@] 

	cmp dx, 6 				;SI EL MOUSE FUE PRESIONADO EN EL RENGLON 6 (BOTON DE REGRESAR RELOJ)
	je boton_e 				;SE VA A REVISAR SI FUE DENTRO DE [@]

	cmp dx, 4				;SI EL MOUSE FUE PRESIONADO EN EL RENGLON 4 (BOTON DE CRONOMETRO)
	je boton_c 				;SE VA A REVISAR SI FUE DENTRO DE [@]

	cmp dx, 12 				;SI EL MOUSE FUE PRESIONADO EN EL RENGLON 12 (BOTON DE REGRESAR CRONOMETRO)
	je boton_ee 			;SE VA A REVISAR SI FUE DENTRO DE [@]

	cmp dx, 9 				;SI EL MOUSE FUE PRESIONADO EN EL RENGLON 9 (BOTON DE REINICIAR)
	je boton_re 			;SE VA A REVISAR SI FUE DENTRO DE [@]

	cmp dx, 7 				;SI EL MOUSE FUE PRESIONADO EN EL RENGLON 7 (BOTON DE INICIAR)
	je boton_ini 			;SE VA A REVISAR SI FUE DENTRO DE [@]

	cmp dx, 8 				;SI EL MOUSE FUE PRESIONADO EN EL RENGLON 8 (BOTON DE PAUSA)
	je boton_pause 			;SE VA A REVISAR SI FUE DENTRO DE [@]

	jmp mouse_no_click
boton_r:
	jmp boton_r1

boton_r1:
	cmp cx, 4				;LOGICA PARA REVISAR SI EL MOUSE FUE PRESIONADO EN [@]
	jge boton_r2 			;[@] SE ENCUENTRA EN RENGLON 3 Y ENTRE COLUMNAS 4 Y 6
	jmp mouse_no_click
boton_r2:
	cmp cx, 6
	jbe boton_r3
	jmp mouse_no_click
boton_r3:
	jmp imprimeReloj 		;SE CUMPLIERON TODAS LAS CONDICIONES

	jmp mouse_no_click
boton_e:
	jmp boton_e1

boton_e1: 					
	cmp cx, 36 				;LOGICA PARA REVISAR SI EL MOUSE FUE PRESIONADO EN [@]
	jge boton_e2 			;[@] SE ENCUENTRA EN RENGLON 6 Y ENTRE COLUMNAS 36 Y 38
	jmp mouse_no_click

boton_e2:
	cmp cx, 38
	jbe boton_e3
	jmp mouse_no_click
boton_e3:
	jmp imprime_ui 			;SE CUMPLIERON TODAS LAS CONDICIONES

	jmp mouse_no_click
boton_ee:
	jmp boton_ee1

boton_ee1: 					
	cmp cx, 36 				;LOGICA PARA REVISAR SI EL MOUSE FUE PRESIONADO EN [@]
	jge boton_ee2 			;[@] SE ENCUENTRA EN RENGLON 6 Y ENTRE COLUMNAS 36 Y 38
	jmp mouse_no_click

boton_ee2:
	cmp cx, 38
	jbe boton_ee3
	jmp mouse_no_click
boton_ee3:
	jmp imprime_ui 			;SE CUMPLIERON TODAS LAS CONDICIONES

	jmp mouse_no_click
boton_c:
	jmp boton_c1

boton_c1: 					
	cmp cx, 4 				;LOGICA PARA REVISAR SI EL MOUSE FUE PRESIONADO EN [@]
	jge boton_c2 			;[@] SE ENCUENTRA EN RENGLON 4 Y ENTRE COLUMNAS 4 Y 6
	jmp mouse_no_click

boton_c2:
	cmp cx, 6
	jbe boton_c3
	jmp mouse_no_click
boton_c3:
	jmp imprimeCronometro	;SE CUMPLIERON TODAS LAS CONDICIONES

	jmp mouse_no_click
boton_re:
	jmp boton_re1

boton_re1: 					
	cmp cx, 36 				;LOGICA PARA REVISAR SI EL MOUSE FUE PRESIONADO EN [@]
	jge boton_re2 			;[@] SE ENCUENTRA EN RENGLON 9 Y ENTRE COLUMNAS 36 Y 38
	jmp mouse_no_click

boton_re2:
	cmp cx, 38
	jbe boton_re3
	jmp mouse_no_click
boton_re3:
	jmp imprimeCronometro	;SE CUMPLIERON TODAS LAS CONDICIONES

	jmp mouse_no_click
boton_ini:
	jmp boton_ini1

boton_ini1: 					
	cmp cx, 36 				;LOGICA PARA REVISAR SI EL MOUSE FUE PRESIONADO EN [@]
	jge boton_ini2 			;[@] SE ENCUENTRA EN RENGLON 7 Y ENTRE COLUMNAS 36 Y 38
	jmp mouse_no_click

boton_ini2:
	cmp cx, 38
	jbe boton_ini3
	jmp mouse_no_click
boton_ini3:
	jmp loop1				;SE CUMPLIERON TODAS LAS CONDICIONES

	jmp mouse_no_click
boton_pause:
	jmp boton_pause1

boton_pause1: 					
	cmp cx, 36 				;LOGICA PARA REVISAR SI EL MOUSE FUE PRESIONADO EN [@]
	jge boton_pause2 		;[@] SE ENCUENTRA EN RENGLON 8 Y ENTRE COLUMNAS 36 Y 38
	jmp mouse_no_click

boton_pause2:
	cmp cx, 38
	jbe boton_pause3
	jmp mouse_no_click
boton_pause3:
	jmp pausaloop			;SE CUMPLIERON TODAS LAS CONDICIONES

	jmp mouse_no_click
boton_x:
	jmp boton_x1

boton_x1:
	cmp cx, 76 				;LOGICA PARA REVISAR SI EL MOUSE FUE PRESIONADO EN [X]
	jge boton_x2 			;[X] SE ENCUENTRA EN RENGLON 0 Y ENTRE COLUMNAS 76 Y 78
	jmp mouse_no_click
boton_x2:
	cmp cx, 78
	jbe boton_x3
	jmp mouse_no_click
boton_x3:
	jmp salir 				;SE CUMPLIERON TODAS LAS CONDICIONES

;;;;;;;;;;;;;
;;; RELOJ ;;;
;;;;;;;;;;;;;

imprimeReloj:
	posiciona_cursor 3, 35
	imprime_cadena_color [reloj], 20, cBlanco, bgGrisOscuro
	posiciona_cursor 6, 35
	imprime_cadena_color [menu2], 14, cBlanco, bgGrisOscuro

	;IMPRIMIR [@] PARA REGRESAR AL MENU
	posiciona_cursor 6, 36
	imprime_caracter_color '[', cRojoClaro, bgGrisOscuro
	posiciona_cursor 6, 37
	imprime_caracter_color '@', cRojoClaro, bgGrisOscuro
	posiciona_cursor 6, 38
	imprime_caracter_color ']', cRojoClaro, bgGrisOscuro

	repite:
	lea bx, time
	call GETTIME
	posiciona_cursor 4, 38
	imprime_cadena_color [time], 15, cBlanco, bgNegro

	lee_mouse
	test bx, 0001h 			;PARA REVISAR SI EL BOTON IZQUIERDO DEL MOUSE FUE PRESIONADO
	jz repite				;SI EL BOTON IZQUIERDO NO FUE PRESIONADO, SALTA A 'mouse'

	mov ax, dx 				;COPIA DX EN AX, DX ES UN VALOR ENTRE 0 Y 199 (RENGLON)
	div [ocho] 				;DIVISION DE 8 BITS

	xor ah, ah 				;DESCARTA EL RESIDUO DE LA DIVISION ANTERIOR
	mov dx, ax 				;COPIA AX EN DX, AX ES UN VSLOR ENTRE 0 Y 24 (RENGLON)

	mov ax, cx 				;COPIA CX EN AX, CX ES UN VALOR ENTRE 0 Y 639 (COLUMNA)
	div [ocho] 				;DIVISION DE 8 BITS

	xor ah, ah 				;DESCARTA EL RESIDUO DE LA DIVISION ANTERIOR
	mov cx, ax 				;COPIA AX EN CX, AX ES UN VALOR ENTRE 0 Y 79 (COLUMNA)

	jmp mouse

;;;;;;;;;;;;;;;;;
;;; FIN RELOJ ;;;
;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
;;; CRONOMETRO ;;;
;;;;;;;;;;;;;;;;;;

imprimeCronometro:
	posiciona_cursor 3, 35
	imprime_cadena_color [cronometro], 13, cBlanco, bgGrisOscuro
	posiciona_cursor 12, 35
	imprime_cadena_color [menu2], 14, cBlanco, bgGrisOscuro

	;IMPRIMIR [@] PARA REGRESAR AL MENU
	posiciona_cursor 12, 36
	imprime_caracter_color '[', cRojoClaro, bgGrisOscuro
	posiciona_cursor 12, 37
	imprime_caracter_color '@', cRojoClaro, bgGrisOscuro
	posiciona_cursor 12, 38
	imprime_caracter_color ']', cRojoClaro, bgGrisOscuro

	lea bx, timer
	call RESET 
	posiciona_cursor 4, 38
	imprime_cadena_color [timer], 9, cBlanco, bgNegro

	mov ah,00h
	int 1Ah
	mov [tiempoInicial], dx 
	mov [tiempoInicial+2], cx

	posiciona_cursor 7, 35
	imprime_cadena_color [iniciar], 13, cBlanco, bgGrisOscuro

	;IMPRIMIR [@] PARA INICIAR CRONOMETRO
	posiciona_cursor 7, 36
	imprime_caracter_color '[', cRojoClaro, bgGrisOscuro
	posiciona_cursor 7, 37
	imprime_caracter_color '@', cRojoClaro, bgGrisOscuro
	posiciona_cursor 7, 38
	imprime_caracter_color ']', cRojoClaro, bgGrisOscuro

	posiciona_cursor 8, 35
	imprime_cadena_color [detener], 12, cBlanco, bgGrisOscuro

	;IMPRIMIR [@] PARA PAUSAR CRONOMETRO
	posiciona_cursor 8, 36
	imprime_caracter_color '[', cRojoClaro, bgGrisOscuro
	posiciona_cursor 8, 37
	imprime_caracter_color '@', cRojoClaro, bgGrisOscuro
	posiciona_cursor 8, 38
	imprime_caracter_color ']', cRojoClaro, bgGrisOscuro

	posiciona_cursor 9, 35
	imprime_cadena_color [reiniciar], 14, cBlanco, bgGrisOscuro

	;IMPRIMIR [@] PARA REINICIAR CRONOMETRO
	posiciona_cursor 9, 36
	imprime_caracter_color '[', cRojoClaro, bgGrisOscuro
	posiciona_cursor 9, 37
	imprime_caracter_color '@', cRojoClaro, bgGrisOscuro
	posiciona_cursor 9, 38
	imprime_caracter_color ']', cRojoClaro, bgGrisOscuro

intermedio: 				;ESPERA A QUE EL USUARIO HAGA CLICK SOBRE LOS BOTONES
	lee_mouse
	test bx, 0001h
	jz intermedio

	mov ax, dx 				;COPIA DX EN AX, DX ES UN VALOR ENTRE 0 Y 199 (RENGLON)
	div [ocho] 				;DIVISION DE 8 BITS

	xor ah, ah 				;DESCARTA EL RESIDUO DE LA DIVISION ANTERIOR
	mov dx, ax 				;COPIA AX EN DX, AX ES UN VSLOR ENTRE 0 Y 24 (RENGLON)

	mov ax, cx 				;COPIA CX EN AX, CX ES UN VALOR ENTRE 0 Y 639 (COLUMNA)
	div [ocho] 				;DIVISION DE 8 BITS

	xor ah, ah 				;DESCARTA EL RESIDUO DE LA DIVISION ANTERIOR
	mov cx, ax 				;COPIA AX EN CX, AX ES UN VALOR ENTRE 0 Y 79 (COLUMNA)

	jmp mouse

loop1:
	lea bx, timer
	call GETTIMER

	posiciona_cursor 4, 38
	imprime_cadena_color [timer], 9, cBlanco, bgNegro

	lee_mouse
	test bx, 0001h 			;PARA REVISAR SI EL BOTON IZQUIERDO DEL MOUSE FUE PRESIONADO
	jz loop1				;SI EL BOTON IZQUIERDO NO FUE PRESIONADO, SALTA A 'mouse'

	mov ax, dx 				;COPIA DX EN AX, DX ES UN VALOR ENTRE 0 Y 199 (RENGLON)
	div [ocho] 				;DIVISION DE 8 BITS

	xor ah, ah 				;DESCARTA EL RESIDUO DE LA DIVISION ANTERIOR
	mov dx, ax 				;COPIA AX EN DX, AX ES UN VSLOR ENTRE 0 Y 24 (RENGLON)

	mov ax, cx 				;COPIA CX EN AX, CX ES UN VALOR ENTRE 0 Y 639 (COLUMNA)
	div [ocho] 				;DIVISION DE 8 BITS

	xor ah, ah 				;DESCARTA EL RESIDUO DE LA DIVISION ANTERIOR
	mov cx, ax 				;COPIA AX EN CX, AX ES UN VALOR ENTRE 0 Y 79 (COLUMNA)

	jmp mouse

pausaloop:
	posiciona_cursor 4, 38
	imprime_cadena_color [timer], 9, cBlanco, bgNegro

	lee_mouse
	test bx, 0001h 			;PARA REVISAR SI EL BOTON IZQUIERDO DEL MOUSE FUE PRESIONADO
	jz pausaloop			;SI EL BOTON IZQUIERDO NO FUE PRESIONADO, SALTA A 'mouse'

	mov ax, dx 				;COPIA DX EN AX, DX ES UN VALOR ENTRE 0 Y 199 (RENGLON)
	div [ocho] 				;DIVISION DE 8 BITS

	xor ah, ah 				;DESCARTA EL RESIDUO DE LA DIVISION ANTERIOR
	mov dx, ax 				;COPIA AX EN DX, AX ES UN VSLOR ENTRE 0 Y 24 (RENGLON)

	mov ax, cx 				;COPIA CX EN AX, CX ES UN VALOR ENTRE 0 Y 639 (COLUMNA)
	div [ocho] 				;DIVISION DE 8 BITS

	xor ah, ah 				;DESCARTA EL RESIDUO DE LA DIVISION ANTERIOR
	mov cx, ax 				;COPIA AX EN CX, AX ES UN VALOR ENTRE 0 Y 79 (COLUMNA)

	jmp mouse

;;;;;;;;;;;;;;;;;;;;;;
;;; FIN CRONOMETRO ;;;
;;;;;;;;;;;;;;;;;;;;;;

teclado: 					;SI NO SE ENCONTRO EL DRIVER DEL MOUSE, MUESTRA UN MENSAJE
	mov ah, 08h
	int 21h
	cmp al, 0Dh
	jnz teclado

salir: 						;INICIA ETIQUETA SALIR
	clear 					;LIMPIA PANTALLA
	mov ax, 4C00h
	int 21h 				;PASA EL CONTROL AL SISTEMA OPERATIVO

;;;;;;;;;;;;;;;;;;;;;;
;;; PROCEDIMIENTOS ;;;
;;;;;;;;;;;;;;;;;;;;;;

DIBUJA_MARCO_EXT proc 
	posiciona_cursor 0, 0	;IMPRIMIR ESQUINA SUPERIOR IZQUIERDA DEL MARCO
	imprime_caracter_color marcoEsqSupIzq, cVerdeClaro, bgNegro

	posiciona_cursor 0, 79 	;IMPRIMIR ESQUINA SUPERIOR DERECHA DEL MARCO
	imprime_caracter_color marcoEsqSupDer, cVerdeClaro, bgNegro

	posiciona_cursor 24, 0 	;IMPRIMIR ESQUINA INFERIOR IZQUIERDA DEL MARCO
	imprime_caracter_color marcoEsqInfIzq, cVerdeClaro, bgNegro

	posiciona_cursor 24, 79 ;IMPRIMIR ESQUINA INFERIOR DERECHA DEL MARCO
	imprime_caracter_color marcoEsqInfDer, cVerdeClaro, bgNegro

	mov cx, 78 				;IMPRIMIR MARCOS HORIZONTALES

marco_sup_e_inf:
	mov [col_aux], cl

	posiciona_cursor 0, [col_aux] 	;SUPERIOR
	imprime_caracter_color marcoHor, cVerdeClaro, bgNegro

	posiciona_cursor 24, [col_aux] 	;INFERIOR
	imprime_caracter_color marcoHor, cVerdeClaro, bgNegro
	mov cl, [col_aux]
	loop marco_sup_e_inf

	mov cx, 23 				;IMPRIMIR MARCOS VERTICALES

marco_der_e_izq:
	mov [ren_aux], cl

	posiciona_cursor [ren_aux], 0 	;IZQUIERDO
	imprime_caracter_color marcoVer, cVerdeClaro, bgNegro

	posiciona_cursor [ren_aux], 79 	;DERECHO
	imprime_caracter_color marcoVer, cVerdeClaro, bgNegro
	mov cl, [ren_aux]
	loop marco_der_e_izq

	;IMPRIMIR [X] PARA CERRAR PROGRAMA
	posiciona_cursor 0, 76
	imprime_caracter_color '[', cRojoClaro, bgNegro
	posiciona_cursor 0, 77
	imprime_caracter_color 'X', cRojoClaro, bgNegro
	posiciona_cursor 0, 78
	imprime_caracter_color ']', cRojoClaro, bgNegro

	;IMPRIMIR TITULO
	posiciona_cursor 0, 31
	imprime_cadena_color [menu], 21, cBlanco, bgNegro
	ret 
	endp

GETTIME proc				;INICIO DEL PROCESO GETTIME
	push ax					;LO QUE CONTIENE ax SE GUARDA EN LA PILA
	push cx					;LO QUE CONTIENE bx SE GUARDA EN LA PILA

	mov ah, 2Ch				;INTERRUPCION QUE SIRVE PARA OBTENER LA HORA DEL SISTEMA
	int 21h

	mov al, ch 				;GUARDAMOS EN AL EL CONTENIDO DE CH, EN ESTE CASO LAS HORAS
	call CONVERT			;LLAMAMOS AL PROCESO CONVERT
	mov [bx], ax			;SE MUEVEN LAS HORAS A LA POSICION QUE TIENE [bx]
							;EJEMPLO 10:00:00:00
	
	mov al, cl 				;GUARDAMOS EN AL EL CONTENIDO DE CL, EN ESTE CASO LOS MINUTOS
	call CONVERT  			;LLAMAMOS AL PROCESO CONVERT
	mov [bx+3], ax 			;SE MUEVEN LOS MINUTOS A LA POSICION QUE TIENE [bx+3]
							;EJEMPLO 10:51:00:00

	mov al, dh 				;GUARDAMOS EN AL EL CONTENIDO DE DH, EN ESTE CASO LOS SEGUNDOS
	call CONVERT 			;LLAMAMOS AL PROCESO CONVERT
	mov [bx+6], ax 			;SE MUEVEN LOS SEGUNDOS A LA POSICION QUE TIENE [bx+6]
							;EJEMPLO 10:51:42:00

	mov al, dl 				;GUARDAMOS EN AL EL CONTENIDO DE DL, EN ESTE CASO LOS MILISEGUNDOS
	call CONVERT 			;LLAMAMOS AL PROCESO CONVERT
	mov [bx+9], ax 			;SE MUEVEN LOS MILISEGUNDOS A LA POSICION QUE TIENE [bx+9]
							;EJEMPLO 10:51:42:12 

	pop cx 					;SACAMOS DE LA PILA cx
	pop ax					;SACAMOS DE LA PILA ax

	ret 					;CERRAMOS EL PROCESO Y CONTINUAMOS CON EL FLUJO DEL PROGRAMA
	endp

CONVERT proc 				;INICIO DEL PROCESO CONVERT
	push dx 				;LO QUE CONTIENE dx SE GUARDA EN LA PILA

	mov ah, 0				;UTILIZAMOS ESTAS FUNCIONES PARA PASAR DE ASCII A DECIMAL
	mov dl, 10
	div dl
	or ax, 3030h	

	pop dx					;SACAMOS DE LA PILA dx
	ret 					;RETORNAMOS EL VALOR OBTENIDO
	endp

GETTIMER proc
	push ax 				;LO QUE CONTIENE ax SE GUARDA EN LA PILA
	push cx 				;LO QUE CONTIENE cx SE GUARDA EN LA PILA
	push dx 				;LO QUE CONTIENE dx SE GUARDA EN LA PILA
	push bx 				;LO QUE CONTIENE bx SE GUARDA EN LA PILA

	mov ah,00h
	int 1Ah

	mov ax, [tiempoInicial]		;AX = parte baja de t_inicial
	mov bx, [tiempoInicial+2]	;BX = parte alta de t_inicial

	sub dx, ax  				;DX = DX - AX = t_final - t_inicial, DX guarda la parte baja del contador de ticks
	sbb cx, bx 					;CX = CX - BX - C = t_final - t_inicial - C, CX guarda la parte alta del contador de ticks y se resta el acarreo si hubo en la resta anterior

	mov ax, dx 				;GUARDAMOS EN ax EL CONTENIDO DE dx, EN ESTE CASO LA PARTE BAJA DEL CONTADOR 
	mul [tick_ms] 			;MULTIPLICAMOS ax POR LOS TICKS QUE EXISTEN EN CADA MILISEGUNDO
	div [mil]				;DESPUES LO DIVIDIMOS ENTRE 1000
	
	mov [miliSegundos], dx 	;AQUI OBTENEMOS LOS MILISEGUNDOS
	div [sesenta] 			;DIVIDIMOS ENTRE 60 PARA OBTENER LOS SEGUNDOS 
	mov [segundos], ah 		;AQUI OBTENEMOS LOS SEGUNDOS 
	xor ah, ah 				
	div[sesenta] 			;DIVIDIMOS ENTRE 60 PARA OBTENER LOS MINUTOS 
	mov [minutos], ah 		;OBTENEMOS LOS MINUTOS

	pop bx 					;RECUPERAMOS LO QUE TENIAMOS EN bx PARA PODER MODIFICAR LA VARIABLE TIMER 

	xor ah, ah 				;COMENZAMOS A CONVERTIR EL ASCII PARA LOS MINUTOS 
	mov al, [minutos]
	AAM
	or ax, 3030h
	mov cl, al
	mov [bx], ah 			;DECENAS DE LOS MINUTOS
	mov [bx+1], cl 			;UNIDADES DE LOS MINUTOS 

	xor ah, ah 				;COMENZAMOS A CONVERTIR EL ASCII PARA LOS SEGUNDOS 
	mov al, [segundos]
	AAM
	or ax, 3030h
	mov cl, al
	mov [bx+3], ah 			;DECENAS DE LOS SEGUNDOS
	mov [bx+4], cl 			;UNIDADES DE LOS SEGUNDOS 

	mov ax, [miliSegundos] 	;COMENZAMOS A CONVERTIR EL ASCII PARA LOS MILISEGUNDOS 
	div [cien]
	xor al, 30h
	mov cl, ah
	mov [bx+6], al 			;CENTENAS DE LOS MILISEGUNDOS

	mov al, cl 				
	xor ah, ah
	AAM
	or ax, 3030h
	mov cl, al
	mov [bx+7], ah 			;DECENAS DE LOS MILISEGUNDOS 
	mov [bx+8], cl 			;UNIDADES DE LOS MILISEGUNDOS

	pop dx 					;SACAMOS DE LA PILA dx
	pop cx 					;SACAMOS DE LA PILA cx 
	pop ax 					;SACAMOS DE LA PILA ax

	ret
	endp

RESET proc 					;INICIO DEL PROCESO RESET 
	push ax 				;LO QUE CONTIENE ax SE GUARDA EN LA PILA
	push cx 				;LO QUE CONTIENE cx SE GUARDA EN LA PILA
	push bx 				;LO QUE CONTIENE bx SE GUARDA EN LA PILA

	mov ax, 3030h 			;LIMPIAMOS LAS VARIABLES
	mov [bx], ax
	mov [bx+3], ax
	mov [bx+6], ax
	mov [bx+7], ax

	pop bx 					;SACAMOS DE LA PILA bx
	pop cx 					;SACAMOS DE LA PILA cx
	pop ax 					;SACAMOS DE LA PILA ax 

	ret
	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FIN PROCEDIMIENTOS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

	end main
