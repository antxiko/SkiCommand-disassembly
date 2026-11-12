; ==========================================================================
; SKI COMMAND - Casio - MSX1 (1984) - ROM de 16 KB en 0x8000
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x08000


; ----------------------------------------------------------------------
; DATOS cabecera: "AB", INIT (0x8010) y el resto de la cabecera a cero
;   0x8000..0x8010  (16 bytes)
DATA_cabecera:
	defb 041h,042h	; 8000
	defw 08010h,00000h,00000h,00000h,00000h,00000h,00000h	; 8002

; ======================================================================
; CODIGO 0x8010..0x8465  (1109 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; INIT: el sonido callado, SCREEN 2, el registro 1, el record y la presentacion.
; ----------------------------------------------------------------------
init:		; El arranque
	di			;8010
	ld sp,0f300h		;8011   ; la pila, por debajo de la zona de trabajo de la BIOS
	call sonido_calla		;8014   ; el sonido a cero
	ld a,002h		;8017
	ld (0fcafh),a		;8019   ; SCRMOD = 2...
	call 0005fh		;801c   ; ...y CHGMOD: SCREEN 2
	ld bc,0e201h		;801f   ; el registro 1 a 0xE2: 16 K, pantalla encendida, interrupciones, sprites de 16x16
	call 00047h		;8022   ; WRTVDP
	ld a,001h		;8025   ; el borde (BDRCLR) negro...
	ld (0f3ebh),a		;8027
	call 00062h		;802a   ; ...con CHGCLR
	ld hl,00064h		;802d   ; el record empieza en 100 (10.000 en pantalla)
	ld (0e906h),hl		;8030
	call 00041h		;8033   ; DISSCR: la pantalla apagada mientras se dibuja
presentacion:		; La presentacion: CASIO y SKI COMMAND en letras grandes, PUSH TRIGGER y la demo
	ld hl,00064h		;8036   ; la primera vida extra a los 100 (10.000)
	ld (0e908h),hl		;8039
	call nombres_borra		;803c   ; la tabla de nombres a cero
	call irq_solo_musica_pon		;803f   ; la interrupcion, solo la musica
	call ram_borra		;8042   ; la RAM de la partida a cero
	ld hl,00000h		;8045   ; sin puntos...
	ld (0e90ah),hl		;8048   ; ...ni ronda...
	ld (0e90ch),hl		;804b   ; ...ni demo
	ld (0e914h),hl		;804e
	ld a,004h		;8051   ; cuatro vidas
	ld (0e90eh),a		;8053   ; (tres de reserva y la que juega)
	call sprites_fuera		;8056   ; los sprites fuera de la pantalla
	ld hl,02000h		;8059   ; el color de las letras grandes: 0xF1, blanco sobre negro...
	ld bc,00800h		;805c
	ld a,0f1h		;805f   ; ...los 2 KB del primer tercio
	call 00056h		;8061
	ld hl,0b774h		;8064   ; los dibujos de las letras grandes (0xB774, 28 letras)
	ld de,00000h		;8067
	ld bc,000e0h		;806a
	call 0005ch		;806d
	ld hl,0b7f4h		;8070   ; y los de las letras pequenas (0xB7F4, a partir de la letra 0x30)
	ld de,00180h		;8073
	ld bc,00180h		;8076
	call 0005ch		;8079
	call tercio_copia		;807c   ; copia el primer tercio de dibujos y colores a los otros dos
	ld hl,02000h		;807f   ; otra vez los colores: 0x71, azul claro sobre negro
	ld bc,00800h		;8082
	ld a,071h		;8085
	call 00056h		;8087
	ld hl,084bch		;808a   ; los seis carteles de la presentacion (0x84BC)...
	ld b,006h		;808d
L_808F:
	push bc			;808f
	call lee4		;8090   ; ...direccion y longitud...
	ld b,000h		;8093   ; (la longitud es un byte: el puntero vuelve atras uno)
	dec hl			;8095
	call ldirvm		;8096   ; ...y el texto a la tabla de nombres
	pop bc			;8099
	djnz L_808F		;809a
	call ram_borra		;809c   ; la RAM de la partida a cero
	call 00044h		;809f   ; ENASCR
	ld hl,00000h		;80a2   ; el contador de cuadros a cero
	ld (0e881h),hl		;80a5
espera_titulo:		; Espera el boton 1, o que pasen 512 cuadros: entonces empieza la demo
	ld a,(0e882h)		;80a8   ; el contador de cuadros, la parte alta...
	cp 002h		;80ab   ; ...a los 512 cuadros...
	jr c,L_80BC		;80ad
	ld (0e914h),a		;80af   ; ...es la demo
	ld a,001h		;80b2   ; la demo empieza en la ronda 1...
	ld (0e90eh),a		;80b4   ; ...con una vida
	ld (0e90ch),a		;80b7
	jr empieza		;80ba
L_80BC:
	call mando		;80bc   ; lee el mando
	ld a,(0e89eh)		;80bf   ; el boton 1...
	rra			;80c2   ; ...en el acarreo
	jr nc,espera_titulo		;80c3
empieza:		; Empieza una partida (o la demo): la ronda siguiente
	xor a			;80c5   ; aun no se ha pasado de la demo a jugar
	ld (0e90dh),a		;80c6
	ld hl,0e90ch		;80c9   ; la ronda...
	inc (hl)			;80cc   ; ...una mas
ronda:		; Una ronda: carga los dibujos de la pista, el marcador y el cartel ROUND
	call 00041h		;80cd   ; DISSCR
	call irq_solo_musica_pon		;80d0   ; la interrupcion, solo la musica
	ld hl,09fedh		;80d3   ; los dibujos de la pista (0x9FED): 28 casillas...
	ld de,00000h		;80d6   ; a la casilla 0
	ld bc,000e0h		;80d9   ; ...a las primeras de la tabla de dibujos
	call 0005ch		;80dc   ; LDIRVM
	ld hl,0a00dh		;80df   ; el suelo de la pista (0xA00D): 18 casillas...
	ld de,0e000h		;80e2   ; en 0xE000...
	ld c,090h		;80e5   ; ...giradas (cada casilla, de lado: 0x96DA)...
	push de			;80e7
	call gira		;80e8   ; ...en 0xE000...
	pop hl			;80eb
	ld de,000e0h		;80ec   ; ...y detras de las de la pista
	ld bc,00090h		;80ef
	call 0005ch		;80f2   ; LDIRVM
	ld hl,0adfdh		;80f5   ; sus colores (0xADFD)
	ld de,02000h		;80f8   ; a 0x2000
	ld bc,000e0h		;80fb
	call 0005ch		;80fe   ; LDIRVM
	ld hl,0ae1dh		;8101   ; y los del suelo (0xAE1D)
	ld de,020e0h		;8104   ; a 0x20E0
	ld bc,00090h		;8107
	call 0005ch		;810a   ; LDIRVM
	ld hl,02180h		;810d   ; el resto de colores: 0xF4, blanco sobre azul
	ld bc,00280h		;8110   ; 0x280 bytes...
	ld a,0f4h		;8113   ; ...de la casilla 0x30 en adelante
	call 00056h		;8115   ; FILVRM
	ld hl,0aa4dh		;8118   ; la nieve de los lados (0xAA4D, 59 casillas desde la 0x80)...
	ld de,00400h		;811b   ; a 0x0400...
	ld bc,001d8h		;811e   ; ...0x1D8 bytes
	call 0005ch		;8121   ; LDIRVM
	ld hl,0ac25h		;8124   ; ...y sus colores (0xAC25)
	ld de,02400h		;8127   ; a 0x2400
	ld bc,001d8h		;812a
	call 0005ch		;812d   ; LDIRVM
	call tercio_copia		;8130   ; copia el primer tercio a los otros dos
	ld hl,0a0cdh		;8133   ; los dibujos del marcador (0xA0CD, 32 casillas desde la 0x80)
	ld de,00400h		;8136   ; a 0x0400
	ld bc,00100h		;8139
	call 0005ch		;813c   ; LDIRVM
	ld hl,02400h		;813f   ; y sus colores: 0xF5, blanco sobre azul claro...
	ld bc,000a8h		;8142   ; 0xA8 bytes
	ld a,0f5h		;8145
	call 00056h		;8147   ; FILVRM
	ld hl,024a0h		;814a   ; ...y otro tramo igual
	ld bc,00050h		;814d   ; 0x50 bytes desde 0x24A0
	ld a,0f5h		;8150
	call 00056h		;8152   ; FILVRM
	ld hl,0aeddh		;8155   ; los de las cifras (0xAEDD)
	ld de,024e8h		;8158   ; a 0x24E8
	ld bc,00018h		;815b
	call 0005ch		;815e   ; LDIRVM
	ld hl,0aef5h		;8161   ; y los colores de las letras grandes (0xAEF5)
	ld de,02020h		;8164   ; a 0x2020
	ld bc,00040h		;8167
	call 0005ch		;816a   ; LDIRVM
	call sprites_carga		;816d   ; los sprites (0xA1CD y 0xA34D)
	ld a,080h		;8170   ; la espera: 128 cuadros
	ld (0e884h),a		;8172
	call demo		;8175   ; si es la demo, sin cartel
	jr nz,L_8198		;8178   ; la demo
	call nombres_borra		;817a   ; la tabla de nombres a cero
	ld de,018e8h		;817d   ; fila 7, columna 8: ROUND...
	ld hl,08551h		;8180   ; ...(0x8551, 15 letras)
	ld bc,0000fh		;8183   ; 15 letras
	call 0005ch		;8186   ; LDIRVM
	ld de,018eeh		;8189   ; ...y la ronda, en la columna 14
	call pinta_ronda		;818c   ; la ronda en tres cifras
	call 00044h		;818f   ; ENASCR
espera_cartel:		; Espera a que la cuenta 0xE884 llegue a 0xFF
	ld a,(0e884h)		;8192
	inc a			;8195
	jr nz,espera_cartel		;8196
L_8198:
	call 00041h		;8198   ; la pantalla, apagada
	call nombres_borra		;819b   ; la tabla de nombres a cero
	ld hl,01900h		;819e   ; la pista: 16 filas de 25 casillas, desde la fila 8...
	ld b,010h		;81a1   ; 16 filas
L_81A3:
	push bc			;81a3
	push hl			;81a4
	ld bc,00019h		;81a5   ; 25 casillas...
	ld a,002h		;81a8   ; ...con la casilla 2 (la pista lisa)
	call 00056h		;81aa
	pop hl			;81ad
	ld de,00020h		;81ae
	add hl,de			;81b1
	pop bc			;81b2
	djnz L_81A3		;81b3
	ld b,00bh		;81b5   ; la nieve de la izquierda: 11 filas en escalera...
	ld hl,01900h		;81b7   ; desde la fila 8, columna 0
	ld e,00bh		;81ba   ; 11 casillas la primera
L_81BC:
	push bc			;81bc   ; una fila...
	ld c,e			;81bd   ; ...de E casillas...
	ld b,000h		;81be
	ld a,003h		;81c0   ; ...con la casilla 3, cada fila una menos
	push hl			;81c2
	push de			;81c3
	call 00056h		;81c4
	pop de			;81c7
	pop hl			;81c8
	ld bc,00020h		;81c9   ; la fila siguiente
	add hl,bc			;81cc
	pop bc			;81cd
	dec e			;81ce   ; una menos
	djnz L_81BC		;81cf
	ld b,00bh		;81d1   ; la de la derecha: 11 filas, desde la columna 14...
	ld hl,0190eh		;81d3
	ld e,00bh		;81d6   ; 11 casillas la primera
L_81D8:
	push bc			;81d8   ; una fila...
	ld c,e			;81d9   ; ...de E casillas...
	ld b,000h		;81da
	ld a,003h		;81dc
	push hl			;81de
	push de			;81df
	call 00056h		;81e0
	pop de			;81e3
	pop hl			;81e4
	ld bc,00021h		;81e5   ; ...bajando una columna mas en cada fila
	add hl,bc			;81e8
	pop bc			;81e9
	dec e			;81ea   ; una menos
	djnz L_81D8		;81eb
	call monte		;81ed   ; el monte del fondo (0x9187)
	call marcador_pinta		;81f0   ; el marcador
	call ram_borra		;81f3   ; la RAM de la partida a cero
	ld hl,08465h		;81f6   ; los sprites del esquiador (0x8465: tres sprites)...
	ld de,0e800h		;81f9   ; en 0xE800
	ld bc,00010h		;81fc   ; 16 bytes
	ldir		;81ff
	ld de,0e8a0h		;8201   ; ...y su Y, su X y su dibujo
	ld bc,00003h		;8204   ; 3 bytes
	ldir		;8207
	ld a,003h		;8209   ; la pista empieza recta (columna 3)
	ld (0e8fdh),a		;820b
	ld a,(0e90dh)		;820e   ; la parte alta del contador de cuadros: se pasa de la demo?
	ld (0e882h),a		;8211   ; en 0xE882: los tramos siguen donde iba la demo
	call tramo_dibujos		;8214   ; los dibujos de la nieve del tramo
	di			;8217   ; sin interrupciones mientras se pinta
	xor a			;8218   ; el contador de cuadros a cero
	ld (0e881h),a		;8219
	call pista		;821c   ; las lineas de la pista
	call esquiador_sprites		;821f   ; el esquiador
	call sprites_vram		;8222   ; los sprites
	call 00044h		;8225   ; ENASCR
	call ronda1_juega		;8228   ; la ronda 1 y no la demo? (Z)...
	push bc			;822b
	call z,musica_salida		;822c   ; ...la musica de salida
	pop bc			;822f
	ld a,b			;8230   ; la ronda...
ronda_dificultad:		; La dificultad: la ronda, de 2 en 2 hasta menos de 6, por 4, en la tabla 0x84A4
	cp 006h		;8231
	jr c,L_8239		;8233   ; menos de 6...
	sub 002h		;8235   ; ...si no, dos menos
	jr ronda_dificultad		;8237
L_8239:
	add a,a			;8239   ; (por cuatro)
	add a,a			;823a
	ld c,a			;823b
	ld b,000h		;823c
	ld hl,084a4h		;823e   ; la tabla de dificultad (0x84A4)
	add hl,bc			;8241
	ld de,0e8feh		;8242   ; a 0xE8FE: cuatro bytes
	ld bc,00004h		;8245
	ldir		;8248
	ld a,080h		;824a   ; la musica de la ronda, dentro de 128 cuadros
	ld (0e889h),a		;824c
	ld hl,08569h		;824f   ; la interrupcion de la partida (0x8569)
	ld (0fda0h),hl		;8252
bucle_ronda:		; El bucle de la ronda: todo va en la interrupcion; aqui se espera a que se acabe o a perder una vida
	ld hl,0e8f9h		;8255   ; se ha acabado la ronda?...
	ld a,(hl)			;8258
	or a			;8259
	jp nz,pattern_clear		;825a   ; ...PATTERN CLEAR
	inc hl			;825d   ; ha chocado el esquiador?
	ld a,(hl)			;825e   ; (0xE8FA)
	or a			;825f   ; choque?
	jr z,bucle_ronda		;8260
	call irq_solo_musica_pon		;8262   ; la interrupcion, solo la musica
	ld a,(0e882h)		;8265   ; la parte alta del contador de cuadros...
	ld (0e90dh),a		;8268   ; ...pasa a 0xE90D (la demo se acaba al chocar)
	call musica_choque		;826b   ; la musica del choque
	ld hl,0e80ch		;826e   ; los sprites fuera de la pantalla (0xC0), salvo los cuatro primeros...
	ld de,0e80dh		;8271
	ld bc,00070h		;8274   ; 0x70 bytes
	ld (hl),0c0h		;8277   ; 0xC0...
	ldir		;8279   ; ...en 0x70 bytes
	ld hl,0a9edh		;827b   ; el esquiador cayendo (0xA9ED, tres dibujos)...
	ld de,03c00h		;827e   ; ...a los sprites 0x80-0x82
	ld bc,00060h		;8281   ; 0x60 bytes...
	call sprites_girados		;8284   ; ...y girados
	ld a,0f8h		;8287   ; la espera: 8 cuadros
	ld (0e884h),a		;8289
	xor a			;828c   ; sin paso de lado...
	ld (0e8fch),a		;828d   ; (0xE8FC)
	ld a,(0e8a3h)		;8290   ; ...salvo si estaba saltando...
	or a			;8293
	jr z,L_829B		;8294
	ld a,003h		;8296   ; ...entonces 3
	ld (0e8fch),a		;8298
L_829B:
	ld a,001h		;829b   ; el dibujo del esquiador en el suelo...
	ld (0e8a2h),a		;829d
	ld a,008h		;82a0   ; ...y el del recorrido
	ld (0e88dh),a		;82a2   ; (0xE88D, el dibujo de la caida)
	ld b,005h		;82a5   ; cinco vueltas de la caida
L_82A7:
	push bc			;82a7
caida_espera:		; La caida: pinta el esquiador y espera la cuenta
	call esquiador_sprites		;82a8
	call sprites_vram		;82ab   ; y los sprites
	ld a,(0e884h)		;82ae   ; la espera...
	inc a			;82b1   ; ...ha acabado?
	jr nz,caida_espera		;82b2
	ld a,(0e8fch)		;82b4   ; el paso de lado...
	ld b,a			;82b7
	ld a,(0e8a0h)		;82b8   ; ...a la Y
	add a,b			;82bb
	ld (0e8a0h),a		;82bc
	ld a,0f8h		;82bf   ; otros 8 cuadros
	ld (0e884h),a		;82c1   ; (0xE884)
	ld a,(0e88dh)		;82c4   ; el dibujo siguiente...
	inc a			;82c7
	cp 00bh		;82c8   ; ...hasta el 0x0A...
	jr c,L_82CE		;82ca
	ld a,009h		;82cc   ; ...y vuelta al 9
L_82CE:
	ld (0e8a2h),a		;82ce
	ld (0e88dh),a		;82d1
	pop bc			;82d4   ; la vuelta siguiente
	djnz L_82A7		;82d5
caida_fin:		; Despues de la caida: la cuenta, los sprites fuera y a esperar la musica
	ld a,(0e884h)		;82d7   ; la ultima espera
	inc a			;82da
	jr nz,caida_fin		;82db
	call sprites_fuera		;82dd   ; los sprites fuera de la pantalla
	call sprites_vram		;82e0
caida_musica:		; Espera a que la musica deje de sonar
	call musica_suena		;82e3
	jr nz,caida_musica		;82e6
	ld hl,0e90eh		;82e8   ; una vida menos...
	dec (hl)			;82eb
	jp nz,ronda		;82ec   ; ...y si quedan, otra vez la ronda
	call nombres_borra		;82ef   ; GAME OVER: la tabla de nombres a cero
	call marcador_pinta		;82f2   ; el marcador
	ld hl,08560h		;82f5   ; GAME OVER (0x8560) en la fila 7, columna 8
	ld de,018e8h		;82f8   ; fila 7, columna 8
	ld bc,00009h		;82fb   ; 9 letras
	call 0005ch		;82fe
	call musica_game_over		;8301   ; la musica de GAME OVER
game_over_espera:		; Espera a que acabe la musica y vuelve a la presentacion
	call musica_suena		;8304
	jr nz,game_over_espera		;8307
	jp presentacion		;8309
pattern_clear:		; PATTERN CLEAR: la ronda superada y la presentacion del bonus
	call irq_solo_musica_pon		;830c   ; la interrupcion, solo la musica
	ld hl,08544h		;830f   ; PATTERN CLEAR (0x8544) en la fila 2, columna 7
	ld de,01847h		;8312   ; fila 2, columna 7
	ld bc,0000dh		;8315   ; 13 letras
	call 0005ch		;8318
	call musica_pattern_clear		;831b   ; su musica
pattern_clear_espera:		; Espera a que acabe la musica
	call musica_suena		;831e
	jr nz,pattern_clear_espera		;8321
	call nombres_borra		;8323   ; la tabla de nombres a cero
	call 00041h		;8326   ; DISSCR
	ld hl,0a90dh		;8329   ; los dibujos de la presentacion del bonus (0xA90D): el esquiador de cara, girado...
	ld de,03800h		;832c   ; a 0x3800
	ld bc,000c0h		;832f   ; 0xC0 bytes
	push hl			;8332
	call sprites_girados		;8333   ; ...(0x9635: cada sprite de 16x16 de lado)
	pop hl			;8336
	call sprites_espejo		;8337   ; tres copias mas, cada una girada otra vez (0x967D)
	call sprites_espejo		;833a
	call sprites_espejo		;833d
	ld de,03b00h		;8340   ; y sus dibujos, a 0x3B00 (0xA9CD)
	ld hl,0a9cdh		;8343   ; 0x20 bytes
	ld bc,00020h		;8346   ; (un sprite)
	call ldirvm		;8349
	ld hl,099c7h		;834c   ; las casillas del bonus (0x99C7, 110 casillas desde la 0x80)
	ld de,00400h		;834f   ; a 0x0400
	ld bc,00370h		;8352   ; 0x370 bytes
	call 0005ch		;8355
	ld hl,02000h		;8358   ; los colores: 0xF4, blanco sobre azul...
	ld bc,00800h		;835b   ; 0x800 bytes
	ld a,0f4h		;835e
	call 00056h		;8360
	ld hl,02400h		;8363   ; ...0xF5...
	ld bc,002d8h		;8366   ; 0x2D8 bytes
	ld a,0f5h		;8369
	call 00056h		;836b
	ld hl,02448h		;836e   ; ...0xFE, blanco sobre gris...
	ld bc,00118h		;8371   ; 0x118 bytes desde 0x2448
	ld a,0feh		;8374
	call 00056h		;8376
	ld hl,02560h		;8379   ; ...0xE5, gris sobre azul claro...
	ld bc,00048h		;837c   ; 0x48 bytes desde 0x2560
	ld a,0e5h		;837f
	call 00056h		;8381
	ld hl,025a8h		;8384   ; ...0xA4, amarillo sobre azul
	ld bc,00020h		;8387   ; 0x20 bytes desde 0x25A8
	ld a,0a4h		;838a
	call 00056h		;838c
	ld hl,09d37h		;838f   ; los colores de las casillas del bonus (0x9D37)
	ld de,025c8h		;8392   ; a 0x25C8
	ld bc,00518h		;8395   ; 0x518 bytes
	call 0005ch		;8398
	ld hl,0aef5h		;839b   ; los de las letras grandes
	ld de,02020h		;839e   ; a 0x2020
	ld bc,00040h		;83a1   ; 0x40 bytes
	call 0005ch		;83a4
	call tercio_copia		;83a7   ; copia el primer tercio a los otros dos
	ld hl,01800h		;83aa   ; la tabla de nombres: 24 filas de 25 casillas 0x80 (el cielo)
	ld b,018h		;83ad   ; 24 filas
L_83AF:
	push bc			;83af   ; una fila...
	push hl			;83b0
	ld bc,00019h		;83b1
	ld a,080h		;83b4   ; ...de 25 casillas 0x80
	call 00056h		;83b6
	pop hl			;83b9
	ld de,00020h		;83ba   ; la fila siguiente
	add hl,de			;83bd
	pop bc			;83be
	djnz L_83AF		;83bf
	ld hl,01800h		;83c1   ; el monte: ocho filas, de la casilla 4 a la 0x0B
	ld a,004h		;83c4   ; desde la casilla 4...
	ld b,008h		;83c6   ; 8 filas
L_83C8:
	push bc			;83c8
	push hl			;83c9
	ld bc,00019h		;83ca   ; ...una fila de 25 de la misma casilla
	call 00056h		;83cd
	pop hl			;83d0
	ld bc,00020h		;83d1   ; la fila siguiente...
	add hl,bc			;83d4
	inc a			;83d5   ; ...con la casilla siguiente...
	cp 00bh		;83d6
	jr c,L_83DC		;83d8
	ld a,00bh		;83da   ; ...hasta la 0x0B
L_83DC:
	pop bc			;83dc
	djnz L_83C8		;83dd
	ld hl,09edfh		;83df   ; el campo del bonus (0x9EDF): 13 filas de 10 casillas, desde la fila 6...
	ld de,018c0h		;83e2   ; fila 6, columna 0
	ld b,00dh		;83e5   ; 13 filas
L_83E7:
	push bc			;83e7   ; una fila del campo...
	push hl			;83e8
	push de			;83e9
	ld bc,0000ah		;83ea   ; ...de 10 casillas
	call 0005ch		;83ed
	pop de			;83f0
	ld hl,00020h		;83f1   ; la fila siguiente de la pantalla...
	add hl,de			;83f4
	ex de,hl			;83f5
	pop hl			;83f6
	ld bc,0000ah		;83f7   ; ...y de la tabla
	add hl,bc			;83fa
	pop bc			;83fb
	djnz L_83E7		;83fc
	ld b,005h		;83fe   ; ...cinco filas de 25...
L_8400:
	push bc			;8400
	push hl			;8401
	push de			;8402
	ld bc,00019h		;8403   ; una fila de 25...
	call 0005ch		;8406
	pop de			;8409
	ld hl,00020h		;840a   ; la fila siguiente...
	add hl,de			;840d
	ex de,hl			;840e
	pop hl			;840f
	ld bc,00019h		;8410   ; ...25 casillas mas alla en la tabla
	add hl,bc			;8413
	pop bc			;8414
	djnz L_8400		;8415
	ld de,01a14h		;8417   ; ...y tres de 5 en la fila 16, columna 20: las tres dianas
	ld b,003h		;841a   ; 3 filas
L_841C:
	push bc			;841c
	push hl			;841d
	push de			;841e
	ld bc,00005h		;841f   ; una fila de 5 (una diana)
	call 0005ch		;8422   ; LDIRVM
	pop de			;8425
	ld hl,00020h		;8426   ; la fila siguiente
	add hl,de			;8429
	ex de,hl			;842a
	pop hl			;842b
	ld bc,00005h		;842c   ; ...5 casillas mas alla
	add hl,bc			;842f
	pop bc			;8430
	djnz L_841C		;8431
	call marcador_pinta		;8433   ; el marcador
	call 00044h		;8436   ; ENASCR
	call musica_titulo		;8439   ; la musica del bonus
	call ram_borra		;843c   ; la RAM de la partida a cero
	ld hl,00018h		;843f   ; el recorrido del esquiador empieza en (Y 0x18, X 0)...
	ld (0e88dh),hl		;8442
	ld hl,09507h		;8445   ; ...y sigue la tabla 0x9507
	ld (0e88fh),hl		;8448
	ld hl,08478h		;844b   ; los sprites del bonus (0x8478: once sprites)
	ld de,0e800h		;844e
	ld bc,0002ch		;8451
	ldir		;8454
	ld hl,08599h		;8456   ; la interrupcion del bonus (0x8599)
	ld (0fda0h),hl		;8459
bonus_espera:		; Espera a que el esquiador acabe el recorrido y pasa a la ronda siguiente
	ld a,(0e8f9h)		;845c
	or a			;845f
	jr z,bonus_espera		;8460
	jp empieza		;8462

; ----------------------------------------------------------------------
; DATOS sprites_esquiador: Los tres sprites del esquiador al empezar (Y 0xC0,
;   X 0, dibujo, color) y su Y, X y dibujo
;   0x8465..0x8478  (19 bytes)
DATA_8465:
	defb 0c0h,000h,000h,004h	; 8465
	defb 0c0h,000h,004h,001h	; 8469
	defb 0c0h,000h,008h,006h	; 846d
	defb 0c0h,000h,048h,001h	; 8471
	defb 090h,068h,000h	; 8475

; ----------------------------------------------------------------------
; DATOS sprites_bonus: Los once sprites del bonus: el esquiador, el disparo y
;   las tres dianas (Y, X, dibujo, color)
;   0x8478..0x84a4  (44 bytes)
DATA_8478:
	defb 0c0h,000h,000h,007h	; 8478
	defb 0c0h,000h,000h,001h	; 847c
	defb 0c0h,000h,000h,006h	; 8480
	defb 0c0h,000h,000h,000h	; 8484
	defb 0c0h,000h,0b0h,001h	; 8488
	defb 050h,02ch,000h,000h	; 848c
	defb 050h,03ch,000h,000h	; 8490
	defb 068h,02ch,000h,000h	; 8494
	defb 068h,03ch,000h,000h	; 8498
	defb 080h,02ch,000h,000h	; 849c
	defb 080h,03ch,000h,000h	; 84a0

; ----------------------------------------------------------------------
; DATOS dificultad: Seis dificultades (4 bytes): 0xE8FE 0 si sale el aparato,
;   0xE8FF el paso de los enemigos, 0xE900 el de lo que cae (0xFF: nada),
;   0xE901 la mascara de cuadros de la pista (15 o 7)
;   0x84a4..0x84bc  (24 bytes)
DATA_dificultad:
	defb 0ffh,001h,0ffh,00fh	; 84a4
	defb 000h,001h,0ffh,00fh	; 84a8
	defb 000h,002h,001h,00fh	; 84ac
	defb 000h,002h,001h,007h	; 84b0
	defb 000h,003h,001h,007h	; 84b4
	defb 000h,003h,002h,007h	; 84b8

; ----------------------------------------------------------------------
; DATOS carteles: Los seis carteles de la presentacion: direccion en la tabla
;   de nombres, longitud y letras (CASIO y SKI COMMAND en letras grandes, PUSH
;   TRIGGER 1 TO START GAME, COPYRIGHT 1984 @ CASIO)
;   0x84bc..0x8544  (136 bytes)
DATA_carteles:
	defb 04ah,018h,00ch	; 84bc
	defb 03ah,03ch,000h,001h,04ah,000h,03ah,03ch,057h,000h,03ah,05ah	; 84bf  :<..J.:<W.:Z
	defb 06ah,018h,00ch	; 84cb
	defb 03bh,03dh,000h,046h,04bh,000h,051h,002h,058h,000h,03bh,003h	; 84ce  ;=.FK.Q.X.;.
	defb 0c5h,018h,016h	; 84da
	defb 03ah,03ch,004h,005h,057h,000h,000h,000h,03ah,03ch,03ah,05ah,007h,00bh,007h,00bh,001h,04ah,007h,009h,00dh,00fh	; 84dd  :<..W...:<:Z.....J....
	defb 0e5h,018h,016h	; 84f3
	defb 051h,002h,046h,006h,058h,000h,000h,000h,03bh,03dh,03bh,003h,008h,00ch,008h,00ch,046h,04bh,008h,00ah,00eh,04fh	; 84f6  Q.F.X...;=;.....FK...O
	defb 0c2h,019h,01ch	; 850c
	defb 050h,055h,053h,048h,000h,054h,052h,049h,047h,047h,045h,052h,000h,031h,000h,054h,030h,000h,053h,054h,041h,052h,054h,000h,047h,041h,04dh,045h	; 850f  PUSH.TRIGGER.1.T0.START.GAME
	defb 0c5h,01ah,016h	; 852b
	defb 043h,030h,050h,059h,052h,049h,047h,048h,054h,000h,031h,039h,038h,034h,000h,040h,000h,043h,041h,053h,049h,030h	; 852e  C0PYRIGHT.1984.@.CASI0

; ----------------------------------------------------------------------
; DATOS textos: PATTERN CLEAR, ROUND y GAME OVER (en la fuente del juego la O
;   es un 0)
;   0x8544..0x8569  (37 bytes)
DATA_textos:
	defb 050h,041h,054h,054h,045h,052h,04eh,000h,043h,04ch,045h,041h,052h,052h,030h,055h	; 8544  PATTERN.CLEARR0U
	defb 04eh,044h,000h,000h,000h,000h,000h,053h,054h,041h,052h,054h,047h,041h,04dh,045h	; 8554  ND.....STARTGAME
	defb 000h,030h,056h,045h,052h	; 8564

; ======================================================================
; CODIGO 0x8569..0x868d  (292 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; La interrupcion de la partida (0xFDA0 = 0x8569): si la anterior no ha acabado, solo la musica; si no, un cuadro entero de juego.
; ----------------------------------------------------------------------
irq_partida:		; La interrupcion de la partida
	ld a,(0e880h)		;8569   ; la anterior aun esta corriendo?...
	or a			;856c
	jr nz,irq_solo_musica		;856d   ; ...entonces solo la musica y fuera
	cpl			;856f   ; 0xFF: corriendo
	ld (0e880h),a		;8570
	call sprites_vram		;8573   ; los sprites a la VRAM
	call tramo		;8576   ; cada 256 cuadros, los dibujos de la nieve del tramo
	call pista		;8579   ; las lineas de la pista y las curvas
	call objetos		;857c   ; los arboles y las rocas
	call musica_cuadro		;857f   ; la musica
	call esquiador		;8582   ; el esquiador: mando, salto y sus sprites
	call disparo		;8585   ; el disparo
	call choques		;8588   ; los choques del esquiador
	call ronda_cuadro		;858b   ; la ronda: el fin, la musica, las curvas y los objetos nuevos
	call aparato		;858e   ; el aparato
	call enemigos		;8591   ; los enemigos
irq_fin:		; El marcador, los contadores y la vuelta a la BIOS
	call marcador		;8594
	jr contadores		;8597

; ----------------------------------------------------------------------
; La interrupcion del bonus (0xFDA0 = 0x8599): el esquiador hace su recorrido y dispara a las tres dianas.
; ----------------------------------------------------------------------
irq_bonus:		; La interrupcion del bonus
	call sprites_vram		;8599   ; los sprites a la VRAM
	call recorrido		;859c   ; el recorrido del esquiador
	call bonus_disparo		;859f   ; el disparo
	call bonus_dianas		;85a2   ; las dianas que giran
	call marcador		;85a5   ; el marcador

; ----------------------------------------------------------------------
; La interrupcion de siempre (0xFDA0 = 0x85A8): la musica y los contadores.
; ----------------------------------------------------------------------
irq_musica:		; La interrupcion de siempre
	call musica_cuadro		;85a8   ; la musica
contadores:		; El contador de cuadros y las diez cuentas
	ld hl,0e881h		;85ab   ; el contador de cuadros: la parte baja...
	inc (hl)			;85ae
	inc hl			;85af
	jr nz,L_85B3		;85b0
	inc (hl)			;85b2   ; ...y la alta
L_85B3:
	inc hl			;85b3
	ld b,00ah		;85b4   ; las diez cuentas de 0xE884...
L_85B6:
	inc (hl)			;85b6   ; ...suben...
	jr nz,L_85BA		;85b7
	dec (hl)			;85b9   ; ...y se paran en 0xFF
L_85BA:
	inc hl			;85ba
	djnz L_85B6		;85bb
	xor a			;85bd   ; la interrupcion ha acabado
	ld (0e880h),a		;85be
	pop bc			;85c1   ; fuera la vuelta a la BIOS...
	jp 00d02h		;85c2   ; ...y al final de su rutina de interrupcion (0x0D02): sin leer el teclado
irq_solo_musica:		; La interrupcion llega con la anterior aun corriendo: la musica y a 0x0D02
	pop bc			;85c5   ; fuera la vuelta a la BIOS...
	ld hl,00d02h		;85c6   ; ...y la musica vuelve a 0x0D02
	push hl			;85c9
musica_cuadro:		; La musica de este cuadro: en la demo, callada
	call demo		;85ca   ; es la demo?...
	jp nz,sonido_calla		;85cd   ; ...silencio
	jp sonido_cuadro		;85d0   ; un cuadro de los tres canales
sprites_vram:		; La tabla de sprites (0xE800) a la VRAM (0x1B00); en la demo, ademas, el mando
	ld hl,0e800h		;85d3   ; los 128 bytes...
	ld de,01b00h		;85d6   ; ...a la tabla de atributos
	ld bc,00080h		;85d9
	call 0005ch		;85dc
	call demo		;85df   ; es la demo?
	jr z,mando		;85e2
	call lee_botones		;85e4   ; en la demo, un boton...
	ld a,b			;85e7
	or a			;85e8
	jp nz,presentacion		;85e9   ; ...vuelve a la presentacion
	ld a,(0e88ah)		;85ec   ; la demo cambia de direccion cuando acaba su cuenta
	inc a			;85ef
	ret nz			;85f0
mando:		; Lee el mando: la direccion (o la de la demo) y los botones
	ld a,(0e8a3h)		;85f1   ; saltando no se cambia de direccion
	or a			;85f4
	jr nz,mando_botones		;85f5
	ld a,(0e88bh)		;85f7   ; la cuenta del golpe aun no ha acabado?
	inc a			;85fa
	ret nz			;85fb
	call demo		;85fc   ; es la demo?
	jr z,mando_direccion		;85ff
	call azar		;8601   ; la demo: una espera al azar...
	or 0e0h		;8604
	ld (0e88ah),a		;8606
	call azar		;8609   ; ...y una direccion al azar
	jr mando_guarda		;860c
mando_direccion:		; La direccion: la del teclado, la del mando 1 y la del 2, juntas
	xor a			;860e   ; el teclado (GTSTCK 0)...
	call direccion		;860f
	ld b,a			;8612
	ld a,001h		;8613   ; ...el mando 1...
	call direccion		;8615
	or b			;8618
	ld b,a			;8619
	ld a,002h		;861a   ; ...y el mando 2
	call direccion		;861c
	or b			;861f
mando_guarda:		; Guarda la direccion
	ld (0e89dh),a		;8620
mando_botones:		; Los botones: en la demo, el disparo casi siempre y el salto de vez en cuando
	call demo		;8623
	jr z,mando_botones_lee		;8626
	ld b,001h		;8628   ; la demo dispara...
	call azar		;862a   ; ...y una vez de cada 16...
	and 00fh		;862d
	jr nz,mando_botones_guarda		;862f
	ld b,003h		;8631   ; ...salta
	jr mando_botones_guarda		;8633
mando_botones_lee:		; Los botones de verdad
	call lee_botones		;8635
mando_botones_guarda:		; Guarda los botones
	ld a,b			;8638
	ld (0e89eh),a		;8639
	ret			;863c

; ----------------------------------------------------------------------
; Los botones: el 1 es la barra o el disparo de cualquier mando; el 2, el segundo boton de un mando o la tecla GRAPH.
; ----------------------------------------------------------------------
lee_botones:		; Lee los botones: B bit 0 el disparo, bit 1 el salto
	ld a,000h		;863d   ; GTTRIG 0: la barra...
	call 000d8h		;863f
	ld b,a			;8642
	ld a,001h		;8643   ; ...GTTRIG 1: el boton 1 del mando 1...
	push bc			;8645
	call 000d8h		;8646
	pop bc			;8649
	or b			;864a
	ld b,a			;864b
	push bc			;864c
	ld a,002h		;864d   ; ...GTTRIG 2: el del mando 2
	call 000d8h		;864f
	pop bc			;8652
	or b			;8653
	ld b,000h		;8654
	jr z,L_865A		;8656
	set 0,b		;8658   ; bit 0: el disparo
L_865A:
	ld a,003h		;865a   ; GTTRIG 3 y 4: el segundo boton de los dos mandos...
	push bc			;865c
	call 000d8h		;865d
	ld b,a			;8660
	ld a,004h		;8661   ; GTTRIG 4: el del mando 2
	push bc			;8663
	call 000d8h		;8664
	pop bc			;8667
	or b			;8668
	ld b,a			;8669
	ld a,006h		;866a   ; ...y la fila 6 del teclado (SNSMAT): la tecla GRAPH (bit 2)
	push bc			;866c
	call 00141h		;866d   ; SNSMAT
	pop bc			;8670
	cpl			;8671   ; pulsada (bit a 0)...
	and 004h		;8672   ; ...la GRAPH...
	rra			;8674   ; ...al bit 0
	rra			;8675
	or b			;8676   ; junto con los botones
	pop bc			;8677
	jr z,mando_botones_guarda		;8678
	set 1,b		;867a   ; bit 1: el salto
	ret			;867c
direccion:		; La direccion de un mando (GTSTCK A) en los bits del juego (tabla 0x868D)
	push bc			;867d
	push hl			;867e
	call 000d5h		;867f   ; GTSTCK
	ld hl,0868dh		;8682   ; la tabla de direcciones...
	ld c,a			;8685
	ld b,000h		;8686
	add hl,bc			;8688   ; ...mas la direccion...
	ld a,(hl)			;8689   ; ...sus bits
	pop hl			;868a
	pop bc			;868b
	ret			;868c

; ----------------------------------------------------------------------
; DATOS direcciones: De la direccion de GTSTCK (0 nada, 1 arriba... 8 arriba a
;   la izquierda) a los bits del juego (0 derecha, 1 arriba, 2 izquierda, 3
;   abajo)
;   0x868d..0x8696  (9 bytes)
DATA_direcciones:
	defb 000h,002h,003h,001h,009h,008h,00ch,004h,006h	; 868d  .........

; ======================================================================
; CODIGO 0x8696..0x8793  (253 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; La ronda: el paso de la demo a la partida, el fin de la ronda, la musica y lo que va saliendo en la pista.
; ----------------------------------------------------------------------
ronda_cuadro:		; Un cuadro de la ronda
	call ronda1_juega		;8696   ; la ronda 1 y no es la demo?
	jr nz,ronda_musica		;8699
	call musica_suena		;869b   ; la musica sigue sonando?
	jr nz,ronda_fin_cuadro		;869e
	inc a			;86a0   ; no: ya se juega (0xE90D = 1)
	ld (0e90dh),a		;86a1
ronda_musica:		; Si la musica se ha callado, la de la ronda
	call musica_suena		;86a4
	call z,musica_ronda		;86a7   ; la musica de la ronda, otra vez
	ld a,(0e889h)		;86aa   ; la cuenta de la musica ha acabado?
	inc a			;86ad
	jr nz,ronda_fin_cuadro		;86ae
	ld a,(0e882h)		;86b0   ; el tramo de la ronda...
	cp 00ch		;86b3   ; ...antes del 12: la ronda sigue
	jr c,ronda_curva		;86b5
	cp 00eh		;86b7   ; del 12 al 13, sin curvas
	jr c,ronda_recta		;86b9
	ld hl,(0e8dah)		;86bb   ; del 14 en adelante: sin aparato...
	ld a,l			;86be
	or h			;86bf
	jr nz,ronda_recta		;86c0
	ld a,(0e8deh)		;86c2   ; ...ni enemigos...
	or a			;86c5
	jr nz,ronda_recta		;86c6
	inc a			;86c8   ; ...la ronda se acaba
	ld (0e8f9h),a		;86c9   ; la ronda se acaba
ronda_recta:		; Al final de la ronda la pista se pone recta: columna 3 y la curva acabada
	ld hl,00303h		;86cc
	ld (0e8fdh),hl		;86cf   ; columna 3 y curva 3
	ld a,(0e902h)		;86d2   ; ya estaba recta?
	cp 003h		;86d5   ; la curva...
	jr z,ronda_objeto		;86d7   ; ...acabada
	push hl			;86d9
	call pista_pinta		;86da   ; la pista...
	call monte_borra		;86dd   ; ...el monte sin curva...
	call monte		;86e0   ; ...y el monte recto
	pop hl			;86e3
	ld (0e902h),hl		;86e4   ; la columna y la curva acabada
	ld hl,00000h		;86e7   ; sin curva
	ld (0e8a7h),hl		;86ea   ; sin curva
	jr ronda_objeto		;86ed
ronda_fin_cuadro:		; Fuera del cuadro: el marcador y los contadores
	pop bc			;86ef   ; fuera la vuelta...
	jp irq_fin		;86f0   ; ...y al final de la interrupcion
ronda_curva:		; Una curva nueva, a veces: a la izquierda, a la derecha o hacia el centro
	ld a,(0e8a7h)		;86f3   ; ya hay una curva en marcha?
	or a			;86f6   ; (0xE8A7)
	jr nz,ronda_objeto		;86f7
	ld a,(0e883h)		;86f9   ; la cuenta de las curvas ha acabado?
	inc a			;86fc   ; (0xE883)
	jr nz,ronda_objeto		;86fd
	call azar		;86ff   ; y, al azar, una vez de cada 256
	or a			;8702   ; 0: una curva
	jr nz,ronda_objeto		;8703
	ld b,004h		;8705   ; cuatro pasos de curva...
	ld a,(0e8a8h)		;8707   ; ...en la curva en que estaba...
	or a			;870a
	jr z,ronda_curva_azar		;870b   ; 0: recta
	jp p,ronda_curva_guarda		;870d   ; ...si va a la derecha, vuelve...
	jr ronda_curva_izquierda		;8710   ; ...si va a la izquierda, vuelve
ronda_curva_azar:		; Recta: a un lado al azar
	call azar		;8712
	rrca			;8715   ; bit 0 al azar...
	jr c,ronda_curva_guarda		;8716   ; ...a la derecha
ronda_curva_izquierda:		; La curva, a la izquierda (bit 7)
	set 7,b		;8718
ronda_curva_guarda:		; Guarda la curva que viene
	ld a,b			;871a
	ld (0e8a7h),a		;871b
ronda_objeto:		; Un objeto nuevo en la pista cuando acaba su cuenta: un hueco libre en 0xE8B0
	ld a,(0e886h)		;871e   ; la cuenta de los arboles ha acabado?
	inc a			;8721
	ret nz			;8722
	ld hl,0e8b0h		;8723   ; diez huecos...
	ld b,00ah		;8726
ronda_objeto_hueco:		; Busca un hueco libre
	push hl			;8728
	call lee4		;8729   ; la entrada
	ld a,e			;872c   ; libre si la direccion es 0
	or d			;872d
	jr z,ronda_objeto_tipo		;872e
	pop de			;8730
	djnz ronda_objeto_hueco		;8731   ; la siguiente
	ret			;8733
ronda_objeto_tipo:		; El tipo de objeto: al azar de 0 a 19 (0x8793: 20 tipos de 3 bytes)
	ld hl,08793h		;8734
L_8737:
	call azar20		;8737   ; un tipo de 0 a 19
	ld c,a			;873a   ; en C
	ld a,(0e8d9h)		;873b   ; el arbol del enemigo especial ya esta?
	or a			;873e
	jr nz,ronda_objeto_ronda		;873f
	ld a,(0e8abh)		;8741   ; toca el enemigo especial?
	or a			;8744
	jr z,ronda_objeto_ronda		;8745
ronda_objeto_especial:		; El enemigo especial sale de un arbol: un tipo de 5 a 19
	call azar20		;8747
	add a,005h		;874a   ; de 5...
	cp 014h		;874c   ; ...a 19
	jr c,ronda_objeto_especial		;874e
	ld c,a			;8750   ; ya no toca
	xor a			;8751
	ld (0e8abh),a		;8752
	pop ix		;8755   ; el hueco...
	push ix		;8757   ; ...y su arbol
	ld (0e8d8h),ix		;8759   ; ...es el del enemigo especial
ronda_objeto_ronda:		; En las tres primeras rondas, sin los tipos 10 a 14
	ld a,(0e90ch)		;875d
	cp 004h		;8760   ; la ronda...
	jr nc,ronda_objeto_pon		;8762   ; ...de la 4 en adelante, todos
	ld a,c			;8764   ; el tipo...
	cp 00ah		;8765   ; ...del 10 al 14, otro
	jr c,ronda_objeto_pon		;8767   ; menos de 10, vale
	cp 00fh		;8769
	jr c,L_8737		;876b   ; del 10 al 14, otro
ronda_objeto_pon:		; El objeto: su columna (0x192A + el primer byte), su tipo y su paso
	ld a,c			;876d
	add a,a			;876e   ; tres bytes por tipo
	add a,c			;876f   ; ...mas uno: por tres
	ld c,a			;8770
	ld b,000h		;8771   ; BC = el tipo por tres
	add hl,bc			;8773
	ld c,(hl)			;8774   ; su columna
	inc hl			;8775   ; el paso del tipo
	ld b,000h		;8776
	ld de,0192ah		;8778   ; la fila 9, columna 10 de la tabla de nombres...
	ex de,hl			;877b   ; ...mas la columna del tipo
	add hl,bc			;877c
	ex de,hl			;877d
	push hl			;877e   ; HL la direccion
	pop bc			;877f
	pop hl			;8780   ; HL la entrada
	ld (hl),e			;8781   ; la direccion...
	inc hl			;8782
	ld (hl),d			;8783   ; la direccion en la entrada
	inc hl			;8784
	ex de,hl			;8785   ; ...el tipo y su paso
	push bc			;8786   ; el tipo y el paso, del tipo
	pop hl			;8787
	ld bc,00002h		;8788   ; dos bytes: el tipo y el paso
	ldir		;878b
	ld a,090h		;878d   ; la cuenta del siguiente: 112 cuadros
	ld (0e886h),a		;878f
	ret			;8792

; ----------------------------------------------------------------------
; DATOS objetos: Los 20 tipos de objeto de la pista (3 bytes): la columna de
;   salida, el tipo (arbol, roca, mogul, bandera...) y el paso
;   0x8793..0x87de  (75 bytes)
DATA_objetos:
	defb 000h,000h,000h	; 8793
	defb 000h,000h,010h	; 8796
	defb 001h,000h,010h	; 8799
	defb 002h,000h,010h	; 879c
	defb 002h,000h,020h	; 879f
	defb 000h,004h,030h	; 87a2
	defb 000h,004h,040h	; 87a5
	defb 001h,004h,040h	; 87a8
	defb 002h,004h,040h	; 87ab
	defb 002h,004h,050h	; 87ae
	defb 000h,008h,000h	; 87b1
	defb 000h,008h,010h	; 87b4
	defb 001h,008h,010h	; 87b7
	defb 002h,008h,010h	; 87ba
	defb 002h,008h,020h	; 87bd
	defb 000h,00ch,060h	; 87c0
	defb 000h,00ch,070h	; 87c3
	defb 001h,00ch,070h	; 87c6
	defb 001h,00ch,070h	; 87c9
	defb 002h,00ch,080h	; 87cc
	defb 000h,010h,000h	; 87cf
	defb 000h,010h,010h	; 87d2
	defb 001h,010h,010h	; 87d5
	defb 002h,010h,010h	; 87d8
	defb 002h,010h,020h	; 87db

; ======================================================================
; CODIGO 0x87de..0x8910  (306 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; El esquiador: el salto, la direccion y sus tres sprites.
; ----------------------------------------------------------------------
esquiador:		; El esquiador de este cuadro
	ld a,(0e8a3h)		;87de   ; saltando?
	or a			;87e1
	jp nz,esquiador_salto		;87e2
	ld a,(0e89eh)		;87e5   ; el boton del salto...
	bit 1,a		;87e8
	jr z,esquiador_suelta		;87ea
	ld a,(0e8a4h)		;87ec   ; ...ya pulsado?
	or a			;87ef
	jr nz,esquiador_mueve		;87f0
	inc a			;87f2   ; un salto...
	ld (0e8a4h),a		;87f3
	ld (0e8a3h),a		;87f6
	call efecto_salto		;87f9   ; ...con su sonido
	xor a			;87fc   ; la cuenta del salto, desde 0
	ld (0e884h),a		;87fd
	ld hl,0e8a2h		;8800   ; el dibujo del salto
	inc (hl)			;8803
	jr esquiador_mueve		;8804
esquiador_suelta:		; El boton del salto, suelto
	xor a			;8806
	ld (0e8a4h),a		;8807
esquiador_mueve:		; Mueve el esquiador con la direccion
	ld hl,0e8a0h		;880a
	ld a,(0e89dh)		;880d
	call mueve		;8810
	ld a,(0e8a3h)		;8813   ; en el aire, el dibujo no cambia con la direccion
	or a			;8816
	jr nz,esquiador_sprites		;8817
	ld a,(0e893h)		;8819
	ld (0e8a2h),a		;881c
esquiador_sprites:		; Los tres sprites del esquiador (0xE800): su Y, su X y el dibujo (0x8910, 12 bytes por dibujo)
	ld a,(0e8a2h)		;881f
	ld hl,08910h		;8822   ; la tabla de dibujos (0x8910)...
	add a,a			;8825   ; por doce...
	add a,a			;8826
	ld c,a			;8827
	add a,a			;8828
	add a,c			;8829
	ld c,a			;882a
	ld b,000h		;882b
	add hl,bc			;882d
	ld b,003h		;882e   ; tres sprites en el aire...
	ld a,(0e8a3h)		;8830
	or a			;8833
	jr nz,L_8838		;8834
	ld b,004h		;8836   ; ...cuatro en el suelo (la sombra)
L_8838:
	ld de,0e800h		;8838   ; en 0xE800
esquiador_sprite:		; Un sprite: Y + dy, X + dx, dibujo y color
	ld a,(0e8a0h)		;883b   ; la Y...
	add a,(hl)			;883e   ; ...mas la del sprite
	ld (de),a			;883f
	inc hl			;8840
	inc de			;8841
	ld a,(0e8a1h)		;8842   ; la X...
	add a,(hl)			;8845   ; ...mas la del sprite
	ld (de),a			;8846
	inc hl			;8847
	inc de			;8848
	ld a,(hl)			;8849   ; el dibujo
	ld (de),a			;884a
	inc de			;884b
	inc de			;884c   ; (el color se queda)
	inc hl			;884d
	djnz esquiador_sprite		;884e
	ret			;8850
esquiador_salto:		; En el aire: la sombra 8 puntos por encima y el salto
	ld a,(0e8a1h)		;8851   ; la X...
	add a,0f8h		;8854   ; ...menos 8: la de la sombra
	ld (0e80dh),a		;8856
	call salto		;8859
	jp esquiador_mueve		;885c
salto:		; El salto, por la cuenta 0xE884: sube, se queda y baja, con sus dibujos
	ld a,(0e884h)		;885f
	cp 002h		;8862   ; los dos primeros cuadros, nada
	ret c			;8864
	jr nz,salto_sube		;8865   ; el segundo: el dibujo del salto...
	ld a,(0e8a2h)		;8867
	inc a			;886a
	ld (0e8a2h),a		;886b
	ld a,04ch		;886e   ; ...y la sombra pequena
	ld (0e80eh),a		;8870
	ret			;8873
salto_sube:		; Del 2 al 34: sube
	cp 023h		;8874
	jr nc,salto_baja		;8876
	cp 01bh		;8878   ; en el 27, la sombra mas pequeno
	jr nz,salto_sube_paso		;887a
	ld hl,0e80eh		;887c
	ld (hl),050h		;887f
salto_sube_paso:		; Un punto arriba
	ld a,(0e8a0h)		;8881
	dec a			;8884
	ld (0e8a0h),a		;8885
	ret			;8888
salto_baja:		; Del 43 al 74: baja
	cp 02bh		;8889
	ret c			;888b
	cp 04bh		;888c
	jr nc,salto_cae		;888e
	cp 033h		;8890   ; en el 51, la sombra mediana
	jr nz,salto_baja_paso		;8892
	ld a,04ch		;8894
	ld (0e80eh),a		;8896
salto_baja_paso:		; Un punto abajo
	ld a,(0e8a0h)		;8899
	inc a			;889c
	ld (0e8a0h),a		;889d
	ret			;88a0
salto_cae:		; En el 75: el dibujo de la caida y la sombra grande
	jr nz,salto_fin		;88a1   ; en el 75...
	ld a,(0e8a2h)		;88a3   ; ...el dibujo anterior...
	dec a			;88a6
	ld (0e8a2h),a		;88a7
	ld a,048h		;88aa   ; ...y la sombra grande (0x48)
	ld (0e80eh),a		;88ac
	ret			;88af
salto_fin:		; Del 91 en adelante: en el suelo, el salto se acaba
	cp 05bh		;88b0
	ret c			;88b2
	ld a,(0e8a2h)		;88b3
	dec a			;88b6
	ld (0e8a2h),a		;88b7
	xor a			;88ba   ; ya no salta...
	ld (0e8a3h),a		;88bb
	dec a			;88be   ; ...y la cuenta se para
	ld (0e884h),a		;88bf
	pop bc			;88c2   ; y no se mueve en este cuadro
	ret			;88c3
mueve:		; Mueve el esquiador con la direccion B: la Y (abajo de dos en dos, cada cuatro cuadros) y la X
	ld b,a			;88c4
	ld a,(0e8a3h)		;88c5   ; en el aire...
	or a			;88c8
	jr z,mueve_suelo		;88c9
	ld a,(0e881h)		;88cb   ; ...se mueve en los cuadros pares...
	and 001h		;88ce
	ret nz			;88d0
	xor a			;88d1   ; ...con el dibujo de frente
	jr mueve_x		;88d2
mueve_suelo:		; En el suelo
	xor a			;88d4
	bit 1,b		;88d5   ; arriba...
	jr z,mueve_abajo		;88d7
	dec (hl)			;88d9   ; ...un punto
mueve_abajo:		; Abajo: dos puntos cada cuatro cuadros
	bit 3,b		;88da
	jr z,mueve_x		;88dc
	push af			;88de   ; uno de cada cuatro cuadros...
	ld a,(0e881h)		;88df
	and 003h		;88e2
	jr nz,mueve_abajo_fin		;88e4
	inc (hl)			;88e6   ; ...dos puntos
	inc (hl)			;88e7
mueve_abajo_fin:		; La X
	pop af			;88e8
mueve_x:		; La X: izquierda, dibujo 3; derecha, dibujo 6
	inc hl			;88e9
	bit 2,b		;88ea   ; izquierda: un punto...
	jr z,mueve_derecha		;88ec
	dec (hl)			;88ee
	ld a,003h		;88ef   ; ...y el dibujo 3
mueve_derecha:		; A la derecha
	bit 0,b		;88f1
	jr z,mueve_dibujo		;88f3
	inc (hl)			;88f5   ; derecha: un punto...
	ld a,006h		;88f6   ; ...y el dibujo 6
mueve_dibujo:		; El dibujo del esquiador, y la Y entre 0x88 y 0xA0 en el suelo
	ld (0e893h),a		;88f8
	ld a,(0e8a3h)		;88fb
	or a			;88fe
	ret nz			;88ff
	ld hl,0e8a0h		;8900
	ld a,(hl)			;8903   ; la Y...
	cp 088h		;8904   ; ...no por encima de 0x88...
	jr nc,L_890A		;8906
	ld (hl),088h		;8908
L_890A:
	cp 0a0h		;890a   ; ...ni por debajo de 0xA0
	ret c			;890c
	ld (hl),0a0h		;890d
	ret			;890f

; ----------------------------------------------------------------------
; DATOS dibujos_esquiador: Los once dibujos del esquiador: cuatro sprites de 3
;   bytes (dy, dx, dibujo)
;   0x8910..0x8991  (129 bytes)
DATA_dibujos_esquiador:
	defb 000h,0f9h,000h,00ah,0f9h,004h,00eh,0f8h,008h,019h,0f8h,048h	; 8910  ...........H
	defb 006h,0f9h,000h,010h,0f9h,00ch,00eh,0f8h,008h,000h,000h,000h	; 891c  ............
	defb 0ffh,0f9h,000h,008h,0f8h,010h,010h,0f8h,014h,000h,000h,000h	; 8928  ............
	defb 000h,0f8h,018h,009h,0f8h,01ch,00eh,0fbh,020h,01ah,0fbh,048h	; 8934  ........ ..H
	defb 007h,0f8h,018h,010h,0f8h,024h,013h,0fah,020h,000h,000h,000h	; 8940  .....$.. ...
	defb 0ffh,0f8h,018h,008h,0f8h,028h,013h,0fch,02ch,000h,000h,000h	; 894c  .....(..,...
	defb 000h,0f8h,030h,009h,0f8h,034h,00eh,0f5h,038h,01ah,0f5h,048h	; 8958  ..0..4..8..H
	defb 007h,0f8h,030h,010h,0f8h,03ch,013h,0f6h,038h,000h,000h,000h	; 8964  ..0..<..8...
	defb 0ffh,0f8h,030h,008h,0f8h,040h,013h,0f4h,044h,000h,000h,000h	; 8970  ..0..@..D...
	defb 00dh,0f5h,080h,006h,0f7h,084h,003h,0fah,088h,000h,000h,000h	; 897c  ............
	defb 00dh,0fbh,08ch,006h,0f9h,090h,003h,0f6h,094h	; 8988  .........

; ======================================================================
; CODIGO 0x8991..0x8bcf  (574 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; Los choques del esquiador: con la nieve de los lados, los enemigos, los arboles y las rocas, y lo que cae.
; ----------------------------------------------------------------------
choques:		; Los choques del esquiador
	ld a,(0e8a1h)		;8991   ; la X...
	sub 00ch		;8994   ; ...fuera de la pista por los lados?...
	cp 0b6h		;8996
	jr c,choques_suelo		;8998
	ld (0e8fah),a		;899a   ; ...ha chocado
	ret			;899d
choques_suelo:		; En el aire, ni enemigos ni pista
	ld a,(0e884h)		;899e
	cp 050h		;89a1
	jp c,choques_cae		;89a3
	ld hl,(0e8a0h)		;89a6   ; su Y y su X...
	ld ix,0e8e2h		;89a9   ; ...contra los cuatro enemigos
	ld b,004h		;89ad
choques_enemigo:		; Un enemigo: si esta en marcha y a menos de 12 en Y y 13 en X, choque
	ld e,(ix+000h)		;89af   ; la Y del enemigo...
	ld d,(ix+001h)		;89b2   ; ...y su X
	ld a,(ix+003h)		;89b5   ; esta en marcha?
	or a			;89b8
	jr z,choques_siguiente		;89b9
	ld a,l			;89bb   ; la distancia en Y...
	sub e			;89bc
	call absoluto		;89bd
	cp 00ch		;89c0   ; ...menos de 12?
	jr nc,choques_siguiente		;89c2
	ld a,h			;89c4   ; la distancia en X...
	sub d			;89c5
	call absoluto		;89c6
	cp 00dh		;89c9   ; ...menos de 13: choque
	jr c,choque		;89cb
choques_siguiente:		; El enemigo siguiente
	inc ix		;89cd
	inc ix		;89cf
	inc ix		;89d1
	inc ix		;89d3
	djnz choques_enemigo		;89d5
choques_pista:		; La casilla de la pista debajo del esquiador (tres filas mas abajo)
	ld hl,(0e8a0h)		;89d7   ; la Y y la X del esquiador...
	call xy_nombres		;89da   ; ...su casilla...
	ld de,00060h		;89dd   ; ...tres filas mas abajo (los esquis)
	add hl,de			;89e0
	call 0004ah		;89e1   ; RDVRM
	cp 0a5h		;89e4   ; una bandera de la pista (casillas 0xA5-0xAE)?...
	jr c,choques_arriba		;89e6
	cp 0afh		;89e8
	jr nc,choques_arriba		;89ea
	ld a,(0e88bh)		;89ec   ; ...si la cuenta del golpe ha acabado...
	inc a			;89ef
	jr nz,choques_cae		;89f0
choques_rebota:		; Un golpe: la direccion se vuelve al azar durante 32 cuadros
	call azar		;89f2
	and 005h		;89f5   ; una direccion al azar...
	jr z,choques_rebota		;89f7
	or 002h		;89f9   ; ...y siempre con el bit de arriba: frena
	ld (0e89dh),a		;89fb
	ld a,0e0h		;89fe   ; 32 cuadros
	ld (0e88bh),a		;8a00
	jr choques_cae		;8a03
choques_arriba:		; La casilla de encima
	ld de,0ffe0h		;8a05   ; una fila mas arriba
	add hl,de			;8a08
	call 0004ah		;8a09   ; RDVRM
	cp 0a5h		;8a0c   ; tambien una bandera?
	jr c,choques_tipo		;8a0e
	cp 0afh		;8a10
	jr nc,choques_tipo		;8a12
	jr choques_cae		;8a14
choques_tipo:		; Que casilla es: 0xBA la del enemigo especial; 0x99-0x9E, nieve que no choca
	cp 0bah		;8a16
	jr nz,choques_nieve		;8a18
	ld a,(0e8d9h)		;8a1a   ; el arbol del enemigo especial ya esta?...
	or a			;8a1d
	ret nz			;8a1e
	inc a			;8a1f   ; ...si no, que salga
	ld (0e8abh),a		;8a20
	ret			;8a23
choques_nieve:		; 0x99-0x9E: nieve, sin choque
	cp 099h		;8a24
	jr c,choques_casilla		;8a26
	cp 09fh		;8a28
	jr c,choques_cae		;8a2a
choques_casilla:		; 0x00-0x02, la pista; otra cosa, choque
	cp 003h		;8a2c
	jr c,choques_cae		;8a2e
choque:		; Choque: con que (0xE8FA)
	ld (0e8fah),a		;8a30
	ret			;8a33
choques_cae:		; Lo que cae (0xE860), a menos de 8 en Y y en X: choque
	ld hl,(0e860h)		;8a34   ; lo que cae...
	ld de,(0e8a0h)		;8a37   ; ...y el esquiador
	ld a,d			;8a3b   ; la distancia en X...
	sub h			;8a3c
	call absoluto		;8a3d
	cp 008h		;8a40   ; ...menos de 8?
	ret nc			;8a42
	ld a,e			;8a43   ; la distancia en Y (8 mas abajo)...
	add a,008h		;8a44
	sub l			;8a46
	call absoluto		;8a47
	cp 008h		;8a4a   ; ...menos de 8: choque
	ret nc			;8a4c
	jr choque		;8a4d

; ----------------------------------------------------------------------
; El aparato volador (por la forma, un helicoptero; el juego no lo nombra): sale de vez en cuando, se acerca volando hacia el esquiador, suelta cosas y explota cuando lo tocan.
; ----------------------------------------------------------------------
aparato:		; El aparato de este cuadro
	ld a,(0e8aah)		;8a4f   ; tocada?
	or a			;8a52
	jr z,aparato_marcha		;8a53
	ld a,(0e881h)		;8a55   ; cada ocho cuadros...
	add a,004h		;8a58   ; cada ocho cuadros
	and 007h		;8a5a
	jr nz,aparato_fin		;8a5c
	call aparato_sprites_fuera		;8a5e   ; fuera los sprites del aparato
	ld hl,0e8dah		;8a61   ; el aparato
	push hl			;8a64
	call lee4		;8a65
	pop hl			;8a68
	inc e			;8a69   ; la explosion sube un punto...
	push hl			;8a6a
	call guarda4		;8a6b   ; ...un punto mas abajo
	pop hl			;8a6e
	ld a,e			;8a6f   ; ...hasta la Y 0x30...
	cp 030h		;8a70   ; hasta 0x30
	jr c,L_8A80		;8a72
	ld de,00000h		;8a74   ; ...y entonces el aparato se va
	call guarda4		;8a77
	xor a			;8a7a
	ld (0e8aah),a		;8a7b
	jr aparato_fin		;8a7e
L_8A80:
	ld ix,0e814h		;8a80   ; la explosion: dos sprites en su sitio
	ld (ix+000h),e		;8a84   ; un sprite en su Y y X...
	ld (ix+001h),d		;8a87
	ld (ix+002h),0f8h		;8a8a   ; ...dibujo 0xF8...
	ld (ix+003h),001h		;8a8e   ; ...color 1
	ld (ix+004h),e		;8a92   ; otro...
	ld (ix+005h),d		;8a95
	ld (ix+006h),0fch		;8a98   ; ...dibujo 0xFC...
	ld (ix+007h),00ah		;8a9c   ; ...color 0x0A
	jr aparato_fin		;8aa0
aparato_marcha:		; En marcha
	call aparato_mueve		;8aa2
aparato_fin:		; Y lo que cae
	jp cae		;8aa5
aparato_mueve:		; Mueve el aparato cada ocho cuadros: hacia la X del esquiador, y sube
	ld a,(0e881h)		;8aa8
	add a,004h		;8aab
	and 007h		;8aad
	ret nz			;8aaf
	ld hl,0e8dah		;8ab0
	push hl			;8ab3
	call lee4		;8ab4
	pop hl			;8ab7
	ld a,e			;8ab8   ; no hay aparato?
	or d			;8ab9
	jr z,aparato_sale		;8aba
	call aparato_sprites_fuera		;8abc   ; fuera sus sprites
	ld a,(0e8a1h)		;8abf   ; hacia la X del esquiador...
	cp d			;8ac2
	jr z,L_8AC9		;8ac3
	jr c,L_8ACB		;8ac5   ; ...a la izquierda o a la derecha
	inc d			;8ac7
	inc d			;8ac8
L_8AC9:
	inc d			;8ac9
	inc d			;8aca
L_8ACB:
	dec d			;8acb
	dec d			;8acc
	dec e			;8acd   ; dos puntos arriba
	dec e			;8ace
	ld a,c			;8acf   ; el dibujo, segun la Y
	and 004h		;8ad0
	ld c,a			;8ad2
	ld a,e			;8ad3
	cp 0f8h		;8ad4   ; por arriba de la pantalla: se va...
	jr c,aparato_dibujo		;8ad6
	ld (hl),000h		;8ad8
	inc hl			;8ada
	ld (hl),000h		;8adb
	inc hl			;8add
	ld (hl),000h		;8ade
	call efecto_aparato_fuera		;8ae0   ; ...con su sonido
	ret			;8ae3
aparato_dibujo:		; Cuanto mas lejos, mas pequeno: cuatro tamanos y mas lenta
	cp 038h		;8ae4   ; por encima de 0x38...
	jr nc,aparato_guarda		;8ae6
	inc c			;8ae8   ; ...una talla menos...
	dec e			;8ae9   ; ...y un punto mas arriba
	cp 028h		;8aea   ; por encima de 0x28...
	jr nc,aparato_guarda		;8aec
	inc c			;8aee   ; ...otra talla...
	dec e			;8aef   ; ...y otro punto
	cp 010h		;8af0   ; por encima de 0x10...
	jr nc,aparato_guarda		;8af2
	inc c			;8af4   ; ...la mas pequeno...
	dec e			;8af5   ; ...y otro punto
aparato_guarda:		; Guarda el aparato
	call guarda4		;8af6
	jr aparato_sprites		;8af9
aparato_sale:		; Un aparato nuevo: si la ronda la tiene, una vez de cada 16
	ld a,(0e8feh)		;8afb   ; esta ronda tiene aparato?
	or a			;8afe
	ret nz			;8aff
	call azar		;8b00
	and 00fh		;8b03
	ret nz			;8b05
	ld hl,08bcfh		;8b06   ; el aparato sale por el centro (0x8BCF)...
	ld a,(0e8a8h)		;8b09
	or a			;8b0c
	jr z,aparato_sale_pon		;8b0d
	ld hl,08bd3h		;8b0f   ; ...o por un lado, segun la curva...
	inc a			;8b12
	jr nz,aparato_sale_pon		;8b13
	ld hl,08bd7h		;8b15   ; ...(0x8BD3 o 0x8BD7)
aparato_sale_pon:		; Su Y, su X y su paso
	ld de,0e8dah		;8b18
	ld bc,00003h		;8b1b
	ldir		;8b1e
aparato_sale_color:		; Su color, uno de tres al azar (0x8BDB)
	call azar		;8b20   ; al azar...
	and 003h		;8b23   ; ...de 1 a 3...
	jr z,aparato_sale_color		;8b25
	dec a			;8b27
	ld hl,08bdbh		;8b28   ; ...en la tabla de tipos
	ld b,000h		;8b2b
	ld c,a			;8b2d
	add hl,bc			;8b2e
	ld a,(hl)			;8b2f
	ld (de),a			;8b30   ; su color
	call efecto_aparato		;8b31   ; su sonido
aparato_sprites:		; Los sprites del aparato: su tamano (0x8BDE) y los dibujos (0x8BEE)
	ld hl,0e8dah		;8b34
	call lee4		;8b37   ; Y, X, paso y tipo
	ld a,b			;8b3a   ; el color, a A'
	ex af,af'			;8b3b
	ld ix,08beeh		;8b3c   ; la tabla de dibujos de su tipo...
	ld b,000h		;8b40
	add ix,bc		;8b42   ; el tipo, por dos, en la tabla
	add ix,bc		;8b44
	ld l,(ix+000h)		;8b46
	ld h,(ix+001h)		;8b49
	push hl			;8b4c
	pop ix		;8b4d
	ld l,(ix+000h)		;8b4f   ; ...y la primera palabra, el desplazamiento
	ld h,(ix+001h)		;8b52
	inc ix		;8b55
	inc ix		;8b57
	add hl,de			;8b59   ; la Y y la X, mas el desplazamiento
	ex de,hl			;8b5a
	ld hl,08bdeh		;8b5b   ; el ancho y el alto en sprites
	call tabla_par		;8b5e
	ld hl,0e814h		;8b61   ; en 0xE814
aparato_fila:		; Una fila de sprites
	push de			;8b64   ; la fila
	push bc			;8b65
aparato_sprite:		; Un sprite: Y, X, dibujo y color
	ld (hl),e			;8b66   ; la Y
	inc hl			;8b67
	ld (hl),d			;8b68   ; la X
	inc hl			;8b69
	ld a,(ix+000h)		;8b6a   ; el dibujo...
	ld (hl),a			;8b6d
	inc hl			;8b6e
	inc ix		;8b6f   ; el siguiente dibujo
	ex af,af'			;8b71
	ld (hl),a			;8b72   ; ...y el color
	ex af,af'			;8b73
	inc hl			;8b74
	ld a,d			;8b75   ; el siguiente, 16 a la derecha
	add a,010h		;8b76
	ld d,a			;8b78
	djnz aparato_sprite		;8b79   ; los sprites de la fila
	pop bc			;8b7b
	pop de			;8b7c
	ld a,e			;8b7d   ; la fila siguiente, 16 abajo
	add a,010h		;8b7e
	ld e,a			;8b80
	dec c			;8b81   ; las filas
	jr nz,aparato_fila		;8b82
	ret			;8b84
cae:		; Lo que cae del aparato (0xE860): baja hasta abajo de la pantalla
	ld a,(0e900h)		;8b85   ; esta ronda tiene cosas que caen?
	inc a			;8b88
	ret z			;8b89
	ld hl,0e860h		;8b8a   ; su Y...
	call lee4		;8b8d
	ld a,e			;8b90
	cp 0c0h		;8b91   ; ...en la pantalla?
	jr c,cae_baja		;8b93
	call azar		;8b95   ; no: uno nuevo una vez de cada 64...
	and 03fh		;8b98
	ret nz			;8b9a
	ld hl,0e8dah		;8b9b   ; ...si el aparato esta en el paso 1...
	call lee4		;8b9e
	ld a,c			;8ba1
	cp 001h		;8ba2
	ret nz			;8ba4
	ld (0e860h),de		;8ba5   ; ...desdel aparato...
	ld hl,001ach		;8ba9   ; ...con su dibujo y color
	ld (0e862h),hl		;8bac
	ret			;8baf
cae_baja:		; Baja con el paso de la ronda; por debajo de 0x50, un punto mas
	ld a,(0e900h)		;8bb0
	add a,e			;8bb3
	ld e,a			;8bb4
	ld b,001h		;8bb5
	cp 050h		;8bb7
	jr c,cae_guarda		;8bb9
	inc e			;8bbb
	ld c,0b0h		;8bbc
	ld a,e			;8bbe
	cp 0b8h		;8bbf   ; hasta 0xB8...
	jr c,cae_guarda		;8bc1
	ld a,0c0h		;8bc3   ; ...y fuera
	ld (0e860h),a		;8bc5
	ret			;8bc8
cae_guarda:		; Guarda lo que cae
	ld hl,0e860h		;8bc9
	jp guarda4		;8bcc

; ----------------------------------------------------------------------
; DATOS aparato_salidas: El aparato sale de tres sitios (Y, X, paso): el
;   centro, la izquierda y la derecha
;   0x8bcf..0x8bdb  (12 bytes)
DATA_aparato_salidas:
	defb 03ch,060h,000h	; 8bcf
	defb 000h	; 8bd2
	defb 03ch,050h,000h	; 8bd3
	defb 000h	; 8bd6
	defb 03ch,070h,000h	; 8bd7
	defb 000h	; 8bda

; ----------------------------------------------------------------------
; DATOS aparato_colores: Los tres colores del aparato: negro (1), rojo claro
;   (9) y blanco (15)
;   0x8bdb..0x8bde  (3 bytes)
DATA_aparato_colores:
	defb 001h,009h,00fh	; 8bdb

; ----------------------------------------------------------------------
; DATOS aparato_tamanos: El tamano del aparato en sprites (ancho, alto), por
;   su dibujo
;   0x8bde..0x8bee  (16 bytes)
DATA_aparato_tamanos:
	defb 001h,001h	; 8bde
	defb 001h,001h	; 8be0
	defb 002h,002h	; 8be2
	defb 002h,003h	; 8be4
	defb 001h,001h	; 8be6
	defb 001h,001h	; 8be8
	defb 001h,002h	; 8bea
	defb 002h,003h	; 8bec

; ----------------------------------------------------------------------
; DATOS aparato_dibujos: Los dibujos del aparato: punteros (0x8BEE) a su
;   desplazamiento y sus numeros de dibujo
;   0x8bee..0x8c24  (54 bytes)
DATA_aparato_dibujos:
	defw 08bfeh,08c01h,08c04h,08c0ah,08c12h,08c15h,08c18h,08c1ch	; 8bee
	defb 0f8h,0f8h,088h	; 8bfe
	defb 0f4h,0f8h,084h	; 8c01
	defb 0efh,0f0h,074h	; 8c04
	defb 078h,07ch,080h	; 8c07
	defb 0e8h,0e8h,05ch	; 8c0a
	defb 060h,064h,068h	; 8c0d
	defb 06ch,070h,0f8h	; 8c10
	defb 0f8h,0b8h,0f4h	; 8c13
	defb 0f8h,0bch,0efh	; 8c16
	defb 0f0h,0c0h,0c4h	; 8c19
	defb 0e8h,0e8h,0c8h	; 8c1c
	defb 0cch,0d0h,0d4h	; 8c1f
	defb 0d8h,0dch	; 8c22

; ======================================================================
; CODIGO 0x8c24..0x8e03  (479 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; Los cuatro esquiadores enemigos (0xE8E2, 4 bytes: Y, X, paso, tipo): salen de abajo, suben esquivando y se acercan al esquiador.
; ----------------------------------------------------------------------
enemigos:		; Los cuatro enemigos, uno cada cuatro cuadros
	ld hl,0e8e2h		;8c24
	ld iy,0e82ch		;8c27   ; sus sprites, desde 0xE82C (12 bytes cada uno)
	ld b,004h		;8c2b
enemigos_uno:		; Un enemigo
	push bc			;8c2d
	push hl			;8c2e
	push iy		;8c2f
	call enemigo		;8c31
	pop iy		;8c34
	pop hl			;8c36
	pop bc			;8c37
	ld de,00004h		;8c38   ; el siguiente enemigo...
	add hl,de			;8c3b
	ld de,0000ch		;8c3c   ; ...y sus sprites
	add iy,de		;8c3f
	djnz enemigos_uno		;8c41
	ret			;8c43
enemigo:		; Un enemigo (HL su entrada, IY sus sprites)
	push hl			;8c44
	ld a,(0e881h)		;8c45   ; uno de cada cuatro cuadros
	and 003h		;8c48   ; cada cuatro cuadros...
	pop hl			;8c4a
	ret nz			;8c4b
	push hl			;8c4c   ; fuera sus tres sprites (0xC0)...
	push iy		;8c4d   ; los sprites del enemigo...
	pop hl			;8c4f
	push hl			;8c50
	pop de			;8c51
	inc de			;8c52   ; ...los doce bytes...
	ld bc,0000ch		;8c53
	ld (hl),0c0h		;8c56   ; ...a 0xC0
	ldir		;8c58
	pop hl			;8c5a
	ld (0e88dh),hl		;8c5b   ; el enemigo en curso
	call lee4		;8c5e   ; Y, X, paso y tipo
	ld a,d			;8c61   ; no hay enemigo?...
	or e			;8c62
	jp z,enemigo_nuevo		;8c63   ; ...uno nuevo, quiza
	ld a,b			;8c66   ; el tipo 0 es un enemigo derribado...
	or a			;8c67   ; derribado?
	jr nz,enemigo_mueve		;8c68
	ld a,c			;8c6a   ; ...que cae: su paso sube de 16 en 16...
	add a,010h		;8c6b
	ld c,a			;8c6d
	and 0f0h		;8c6e   ; el paso...
	jr nz,L_8C78		;8c70
	ld de,00000h		;8c72   ; ...y al acabar, fuera
	jp guarda4_88d		;8c75
L_8C78:
	call guarda4_88d		;8c78
	ld ix,08e3fh		;8c7b   ; los dibujos del derribado (0x8E3F)
	jp enemigo_sprites_tabla		;8c7f
enemigo_mueve:		; Un enemigo en marcha: mira la pista que tiene delante (RDVRM) y la esquiva
	push bc			;8c82
	push de			;8c83
	ex de,hl			;8c84
	ld a,h			;8c85   ; la Y, cuatro puntos menos
	sub 004h		;8c86
	ld h,a			;8c88
	call xy_nombres		;8c89   ; ...la casilla...
	ld de,00040h		;8c8c   ; ...dos filas mas abajo
	add hl,de			;8c8f
	pop de			;8c90
	call casilla_fila		;8c91   ; RDVRM de la casilla de delante
	ld b,a			;8c94
	xor a			;8c95   ; sin paso de lado
	ld (0e8fch),a		;8c96
	ex af,af'			;8c99   ; el resultado a A'
	ld a,h			;8c9a   ; en la fila 0x1A, tambien la casilla de la derecha
	cp 01ah		;8c9b
	jr nz,enemigo_libre		;8c9d
	inc hl			;8c9f
	call casilla_fila		;8ca0   ; y la de la derecha
	dec hl			;8ca3
	ex af,af'			;8ca4
enemigo_libre:		; Nada delante: si esta por debajo de 0x50 en la pantalla, va hacia el esquiador
	ex af,af'			;8ca5
	or b			;8ca6
	jr nz,enemigo_esquiva		;8ca7
	ld a,e			;8ca9
	cp 050h		;8caa   ; en la parte de abajo...
	jr c,enemigo_sube		;8cac
	ld a,(0e8a1h)		;8cae   ; hacia la X del esquiador
	sub d			;8cb1   ; ...la distancia en X...
	push af			;8cb2
	call absoluto		;8cb3
	cp 008h		;8cb6   ; ya esta a menos de 8: recto
	jr c,enemigo_recto		;8cb8
	pop af			;8cba   ; ...a que lado
	jr c,enemigo_izquierda		;8cbb
	jr enemigo_derecha		;8cbd
enemigo_esquiva:		; Algo delante: a un lado al azar
	call azar		;8cbf
	bit 0,a		;8cc2   ; al azar, un lado
	jr z,enemigo_izquierda		;8cc4
enemigo_derecha:		; A la derecha, si alli no hay nada
	ld a,002h		;8cc6
	ld (0e8fch),a		;8cc8
	ld a,d			;8ccb   ; cuatro puntos a la derecha...
	add a,004h		;8ccc
	ld d,a			;8cce
	inc hl			;8ccf   ; ...y la casilla de alli
	inc hl			;8cd0
	call casilla_fila		;8cd1   ; la casilla de alli
	dec hl			;8cd4
	dec hl			;8cd5
	or a			;8cd6   ; libre?
	jr z,enemigo_sube		;8cd7
	ld a,d			;8cd9
	sub 004h		;8cda
	ld d,a			;8cdc
enemigo_izquierda:		; A la izquierda, si alli no hay nada
	ld a,0feh		;8cdd   ; paso de lado -2
	ld (0e8fch),a		;8cdf
	ld a,d			;8ce2   ; cuatro puntos a la izquierda...
	sub 004h		;8ce3
	ld d,a			;8ce5
	dec hl			;8ce6
	call casilla_fila		;8ce7   ; ...la casilla de alli
	inc hl			;8cea
	or a			;8ceb
	jr z,enemigo_sube		;8cec   ; libre?
	ld a,d			;8cee
	add a,004h		;8cef
	ld d,a			;8cf1
	ld a,002h		;8cf2   ; tampoco: vuelve a probar la derecha
	ld (0e8fch),a		;8cf4
	ld a,d			;8cf7   ; cuatro a la derecha...
	add a,004h		;8cf8
	ld d,a			;8cfa
	inc hl			;8cfb
	inc hl			;8cfc
	call casilla_fila		;8cfd   ; ...la casilla de alli
	dec hl			;8d00
	dec hl			;8d01
	or a			;8d02
	jr z,enemigo_sube		;8d03
	ld a,d			;8d05
	sub 004h		;8d06
	ld d,a			;8d08
	xor a			;8d09   ; todo ocupado: frena (la Y retrocede lo que sube la pista)
	ld (0e8fch),a		;8d0a   ; sin paso de lado
	ld a,(0e8ffh)		;8d0d   ; lo que sube la pista...
	sub e			;8d10
	neg		;8d11   ; ...a la contra
	ld e,a			;8d13
	push af			;8d14
enemigo_recto:		; Recto
	pop af			;8d15
enemigo_sube:		; Sube con la pista (0xE8FF) y su dibujo segun lo cerca que esta: cuatro tamanos
	pop bc			;8d16
	ld a,(0e8ffh)		;8d17   ; sube con la pista...
	add a,e			;8d1a
	ld e,a			;8d1b
	ld c,000h		;8d1c   ; el tamano 0
	ld hl,(0e88dh)		;8d1e   ; el enemigo en curso
	cp 048h		;8d21   ; hasta 0x48, el mas pequeno
	jr c,enemigo_guarda		;8d23
	inc c			;8d25   ; tamano 1...
	inc e			;8d26   ; ...y un punto mas
	cp 060h		;8d27   ; hasta 0x60...
	jr c,enemigo_guarda		;8d29
	inc c			;8d2b   ; tamano 2...
	inc e			;8d2c   ; ...y dos mas
	inc e			;8d2d
	cp 0b0h		;8d2e   ; hasta 0xB0...
	jr c,enemigo_guarda		;8d30
	inc c			;8d32   ; tamano 3...
	inc e			;8d33   ; ...y tres mas
	inc e			;8d34
	inc e			;8d35
	push bc			;8d36
	push de			;8d37
	push hl			;8d38
	push af			;8d39
	ld a,(0f024h)		;8d3a   ; el canal 2 suena?...
	or a			;8d3d
	call z,efecto_enemigo		;8d3e   ; ...si no, el sonido del enemigo
	pop af			;8d41
	pop hl			;8d42
	pop de			;8d43
	pop bc			;8d44
	cp 0c8h		;8d45   ; por debajo de 0xC8 se va...
	jr c,enemigo_guarda		;8d47
	ld de,00000h		;8d49
	call guarda4		;8d4c
	ld hl,0e8deh		;8d4f   ; ...y hay uno menos
	dec (hl)			;8d52
	ret			;8d53
enemigo_guarda:		; Guarda el enemigo y pinta sus sprites
	call guarda4		;8d54   ; guarda Y, X, paso y tipo
	jr enemigo_sprites		;8d57
enemigo_nuevo:		; Un enemigo nuevo: cuando acaba la cuenta y si la pista no esta acabando, uno de cada 32
	ld a,(0e902h)		;8d59
	or a			;8d5c   ; la curva acabada?
	ret nz			;8d5d
	ld a,(0e887h)		;8d5e   ; la cuenta de los enemigos...
	inc a			;8d61
	ret nz			;8d62
	call azar		;8d63   ; al azar...
	and 01fh		;8d66   ; ...uno de cada 32
	ret nz			;8d68
	ld hl,0e8deh		;8d69   ; uno mas
	inc (hl)			;8d6c
	ld hl,08bcfh		;8d6d   ; sale por el centro o por un lado, segun la curva (como el aparato)
	ld a,(0e8a8h)		;8d70   ; la curva...
	or a			;8d73
	jr z,enemigo_nuevo_pon		;8d74
	ld hl,08bd3h		;8d76
	inc a			;8d79
	jr nz,enemigo_nuevo_pon		;8d7a
	ld hl,08bd7h		;8d7c
enemigo_nuevo_pon:		; Su Y, su X y su paso
	ld de,(0e88dh)		;8d7f   ; en la entrada del enemigo
	ld bc,00003h		;8d83
	ldir		;8d86
enemigo_nuevo_tipo:		; El tipo, al azar de 1 a 7
	call azar		;8d88   ; al azar...
	and 00fh		;8d8b   ; ...de 1...
	jr z,enemigo_nuevo_tipo		;8d8d
	cp 008h		;8d8f   ; ...a 7
	jr nc,enemigo_nuevo_tipo		;8d91
	ld (de),a			;8d93   ; el tipo
	ld a,0b0h		;8d94   ; el siguiente, dentro de 80 cuadros
	ld (0e887h),a		;8d96
enemigo_sprites:		; Los sprites del enemigo: sus dibujos de 0x8E13
	ld ix,08e13h		;8d99
enemigo_sprites_tabla:		; Los sprites con la tabla IX: cuantos, y por cada uno dy, dx, dibujo y color
	ld hl,(0e88dh)		;8d9d
	call lee4		;8da0
	ld a,c			;8da3   ; el paso (el tamano)...
	and 00fh		;8da4
	ld c,a			;8da6
	ld a,b			;8da7   ; ...y el tipo
	ex af,af'			;8da8   ; el tipo, a A'
	ld b,000h		;8da9
	add ix,bc		;8dab   ; la tabla del tamano...
	add ix,bc		;8dad
	ld l,(ix+000h)		;8daf   ; ...su puntero
	ld h,(ix+001h)		;8db2
	ld b,(hl)			;8db5   ; cuantos sprites
	inc hl			;8db6
enemigo_sprite:		; Un sprite: Y + dy, X + dx (el de las piernas, con el paso de lado), dibujo y color del tipo (0x8E03)
	push bc			;8db7
	ld a,e			;8db8   ; la Y...
	add a,(hl)			;8db9   ; ...mas la del sprite
	inc hl			;8dba
	ld (iy+000h),a		;8dbb   ; a la tabla
	ld a,d			;8dbe   ; la X...
	add a,(hl)			;8dbf   ; ...mas la del sprite
	inc hl			;8dc0
	ld c,000h		;8dc1
	push af			;8dc3
	ld a,b			;8dc4   ; el segundo sprite (las piernas)...
	cp 002h		;8dc5
	jr nz,L_8DCD		;8dc7
	ld a,(0e8fch)		;8dc9   ; ...con el paso de lado
	ld c,a			;8dcc
L_8DCD:
	pop af			;8dcd
	add a,c			;8dce
	ld (iy+001h),a		;8dcf   ; la X a la tabla
	ld a,(hl)			;8dd2   ; el dibujo
	inc hl			;8dd3
	ld (iy+002h),a		;8dd4
	push ix		;8dd7
	ex af,af'			;8dd9
	push af			;8dda
	ld c,a			;8ddb   ; los colores del tipo...
	ld b,000h		;8ddc
	ld ix,08e03h		;8dde
	add ix,bc		;8de2
	add ix,bc		;8de4
	ld a,(hl)			;8de6   ; ...mas el del sprite
	ld c,a			;8de7
	ld b,000h		;8de8
	add ix,bc		;8dea
	inc hl			;8dec
	ld a,(ix+000h)		;8ded   ; el color
	ld (iy+003h),a		;8df0
	pop af			;8df3
	ex af,af'			;8df4
	pop ix		;8df5
	inc iy		;8df7   ; el sprite siguiente
	inc iy		;8df9
	inc iy		;8dfb
	inc iy		;8dfd
	pop bc			;8dff
	djnz enemigo_sprite		;8e00
	ret			;8e02

; ----------------------------------------------------------------------
; DATOS colores_enemigos: Los colores de los enemigos: dos por tipo (el del
;   cuerpo y el de las piernas)
;   0x8e03..0x8e13  (16 bytes)
DATA_colores_enemigos:
	defb 006h,006h	; 8e03
	defb 00ah,002h	; 8e05
	defb 003h,005h	; 8e07
	defb 004h,006h	; 8e09
	defb 005h,007h	; 8e0b
	defb 00ah,00ch	; 8e0d
	defb 00ch,001h	; 8e0f
	defb 00dh,00fh	; 8e11

; ----------------------------------------------------------------------
; DATOS dibujos_enemigos: Los dibujos de los enemigos: cuatro tamanos (0x8E13)
;   y cuatro del derribado (0x8E3F), cada uno cuantos sprites y dy, dx,
;   dibujo, color
;   0x8e13..0x8e5b  (72 bytes)
DATA_dibujos_enemigos:
	defw 08e1bh,08e20h,08e29h,08e32h	; 8e13
	defb 001h	; 8e1b
	defb 000h,0f8h,0a8h,001h	; 8e1c
	defb 002h,0f8h,0f8h,0a0h	; 8e20
	defb 000h,0fdh,0f8h,0a4h	; 8e24
	defb 001h,002h,0f8h,0f8h	; 8e28
	defb 098h,000h,0feh,0f8h	; 8e2c
	defb 09ch,001h,003h,000h	; 8e30
	defb 0f8h,090h,000h,0f0h	; 8e34
	defb 0f8h,08ch,000h,0f8h	; 8e38
	defb 0f8h,094h,001h,047h	; 8e3c
	defb 08eh,04ch,08eh,051h	; 8e40
	defb 08eh,056h,08eh,001h	; 8e44
	defb 000h,0f8h,0b4h,000h	; 8e48
	defb 001h,000h,0f8h,0b8h	; 8e4c
	defb 000h,001h,000h,0f8h	; 8e50
	defb 0bch,000h,001h,000h	; 8e54
	defb 0f8h,0bch,000h	; 8e58

; ======================================================================
; CODIGO 0x8e5b..0x919f  (836 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; El disparo del esquiador: sale con el boton 1 y sube; da a los enemigos (100 puntos), al aparato (200) o a las banderas (1000).
; ----------------------------------------------------------------------
disparo:		; El disparo de este cuadro
	ld a,(0e8f8h)		;8e5b   ; ya hay uno?
	or a			;8e5e
	jr nz,disparo_vuela		;8e5f
	call boton_disparo		;8e61   ; el boton 1, recien pulsado?
	call boton_nuevo		;8e64
	ld hl,(0e8a0h)		;8e67   ; sale de la Y y la X del esquiador...
	ld (0e810h),hl		;8e6a
	ld a,054h		;8e6d   ; ...con el dibujo 0x54...
	ld (0e812h),a		;8e6f
	ld a,001h		;8e72   ; ...y el color 1
	ld (0e813h),a		;8e74
	ld (0e8f8h),a		;8e77
	ld a,(0e884h)		;8e7a   ; durante el salto, va al aparato
	cp 050h		;8e7d
	jr c,disparo_tipo		;8e7f
	xor a			;8e81
disparo_tipo:		; Guarda a que va y su sonido
	ld (0e8a5h),a		;8e82
	jp efecto_disparo		;8e85
disparo_vuela:		; El disparo en el aire: los enemigos o el aparato, y sube
	ld a,(0e881h)		;8e88
	call disparo_enemigos		;8e8b
	call disparo_sube		;8e8e
	ret			;8e91
disparo_sube:		; Sube cuatro puntos: lo que hay en la pista
	ld a,(0e810h)		;8e92
	sub 004h		;8e95
	ld b,a			;8e97
	ld a,(0e8a5h)		;8e98
	or a			;8e9b
	ld a,b			;8e9c
	jr z,disparo_pista		;8e9d   ; va a la pista
	cp 01ch		;8e9f   ; hacial aparato: hasta la Y 0x1C
	jr nc,disparo_guarda		;8ea1
	jr disparo_acaba		;8ea3
disparo_pista:		; La casilla de debajo: una bandera (0xAF en adelante, no 0xBA) da 1000 puntos
	push af			;8ea5
	ld hl,(0e810h)		;8ea6
	call casilla_xy		;8ea9   ; la casilla de debajo
	cp 0bah		;8eac   ; 0xBA no...
	jr z,disparo_choca		;8eae
	cp 0afh		;8eb0   ; ...0xAF o mas: una bandera
	jr c,disparo_choca		;8eb2
	ld hl,(0e90ah)		;8eb4   ; diez puntos (1000)
	ld de,0000ah		;8eb7
	add hl,de			;8eba
	ld (0e90ah),hl		;8ebb
	call efecto_bandera		;8ebe   ; su sonido
	ld hl,(0e8d8h)		;8ec1   ; el arbol del enemigo especial...
	push hl			;8ec4
	call lee4		;8ec5
	call objeto_borra		;8ec8   ; ...se borra
	ld de,00000h		;8ecb
	ld (0e8d8h),de		;8ece
	pop hl			;8ed2
	call guarda4		;8ed3   ; borrado
	jr disparo_fuera		;8ed6
disparo_choca:		; 0x80-0xA3, un arbol o una roca: el disparo se para
	cp 080h		;8ed8
	jr c,disparo_alto		;8eda
	cp 0a4h		;8edc   ; hasta 0xA3: un objeto
	jr c,disparo_fuera		;8ede
disparo_alto:		; Por encima de 0x40, sigue
	pop af			;8ee0
	cp 040h		;8ee1   ; por encima de 0x40...
	jr nc,disparo_guarda		;8ee3
disparo_fuera:		; Se acaba
	pop af			;8ee5
disparo_acaba:		; El disparo fuera de la pantalla
	ld a,0c0h		;8ee6
	ld (0e810h),a		;8ee8
	xor a			;8eeb
	ld (0e8f8h),a		;8eec
	ret			;8eef
disparo_guarda:		; Guarda la Y; por encima de 0x90, el dibujo pequeno
	ld (0e810h),a		;8ef0
	cp 090h		;8ef3
	ret nc			;8ef5
	ld a,058h		;8ef6   ; el dibujo del disparo lejano
	ld (0e812h),a		;8ef8
	ret			;8efb
disparo_enemigos:		; Contra los enemigos: a menos de 6 en Y y en X
	ld a,(0e8a5h)		;8efc   ; va al aparato?
	or a			;8eff
	jr nz,disparo_aparato		;8f00
	ld hl,0e8e2h		;8f02   ; cinco: los cuatro enemigos y el aparato
	ld b,005h		;8f05
L_8F07:
	push bc			;8f07   ; un enemigo...
	push hl			;8f08
	call lee4		;8f09   ; ...Y, X, paso, tipo
	ld a,b			;8f0c   ; derribado ya?
	or a			;8f0d
	jr z,disparo_enemigos_sig		;8f0e   ; derribado: el siguiente
	ld a,(0e810h)		;8f10   ; la Y del disparo...
	sub e			;8f13   ; ...menos la del enemigo...
	call absoluto		;8f14
	cp 006h		;8f17   ; ...menos de 6?
	jr nc,disparo_enemigos_sig		;8f19
	ld a,(0e811h)		;8f1b   ; la X del disparo...
	sub d			;8f1e   ; ...menos la del enemigo...
	call absoluto		;8f1f
	cp 006h		;8f22   ; ...menos de 6: tocado
	jr nc,disparo_enemigos_sig		;8f24
	push bc			;8f26   ; guarda el enemigo...
	push de			;8f27
	push hl			;8f28
	call efecto_derribo		;8f29   ; su sonido
	ld hl,(0e90ah)		;8f2c   ; un punto (100)
	inc hl			;8f2f
	ld (0e90ah),hl		;8f30
	ld hl,0e8deh		;8f33   ; un enemigo menos
	dec (hl)			;8f36
	pop hl			;8f37
	pop de			;8f38
	pop bc			;8f39
	ld b,000h		;8f3a   ; el enemigo pasa a derribado (tipo 0)...
	ld a,c			;8f3c   ; ...con el bit 7 de su paso
	or 080h		;8f3d   ; el bit 7 del paso
	ld c,a			;8f3f
	ld a,0cfh		;8f40   ; el disparo, fuera
	ld (0e810h),a		;8f42
	xor a			;8f45
	ld (0e8f8h),a		;8f46
	pop hl			;8f49
	call guarda4		;8f4a   ; el enemigo, guardado
	pop bc			;8f4d   ; fuera del bucle
	pop bc			;8f4e
	ret			;8f4f
disparo_enemigos_sig:		; El siguiente
	pop hl			;8f50   ; el enemigo, sin cambiar
	call guarda4		;8f51
	pop bc			;8f54
	djnz L_8F07		;8f55   ; el siguiente
	ret			;8f57
disparo_aparato:		; Contra el aparato (0xE8DA): con el aparato tocado, el disparo a menos de 8 da una vida
	ld hl,0e8dah		;8f58   ; el aparato
	push hl			;8f5b
	call lee4		;8f5c
	pop hl			;8f5f
	ld a,d			;8f60   ; no hay?
	or e			;8f61
	ret z			;8f62
	ld a,(0e8aah)		;8f63   ; ya tocada?
	or a			;8f66
	jr z,disparo_aparato_tamano		;8f67
	ld hl,(0e810h)		;8f69   ; el disparo...
	ld a,e			;8f6c   ; ...contra el aparato en Y...
	sub l			;8f6d
	call absoluto		;8f6e
	cp 008h		;8f71   ; ...a menos de 8...
	ret nc			;8f73
	ld a,d			;8f74   ; ...y en X...
	sub h			;8f75
	call absoluto		;8f76
	cp 008h		;8f79   ; ...a menos de 8
	ret nc			;8f7b
	call efecto_vida		;8f7c   ; su sonido
	ld hl,0e90eh		;8f7f   ; una vida mas
	inc (hl)			;8f82
	call marcador_pinta		;8f83   ; el marcador
	xor a			;8f86   ; el aparato se va
	ld (0e8aah),a		;8f87
	ld hl,00000h		;8f8a   ; sin aparato
	ld (0e8dah),hl		;8f8d
	call aparato_sprites_fuera		;8f90   ; ni sus sprites
	ret			;8f93
disparo_aparato_tamano:		; El aparato entero: su tamano en sprites, por 8
	ld a,c			;8f94   ; su dibujo...
	cp 004h		;8f95   ; ...con la explosion (4 en adelante), no
	ret nc			;8f97
	ld hl,08bdeh		;8f98   ; su tamano en sprites (ancho en C, alto en B)...
	call tabla_par		;8f9b
	sla b		;8f9e   ; ...por 8
	sla b		;8fa0
	sla b		;8fa2
	sla c		;8fa4
	sla c		;8fa6
	sla c		;8fa8
	ld a,(0e810h)		;8faa   ; la distancia en Y...
	sub e			;8fad
	call absoluto		;8fae   ; ...dentro de su alto?
	cp c			;8fb1
	ret nc			;8fb2
	ld a,(0e811h)		;8fb3   ; la distancia en X...
	sub d			;8fb6
	call absoluto		;8fb7   ; ...dentro de su ancho?
	cp b			;8fba
	ret nc			;8fbb
	ld hl,0e8dah		;8fbc   ; tocada
	push hl			;8fbf
	push hl			;8fc0
	call lee4		;8fc1   ; Y, X, paso y tipo
	ld a,b			;8fc4   ; su color, a A'
	ex af,af'			;8fc5
	ld b,006h		;8fc6   ; el paso de la explosion...
	ld a,c			;8fc8   ; el dibujo de la explosion: cuatro mas
	add a,004h		;8fc9
	ld c,a			;8fcb
	pop hl			;8fcc
	call guarda4		;8fcd   ; guarda
	call efecto_diana		;8fd0   ; ...su sonido
	ld a,0cfh		;8fd3   ; el disparo, fuera
	ld (0e810h),a		;8fd5
	xor a			;8fd8   ; no hay disparo
	ld (0e8f8h),a		;8fd9
	ld hl,(0e90ah)		;8fdc   ; dos puntos (200)
	inc hl			;8fdf
	inc hl			;8fe0
	ld (0e90ah),hl		;8fe1
	pop hl			;8fe4   ; el aparato otra vez...
	call lee4		;8fe5
	ex af,af'			;8fe8   ; ...el color que tenia
	dec a			;8fe9   ; si era el negro (color 1): tocado
	ret nz			;8fea
	inc a			;8feb   ; 1: tocada
	ld (0e8aah),a		;8fec
	call efecto_golpe		;8fef   ; su sonido
	ret			;8ff2

; ----------------------------------------------------------------------
; Las lineas de la pista: el suelo baja con diez dibujos de rayas (0x919F y 0x91D1), y las curvas mueven la pista entera de lado.
; ----------------------------------------------------------------------
pista:		; Un cuadro de la pista: las rayas si toca, y la curva
	ld hl,0e901h		;8ff3
	ld a,(0e881h)		;8ff6   ; cada tantos cuadros como diga la dificultad (0xE901)
	add a,002h		;8ff9
	and (hl)			;8ffb
	jp nz,pista_curva		;8ffc
	ld a,(0e89ch)		;8fff   ; la fase de las rayas: 0 a 9
	inc a			;9002
	cp 00ah		;9003
	jr c,pista_fase		;9005
	xor a			;9007
pista_fase:		; Las rayas de la izquierda: diez filas de cinco casillas desde la fila 9, columna 0
	ld (0e89ch),a		;9008
	sub 009h		;900b
	neg		;900d
	ld c,a			;900f
	add a,a			;9010
	add a,a			;9011
	add a,c			;9012
	ld c,a			;9013
	ld b,000h		;9014
	ld hl,0919fh		;9016   ; la tabla de la izquierda (0x919F)
	add hl,bc			;9019
	ld de,01920h		;901a   ; fila 9, columna 0
	ld b,00ah		;901d
	ld c,005h		;901f
pista_izquierda:		; Una fila, mas corta cuanto mas arriba
	push bc			;9021   ; la fila...
	push de			;9022
	ld a,005h		;9023   ; cinco casillas...
	ld b,000h		;9025
	bit 7,c		;9027   ; C negativo: la fila se corta por la izquierda...
	jr z,L_902E		;9029
	add a,c			;902b   ; ...cuantas quedan
	ld c,000h		;902c
L_902E:
	ex de,hl			;902e   ; la columna en la tabla de nombres
	add hl,bc			;902f
	ex de,hl			;9030
	ld c,a			;9031
	ld b,000h		;9032
	push hl			;9034
	push af			;9035
	sub 005h		;9036   ; los que sobran del principio...
	neg		;9038
	ld c,a			;903a
	ld b,000h		;903b
	add hl,bc			;903d   ; ...se saltan
	pop af			;903e
	ld c,a			;903f
	ld b,000h		;9040
	call 0005ch		;9042   ; LDIRVM
	pop hl			;9045
	ld bc,00005h		;9046   ; la fila siguiente de la tabla
	add hl,bc			;9049
	push hl			;904a
	ld bc,091d1h		;904b   ; se sale de la tabla?...
	or a			;904e
	sbc hl,bc		;904f
	pop hl			;9051
	jr c,pista_izquierda_sig		;9052
	ld hl,0919fh		;9054   ; ...vuelve a su principio
pista_izquierda_sig:		; La fila siguiente, una columna a la derecha
	pop de			;9057
	ex de,hl			;9058
	ld bc,00020h		;9059   ; la fila siguiente, 32 mas
	add hl,bc			;905c   ; la fila siguiente
	ex de,hl			;905d
	pop bc			;905e
	dec c			;905f   ; una casilla menos
	djnz pista_izquierda		;9060   ; diez filas
	ld a,(0e89ch)		;9062   ; las de la derecha (0x91D1), desde la fila 9, columna 15
	sub 009h		;9065
	neg		;9067
	ld c,a			;9069
	add a,a			;906a
	add a,a			;906b
	add a,c			;906c
	ld c,a			;906d
	ld b,000h		;906e
	ld hl,091d1h		;9070   ; la tabla de la derecha
	add hl,bc			;9073
	ld de,0192fh		;9074   ; fila 9, columna 15
	ld b,00ah		;9077
	ld c,005h		;9079
pista_derecha:		; Una fila de la derecha
	push bc			;907b
	push de			;907c
	ld a,005h		;907d   ; cinco casillas...
	bit 7,c		;907f
	jr z,L_9084		;9081   ; ...o menos, por la derecha
	add a,c			;9083
L_9084:
	ld c,a			;9084   ; cuantas
	ld b,000h		;9085
	push hl			;9087
	call 0005ch		;9088   ; LDIRVM
	pop hl			;908b
	ld bc,00005h		;908c   ; cinco mas en la tabla
	add hl,bc			;908f
	push hl			;9090
	ld bc,09203h		;9091   ; se sale de la tabla?
	or a			;9094
	sbc hl,bc		;9095
	pop hl			;9097
	jr c,pista_derecha_sig		;9098
	ld hl,091d1h		;909a   ; ...vuelve a su principio
pista_derecha_sig:		; La siguiente, una columna a la izquierda
	pop de			;909d
	ex de,hl			;909e
	ld bc,00021h		;909f   ; la fila siguiente, 33 mas
	add hl,bc			;90a2
	ex de,hl			;90a3
	pop bc			;90a4
	dec c			;90a5
	djnz pista_derecha		;90a6   ; diez filas
pista_curva:		; La curva, cada ocho cuadros: la columna de la pista va de 0 a 0x1E
	ld a,(0e881h)		;90a8
	inc a			;90ab   ; cada ocho cuadros...
	and 007h		;90ac
	ret nz			;90ae
	ld a,(0e8a7h)		;90af   ; la curva que viene
	ld b,a			;90b2
	and 07fh		;90b3   ; la cuenta...
	or a			;90b5   ; ...se ha acabado?
	ret z			;90b6
	bit 7,b		;90b7   ; a la derecha o a la izquierda?
	jp z,pista_curva_izq		;90b9
	ld a,b			;90bc   ; la cuenta...
	and 07fh		;90bd
	dec b			;90bf   ; una menos
	dec a			;90c0
	ld a,b			;90c1   ; ...el ultimo paso?
	jr nz,pista_curva_paso		;90c2
	call monte_borra		;90c4   ; el ultimo paso: el monte, recto
	ld hl,0e8a8h		;90c7   ; la curva cambia
	inc (hl)			;90ca   ; una curva mas a la derecha
	jr z,pista_curva_recta		;90cb   ; pasa por cero: recta
	ld hl,0919fh		;90cd   ; el monte de la curva a la derecha
	ld de,01903h		;90d0   ; fila 8, columna 3
	ld bc,00005h		;90d3
	call 0005ch		;90d6
	ld hl,091d1h		;90d9
	ld de,0190bh		;90dc   ; fila 8, columna 11
	ld bc,00005h		;90df
	call 0005ch		;90e2
	jr pista_curva_fin		;90e5
pista_curva_recta:		; Vuelve a recta
	call monte		;90e7
pista_curva_fin:		; La curva acabada
	xor a			;90ea
	ld (0e883h),a		;90eb   ; sin espera de curva
pista_curva_paso:		; Un paso: la columna una mas
	ld (0e8a7h),a		;90ee
	ld a,(0e8fdh)		;90f1   ; una columna mas...
	inc a			;90f4
	cp 01eh		;90f5   ; ...hasta 0x1E...
	jr c,pista_columna		;90f7
	xor a			;90f9   ; ...y vuelta a 0
	jr pista_columna		;90fa
pista_curva_izq:		; A la izquierda
	ld a,b			;90fc   ; el ultimo paso?
	dec a			;90fd   ; el ultimo paso?
	jr nz,pista_curva_izq_paso		;90fe
	call monte_borra		;9100   ; el monte, recto
	ld hl,0e8a8h		;9103   ; la curva cambia
	dec (hl)			;9106   ; una curva mas a la izquierda
	jr z,pista_curva_izq_recta		;9107
	ld hl,0919fh		;9109   ; el monte de la curva a la izquierda
	ld de,01908h		;910c   ; fila 8, columna 8
	ld bc,00005h		;910f
	call 0005ch		;9112
	ld hl,091d1h		;9115
	ld de,0190fh		;9118   ; fila 8, columna 15
	ld bc,00005h		;911b
	call 0005ch		;911e
	jr pista_curva_izq_fin		;9121
pista_curva_izq_recta:		; Vuelve a recta
	call monte		;9123
pista_curva_izq_fin:		; La curva acabada
	xor a			;9126
	ld (0e883h),a		;9127   ; sin espera de curva
pista_curva_izq_paso:		; Un paso: la columna una menos
	ld (0e8a7h),a		;912a
	ld a,(0e8fdh)		;912d   ; una columna menos...
	sub 001h		;9130   ; una columna menos
	jr nc,pista_columna		;9132
	ld a,01eh		;9134   ; ...de 0 a 0x1E
pista_columna:		; Guarda la columna
	ld (0e8fdh),a		;9136
pista_pinta:		; Las ocho filas de arriba de la pista (0xE000), desde la columna de la curva, a la tabla de nombres
	ld de,01800h		;9139   ; la tabla de nombres...
	ld hl,0e000h		;913c   ; desde 0xE000
	ld b,008h		;913f   ; ocho filas
L_9141:
	push bc			;9141
	ld a,(0e8fdh)		;9142   ; la columna de la pista...
	ld c,a			;9145
	ld b,000h		;9146
	push hl			;9148
	add hl,bc			;9149   ; la columna...
	sub 01fh		;914a   ; cuantas quedan hasta el final de la fila...
	neg		;914c
	ld c,a			;914e
	ld b,000h		;914f
	cp 019h		;9151   ; ...hasta 25 casillas
	jr c,L_9158		;9153
	ld bc,00019h		;9155   ; ...hasta 25
L_9158:
	push af			;9158
	call ldirvm		;9159   ; LDIRVM
	pop af			;915c
	pop hl			;915d
	cp 019h		;915e   ; y lo que queda, desde el principio de la fila
	jr nc,pista_pinta_sig		;9160
	sub 019h		;9162   ; lo que falta...
	neg		;9164
	ld c,a			;9166   ; ...desde el principio de la fila
	ld b,000h		;9167
	push hl			;9169
	call ldirvm		;916a
	pop hl			;916d
pista_pinta_sig:		; La fila siguiente
	ld bc,0001fh		;916e
	add hl,bc			;9171   ; la fila siguiente: 31 en la RAM...
	ex de,hl			;9172
	ld bc,00007h		;9173   ; ...y 32 en la tabla de nombres
	add hl,bc			;9176
	ex de,hl			;9177
	pop bc			;9178
	djnz L_9141		;9179
	ret			;917b
monte_borra:		; El monte del fondo: siete casillas vacias en la fila 8
	ld hl,01908h		;917c
	ld bc,00007h		;917f   ; siete casillas...
	ld a,002h		;9182   ; ...de la 2 (la pista lisa)
	jp 00056h		;9184
monte:		; El monte del fondo recto: cinco casillas de cada lado en la fila 8
	ld hl,0919fh		;9187   ; la izquierda del monte (0x919F)...
	ld de,01906h		;918a   ; ...en la fila 8, columna 6
	ld bc,00005h		;918d
	call 0005ch		;9190
	ld hl,091d1h		;9193   ; la derecha (0x91D1)...
	ld de,0190dh		;9196   ; ...en la columna 13
	ld bc,00005h		;9199
	jp 0005ch		;919c

; ----------------------------------------------------------------------
; DATOS rayas: Las rayas de la pista: la izquierda (0x919F) y la derecha
;   (0x91D1), diez filas de cinco casillas
;   0x919f..0x9203  (100 bytes)
DATA_rayas:
	defb 003h,003h,003h,004h,005h	; 919f
	defb 003h,003h,003h,003h,008h	; 91a4
	defb 003h,003h,003h,006h,007h	; 91a9
	defb 003h,003h,009h,00ah,00bh	; 91ae
	defb 003h,003h,00ch,00dh,00eh	; 91b3
	defb 003h,003h,003h,012h,013h	; 91b8
	defb 003h,003h,016h,017h,018h	; 91bd
	defb 003h,003h,019h,01ah,01bh	; 91c2
	defb 003h,003h,00fh,010h,011h	; 91c7
	defb 003h,003h,003h,014h,015h	; 91cc
	defb 029h,028h,027h,003h,003h	; 91d1
	defb 02dh,02ch,003h,003h,003h	; 91d6
	defb 026h,025h,024h,003h,003h	; 91db
	defb 02bh,02ah,003h,003h,003h	; 91e0
	defb 01dh,01ch,003h,003h,003h	; 91e5
	defb 020h,003h,003h,003h,003h	; 91ea
	defb 01dh,01ch,003h,003h,003h	; 91ef
	defb 020h,003h,003h,003h,003h	; 91f4
	defb 01fh,01eh,003h,003h,003h	; 91f9
	defb 023h,022h,021h,003h,003h	; 91fe

; ======================================================================
; CODIGO 0x9203..0x92d8  (213 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; Los objetos de la pista (0xE8B0): arboles, rocas, moguls y banderas que bajan con la pista y crecen al acercarse.
; ----------------------------------------------------------------------
objetos:		; Los diez objetos, cada tantos cuadros como diga la dificultad
	ld hl,0e901h		;9203
	ld a,(0e881h)		;9206   ; cada tantos cuadros...
	add a,003h		;9209
	and (hl)			;920b
	ret nz			;920c
	ld hl,0e8b0h		;920d   ; diez objetos
	ld b,00ah		;9210
objetos_uno:		; Uno
	call objeto		;9212
	djnz objetos_uno		;9215
	ret			;9217
objeto:		; Un objeto: lo borra, baja una fila y lo pinta con el dibujo de su tamano
	push bc			;9218
	push hl			;9219
	call lee4		;921a
	ld a,e			;921d   ; libre?
	or d			;921e
	jr z,objeto_libre		;921f
	ld a,b			;9221   ; si ya se ha pintado...
	and 00fh		;9222   ; ...en marcha
	call nz,objeto_borra		;9224   ; ...se borra
	ld hl,092d8h		;9227   ; la bajada por paso (0x92D8): bit 7 crece una talla
	push bc			;922a
	ld c,b			;922b   ; el paso
	ld b,000h		;922c
	add hl,bc			;922e
	pop bc			;922f
	ld a,(hl)			;9230   ; la bajada de este paso...
	push af			;9231
	push bc			;9232
	and 07fh		;9233   ; cuantas columnas se mueve...
	ld c,a			;9235
	ld b,000h		;9236   ; ...columnas...
	ex de,hl			;9238   ; ...a la direccion
	add hl,bc			;9239
	ex de,hl			;923a
	pop bc			;923b
	pop af			;923c
	add a,a			;923d   ; ...y el bit 7: una talla mas
	jr nc,objeto_paso		;923e
	inc c			;9240
objeto_paso:		; Un paso mas; cada 16, se acaba
	inc b			;9241
	ld a,b			;9242   ; el paso
	and 00fh		;9243
	jr nz,objeto_pinta		;9245
	push af			;9247
	ld a,c			;9248   ; cada 16, un tipo mas: el ultimo...
	cp 013h		;9249   ; el del enemigo especial...
	jr nz,objeto_fin		;924b
	xor a			;924d   ; ...deja sitio para otro
	ld (0e8d9h),a		;924e
objeto_fin:		; Se acaba
	ld de,00000h		;9251
	pop af			;9254
objeto_pinta:		; Pinta el objeto (si sigue) y lo guarda
	call nz,objeto_dibuja		;9255
	pop hl			;9258   ; la entrada...
	call guarda4		;9259   ; ...guardada
	pop bc			;925c
	ret			;925d
objeto_libre:		; Hueco libre: el siguiente
	pop hl			;925e
	pop bc			;925f
	ld de,00004h		;9260   ; la entrada siguiente
	add hl,de			;9263
	ret			;9264
objeto_borra:		; Borra un objeto de la tabla de nombres: su tamano (0x9368) en casillas 2 (pista lisa)
	push hl			;9265
	push de			;9266
	push bc			;9267
	push hl			;9268
	ld hl,09368h		;9269   ; el tamano de su talla...
	call tabla_par		;926c   ; (ancho en B, alto en C)
	pop hl			;926f
	ex de,hl			;9270
	ld a,002h		;9271   ; la casilla 2
L_9273:
	push bc			;9273   ; una fila
	push hl			;9274
L_9275:
	call en_pista		;9275   ; dentro de la pista?
	jr nc,L_927F		;9278
	ld a,002h		;927a   ; la casilla 2...
	call 0004dh		;927c   ; ...WRTVRM
L_927F:
	inc hl			;927f   ; la siguiente
	djnz L_9275		;9280
	pop hl			;9282
	ld bc,00020h		;9283   ; la fila siguiente
	add hl,bc			;9286
	pop bc			;9287
	dec c			;9288
	jr nz,L_9273		;9289
	pop bc			;928b
	pop de			;928c
	pop hl			;928d
	ret			;928e
objeto_dibuja:		; Dibuja un objeto: su tamano (0x9368) y sus casillas (0x9390)
	push hl			;928f
	push de			;9290
	push bc			;9291
	ld a,c			;9292   ; la talla...
	ex de,hl			;9293
	push hl			;9294
	push bc			;9295
	ld hl,09390h		;9296   ; ...su puntero de casillas
	add a,a			;9299
	ld c,a			;929a
	ld b,000h		;929b
	add hl,bc			;929d
	ld e,(hl)			;929e   ; su puntero de casillas, en DE
	inc hl			;929f
	ld d,(hl)			;92a0
	inc hl			;92a1
	pop bc			;92a2
	ld hl,09368h		;92a3   ; su tamano
	call tabla_par		;92a6
	pop hl			;92a9
L_92AA:
	push bc			;92aa   ; una fila
	push hl			;92ab
L_92AC:
	call en_pista		;92ac   ; dentro de la pista?
	jr nc,L_92B5		;92af
	ld a,(de)			;92b1   ; su casilla...
	call 0004dh		;92b2   ; WRTVRM
L_92B5:
	inc hl			;92b5   ; la siguiente
	inc de			;92b6   ; la casilla siguiente
	djnz L_92AC		;92b7
	pop hl			;92b9
	ld bc,00020h		;92ba   ; la fila siguiente
	add hl,bc			;92bd
	pop bc			;92be
	dec c			;92bf
	jr nz,L_92AA		;92c0
	pop bc			;92c2
	pop de			;92c3
	pop hl			;92c4
	ret			;92c5
en_pista:		; CY si HL esta dentro de la pista (columna < 25, fila < 0x1B00)
	ld a,l			;92c6   ; la columna...
	and 01fh		;92c7
	cp 019h		;92c9   ; ...menos de 25?
	ret nc			;92cb
	ld a,h			;92cc   ; la fila...
	cp 01bh		;92cd   ; ...antes de 0x1B00?
	ret			;92cf
tabla_par:		; BC = la palabra numero C de la tabla HL
	ld b,000h		;92d0
	add hl,bc			;92d2   ; la entrada C...
	add hl,bc			;92d3
	ld c,(hl)			;92d4   ; ...en BC
	inc hl			;92d5
	ld b,(hl)			;92d6
	ret			;92d7

; ----------------------------------------------------------------------
; DATOS objetos_pasos: La bajada de cada objeto por paso: 16 bytes por tipo
;   (columnas que se mueve; bit 7, una talla mas)
;   0x92d8..0x9368  (144 bytes)
DATA_objetos_pasos:
	defb 020h,0a0h,01fh,09eh,01fh,01fh,09fh,01fh,01fh,01fh,01fh,01fh,01fh,01fh,01fh,01fh	; 92d8   ...............
	defb 020h,0a0h,020h,09fh,020h,020h,0a0h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; 92e8   . .  .         
	defb 020h,0a0h,021h,0a0h,021h,021h,0a1h,021h,021h,021h,021h,021h,021h,021h,021h,021h	; 92f8   .!.!!.!!!!!!!!!
	defb 020h,09fh,01fh,09fh,01fh,01fh,09fh,01fh,01fh,01fh,01fh,01fh,01fh,01fh,01fh,01fh	; 9308   ...............
	defb 020h,09fh,020h,0a0h,020h,020h,0a0h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; 9318   . .  .         
	defb 020h,09fh,021h,0a1h,021h,021h,0a1h,021h,021h,021h,021h,021h,021h,021h,021h,021h	; 9328   .!.!!.!!!!!!!!!
	defb 020h,09fh,01fh,09fh,01fh,01fh,09eh,01fh,01fh,01fh,01fh,01fh,01fh,01fh,01fh,01fh	; 9338   ...............
	defb 020h,09fh,020h,0a0h,020h,020h,09fh,020h,020h,020h,020h,020h,020h,020h,020h,020h	; 9348   . .  .         
	defb 020h,09fh,021h,0a1h,021h,021h,0a0h,021h,021h,021h,021h,021h,021h,021h,021h,021h	; 9358   .!.!!.!!!!!!!!!

; ----------------------------------------------------------------------
; DATOS objetos_tamanos: El tamano de cada talla de objeto en casillas (ancho,
;   alto)
;   0x9368..0x9390  (40 bytes)
DATA_objetos_tamanos:
	defb 001h,001h	; 9368
	defb 001h,001h	; 936a
	defb 001h,003h	; 936c
	defb 002h,003h	; 936e
	defb 001h,001h	; 9370
	defb 002h,003h	; 9372
	defb 003h,003h	; 9374
	defb 004h,003h	; 9376
	defb 001h,001h	; 9378
	defb 001h,001h	; 937a
	defb 001h,003h	; 937c
	defb 002h,003h	; 937e
	defb 001h,002h	; 9380
	defb 002h,006h	; 9382
	defb 003h,006h	; 9384
	defb 004h,008h	; 9386
	defb 001h,001h	; 9388
	defb 001h,001h	; 938a
	defb 001h,003h	; 938c
	defb 002h,003h	; 938e

; ----------------------------------------------------------------------
; DATOS objetos_dibujos: Las casillas de cada objeto y talla: punteros
;   (0x9390) y las casillas, fila a fila
;   0x9390..0x9435  (165 bytes)
DATA_objetos_dibujos:
	defw 093b8h,093b9h,093bah,093bdh,093c3h,093c4h,093cah,093d3h,0941fh,09420h,09421h,09424h,093dfh,093e1h,093edh,093ffh,0942ah,0942bh,0942ch,0942fh	; 9390
	defb 080h,081h,082h,083h,084h,085h,086h,087h	; 93b8  ........
	defb 088h,089h,08ah,08bh,002h,08ch,002h,08dh	; 93c0  ........
	defb 08eh,08fh,090h,091h,092h,093h,094h,095h	; 93c8  ........
	defb 096h,097h,098h,099h,09ah,09bh,09ch,09dh	; 93d0  ........
	defb 09eh,09fh,0a0h,0a1h,0a2h,0a3h,0a4h,08bh	; 93d8  ........
	defb 08bh,002h,08ch,002h,002h,08ch,002h,08dh	; 93e0  ........
	defb 08eh,08fh,08dh,08eh,08fh,090h,091h,092h	; 93e8  ........
	defb 090h,091h,092h,093h,094h,095h,093h,094h	; 93f0  ........
	defb 095h,096h,097h,098h,096h,097h,098h,099h	; 93f8  ........
	defb 09ah,09bh,0bah,0bah,099h,09ah,09bh,09ch	; 9400  ........
	defb 09dh,09eh,002h,002h,09ch,09dh,09eh,09fh	; 9408  ........
	defb 0a0h,0a1h,002h,002h,09fh,0a0h,0a1h,0a2h	; 9410  ........
	defb 0a3h,0a4h,002h,002h,0a2h,0a3h,0a4h,0a5h	; 9418  ........
	defb 0a6h,0a7h,0a8h,0a9h,0aah,0a8h,0abh,0ach	; 9420  ........
	defb 0adh,0aeh,0afh,0b0h,0b1h,0b2h,0b3h,0b4h	; 9428  ........
	defb 0b5h,0b6h,0b7h,0b8h,0b9h	; 9430

; ======================================================================
; CODIGO 0x9435..0x949b  (102 bytes)
; ======================================================================


marcador:		; El marcador: el record, la vida extra, los puntos y el 1UP que parpadea
	ld hl,(0e906h)		;9435   ; el record...
	ld de,(0e90ah)		;9438
	or a			;943c
	sbc hl,de		;943d   ; ...menor que los puntos?
	jr nc,marcador_vida		;943f
	ex de,hl			;9441
	ld de,0270fh		;9442   ; no mas de 9999 (999.900)
	rst 20h			;9445
	jr c,L_944B		;9446
	ld hl,0270fh		;9448
L_944B:
	ld (0e906h),hl		;944b   ; el record nuevo...
	ld de,01899h		;944e   ; ...en la fila 4, columna 25
	call pinta_puntos		;9451
marcador_vida:		; Una vida extra cada 100 puntos (10.000)
	ld hl,(0e90ah)		;9454
	ld de,(0e908h)		;9457
	or a			;945b
	sbc hl,de		;945c
	jr c,marcador_puntos		;945e
	ld hl,0e90eh		;9460   ; una vida mas...
	inc (hl)			;9463
	ld hl,00064h		;9464   ; ...y la siguiente, 100 mas alla
	add hl,de			;9467
	ld (0e908h),hl		;9468
	call efecto_vida		;946b   ; su sonido
	call marcador_pinta		;946e
marcador_puntos:		; Los puntos en la fila 8, columna 25
	ld hl,(0e90ah)		;9471
	ld de,01919h		;9474
	call pinta_puntos		;9477
	ld a,(0e881h)		;947a   ; cada 16 cuadros...
	and 00fh		;947d
	ret nz			;947f
	ld hl,0e8f6h		;9480   ; ...el 1UP se enciende o se apaga
	ld a,(hl)			;9483
	cpl			;9484
	ld (hl),a			;9485
	ld hl,0949eh		;9486   ; "1UP"...
	ld de,018dbh		;9489   ; ...en la fila 6, columna 27...
	ld a,(0e8f6h)		;948c
	or a			;948f
	jr z,L_9495		;9490
	ld hl,0949bh		;9492   ; ...o tres espacios
L_9495:
	ld bc,00003h		;9495
	jp 0005ch		;9498

; ----------------------------------------------------------------------
; DATOS uno_up: "1UP" y tres espacios
;   0x949b..0x94a1  (6 bytes)
DATA_uno_up:
	defb 000h,000h,000h,031h,055h,050h	; 949b

; ======================================================================
; CODIGO 0x94a1..0x9507  (102 bytes)
; ======================================================================


recorrido:		; El recorrido del esquiador en el bonus (0x9507): de punto a punto, de dos en dos cuadros
	ld a,(0e881h)		;94a1
	rra			;94a4
	ret nc			;94a5
	ld hl,(0e88fh)		;94a6   ; el punto al que va
	ld a,(hl)			;94a9
	inc a			;94aa   ; 0xFF: el recorrido se acaba
	jr nz,recorrido_paso		;94ab
	dec a			;94ad
	ld (0e8f9h),a		;94ae
	ret			;94b1
recorrido_paso:		; Un paso (dy, dx); al llegar a su destino, el punto siguiente
	call lee4		;94b2
	ld hl,(0e88dh)		;94b5   ; la posicion...
	ld a,l			;94b8   ; ...mas el paso
	add a,e			;94b9
	ld l,a			;94ba
	ld a,h			;94bb
	add a,d			;94bc
	ld h,a			;94bd
	push hl			;94be   ; ha llegado?
	or a			;94bf
	sbc hl,bc		;94c0
	pop hl			;94c2
	jr nz,recorrido_pinta		;94c3
	ld hl,(0e88fh)		;94c5   ; el punto siguiente
	call lee4		;94c8
	inc hl			;94cb
	ld (0e88fh),hl		;94cc
	push bc			;94cf
	pop hl			;94d0
recorrido_pinta:		; Los tres sprites del esquiador, con el dibujo del punto
	ld (0e88dh),hl		;94d1   ; la posicion nueva
	ld hl,(0e88fh)		;94d4   ; el dibujo del punto...
	call lee4		;94d7
	ld a,(hl)			;94da
	ld hl,(0e88dh)		;94db   ; la posicion
	ld de,0e800h		;94de
	ex de,hl			;94e1
	ld b,003h		;94e2   ; tres sprites
L_94E4:
	ld (hl),e			;94e4   ; la Y...
	inc hl			;94e5   ; Y
	ld (hl),d			;94e6   ; ...la X...
	inc hl			;94e7   ; X
	ld (hl),a			;94e8   ; ...y el dibujo...
	inc hl			;94e9   ; el sprite siguiente
	inc hl			;94ea
	add a,004h		;94eb   ; ...el siguiente, cuatro mas
	djnz L_94E4		;94ed   ; tres sprites
	ld a,e			;94ef   ; por debajo de 0x48...
	cp 048h		;94f0   ; ...por debajo de 0x48?
	ret c			;94f2
	push hl			;94f3   ; en 0x48...
	push de			;94f4
	call z,efecto_golpe		;94f5   ; ...en 0x48 justo, un sonido...
	pop de			;94f8
	pop hl			;94f9
	ld a,0f0h		;94fa   ; ...y por debajo, un sprite mas 16 puntos por encima...
	add a,e			;94fc
	ld (hl),a			;94fd
	inc hl			;94fe
	ld (hl),d			;94ff   ; ...en la X...
	inc hl			;9500
	ld (hl),060h		;9501   ; ...dibujo 0x60...
	inc hl			;9503
	ld (hl),00eh		;9504   ; ...color 0x0E
	ret			;9506

; ----------------------------------------------------------------------
; DATOS recorrido_bonus: El recorrido del bonus: puntos de 7 bytes (dy, dx,
;   destino Y X, dibujo); 0xFF acaba
;   0x9507..0x9535  (46 bytes)
DATA_recorrido_bonus:
	defb 001h,005h,038h,0a0h,000h,000h,004h	; 9507
	defb 038h,0b8h,00ch,0fch,002h,028h,0c0h	; 950e
	defb 030h,0feh,000h,020h,0c0h,030h,0fch	; 9515
	defb 0feh,010h,0b8h,03ch,0feh,0fch,008h	; 951c
	defb 0a8h,048h,000h,0fch,008h,098h,048h	; 9523
	defb 004h,0fch,018h,088h,054h,002h,000h	; 952a
	defb 0d0h,088h,018h,0ffh	; 9531

; ======================================================================
; CODIGO 0x9535..0x95aa  (117 bytes)
; ======================================================================


bonus_disparo:		; El disparo del bonus: sube con su paso; si da en una diana (casilla 0x86), sus puntos
	ld a,(0e810h)		;9535
	cp 0c0h		;9538   ; no hay disparo? (entonces, el boton: 0x95B6)
	jr z,$+124		;953a
	ld de,(0e891h)		;953c   ; su paso...
	ld hl,(0e810h)		;9540   ; ...mas la posicion
	ld a,d			;9543   ; la X...
	add a,h			;9544   ; ...mas el paso
	ld h,a			;9545
	ld a,e			;9546   ; la Y...
	add a,l			;9547   ; ...mas el paso
	ld l,a			;9548
	ld a,l			;9549   ; se sale por abajo o por la derecha?
	cp 0b0h		;954a
	jr nc,bonus_disparo_fuera		;954c
	ld a,h			;954e   ; por la derecha?
	cp 0c0h		;954f
	jr nc,bonus_disparo_fuera		;9551
	ld (0e810h),hl		;9553   ; se guarda...
	call casilla_xy		;9556   ; la casilla de debajo
	cp 086h		;9559   ; una diana?
	ret nz			;955b
	ld hl,(0e810h)		;955c   ; la diana de arriba: 30 puntos...
	ld a,l			;955f   ; la Y
	push hl			;9560
	ld hl,0e8ach		;9561   ; las tres dianas: la de arriba
	ld de,0001eh		;9564   ; 30 puntos
	ld ix,01951h		;9567   ; su cartel, en la fila 10
	ld bc,00000h		;956b   ; la primera
	cp 064h		;956e   ; por debajo de 0x64?
	jr c,bonus_diana		;9570
	inc hl			;9572   ; ...la del medio, 20...
	ld de,00014h		;9573   ; ...20 puntos...
	ld ix,019b1h		;9576   ; en la fila 13
	inc bc			;957a   ; ...fila 13
	cp 07ch		;957b   ; por debajo de 0x7C?
	jr c,bonus_diana		;957d
	inc hl			;957f   ; ...la de abajo, 10
	ld de,0000ah		;9580   ; ...10 puntos...
	ld ix,01a11h		;9583   ; en la fila 16
	inc bc			;9587   ; ...fila 16
bonus_diana:		; La diana tocada empieza a girar y da sus puntos
	ld (hl),a			;9588   ; la diana empieza a girar
	ld hl,(0e90ah)		;9589   ; los puntos
	add hl,de			;958c   ; mas los puntos
	ld (0e90ah),hl		;958d
	push ix		;9590   ; el cartel a su fila
	pop de			;9592
	ld hl,095aah		;9593   ; su cartel de puntos (0x95AA) en la tabla de nombres
	add hl,bc			;9596   ; ...4 bytes cada uno
	add hl,bc			;9597
	add hl,bc			;9598
	add hl,bc			;9599
	ld bc,00004h		;959a
	call 0005ch		;959d   ; LDIRVM
	call efecto_diana		;95a0   ; su sonido
	pop hl			;95a3
bonus_disparo_fuera:		; El disparo, fuera
	ld l,0c0h		;95a4
	ld (0e810h),hl		;95a6
	ret			;95a9

; ----------------------------------------------------------------------
; DATOS bonus_puntos: Los carteles de las tres dianas: 3000, 2000 y 1000 en
;   casillas
;   0x95aa..0x95b6  (12 bytes)
DATA_bonus_puntos:
	defb 033h,030h,030h,030h	; 95aa
	defb 032h,030h,030h,030h	; 95ae
	defb 031h,030h,030h,030h	; 95b2

; ======================================================================
; CODIGO 0x95b6..0x95e0  (42 bytes)
; ======================================================================


bonus_dispara:		; El boton dispara en el bonus: desde el esquiador, con el paso de su dibujo (0x95DE)
	call boton_disparo		;95b6
	call boton_nuevo		;95b9
	ld a,(0e800h)		;95bc   ; el esquiador...
	cp 0b0h		;95bf
	ret nc			;95c1
	ld hl,(0e800h)		;95c2
	ld (0e810h),hl		;95c5   ; ...es de donde sale el disparo
	ld a,(0e802h)		;95c8   ; su dibujo...
	ld c,00ch		;95cb
	add a,c			;95cd
	ld hl,095deh		;95ce   ; ...busca su paso
bonus_dispara_busca:		; Busca el paso del dibujo
	inc hl			;95d1
	inc hl			;95d2
	sub c			;95d3
	jr nz,bonus_dispara_busca		;95d4
	ld e,(hl)			;95d6   ; el paso
	inc hl			;95d7
	ld d,(hl)			;95d8
	ld (0e891h),de		;95d9
	jp efecto_disparo		;95dd   ; y el sonido del disparo

; ----------------------------------------------------------------------
; DATOS bonus_pasos: El paso del disparo (dy, dx) por cada dibujo del
;   esquiador
;   0x95e0..0x95f4  (20 bytes)
DATA_bonus_pasos:
	defb 000h,005h	; 95e0
	defb 0fbh,005h	; 95e2
	defb 000h,0fbh	; 95e4
	defb 000h,0fbh	; 95e6
	defb 0fbh,000h	; 95e8
	defb 0fbh,0fbh	; 95ea
	defb 000h,0fbh	; 95ec
	defb 005h,0fbh	; 95ee
	defb 005h,000h	; 95f0
	defb 005h,005h	; 95f2

; ======================================================================
; CODIGO 0x95f4..0x9632  (62 bytes)
; ======================================================================


bonus_dianas:		; Las dianas tocadas giran: tres dibujos, cada cuatro cuadros
	ld a,(0e881h)		;95f4
	and 003h		;95f7   ; uno de cada cuatro cuadros
	ret nz			;95f9
	ld ix,0e814h		;95fa   ; los sprites de las dianas
	ld hl,0e8ach		;95fe
	ld b,003h		;9601
bonus_diana_gira:		; Una diana
	ld a,(hl)			;9603   ; tocada?
	or a			;9604
	jr z,bonus_diana_sig		;9605
	inc a			;9607   ; el dibujo siguiente...
	and 003h		;9608
	jr nz,bonus_diana_dibujo		;960a
	ld a,001h		;960c   ; ...del 1 al 3
bonus_diana_dibujo:		; Su dibujo (0x9632) en sus dos sprites
	ld (hl),a			;960e
	push hl			;960f
	push bc			;9610
	ld hl,09632h		;9611   ; el dibujo de la tabla...
	ld c,a			;9614
	ld b,000h		;9615
	add hl,bc			;9617
	ld a,(hl)			;9618
	ld (ix+002h),a		;9619   ; ...en sus dos sprites
	ld (ix+003h),006h		;961c   ; (color 6)
	ld (ix+006h),a		;9620
	ld (ix+007h),006h		;9623
	pop bc			;9627
	pop hl			;9628
bonus_diana_sig:		; La siguiente
	ld de,00008h		;9629   ; la siguiente
	add ix,de		;962c
	inc hl			;962e
	djnz bonus_diana_gira		;962f
	ret			;9631

; ----------------------------------------------------------------------
; DATOS dianas_dibujos: Los tres dibujos de la diana que gira
;   0x9632..0x9635  (3 bytes)
DATA_dianas_dibujos:
	defb 0bch,0b8h,0b4h	; 9632

; ======================================================================
; CODIGO 0x9635..0x9997  (866 bytes)
; ======================================================================


sprites_girados:		; Copia BC bytes de sprites (HL) a la VRAM (DE) y otra vez girados de lado, detras
	push hl			;9635
	push bc			;9636
	call ldirvm		;9637   ; tal cual
	pop bc			;963a
	pop hl			;963b
	push hl			;963c
	push bc			;963d
	push de			;963e
	srl b		;963f   ; BC / 32: cuantos sprites
	rr c		;9641
	srl b		;9643
	rr c		;9645
	srl b		;9647
	rr c		;9649
	srl b		;964b
	rr c		;964d
	srl b		;964f
	rr c		;9651
	ld de,0e000h		;9653   ; en 0xE000
sprites_girados_uno:		; Un sprite: sus cuatro cuartos girados (0x96DA)
	push bc			;9656
	ld bc,00010h		;9657   ; el cuarto de arriba a la derecha...
	add hl,bc			;965a   ; el cuarto de abajo
	call gira		;965b   ; ...girado...
	ld bc,00020h		;965e   ; ...el de arriba a la izquierda...
	xor a			;9661
	sbc hl,bc		;9662   ; 16 atras
	ld c,010h		;9664   ; ...16 bytes...
	call gira		;9666   ; ...girados
	ld bc,00010h		;9669   ; la mitad de abajo
	add hl,bc			;966c
	pop bc			;966d
	dec bc			;966e   ; el siguiente
	ld a,b			;966f
	or c			;9670
	jr nz,sprites_girados_uno		;9671
	pop de			;9673
	pop bc			;9674
	ld hl,0e000h		;9675   ; todos, de 0xE000 a la VRAM
	call ldirvm		;9678
	pop hl			;967b   ; HL como estaba
	ret			;967c
sprites_espejo:		; Copia BC bytes a 0xE400 y los deja en 0xE000 dados la vuelta (0x96A4)
	push hl			;967d
	push de			;967e
	push bc			;967f
	ld de,0e400h		;9680   ; a 0xE400
	ldir		;9683   ; LDIR
	ld hl,0e400h		;9685   ; la mitad izquierda...
	ld de,0e000h		;9688
	call espejo_mitad		;968b   ; la mitad izquierda
	ld hl,0e420h		;968e   ; ...y la derecha
	ld de,0e020h		;9691
	call espejo_mitad		;9694   ; la mitad derecha
	pop bc			;9697
	pop de			;9698
	pop hl			;9699
	ld hl,0e000h		;969a   ; los sprites a la VRAM
	call ldirvm		;969d
	ld hl,0e000h		;96a0
	ret			;96a3   ; en HL
espejo_mitad:		; Tres veces: los cuartos de 8x8 en su sitio, girados (0x96C7)
	ld b,003h		;96a4
espejo_cuarto:		; Los cuatro cuartos de un sprite
	push bc			;96a6
	ld bc,00010h		;96a7   ; el cuarto siguiente...
	add hl,bc			;96aa
	call espejo_casilla		;96ab   ; ...girado
	ld bc,0fff0h		;96ae
	add hl,bc			;96b1
	call espejo_casilla		;96b2
	ld bc,00018h		;96b5
	add hl,bc			;96b8
	call espejo_casilla		;96b9
	ld bc,0fff0h		;96bc
	add hl,bc			;96bf
	call espejo_casilla		;96c0
	pop bc			;96c3
	djnz espejo_cuarto		;96c4
	ret			;96c6
espejo_casilla:		; Una casilla de 8x8 girada: las columnas pasan a filas
	ld c,008h		;96c7
espejo_fila:		; Una fila de la casilla nueva
	push hl			;96c9
	xor a			;96ca   ; A, la fila nueva
	ld b,008h		;96cb
espejo_bit:		; Un bit de cada fila vieja
	rrc (hl)		;96cd   ; el bit de la derecha de la fila vieja...
	inc hl			;96cf
	adc a,a			;96d0   ; ...a la nueva
	djnz espejo_bit		;96d1
	pop hl			;96d3
	ld (de),a			;96d4   ; la fila nueva
	inc de			;96d5
	dec c			;96d6
	jr nz,espejo_fila		;96d7
	ret			;96d9
gira:		; Gira C casillas de 8x8 (DE a HL): cada byte nuevo es una columna de la vieja
	ex de,hl			;96da
gira_fila:		; Una fila
	ld b,008h		;96db
	ld a,(de)			;96dd   ; un byte viejo...
gira_bit:		; Un bit
	rrca			;96de   ; ...bit a bit...
	rl (hl)		;96df   ; ...a ocho bytes nuevos
	djnz gira_bit		;96e1
	inc hl			;96e3
	inc de			;96e4
	dec c			;96e5
	jr nz,gira_fila		;96e6
	ex de,hl			;96e8
	ret			;96e9
lee4:		; E, D, C, B de (HL), HL cuatro mas alla
	ld e,(hl)			;96ea   ; E...
	inc hl			;96eb
	ld d,(hl)			;96ec   ; ...D...
	inc hl			;96ed
	ld c,(hl)			;96ee   ; ...C...
	inc hl			;96ef
	ld b,(hl)			;96f0   ; ...B
	inc hl			;96f1
	ret			;96f2
guarda4_88d:		; E, D, C, B en la entrada 0xE88D
	ld hl,(0e88dh)		;96f3
guarda4:		; E, D, C, B en (HL)
	ld (hl),e			;96f6   ; E...
	inc hl			;96f7
	ld (hl),d			;96f8   ; ...D...
	inc hl			;96f9
	ld (hl),c			;96fa   ; ...C...
	inc hl			;96fb
	ld (hl),b			;96fc   ; ...B
	inc hl			;96fd
	ret			;96fe
casilla_fila:		; La casilla de HL (RDVRM) menos 2 (0 = pista); por debajo de la fila 24 o en una bandera, 0
	push de			;96ff
	push hl			;9700
	ld de,01b00h		;9701   ; por debajo de la fila 24...
	or a			;9704
	sbc hl,de		;9705
	pop hl			;9707
	pop de			;9708
	jr nc,casilla_cero		;9709
	call 0004ah		;970b   ; RDVRM
	cp 0bah		;970e   ; 0xBA, el arbol del enemigo especial: 0
	jr z,casilla_cero		;9710
	sub 002h		;9712   ; 0, 1 y 2 son la pista
	ret			;9714
casilla_cero:		; Nada
	xor a			;9715
	ret			;9716
casilla_xy:		; La casilla (RDVRM) debajo de la Y, X de HL
	call xy_nombres		;9717
	jp 0004ah		;971a
xy_nombres:		; De Y, X en pantalla (H, L) a su direccion en la tabla de nombres (0x1800 + Y/8*32 + X/8)
	ld a,h			;971d   ; Y en L, X en H
	ld h,l			;971e
	ld l,a			;971f
	srl h		;9720   ; Y / 8...
	srl h		;9722
	srl h		;9724
	srl h		;9726
	rr l		;9728   ; ...por 32...
	srl h		;972a
	rr l		;972c
	srl h		;972e   ; ...mas X / 8
	rr l		;9730
	push de			;9732
	ld de,01800h		;9733   ; en la tabla de nombres
	add hl,de			;9736
	pop de			;9737
	ret			;9738
pinta_ronda:		; La ronda (o un 1 en la demo), tres cifras, en DE
	call demo		;9739   ; la demo?
	jr nz,pinta_ronda_demo		;973c
	ld a,(0e90ch)		;973e   ; la ronda
	jr pinta_ronda_cifras		;9741
pinta_ronda_demo:		; La demo: ronda 1
	ld a,001h		;9743
pinta_ronda_cifras:		; Las cifras
	ld l,a			;9745
	ld h,000h		;9746
	call cifras		;9748
	ld bc,00003h		;974b   ; tres cifras
	ld hl,0e896h		;974e
	jp 0005ch		;9751
pinta_puntos:		; HL x 100 en seis cifras, en DE
	call cifras		;9754
	ld bc,00006h		;9757   ; seis cifras
	ld hl,0e895h		;975a
	jp 0005ch		;975d
cifras:		; HL en cinco cifras ASCII en 0xE894, y tres ceros detras
	push bc			;9760
	push de			;9761
	ld de,0e894h		;9762   ; en 0xE894
	ld a,030h		;9765   ; la cifra de las decenas de millar...
	ld bc,02710h		;9767
cifras_10000:		; Las decenas de millar
	inc a			;976a   ; ...resta 10.000 mientras se pueda
	or a			;976b
	sbc hl,bc		;976c
	jr nc,cifras_10000		;976e
	dec a			;9770   ; se ha pasado uno
	add hl,bc			;9771   ; lo devuelve
	ld (de),a			;9772
	inc de			;9773
	ld a,030h		;9774
	ld bc,003e8h		;9776   ; los millares...
cifras_1000:		; Los millares
	inc a			;9779   ; ...resta 1.000 mientras se pueda
	or a			;977a
	sbc hl,bc		;977b
	jr nc,cifras_1000		;977d
	dec a			;977f
	add hl,bc			;9780
	ld (de),a			;9781
	inc de			;9782
	ld a,030h		;9783
	ld bc,00064h		;9785   ; las centenas...
cifras_100:		; Las centenas
	inc a			;9788   ; ...resta 100 mientras se pueda
	or a			;9789
	sbc hl,bc		;978a
	jr nc,cifras_100		;978c
	dec a			;978e
	add hl,bc			;978f
	ld (de),a			;9790
	inc de			;9791
	ld a,030h		;9792
	ld bc,0000ah		;9794   ; las decenas...
cifras_10:		; Las decenas
	inc a			;9797   ; las decenas de millar...
	or a			;9798
	sbc hl,bc		;9799
	jr nc,cifras_10		;979b
	dec a			;979d
	add hl,bc			;979e
	ld (de),a			;979f
	inc de			;97a0   ; la siguiente
	ld a,030h		;97a1   ; las unidades
	add a,l			;97a3
	ld (de),a			;97a4
	inc de			;97a5   ; la siguiente
	ld a,030h		;97a6   ; y tres ceros
	ld (de),a			;97a8
	inc de			;97a9   ; la siguiente
	ld a,030h		;97aa
	ld (de),a			;97ac
	inc de			;97ad
	ld (de),a			;97ae
	pop de			;97af
	pop bc			;97b0
	ret			;97b1
tramo:		; Cada 256 cuadros: los dibujos de la nieve del tramo
	ld a,(0e881h)		;97b2   ; en cuanto se pasa de 256 cuadros
	or a			;97b5
	ret nz			;97b6
tramo_dibujos:		; La nieve de cada tramo (0xE882): del 0 al 3, del 4 al 7, del 8 al 11 y del 12 en adelante
	ld a,(0e882h)		;97b7
	ld hl,0af35h		;97ba   ; del 0 al 3: 0xAF35...
	ld de,0ffe1h		;97bd
	ld bc,0b424h		;97c0   ; sus dibujos
	ld ix,0e000h		;97c3   ; sus nombres en 0xE000
	cp 004h		;97c7   ; el tramo...
	jr c,tramo_pinta		;97c9   ; ...del 0 al 3?
	ld hl,0b02dh		;97cb   ; del 4 al 7: 0xB02D...
	ld ix,0e0bah		;97ce   ; en 0xE0BA
	ld bc,0b39ch		;97d2
	cp 008h		;97d5   ; del 4 al 7?
	jr c,tramo_pinta		;97d7
	ld hl,0b06bh		;97d9   ; del 8 al 11: 0xB06B...
	add ix,de		;97dc   ; IX una fila antes
	ld bc,0b2bch		;97de
	cp 00ch		;97e1   ; del 8 al 11?
	jr c,tramo_pinta		;97e3
	ld hl,0b0c8h		;97e5   ; del 12 en adelante: 0xB0C8
	add ix,de		;97e8   ; IX una fila antes
	ld bc,0b144h		;97ea
tramo_pinta:		; Los nombres de las ocho filas de arriba en 0xE000, los dibujos y los colores de la nieve
	push bc			;97ed   ; los dibujos de la nieve
	push hl			;97ee   ; los nombres de este tramo
	ld hl,0af35h		;97ef   ; la pista, sin curva (0xAF35)...
	ld de,0e000h		;97f2   ; a 0xE000...
	ld bc,000f8h		;97f5   ; ...0xF8 bytes
	ldir		;97f8
	pop hl			;97fa   ; ...y encima, la del tramo
	push ix		;97fb   ; encima, en IX...
	pop de			;97fd
	ld bc,000f8h		;97fe   ; ...0xF8 bytes de los del tramo
	ldir		;9801
	pop hl			;9803
	push hl			;9804
	ld de,00480h		;9805   ; 0x1E0 bytes desde la casilla 0x90
	ld bc,001e0h		;9808   ; 0x1E0 bytes
	call 0005ch		;980b
	pop hl			;980e
	ld de,00318h		;980f   ; los colores, 0x318 bytes despues
	add hl,de			;9812
	ld de,02480h		;9813   ; a 0x2480
	ld bc,001e0h		;9816
	call 0005ch		;9819
	jp pista_pinta		;981c   ; y la pista entera a la tabla de nombres
irq_solo_musica_pon:		; La interrupcion de siempre (0x85A8): solo la musica
	ld hl,085a8h		;981f
	ld (0fda0h),hl		;9822   ; 0xFDA0 = 0x85A8
	ld a,0c3h		;9825   ; el "jp" del gancho H.TIMI
	ld (0fd9fh),a		;9827
musica_suena:		; NZ si el primer canal aun suena
	ld a,(0f004h)		;982a   ; el primer canal suena?
	or a			;982d
	ret			;982e
nombres_borra:		; La tabla de nombres a cero, y los sprites fuera
	ld hl,01800h		;982f
	ld bc,00300h		;9832   ; 0x300 bytes de la tabla de nombres...
	xor a			;9835   ; ...a cero
	call 00056h		;9836
sprites_fuera:		; Los 32 sprites fuera de la pantalla (Y 0xC0), en la RAM y en la VRAM
	ld hl,0e800h		;9839   ; 0x80 bytes de la tabla de sprites...
	ld de,0e801h		;983c
	ld bc,00080h		;983f
	ld (hl),0c0h		;9842   ; ...a 0xC0
	ldir		;9844
	ld hl,01b00h		;9846   ; y lo mismo en la VRAM
	ld bc,00080h		;9849
	ld a,0c0h		;984c
	jp 00056h		;984e
sprites_carga:		; Los dibujos de los sprites: los del esquiador (0xA1CD) y girados, y el resto (0xA34D)
	ld hl,0a1cdh		;9851
	ld de,03800h		;9854   ; a 0x3800...
	ld bc,000c0h		;9857
	call ldirvm		;985a   ; ...tal cual...
	ld bc,000c0h		;985d
	call sprites_girados		;9860   ; ...y girados
	ld hl,0a34dh		;9863   ; el resto de los sprites (0xA34D)...
	ld de,03a40h		;9866   ; ...desde 0x3A40
	ld bc,005c0h		;9869
	call 0005ch		;986c
	ld hl,00020h		;986f   ; las casillas 4 a 11, vacias
	ld bc,00040h		;9872   ; las casillas 4 a 11: 64 bytes...
	xor a			;9875   ; ...a cero
	jp 00056h		;9876
ram_borra:		; La RAM de la partida (0xE000-0xE903) a cero, las diez cuentas a 0xFF y lo que cae, fuera
	ld hl,0e000h		;9879   ; 0xE000-0xE903...
	ld de,0e001h		;987c
	ld bc,00903h		;987f
	ld (hl),l			;9882   ; ...a cero
	ldir		;9883
	ld (0e8f9h),bc		;9885   ; tampoco ronda acabada ni choque
	ld hl,0e883h		;9889   ; las diez cuentas...
	ld de,0e884h		;988c
	ld bc,0000ah		;988f
	ld (hl),0ffh		;9892   ; ...a 0xFF
	ldir		;9894
	ld a,0c0h		;9896   ; lo que cae, fuera
	ld (0e860h),a		;9898
demo:		; NZ en la demo
	ld a,(0e914h)		;989b   ; 0xE914...
	or a			;989e   ; ...distinto de 0
	ret			;989f
aparato_sprites_fuera:		; Los sprites del aparato (0xE814), fuera
	push hl			;98a0
	push de			;98a1
	push bc			;98a2
	ld hl,0e814h		;98a3   ; los seis sprites del aparato...
	ld de,0e815h		;98a6
	ld bc,00018h		;98a9
	ld (hl),0c0h		;98ac   ; ...a 0xC0
	ldir		;98ae
	pop bc			;98b0
	pop de			;98b1
	pop hl			;98b2
	ret			;98b3
boton_disparo:		; Vuelve al de arriba si no esta el boton 1
	ld a,(0e89eh)		;98b4   ; el boton 1...
	bit 0,a		;98b7
	ret nz			;98b9
	pop bc			;98ba   ; no: fuera tambien del que llama
	xor a			;98bb
boton_suelto:		; El boton suelto
	ld (0e89fh),a		;98bc
	ret			;98bf
boton_nuevo:		; Vuelve al de arriba si el boton ya estaba pulsado
	ld a,(0e89fh)		;98c0   ; ya estaba pulsado?
	or a			;98c3
	jr z,boton_marca		;98c4
	pop bc			;98c6   ; si: fuera tambien del que llama
	ret			;98c7
boton_marca:		; Lo marca pulsado
	inc a			;98c8
	jr boton_suelto		;98c9
ronda1_juega:		; Z en la ronda 1 jugando (no en la demo ni despues de ella)
	ld a,(0e90ch)		;98cb   ; la ronda menos uno...
	dec a			;98ce
	ld b,a			;98cf
	ld a,(0e90dh)		;98d0   ; ...y si se ha pasado de la demo
	or b			;98d3
	ret			;98d4
tercio_copia:		; Copia los dibujos y los colores del primer tercio a los otros dos (LDIRMV y LDIRVM)
	ld hl,00000h		;98d5   ; los dibujos del primer tercio...
	ld de,0e000h		;98d8
	ld bc,00800h		;98db
	call 00059h		;98de   ; ...LDIRMV a 0xE000...
	ld hl,0e000h		;98e1
	ld de,00800h		;98e4   ; ...al segundo y al tercero
	ld bc,00800h		;98e7
	push hl			;98ea
	call ldirvm		;98eb
	pop hl			;98ee
	call ldirvm		;98ef
	ld hl,02000h		;98f2   ; los colores del primer tercio...
	ld de,0e000h		;98f5
	ld bc,00800h		;98f8
	call 00059h		;98fb   ; ...LDIRMV...
	ld hl,0e000h		;98fe
	ld de,02800h		;9901   ; ...al segundo y al tercero
	ld bc,00800h		;9904
	push hl			;9907
	call ldirvm		;9908
	pop hl			;990b
ldirvm:		; LDIRVM y DE, HL avanzan BC
	push hl			;990c
	push de			;990d
	push bc			;990e
	call 0005ch		;990f   ; LDIRVM
	pop bc			;9912
	pop de			;9913
	pop hl			;9914
	ex de,hl			;9915   ; DE + BC...
	add hl,bc			;9916
	ex de,hl			;9917
	add hl,bc			;9918   ; ...HL + BC
	ret			;9919
marcador_pinta:		; El marcador entero: HIGH SCORE, 1UP, ROUND, los puntos y las vidas
	ld hl,09997h		;991a   ; HIGH (0x9997)...
	ld de,0183ah		;991d   ; fila 1, columna 26
	ld bc,00004h		;9920   ; 4 letras
	call ldirvm		;9923
	ld de,0185ah		;9926   ; ...SCORE...
	ld bc,00005h		;9929   ; 5 letras
	call ldirvm		;992c
	ld de,018dbh		;992f   ; ...1UP...
	ld bc,00003h		;9932   ; 3 letras
	call ldirvm		;9935
	ld de,01a9ah		;9938   ; ...ROUND
	ld bc,00005h		;993b   ; 5 letras
	call ldirvm		;993e
	ld hl,(0e906h)		;9941   ; el record
	ld de,01899h		;9944   ; fila 4, columna 25
	call pinta_puntos		;9947
	ld hl,(0e90ah)		;994a   ; los puntos
	ld de,01919h		;994d   ; fila 8, columna 25
	call pinta_puntos		;9950
	ld a,(0e90eh)		;9953   ; las vidas de reserva...
	or a			;9956   ; sin vidas de reserva?
	jr z,marcador_ronda		;9957
	dec a			;9959   ; la que juega no cuenta
	push af			;995a
	jr z,marcador_ronda		;995b
	cp 006h		;995d   ; hasta cinco...
	jr c,marcador_vidas1		;995f
	ld a,005h		;9961   ; ...en la primera fila
marcador_vidas1:		; Hasta cinco en la fila 13...
	ld hl,019bah		;9963   ; fila 13, columna 26
	call vidas		;9966
	pop af			;9969   ; las que pasan de cinco...
	sub 005h		;996a
	jr c,marcador_ronda		;996c
	jr z,marcador_ronda		;996e
	cp 006h		;9970   ; ...hasta cinco...
	jr c,marcador_vidas2		;9972
	ld a,005h		;9974
marcador_vidas2:		; ...y otras cinco en la 16
	ld hl,01a1ah		;9976   ; ...en la fila 16
	call vidas		;9979
marcador_ronda:		; Y la ronda
	ld de,01adbh		;997c   ; fila 22, columna 27: la ronda
	jp pinta_ronda		;997f
vidas:		; A esquiadores (casillas 0x3E y 0x3F, una encima de otra)
	ld c,a			;9982
	ld b,000h		;9983
	ld a,03eh		;9985   ; la cabeza (0x3E)...
	push hl			;9987
	push bc			;9988
	call 00056h		;9989
	pop bc			;998c
	pop hl			;998d
	ld de,00020h		;998e   ; ...y debajo...
	add hl,de			;9991
	ld a,03fh		;9992   ; ...los esquis (0x3F)
	jp 00056h		;9994

; ----------------------------------------------------------------------
; DATOS marcador_textos: HIGH, SCORE, 1UP y ROUND para el marcador
;   0x9997..0x99a8  (17 bytes)
DATA_marcador_textos:
	defb 048h,049h,047h,048h,053h,043h,030h,052h,045h,031h,055h,050h,052h,030h,055h,04eh	; 9997  HIGHSC0RE1UPR0UN
	defb 044h	; 99a7

; ======================================================================
; CODIGO 0x99a8..0x99c7  (31 bytes)
; ======================================================================


absoluto:		; El valor absoluto de A
	cp 080h		;99a8   ; negativo?
	ret c			;99aa
	neg		;99ab   ; lo cambia de signo
	ret			;99ad
azar:		; Un numero al azar: el de antes rotado mas el registro R
	push bc			;99ae
	ld a,(0e8a9h)		;99af   ; el azar de antes...
	rrca			;99b2   ; ...rotado...
	ld b,a			;99b3
	ld a,r		;99b4   ; ...mas el registro R...
	rrca			;99b6   ; ...rotado
	add a,b			;99b7
	ld (0e8a9h),a		;99b8
	pop bc			;99bb
	ret			;99bc
azar20:		; Al azar de 0 a 19
	call azar		;99bd
	and 01fh		;99c0   ; de 0 a 31...
	cp 014h		;99c2   ; ...mientras no sea menor de 20
	jr nc,azar20		;99c4
	ret			;99c6

; ----------------------------------------------------------------------
; DATOS bonus_casillas: Las 110 casillas del bonus (8 bytes cada una), a
;   partir de la 0x80
;   0x99c7..0x9d37  (880 bytes)
DATA_bonus_casillas:
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 99c7  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 99cf  ........
	defb 000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 99d7  ........
	defb 000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 99df  ........
	defb 000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh	; 99e7  ........
	defb 000h,000h,000h,000h,000h,000h,0ffh,09ah	; 99ef  ........
	defb 000h,000h,000h,000h,000h,000h,0c0h,0c0h	; 99f7  ........
	defb 0ffh,000h,000h,000h,000h,000h,000h,000h	; 99ff  ........
	defb 0c0h,000h,000h,000h,000h,000h,000h,000h	; 9a07  ........
	defb 0ffh,0ffh,0ffh,0ffh,0c0h,0c0h,0c0h,0c0h	; 9a0f  ........
	defb 0ffh,0ffh,0ffh,000h,000h,000h,000h,000h	; 9a17  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h	; 9a1f  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,080h,080h,080h	; 9a27  ........
	defb 080h,080h,080h,080h,080h,080h,080h,080h	; 9a2f  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh	; 9a37  ........
	defb 001h,001h,001h,001h,001h,001h,007h,01ch	; 9a3f  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0feh	; 9a47  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; 9a4f  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0fch,0fch	; 9a57  ........
	defb 0fch,0f1h,0c7h,01fh,07fh,0ffh,0ffh,0ffh	; 9a5f  ........
	defb 0fdh,0fdh,0fdh,0fdh,0fdh,0fdh,0fdh,0fdh	; 9a67  ........
	defb 0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch	; 9a6f  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f3h	; 9a77  ........
	defb 0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9a7f  ........
	defb 07fh,03fh,09fh,0cfh,0e7h,0f3h,0f9h,0fch	; 9a87  .?......
	defb 0f9h,0fch,0feh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9a8f  ........
	defb 0ffh,0ffh,07fh,03fh,01fh,0cfh,0e7h,0f3h	; 9a97  ...?....
	defb 0f8h,0fch,0feh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9a9f  ........
	defb 0ffh,07fh,03fh,01fh,08fh,0c7h,0e3h,0f1h	; 9aa7  ..?.....
	defb 0ffh,0ffh,0ffh,000h,000h,000h,000h,000h	; 9aaf  ........
	defb 0ffh,0ffh,0ffh,0ffh,00fh,001h,000h,000h	; 9ab7  ........
	defb 0f8h,0fch,0ffh,0ffh,0ffh,0ffh,000h,000h	; 9abf  ........
	defb 03fh,0ffh,0ffh,0ffh,0ffh,0ffh,000h,000h	; 9ac7  ?.......
	defb 0ffh,0ffh,0ffh,0ffh,0f8h,0f8h,008h,008h	; 9acf  ........
	defb 0f3h,0ffh,0feh,0feh,002h,002h,002h,002h	; 9ad7  ........
	defb 008h,008h,008h,008h,008h,008h,008h,008h	; 9adf  ........
	defb 008h,008h,010h,010h,010h,010h,010h,010h	; 9ae7  ........
	defb 004h,004h,004h,004h,004h,004h,000h,000h	; 9aef  ........
	defb 010h,010h,010h,000h,000h,000h,000h,000h	; 9af7  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9aff  ........
	defb 07fh,03fh,01fh,00fh,0ffh,0ffh,0ffh,0ffh	; 9b07  .?......
	defb 0feh,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9b0f  ........
	defb 002h,002h,002h,002h,002h,002h,002h,002h	; 9b17  ........
	defb 0ffh,0ffh,0ffh,0ffh,0fch,0c0h,0e0h,000h	; 9b1f  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f0h,000h	; 9b27  ........
	defb 0ffh,0ffh,0ffh,0ffh,0f0h,000h,000h,000h	; 9b2f  ........
	defb 0f0h,0e0h,0c0h,000h,000h,000h,000h,000h	; 9b37  ........
	defb 0ffh,0ffh,0fch,0f8h,0f0h,0e0h,0c0h,080h	; 9b3f  ........
	defb 0f0h,000h,000h,000h,000h,000h,000h,000h	; 9b47  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; 9b4f  ........
	defb 000h,080h,080h,0c0h,0c0h,0c0h,0c0h,0c0h	; 9b57  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h	; 9b5f  ........
	defb 080h,080h,080h,080h,080h,080h,080h,080h	; 9b67  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,000h	; 9b6f  ........
	defb 0dfh,0dfh,0dfh,0dfh,0dfh,0dfh,0dfh,000h	; 9b77  ........
	defb 0fdh,0fdh,0fdh,0fdh,0fdh,0fdh,0fdh,000h	; 9b7f  ........
	defb 0fbh,0fbh,0fbh,0fbh,0fbh,0fbh,0fbh,000h	; 9b87  ........
	defb 000h,000h,000h,000h,0ffh,0ffh,0e0h,000h	; 9b8f  ........
	defb 000h,000h,000h,000h,0fch,0fch,0f0h,0f0h	; 9b97  ........
	defb 00fh,0feh,0fch,0f8h,0f0h,0e0h,020h,024h	; 9b9f  ...... $
	defb 0ffh,0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h	; 9ba7  ........
	defb 080h,0c0h,0e0h,0f0h,0f8h,0fch,0feh,0ffh	; 9baf  ........
	defb 000h,000h,000h,000h,000h,0ffh,0c0h,0ffh	; 9bb7  ........
	defb 0ffh,0ffh,000h,000h,000h,000h,000h,000h	; 9bbf  ........
	defb 0aah,055h,0b6h,0b6h,0aah,0ffh,0ffh,0deh	; 9bc7  .U......
	defb 0aah,055h,0dbh,0dbh,0aah,0dfh,0dfh,0dbh	; 9bcf  .U......
	defb 0aah,055h,06dh,06dh,0aah,0fdh,0fdh,0edh	; 9bd7  .Umm....
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0fbh,0fbh,06bh	; 9bdf  .......k
	defb 0aah,055h,06dh,06dh,0aah,06dh,06dh,0aah	; 9be7  .Umm.mm.
	defb 0aah,055h,0b6h,0b6h,0aah,0b6h,0b6h,0aah	; 9bef  .U......
	defb 0aah,055h,0dbh,0dbh,0aah,0dbh,0dbh,0aah	; 9bf7  .U......
	defb 080h,080h,080h,080h,080h,000h,000h,000h	; 9bff  ........
	defb 080h,0c0h,0e0h,0f0h,0f8h,0fch,0feh,0ffh	; 9c07  ........
	defb 000h,000h,000h,000h,001h,003h,00fh,01fh	; 9c0f  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9c17  ........
	defb 000h,000h,003h,007h,01fh,03fh,0ffh,0ffh	; 9c1f  .....?..
	defb 07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9c27  ........
	defb 000h,000h,000h,000h,000h,000h,007h,00fh	; 9c2f  ........
	defb 000h,000h,000h,000h,001h,003h,0ffh,0ffh	; 9c37  ........
	defb 007h,00fh,03fh,07fh,0ffh,0ffh,0ffh,0ffh	; 9c3f  ..?.....
	defb 000h,000h,001h,003h,00fh,01fh,07fh,0ffh	; 9c47  ........
	defb 0c0h,080h,000h,000h,000h,000h,000h,000h	; 9c4f  ........
	defb 000h,000h,000h,000h,000h,00fh,03fh,0ffh	; 9c57  ......?.
	defb 000h,000h,000h,000h,000h,000h,0c0h,0f0h	; 9c5f  ........
	defb 000h,000h,000h,000h,000h,000h,003h,00fh	; 9c67  ........
	defb 000h,000h,003h,00fh,03fh,0ffh,0ffh,0ffh	; 9c6f  ....?...
	defb 03ch,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9c77  <.......
	defb 000h,000h,0c0h,0f0h,0fch,0ffh,0ffh,0ffh	; 9c7f  ........
	defb 000h,000h,001h,003h,00fh,01fh,0ffh,0ffh	; 9c87  ........
	defb 03fh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9c8f  ?.......
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f8h,0f0h	; 9c97  ........
	defb 0fch,0f8h,0e0h,0c0h,000h,000h,000h,000h	; 9c9f  ........
	defb 0ffh,0ffh,0feh,0fch,0f0h,0e0h,080h,000h	; 9ca7  ........
	defb 0c0h,080h,000h,000h,000h,000h,000h,000h	; 9caf  ........
	defb 000h,000h,000h,000h,003h,00fh,03fh,0ffh	; 9cb7  ......?.
	defb 000h,00fh,03fh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9cbf  ..?.....
	defb 000h,000h,0c0h,0f0h,0ffh,0ffh,0ffh,0ffh	; 9cc7  ........
	defb 003h,00fh,03fh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9ccf  ..?.....
	defb 0fch,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9cd7  ........
	defb 03fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9cdf  ?.......
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9ce7  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0fdh,0f8h,0f0h	; 9cef  ........
	defb 0ffh,0efh,0ffh,07fh,0ffh,0ffh,0ffh,0ffh	; 9cf7  ........
	defb 003h,00fh,03fh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9cff  ..?.....
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d07  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d0f  ........
	defb 0ffh,0ffh,0fch,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d17  ........
	defb 0ffh,0c0h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d1f  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d27  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9d2f  ........

; ----------------------------------------------------------------------
; DATOS bonus_colores: Los colores de las casillas del bonus, desde la 0xB9
;   (la copia sigue 0x518 bytes, hasta 0xA24F)
;   0x9d37..0x9edf  (424 bytes)
DATA_bonus_colores:
	defb 055h,055h,055h,055h,0ffh,0ffh,0feh,0feh	; 9d37  UUUU....
	defb 055h,055h,055h,055h,0f5h,0f5h,0e5h,0e5h	; 9d3f  UUUU....
	defb 0efh,0e4h,0e4h,0e4h,0e4h,0e4h,04ah,04ah	; 9d47  ......JJ
	defb 0eah,0eah,0eah,0eah,0eah,0eah,0eah,0e4h	; 9d4f  ........
	defb 0fah,0fah,0fah,0fah,0fah,0fah,0fah,0fah	; 9d57  ........
	defb 055h,055h,055h,055h,055h,0ddh,0dfh,0ddh	; 9d5f  UUUUU...
	defb 0ddh,0ddh,055h,055h,055h,055h,055h,055h	; 9d67  ..UUUUUU
	defb 054h,054h,05ah,05ah,054h,0a4h,0a4h,0a4h	; 9d6f  TTZZT...
	defb 054h,054h,05ah,05ah,054h,0a4h,0a4h,0a4h	; 9d77  TTZZT...
	defb 054h,054h,05ah,05ah,054h,0a4h,0a4h,0a4h	; 9d7f  TTZZT...
	defb 055h,055h,055h,055h,055h,0a4h,0a4h,0a4h	; 9d87  UUUUU...
	defb 098h,098h,092h,092h,022h,092h,092h,098h	; 9d8f  ...."...
	defb 098h,098h,092h,092h,022h,092h,092h,098h	; 9d97  ...."...
	defb 098h,098h,092h,092h,022h,092h,092h,098h	; 9d9f  ...."...
	defb 095h,095h,095h,095h,025h,055h,055h,055h	; 9da7  ....%UUU
	defb 0f9h,0f9h,0f9h,0f9h,0f2h,0f9h,0f9h,0f9h	; 9daf  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9db7  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9dbf  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9dc7  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9dcf  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9dd7  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9ddf  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9de7  ........
	defb 0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h	; 9def  ........
	defb 07fh,07fh,07fh,07fh,07fh,07fh,07fh,07fh	; 9df7  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9dff  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9e07  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9e0f  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9e17  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9e1f  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9e27  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9e2f  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9e37  ........
	defb 07fh,07fh,07fh,07fh,07fh,07fh,07fh,07fh	; 9e3f  ........
	defb 07fh,07fh,07fh,07fh,07fh,07fh,07fh,07fh	; 9e47  ........
	defb 07fh,07fh,07fh,07fh,07fh,07fh,07fh,07fh	; 9e4f  ........
	defb 07fh,07fh,07fh,07fh,07fh,07fh,07fh,07fh	; 9e57  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9e5f  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9e67  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9e6f  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; 9e77  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f7h	; 9e7f  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f7h	; 9e87  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,077h,077h	; 9e8f  ......ww
	defb 0f7h,0f7h,0f7h,0f7h,0f7h,0f1h,07fh,07fh	; 9e97  ........
	defb 0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h	; 9e9f  ........
	defb 0f5h,0f5h,0f5h,0f5h,077h,077h,077h,077h	; 9ea7  ....wwww
	defb 0f5h,0f5h,0f5h,0f5h,077h,077h,077h,077h	; 9eaf  ....wwww
	defb 0f5h,0f5h,0f5h,077h,077h,077h,077h,077h	; 9eb7  ...wwwww
	defb 0ffh,0ffh,0f7h,077h,077h,077h,077h,077h	; 9ebf  ...wwwww
	defb 0ffh,0f7h,077h,077h,077h,077h,077h,077h	; 9ec7  ..wwwwww
	defb 0ffh,077h,077h,077h,077h,077h,077h,077h	; 9ecf  .wwwwwww
	defb 077h,077h,077h,077h,077h,077h,077h,077h	; 9ed7  wwwwwwww

; ----------------------------------------------------------------------
; DATOS bonus_campo: El campo del bonus en la tabla de nombres: 13 filas de
;   10, cinco de 25 y las tres dianas (tres filas de 5)
;   0x9edf..0x9fed  (270 bytes)
DATA_bonus_campo:
	defb 081h,081h,082h,082h,083h,083h,084h,084h,0b9h,0bah	; 9edf  ..........
	defb 081h,081h,081h,089h,08ah,08bh,0a7h,0a7h,0a7h,0b1h	; 9ee9  ..........
	defb 081h,081h,081h,08ch,0a7h,08dh,0a7h,0ach,0adh,0aeh	; 9ef3  ..........
	defb 081h,081h,08eh,08dh,08fh,0afh,0b0h,080h,080h,080h	; 9efd  ..........
	defb 081h,090h,091h,0a7h,0bbh,0c2h,0c3h,0beh,085h,086h	; 9f07  ..........
	defb 081h,092h,093h,0bch,0b6h,0b7h,0b8h,0bfh,087h,088h	; 9f11  ..........
	defb 081h,094h,081h,0c4h,0c5h,0c6h,0c7h,080h,080h,080h	; 9f1b  ..........
	defb 081h,081h,081h,0c0h,0c1h,0c2h,0c3h,0beh,085h,086h	; 9f25  ..........
	defb 081h,094h,081h,0b5h,0b6h,0b7h,0b8h,0bfh,087h,088h	; 9f2f  ..........
	defb 081h,094h,081h,0c4h,0c5h,0c6h,0c7h,080h,080h,080h	; 9f39  ..........
	defb 081h,095h,081h,0c0h,0c1h,0c2h,0c3h,0beh,085h,086h	; 9f43  ..........
	defb 096h,097h,098h,0bdh,0b6h,0b7h,0b8h,0bfh,087h,088h	; 9f4d  ..........
	defb 099h,09ah,097h,098h,0c8h,0c6h,0c7h,080h,080h,080h	; 9f57  ..........
	defb 081h,09bh,09ch,0a9h,0a8h,081h,0abh,0b2h,080h,080h	; 9f61  ..........
	defb 080h,080h,080h,0d2h,0d3h,0d4h,0d5h,0d6h,0d7h,0d8h	; 9f6b  ..........
	defb 0d9h,081h,081h,081h,081h,09dh,09eh,09fh,0a0h,0a1h	; 9f75  ..........
	defb 0a2h,0a7h,0a7h,080h,0deh,0dfh,0e0h,0e1h,081h,0e2h	; 9f7f  ..........
	defb 0e3h,0e4h,0e5h,0e6h,081h,081h,081h,081h,081h,081h	; 9f89  ..........
	defb 0a7h,0a7h,0a7h,0a7h,0a3h,0aah,0a7h,0a7h,0e7h,0e8h	; 9f93  ..........
	defb 0e9h,0eah,0ebh,0ech,0edh,0edh,0d0h,0d1h,081h,081h	; 9f9d  ..........
	defb 081h,081h,081h,081h,081h,0a7h,0a7h,0a7h,0a7h,0a4h	; 9fa7  ..........
	defb 0a5h,0a7h,0a7h,0edh,0edh,0edh,0edh,0edh,0edh,0dah	; 9fb1  ..........
	defb 0dbh,081h,081h,081h,081h,081h,081h,081h,081h,081h	; 9fbb  ..........
	defb 0a7h,0a7h,0a7h,0a7h,0a6h,0a7h,0a7h,0a7h,0edh,0edh	; 9fc5  ..........
	defb 0edh,0edh,0edh,0dch,0ddh,081h,081h,081h,081h,081h	; 9fcf  ..........
	defb 081h,081h,081h,081h,081h,080h,080h,080h,080h,0c9h	; 9fd9  ..........
	defb 080h,080h,0cah,0cbh,0cch,0cdh,0ceh,0cfh,081h,081h	; 9fe3  ..........

; ----------------------------------------------------------------------
; DATOS pista_casillas: Las 28 casillas de la pista (0x00-0x1B): la lisa, la
;   nieve de los bordes y las rayas; desde 0xA00D, 18 de ellas se cargan
;   tambien de lado para el suelo (0xE0-0xF1)
;   0x9fed..0xa0cd  (224 bytes)
DATA_pista_casillas:
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9fed  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9ff5  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9ffd  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a005  ........
	defb 0ffh,0ffh,0ffh,0ffh,0fch,003h,000h,0ffh	; a00d  ........
	defb 0e0h,0f8h,0feh,0ffh,000h,0ffh,000h,0c0h	; a015  ........
	defb 0ffh,0ffh,0fch,0feh,0ffh,0ffh,0ffh,01fh	; a01d  ........
	defb 0f0h,0fch,0feh,0ffh,000h,0c0h,0e0h,0f0h	; a025  ........
	defb 0fch,0feh,0ffh,0ffh,07fh,0c0h,0e0h,0f0h	; a02d  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,03fh	; a035  .......?
	defb 0ffh,001h,000h,0ffh,0ffh,0e0h,01fh,0fch	; a03d  ........
	defb 0f0h,0f0h,0f0h,0c0h,0e0h,0e0h,0e0h,000h	; a045  ........
	defb 0c0h,01fh,00fh,0fch,0ffh,0ffh,00fh,007h	; a04d  ........
	defb 0e0h,0e0h,000h,000h,000h,03fh,03fh,0c0h	; a055  .....??.
	defb 0f0h,000h,000h,000h,000h,000h,000h,000h	; a05d  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f8h,0fch	; a065  ........
	defb 0ffh,00fh,00fh,0f8h,0fch,0feh,0ffh,0ffh	; a06d  ........
	defb 0f0h,0f0h,000h,000h,000h,000h,000h,000h	; a075  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,001h,0ffh,0ffh	; a07d  ........
	defb 0fch,0feh,0ffh,07fh,0c0h,0e0h,0f0h,0c0h	; a085  ........
	defb 0ffh,0ffh,003h,0ffh,0ffh,0ffh,03fh,00fh	; a08d  ......?.
	defb 0f0h,0fch,0ffh,0feh,0c0h,0f0h,0f0h,0f0h	; a095  ........
	defb 0ffh,0ffh,0ffh,0ffh,0feh,0feh,0c0h,0e0h	; a09d  ........
	defb 0ffh,0ffh,0ffh,00fh,0f0h,0f0h,000h,000h	; a0a5  ........
	defb 0f0h,0fch,0fch,0fch,000h,000h,000h,000h	; a0ad  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,000h,0c0h	; a0b5  ........
	defb 0fch,0ffh,0ffh,0ffh,0ffh,0f8h,0fch,0feh	; a0bd  ........
	defb 000h,080h,0f0h,0fch,0ffh,0ffh,0ffh,000h	; a0c5  ........

; ----------------------------------------------------------------------
; DATOS marcador_casillas: Las 32 casillas del marcador y del monte (desde la
;   0x80 del segundo tercio)
;   0xa0cd..0xa1cd  (256 bytes)
DATA_marcador_casillas:
	defb 080h,0feh,0feh,0ffh,0ffh,0ffh,0ffh,0ffh	; a0cd  ........
	defb 000h,000h,000h,000h,0e0h,0f0h,0f8h,0feh	; a0d5  ........
	defb 000h,080h,0e0h,0fch,0ffh,0ffh,0ffh,0ffh	; a0dd  ........
	defb 000h,000h,000h,000h,088h,0fch,0feh,0ffh	; a0e5  ........
	defb 000h,0c0h,0e0h,0e0h,0f2h,0ffh,0ffh,0ffh	; a0ed  ........
	defb 000h,000h,000h,000h,000h,000h,0b0h,0fch	; a0f5  ........
	defb 000h,0c0h,0f0h,0feh,0ffh,0ffh,0ffh,0ffh	; a0fd  ........
	defb 000h,000h,000h,000h,0c0h,0f8h,0feh,0feh	; a105  ........
	defb 000h,006h,00fh,01fh,01fh,03fh,07fh,0ffh	; a10d  .....?..
	defb 003h,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a115  ........
	defb 000h,000h,000h,001h,01fh,01fh,03fh,07fh	; a11d  ......?.
	defb 001h,003h,0c7h,0ffh,0ffh,0ffh,0ffh,0ffh	; a125  ........
	defb 000h,000h,000h,000h,000h,000h,007h,03fh	; a12d  .......?
	defb 000h,001h,003h,007h,00fh,07fh,0ffh,0ffh	; a135  ........
	defb 000h,000h,000h,000h,000h,001h,01fh,07fh	; a13d  ........
	defb 001h,007h,037h,07fh,0ffh,0ffh,0ffh,0ffh	; a145  ..7.....
	defb 000h,000h,000h,000h,000h,000h,003h,01fh	; a14d  ........
	defb 000h,003h,007h,00fh,03fh,07fh,0ffh,0ffh	; a155  ....?...
	defb 000h,000h,080h,0c0h,0e0h,0f8h,0fch,0ffh	; a15d  ........
	defb 000h,000h,000h,000h,000h,030h,0fch,0ffh	; a165  .....0..
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a16d  ........
	defb 0ffh,07fh,0fbh,067h,0c1h,000h,000h,000h	; a175  ...g....
	defb 0ffh,0efh,0beh,024h,000h,000h,000h,000h	; a17d  ...$....
	defb 07fh,0fbh,0beh,058h,000h,000h,080h,040h	; a185  ...X...@
	defb 0ffh,0fdh,07fh,00fh,002h,000h,001h,000h	; a18d  ........
	defb 000h,080h,0e0h,0fch,0ffh,0ffh,0ffh,0ffh	; a195  ........
	defb 000h,000h,000h,000h,088h,0fch,0feh,0ffh	; a19d  ........
	defb 000h,000h,000h,000h,000h,000h,007h,03fh	; a1a5  .......?
	defb 000h,001h,003h,007h,00fh,07fh,0ffh,0ffh	; a1ad  ........
	defb 080h,0c0h,0e0h,0d8h,05ch,00ch,007h,003h	; a1b5  ....\...
	defb 000h,000h,003h,007h,007h,01eh,073h,010h	; a1bd  ......s.
	defb 00fh,03fh,0fbh,0dfh,000h,001h,000h,000h	; a1c5  .?......

; ----------------------------------------------------------------------
; DATOS sprites_esquiador: Los 12 sprites del esquiador (0x3800), que se
;   cargan tambien de lado
;   0xa1cd..0xa34d  (384 bytes)
DATA_A1CD:
	defb 003h,007h,007h,007h,03fh,07fh,07fh,0ffh	; a1cd  ....?...
	defb 0ffh,0ffh,0efh,07fh,03fh,000h,000h,000h	; a1d5  ....?...
	defb 000h,080h,080h,080h,0f0h,0f8h,0fch,0feh	; a1dd  ........
	defb 0feh,0e7h,0cfh,0e4h,0f0h,000h,000h,000h	; a1e5  ........
	defb 000h,000h,000h,01fh,01fh,03fh,03ch,03ch	; a1ed  .....?<<
	defb 038h,078h,070h,070h,070h,060h,060h,000h	; a1f5  8xppp``.
	defb 030h,018h,00ch,0ech,0e0h,0f0h,0f0h,0f0h	; a1fd  0.......
	defb 070h,078h,038h,038h,038h,018h,018h,000h	; a205  px888...
	defb 000h,000h,000h,000h,01ch,000h,000h,004h	; a20d  ........
	defb 00ch,008h,038h,070h,070h,0e0h,0e0h,0e0h	; a215  ..8pp...
	defb 000h,000h,000h,000h,038h,000h,000h,020h	; a21d  ....8.. 
	defb 030h,010h,01ch,00eh,00eh,007h,007h,007h	; a225  0.......
	defb 000h,000h,000h,03fh,07fh,07fh,07fh,060h	; a22d  ...?...`
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a235  ........
	defb 030h,018h,00ch,0fch,0f8h,0f8h,0f8h,018h	; a23d  0.......
	defb 018h,000h,000h,000h,000h,000h,000h,000h	; a245  ........
	defb 000h,000h,007h,00fh,00fh,00fh,00fh,00eh	; a24d  ........
	defb 007h,007h,007h,007h,007h,007h,003h,003h	; a255  ........
	defb 008h,00ch,0ech,0f4h,0f0h,0f0h,0f0h,070h	; a25d  .......p
	defb 070h,070h,070h,070h,070h,070h,060h,060h	; a265  pppppp``
	defb 000h,000h,000h,000h,000h,000h,008h,008h	; a26d  ........
	defb 00eh,00eh,01eh,01eh,01ch,01ch,01ch,01ch	; a275  ........
	defb 000h,000h,000h,000h,000h,000h,010h,010h	; a27d  ........
	defb 070h,070h,078h,078h,038h,038h,038h,038h	; a285  ppxx8888
	defb 00ch,01eh,01eh,01eh,03fh,07fh,0ffh,0ffh	; a28d  ....?...
	defb 0ffh,07fh,03fh,01fh,00fh,000h,000h,000h	; a295  ..?.....
	defb 000h,000h,000h,000h,0c0h,0e0h,0f0h,0f8h	; a29d  ........
	defb 0dch,08ch,0e0h,0f0h,0f0h,000h,000h,000h	; a2a5  ........
	defb 000h,000h,000h,000h,007h,00fh,00fh,01eh	; a2ad  ........
	defb 01eh,01ch,01ch,01ch,01ch,00eh,006h,003h	; a2b5  ........
	defb 070h,018h,00ch,000h,0f0h,0f8h,0f8h,078h	; a2bd  p......x
	defb 078h,038h,038h,01ch,00eh,006h,007h,003h	; a2c5  x88.....
	defb 000h,000h,000h,000h,0e1h,000h,000h,000h	; a2cd  ........
	defb 0c0h,060h,038h,01ch,01ch,00eh,00eh,007h	; a2d5  .`8.....
	defb 000h,000h,000h,000h,0c0h,000h,080h,0c0h	; a2dd  ........
	defb 040h,060h,038h,01ch,01ch,00eh,007h,003h	; a2e5  @`8.....
	defb 000h,000h,000h,000h,01fh,03fh,07fh,07fh	; a2ed  .....?..
	defb 038h,038h,01ch,00ch,006h,000h,000h,000h	; a2f5  88......
	defb 070h,018h,00ch,000h,0f8h,0f8h,0f8h,070h	; a2fd  p......p
	defb 038h,01ch,00ch,00eh,006h,000h,000h,000h	; a305  8.......
	defb 000h,000h,000h,000h,00fh,00fh,00fh,007h	; a30d  ........
	defb 007h,003h,003h,003h,001h,001h,000h,000h	; a315  ........
	defb 070h,018h,00eh,000h,0f8h,0f8h,0f8h,0b8h	; a31d  p.......
	defb 0b8h,0b8h,0b8h,09ch,09ch,0dch,0cch,0cch	; a325  ........
	defb 0c6h,0e2h,063h,073h,031h,011h,01ch,00eh	; a32d  ..cs1...
	defb 007h,007h,003h,001h,001h,000h,000h,000h	; a335  ........
	defb 000h,000h,000h,000h,000h,0c0h,0e0h,070h	; a33d  .......p
	defb 070h,038h,01ch,01ch,00eh,000h,000h,000h	; a345  p8......

; ----------------------------------------------------------------------
; DATOS sprites: Los 46 sprites de los enemigos, el aparato, lo que cae, el
;   disparo y la explosion (desde 0x3A40)
;   0xa34d..0xa90d  (1472 bytes)
DATA_sprites:
	defb 007h,01fh,03fh,07fh,03fh,01fh,007h,000h	; a34d  ..?.?...
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a355  ........
	defb 0e0h,0f8h,0fch,0feh,0fch,0f8h,0e0h,000h	; a35d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a365  ........
	defb 003h,00fh,01fh,00fh,003h,000h,000h,000h	; a36d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a375  ........
	defb 0c0h,0f0h,0f8h,0f0h,0c0h,000h,000h,000h	; a37d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a385  ........
	defb 001h,003h,001h,000h,000h,000h,000h,000h	; a38d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a395  ........
	defb 0c0h,0e0h,0c0h,000h,000h,000h,000h,000h	; a39d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a3a5  ........
	defb 040h,040h,0e0h,0e0h,0e0h,000h,0e0h,000h	; a3ad  @@......
	defb 040h,000h,000h,000h,000h,000h,000h,000h	; a3b5  @.......
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a3bd  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a3c5  ........
	defb 040h,0e0h,0e0h,000h,040h,000h,000h,000h	; a3cd  @...@...
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a3d5  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a3dd  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a3e5  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a3ed  ........
	defb 000h,000h,000h,000h,000h,000h,001h,001h	; a3f5  ........
	defb 000h,000h,001h,002h,006h,004h,008h,008h	; a3fd  ........
	defb 011h,013h,017h,03fh,077h,0d7h,057h,057h	; a405  ...?w.WW
	defb 03fh,0e0h,080h,000h,000h,000h,000h,07fh	; a40d  ?.......
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a415  ........
	defb 0fch,007h,001h,000h,000h,000h,000h,0feh	; a41d  ........
	defb 0ffh,0fdh,0feh,0ffh,0ffh,0ffh,0ffh,0ffh	; a425  ........
	defb 000h,000h,080h,040h,060h,020h,010h,010h	; a42d  ...@` ..
	defb 088h,0c8h,0e8h,0fch,0eeh,0ebh,0eah,0eah	; a435  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a43d  ........
	defb 000h,000h,000h,000h,000h,000h,080h,080h	; a445  ........
	defb 001h,001h,001h,000h,000h,0f0h,0f0h,0f8h	; a44d  ........
	defb 07ch,01fh,007h,001h,000h,000h,000h,000h	; a455  |.......
	defb 057h,057h,07fh,0ffh,07fh,04fh,0c7h,082h	; a45d  WW...O..
	defb 082h,086h,0c4h,0f4h,07ch,01fh,000h,000h	; a465  ....|...
	defb 0ffh,0ffh,0e0h,01fh,0ffh,0ffh,0ffh,0ffh	; a46d  ........
	defb 007h,003h,03fh,001h,000h,000h,000h,000h	; a475  ..?.....
	defb 0ffh,0ffh,007h,0f8h,0ffh,0ffh,0ffh,0ffh	; a47d  ........
	defb 0e0h,0c0h,0fch,080h,080h,080h,080h,080h	; a485  ........
	defb 0eah,0eah,0feh,0ffh,0feh,0f2h,0e3h,041h	; a48d  .......A
	defb 041h,061h,023h,02fh,03eh,0f8h,000h,000h	; a495  Aa#/>...
	defb 080h,080h,080h,000h,000h,00fh,00fh,01fh	; a49d  ........
	defb 03eh,0f8h,0e0h,080h,000h,000h,000h,000h	; a4a5  >.......
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a4ad  ........
	defb 001h,001h,002h,002h,007h,00eh,00ah,00ah	; a4b5  ........
	defb 000h,000h,000h,001h,007h,03fh,040h,080h	; a4bd  .....?@.
	defb 000h,000h,000h,07fh,0ffh,0ffh,0ffh,0ffh	; a4c5  ........
	defb 000h,000h,080h,080h,0e0h,0fch,002h,001h	; a4cd  ........
	defb 000h,000h,000h,0feh,0ffh,0efh,0f7h,0ffh	; a4d5  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a4dd  ........
	defb 080h,080h,040h,040h,0e0h,070h,050h,050h	; a4e5  ..@@.pPP
	defb 00ah,00ah,00fh,007h,001h,039h,01dh,00fh	; a4ed  .....9..
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a4f5  ........
	defb 0ffh,0ffh,0ffh,0c0h,0ffh,000h,000h,0e0h	; a4fd  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a505  ........
	defb 0ffh,0ffh,0ffh,003h,0ffh,000h,000h,007h	; a50d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a515  ........
	defb 050h,050h,0f0h,0c0h,080h,09ch,0b8h,0f0h	; a51d  PP......
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a525  ........
	defb 000h,000h,000h,000h,003h,00fh,010h,020h	; a52d  ....... 
	defb 020h,07fh,05fh,05fh,07fh,01fh,0d0h,07ch	; a535   .__...|
	defb 000h,000h,000h,080h,080h,0f0h,008h,004h	; a53d  ........
	defb 004h,0feh,0fah,0fah,0feh,0f8h,00bh,03eh	; a545  .......>
	defb 000h,000h,000h,000h,000h,000h,000h,001h	; a54d  ........
	defb 003h,003h,001h,000h,000h,000h,000h,000h	; a555  ........
	defb 000h,000h,000h,000h,000h,000h,000h,080h	; a55d  ........
	defb 0c0h,0c0h,080h,000h,000h,000h,000h,000h	; a565  ........
	defb 001h,003h,003h,00fh,01fh,01fh,03fh,037h	; a56d  ......?7
	defb 063h,060h,003h,00bh,018h,03ch,038h,038h	; a575  c`...<88
	defb 080h,0c0h,0c0h,0f0h,0f8h,0f8h,0fch,0ech	; a57d  ........
	defb 0c6h,006h,0c0h,0d0h,018h,03ch,01ch,01ch	; a585  .....<..
	defb 038h,018h,018h,000h,040h,000h,000h,000h	; a58d  8...@...
	defb 01fh,00fh,000h,000h,000h,000h,000h,000h	; a595  ........
	defb 01ch,018h,018h,000h,002h,000h,000h,000h	; a59d  ........
	defb 0f8h,0f8h,000h,000h,000h,000h,000h,000h	; a5a5  ........
	defb 090h,01fh,004h,004h,007h,003h,007h,007h	; a5ad  ........
	defb 007h,007h,007h,03fh,03fh,00fh,01fh,01fh	; a5b5  ...??...
	defb 009h,0f8h,020h,020h,0e0h,0c0h,0e0h,0e0h	; a5bd  ..  ....
	defb 0e0h,0e0h,0e0h,0fch,0fch,0f0h,0f8h,0f8h	; a5c5  ........
	defb 001h,001h,007h,00fh,01fh,01bh,031h,030h	; a5cd  ......10
	defb 001h,004h,00eh,00ch,00ch,00ch,004h,004h	; a5d5  ........
	defb 0c0h,0c0h,0f0h,0f8h,0fch,0ech,0c6h,006h	; a5dd  ........
	defb 0c0h,010h,038h,018h,018h,018h,010h,010h	; a5e5  ..8.....
	defb 048h,00fh,002h,003h,001h,003h,003h,003h	; a5ed  H.......
	defb 003h,003h,00fh,003h,007h,007h,003h,000h	; a5f5  ........
	defb 009h,0f8h,020h,0e0h,0c0h,0e0h,0e0h,0e0h	; a5fd  .. .....
	defb 0e0h,0e0h,0f8h,0e0h,0f0h,0f0h,0e0h,000h	; a605  ........
	defb 001h,001h,007h,00fh,00bh,008h,001h,004h	; a60d  ........
	defb 006h,004h,004h,004h,000h,000h,000h,007h	; a615  ........
	defb 080h,080h,0e0h,0f0h,0d0h,010h,080h,020h	; a61d  ....... 
	defb 060h,020h,020h,020h,000h,000h,000h,0e0h	; a625  `   ....
	defb 017h,002h,003h,001h,003h,003h,003h,00fh	; a62d  ........
	defb 003h,007h,000h,000h,000h,000h,000h,000h	; a635  ........
	defb 0e8h,040h,0c0h,080h,0c0h,0c0h,0c0h,0f0h	; a63d  .@......
	defb 0c0h,0e0h,000h,000h,000h,000h,000h,000h	; a645  ........
	defb 000h,001h,002h,001h,001h,001h,003h,001h	; a64d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a655  ........
	defb 080h,0c0h,0a0h,0c0h,0c0h,0c0h,0e0h,0c0h	; a65d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a665  ........
	defb 040h,0a0h,040h,000h,000h,000h,000h,000h	; a66d  @.@.....
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a675  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a67d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a685  ........
	defb 020h,050h,0e8h,070h,020h,000h,000h,000h	; a68d   P.p ...
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a695  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a69d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a6a5  ........
	defb 000h,000h,000h,000h,002h,001h,00bh,006h	; a6ad  ........
	defb 015h,00fh,006h,008h,001h,000h,000h,000h	; a6b5  ........
	defb 000h,000h,000h,000h,000h,050h,0e0h,0d0h	; a6bd  .....P..
	defb 060h,0a8h,080h,020h,000h,000h,000h,000h	; a6c5  `.. ....
	defb 000h,000h,000h,010h,001h,007h,00ch,009h	; a6cd  ........
	defb 096h,035h,01dh,00fh,00bh,020h,000h,000h	; a6d5  .5... ..
	defb 000h,000h,008h,080h,080h,068h,014h,048h	; a6dd  .....h.H
	defb 0aah,0fch,028h,0f4h,0a1h,008h,080h,000h	; a6e5  ..(.....
	defb 000h,000h,000h,005h,015h,016h,04ch,037h	; a6ed  ......L7
	defb 0dbh,03dh,0f6h,00fh,053h,0a6h,06ah,012h	; a6f5  .=..S.j.
	defb 000h,000h,000h,000h,0a0h,048h,080h,06ch	; a6fd  .....H.l
	defb 0d0h,060h,0d4h,0b0h,05ch,0a0h,090h,048h	; a705  .`..\..H
	defb 000h,001h,000h,002h,001h,010h,00ah,001h	; a70d  ........
	defb 092h,025h,000h,024h,001h,002h,000h,000h	; a715  .%.$....
	defb 002h,025h,053h,02fh,048h,037h,0cah,01dh	; a71d  .%S/H7..
	defb 056h,09fh,07ah,0a7h,039h,013h,045h,009h	; a725  V.z.9.E.
	defb 0a2h,010h,005h,0a8h,075h,09ah,06eh,0bbh	; a72d  ....u.n.
	defb 0e5h,0b4h,06ah,0d9h,0b0h,0cah,030h,080h	; a735  ..j...0.
	defb 000h,000h,000h,040h,000h,0a0h,004h,0a0h	; a73d  ...@....
	defb 068h,080h,000h,020h,000h,000h,000h,000h	; a745  h.. ....
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a74d  ........
	defb 000h,000h,000h,002h,000h,000h,000h,000h	; a755  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a75d  ........
	defb 040h,008h,043h,010h,08ch,003h,000h,092h	; a765  @.C.....
	defb 000h,000h,000h,048h,000h,022h,088h,012h	; a76d  ...H."..
	defb 0a5h,053h,02fh,0c8h,073h,026h,0c9h,056h	; a775  .S/.s&.V
	defb 080h,000h,084h,091h,001h,0a4h,011h,0e4h	; a77d  ........
	defb 051h,063h,0aeh,077h,09ah,06dh,090h,0edh	; a785  Qc.w.m..
	defb 040h,002h,080h,008h,000h,041h,062h,08ch	; a78d  @....Ab.
	defb 004h,0a1h,024h,0d9h,068h,0a1h,0f6h,040h	; a795  ..$.h..@
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a79d  ........
	defb 010h,000h,002h,0a0h,000h,028h,000h,021h	; a7a5  .....(.!
	defb 012h,000h,001h,004h,000h,000h,000h,002h	; a7ad  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a7b5  ........
	defb 02ch,003h,001h,036h,080h,023h,049h,000h	; a7bd  ,..6.#I.
	defb 004h,000h,010h,000h,000h,000h,000h,000h	; a7c5  ........
	defb 08eh,0d5h,033h,0e9h,0afh,07eh,017h,0c9h	; a7cd  ..3..~..
	defb 044h,003h,04ch,004h,081h,010h,000h,000h	; a7d5  D.L.....
	defb 0afh,0d2h,067h,09eh,0b6h,0e9h,0f8h,095h	; a7dd  ..g.....
	defb 0f3h,0deh,080h,09dh,062h,088h,000h,000h	; a7e5  ....b...
	defb 09dh,070h,0a3h,04ch,0a0h,0e5h,054h,0d2h	; a7ed  .p.L..T.
	defb 020h,0e8h,018h,004h,001h,000h,020h,000h	; a7f5   ..... .
	defb 080h,030h,004h,0e8h,012h,000h,042h,010h	; a7fd  .0....B.
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a805  ........
	defb 020h,083h,018h,003h,017h,07eh,0c5h,01ch	; a80d   ....~..
	defb 0d1h,045h,07ch,0afh,0f3h,03dh,01eh,0f7h	; a815  .E|..=..
	defb 06fh,0dch,03bh,0c8h,001h,074h,0b9h,0e0h	; a81d  o.;..t..
	defb 089h,040h,0f4h,09fh,063h,0ffh,0fdh,0ffh	; a825  .@..c...
	defb 0beh,013h,0f8h,00fh,0c1h,07ch,00fh,0f9h	; a82d  .....|..
	defb 00ch,03bh,071h,09eh,0f9h,0b5h,0dch,03fh	; a835  .;q....?
	defb 004h,030h,0e9h,037h,0ddh,038h,003h,0d8h	; a83d  .0.7.8..
	defb 076h,01fh,0cah,064h,009h,0eeh,07ah,0f3h	; a845  v..d..z.
	defb 010h,060h,081h,00eh,0d8h,061h,08eh,0e3h	; a84d  .`...a..
	defb 038h,085h,018h,06fh,0e8h,00fh,0feh,0e0h	; a855  8..o....
	defb 018h,040h,0c0h,000h,020h,000h,040h,000h	; a85d  .@.. .@.
	defb 0f0h,01dh,000h,080h,0f8h,001h,040h,034h	; a865  ......@4
	defb 0dbh,0e3h,03eh,06fh,099h,01eh,0cfh,001h	; a86d  ..>o....
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a875  ........
	defb 0fbh,0ffh,0edh,0feh,0feh,0efh,0f9h,0e0h	; a87d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a885  ........
	defb 0e7h,09fh,0f1h,0ffh,0dfh,0fch,0ffh,000h	; a88d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a895  ........
	defb 07fh,0fch,0b9h,0ffh,03fh,0f2h,0ffh,03eh	; a89d  ....?..>
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a8a5  ........
	defb 00fh,0fch,0e7h,00eh,0fch,0f1h,09ah,070h	; a8ad  .......p
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a8b5  ........
	defb 0c0h,011h,080h,040h,000h,040h,008h,000h	; a8bd  ...@.@..
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a8c5  ........
	defb 000h,000h,000h,000h,000h,000h,008h,01ch	; a8cd  ........
	defb 008h,014h,000h,000h,000h,000h,000h,000h	; a8d5  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a8dd  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a8e5  ........
	defb 01ch,03eh,07fh,07fh,07fh,049h,022h,000h	; a8ed  .>...I".
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a8f5  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a8fd  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a905  ........

; ----------------------------------------------------------------------
; DATOS sprites_bonus: Los seis sprites del esquiador del bonus, de cara, que
;   se giran y se dan la vuelta para los demas dibujos
;   0xa90d..0xa9cd  (192 bytes)
DATA_A90D:
	defb 003h,007h,007h,00eh,01fh,01fh,03dh,018h	; a90d  ......=.
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a915  ........
	defb 000h,080h,000h,000h,000h,080h,0c0h,0e0h	; a91d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a925  ........
	defb 000h,000h,000h,000h,000h,000h,000h,021h	; a92d  .......!
	defb 039h,03ch,01eh,006h,000h,006h,007h,000h	; a935  9<......
	defb 000h,000h,000h,000h,000h,000h,03eh,010h	; a93d  ......>.
	defb 090h,000h,000h,000h,000h,000h,000h,000h	; a945  ........
	defb 000h,000h,018h,030h,020h,000h,000h,000h	; a94d  ...0 ...
	defb 000h,000h,000h,000h,006h,000h,0f0h,00fh	; a955  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a95d  ........
	defb 000h,000h,000h,000h,000h,000h,004h,0f8h	; a965  ........
	defb 020h,070h,071h,07fh,07fh,078h,038h,038h	; a96d   pq..x88
	defb 038h,000h,000h,000h,000h,000h,000h,000h	; a975  8.......
	defb 000h,000h,0c0h,080h,000h,000h,000h,000h	; a97d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a985  ........
	defb 000h,000h,000h,000h,000h,001h,001h,000h	; a98d  ........
	defb 007h,01fh,00eh,000h,000h,000h,000h,000h	; a995  ........
	defb 038h,0e0h,000h,020h,000h,080h,000h,000h	; a99d  8.. ....
	defb 0c0h,0d0h,038h,018h,000h,000h,000h,000h	; a9a5  ..8.....
	defb 000h,000h,000h,000h,080h,080h,0c0h,040h	; a9ad  .......@
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a9b5  ........
	defb 000h,000h,002h,001h,001h,002h,002h,002h	; a9bd  ........
	defb 004h,024h,044h,004h,004h,008h,008h,008h	; a9c5  .$D.....

; ----------------------------------------------------------------------
; DATOS sprite_diana: El sprite de la diana del bonus (0x3B00)
;   0xa9cd..0xa9ed  (32 bytes)
DATA_sprite_diana:
	defb 007h,01fh,03bh,077h,06fh,0efh,0efh,0ffh	; a9cd  ..;wo...
	defb 089h,041h,021h,011h,009h,005h,003h,001h	; a9d5  .A!.....
	defb 0c0h,0f0h,0f8h,0fch,0fch,0feh,0feh,0feh	; a9dd  ........
	defb 092h,004h,008h,010h,020h,040h,080h,000h	; a9e5  .... @..

; ----------------------------------------------------------------------
; DATOS sprites_caida: Los tres sprites del esquiador que se cae (0x3C00)
;   0xa9ed..0xaa4d  (96 bytes)
DATA_sprites_caida:
	defb 060h,060h,060h,0e3h,0e7h,0f7h,0ffh,07fh	; a9ed  ```.....
	defb 03fh,01fh,00fh,000h,000h,000h,000h,000h	; a9f5  ?.......
	defb 006h,006h,006h,006h,086h,08eh,0feh,0fch	; a9fd  ........
	defb 0f8h,0f0h,0e0h,000h,000h,000h,000h,000h	; aa05  ........
	defb 080h,080h,081h,081h,0cfh,09fh,09fh,05ch	; aa0d  .......\
	defb 05eh,007h,003h,003h,000h,000h,000h,000h	; aa15  ^.......
	defb 000h,000h,080h,0c0h,0b0h,07bh,07fh,067h	; aa1d  .....{.g
	defb 067h,060h,0e0h,0c0h,000h,000h,000h,000h	; aa25  g`......
	defb 0e0h,070h,038h,01ch,00eh,003h,001h,000h	; aa2d  .p8.....
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; aa35  ........
	defb 018h,01ch,01ch,01ch,01ch,01ch,09ch,01ch	; aa3d  ........
	defb 004h,004h,004h,004h,01ch,01ch,01ch,01ch	; aa45  ........

; ----------------------------------------------------------------------
; DATOS nieve_casillas: Las 59 casillas de la nieve y de los objetos (desde la
;   0x80)
;   0xaa4d..0xac25  (472 bytes)
DATA_nieve_casillas:
	defb 000h,000h,000h,000h,000h,010h,078h,0f8h	; aa4d  ......x.
	defb 000h,000h,000h,000h,004h,03eh,07bh,0ffh	; aa55  .....>{.
	defb 000h,000h,000h,001h,007h,00fh,00fh,00fh	; aa5d  ........
	defb 00ch,01eh,0ffh,0fdh,0feh,0ffh,0ffh,0ffh	; aa65  ........
	defb 000h,000h,000h,0c0h,0e0h,0f0h,0f0h,0f0h	; aa6d  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; aa75  ........
	defb 000h,000h,000h,000h,007h,00fh,01fh,03fh	; aa7d  .......?
	defb 000h,000h,000h,000h,000h,080h,0c0h,0e0h	; aa85  ........
	defb 007h,01fh,03fh,07fh,0ffh,03fh,03ch,003h	; aa8d  ..?..?<.
	defb 0ffh,0ffh,0efh,0dfh,0bfh,0ffh,0ffh,0ffh	; aa95  ........
	defb 0f0h,0f8h,0fch,0feh,0ffh,0ffh,0f8h,0f8h	; aa9d  ........
	defb 010h,038h,038h,07ch,038h,07ch,07ch,010h	; aaa5  .88|8||.
	defb 018h,03ch,07eh,01ch,07eh,0fch,03ch,0ffh	; aaad  .<~.~.<.
	defb 001h,000h,001h,003h,000h,000h,000h,000h	; aab5  ........
	defb 0fch,03ch,0ffh,0ffh,0c0h,018h,018h,018h	; aabd  .<......
	defb 080h,000h,080h,0c0h,000h,000h,000h,000h	; aac5  ........
	defb 000h,000h,000h,000h,001h,000h,000h,001h	; aacd  ........
	defb 018h,03ch,07eh,0ffh,0feh,03eh,0ffh,0ffh	; aad5  .<~..>..
	defb 000h,000h,000h,000h,080h,000h,000h,080h	; aadd  ........
	defb 003h,000h,001h,003h,007h,000h,003h,007h	; aae5  ........
	defb 0ffh,07eh,0ffh,0ffh,0ffh,07eh,0ffh,0ffh	; aaed  .~...~..
	defb 0c0h,000h,080h,0c0h,0e0h,000h,080h,0c0h	; aaf5  ........
	defb 00fh,01fh,001h,000h,000h,000h,000h,000h	; aafd  ........
	defb 0ffh,0ffh,0ffh,038h,038h,038h,038h,010h	; ab05  ...8888.
	defb 0e0h,0f0h,000h,000h,000h,000h,000h,000h	; ab0d  ........
	defb 000h,000h,000h,000h,001h,003h,003h,000h	; ab15  ........
	defb 018h,03ch,07eh,0ffh,0ffh,0ffh,0ffh,080h	; ab1d  .<~.....
	defb 000h,000h,000h,000h,080h,0c0h,0c0h,000h	; ab25  ........
	defb 001h,003h,007h,00fh,00fh,003h,007h,00fh	; ab2d  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ab35  ........
	defb 080h,0c0h,0e0h,030h,0f0h,0c0h,0e0h,0f0h	; ab3d  ...0....
	defb 01fh,01eh,007h,00fh,01fh,03fh,07fh,07fh	; ab45  .....?..
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ab4d  ........
	defb 0f8h,038h,0e0h,0f0h,0f8h,0fch,0feh,01eh	; ab55  .8......
	defb 01ch,003h,000h,000h,000h,000h,000h,000h	; ab5d  ........
	defb 0ffh,0ffh,03ch,03ch,03ch,03ch,03ch,018h	; ab65  ..<<<<<.
	defb 0fch,0e0h,000h,000h,000h,000h,000h,000h	; ab6d  ........
	defb 000h,000h,000h,000h,000h,000h,03ch,07eh	; ab75  ......<~
	defb 000h,000h,000h,000h,07eh,015h,015h,07eh	; ab7d  ....~..~
	defb 000h,000h,000h,003h,00fh,00fh,003h,000h	; ab85  ........
	defb 000h,000h,0ffh,015h,015h,015h,015h,015h	; ab8d  ........
	defb 000h,000h,000h,0c0h,0e0h,0f0h,0e0h,080h	; ab95  ........
	defb 000h,000h,000h,007h,01fh,07fh,0ffh,0ffh	; ab9d  ........
	defb 000h,000h,000h,0e0h,0f8h,0feh,0ffh,0ffh	; aba5  ........
	defb 07fh,03fh,00fh,000h,000h,000h,000h,000h	; abad  .?......
	defb 015h,015h,015h,015h,000h,000h,000h,000h	; abb5  ........
	defb 0ffh,0feh,0f8h,0c0h,000h,000h,000h,000h	; abbd  ........
	defb 000h,000h,000h,000h,000h,018h,03ch,03ch	; abc5  ......<<
	defb 000h,000h,018h,018h,07eh,0ffh,0ffh,0ffh	; abcd  ....~...
	defb 000h,000h,000h,001h,003h,002h,003h,001h	; abd5  ........
	defb 03ch,07eh,0c3h,0bdh,0ffh,0ffh,0ffh,0ffh	; abdd  <~......
	defb 000h,000h,000h,080h,0c0h,040h,0c0h,080h	; abe5  .....@..
	defb 001h,003h,007h,00fh,01dh,03fh,07bh,0ffh	; abed  .....?{.
	defb 0ffh,081h,0ffh,081h,0ffh,0ffh,0ffh,0ffh	; abf5  ........
	defb 080h,0c0h,0e0h,0f0h,0b8h,0fch,0deh,0ffh	; abfd  ........
	defb 0f7h,0ffh,0efh,0ffh,0dfh,0ffh,0ffh,07fh	; ac05  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ac0d  ........
	defb 0efh,0ffh,0f7h,0ffh,0fbh,0ffh,0ffh,0feh	; ac15  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; ac1d  ........

; ----------------------------------------------------------------------
; DATOS nieve_colores: Sus colores
;   0xac25..0xadfd  (472 bytes)
DATA_nieve_colores:
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,05eh	; ac25  .......^
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,05eh	; ac2d  .......^
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,05eh	; ac35  .......^
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0aeh,05eh	; ac3d  .......^
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,05eh	; ac45  .......^
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; ac4d  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; ac55  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; ac5d  ........
	defb 0feh,0feh,0feh,0feh,0feh,0f4h,04eh,04eh	; ac65  ......NN
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,04eh	; ac6d  .......N
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0f4h,04eh	; ac75  .......N
	defb 0feh,0feh,02eh,0feh,02eh,0feh,02eh,06eh	; ac7d  .......n
	defb 0feh,0feh,0feh,02eh,0feh,0ffh,02eh,0feh	; ac85  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; ac8d  ........
	defb 0ffh,02eh,0feh,0feh,032h,01eh,06eh,06eh	; ac95  ....2.nn
	defb 03eh,0feh,0feh,02eh,0feh,0feh,0feh,0feh	; ac9d  >.......
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; aca5  ........
	defb 0feh,0feh,0feh,0feh,0f3h,02eh,0feh,0feh	; acad  ........
	defb 0feh,0feh,0feh,0feh,03eh,0feh,0feh,0feh	; acb5  ....>...
	defb 0feh,0feh,0feh,0feh,03eh,0feh,0feh,0feh	; acbd  ....>...
	defb 0eeh,02eh,0feh,0feh,0eeh,02eh,0feh,0feh	; acc5  ........
	defb 02eh,0eeh,0feh,0feh,02eh,0feh,0feh,0feh	; accd  ........
	defb 0feh,03eh,02eh,0eeh,0eeh,0eeh,0eeh,0eeh	; acd5  .>......
	defb 0feh,0feh,02eh,01eh,06eh,06eh,06eh,0feh	; acdd  ....nnn.
	defb 0feh,0ceh,0feh,0feh,0feh,0feh,0feh,0feh	; ace5  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; aced  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0fch	; acf5  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0ceh,0feh	; acfd  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; ad05  ........
	defb 0feh,0feh,0feh,0feh,033h,0cch,0feh,0feh	; ad0d  ....3...
	defb 0feh,0feh,0feh,03eh,0ceh,03eh,0feh,0feh	; ad15  ...>.>..
	defb 0feh,03eh,03eh,0feh,0feh,0feh,0feh,0feh	; ad1d  .>>.....
	defb 0feh,0feh,033h,0cch,0feh,0feh,0feh,0feh	; ad25  ..3.....
	defb 0feh,0ceh,0ceh,0feh,0feh,0feh,0feh,0feh	; ad2d  ........
	defb 03eh,0ceh,0eeh,0eeh,0eeh,0eeh,0eeh,0eeh	; ad35  >.......
	defb 0feh,0cch,01eh,06eh,06eh,06eh,04eh,0feh	; ad3d  ...nnnN.
	defb 0ceh,0ceh,0eeh,0eeh,0eeh,0eeh,0eeh,0eeh	; ad45  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,01eh,04eh	; ad4d  .......N
	defb 0feh,0feh,0feh,0feh,01eh,047h,047h,07eh	; ad55  .....GG~
	defb 0feh,0feh,0feh,01eh,07eh,07eh,07eh,0feh	; ad5d  ....~~~.
	defb 0feh,0feh,01eh,047h,047h,047h,047h,047h	; ad65  ...GGGGG
	defb 0feh,0feh,0feh,01eh,04eh,04eh,04eh,04eh	; ad6d  ....NNNN
	defb 0feh,0feh,0feh,01eh,07eh,07eh,07eh,07eh	; ad75  ....~~~~
	defb 0feh,0feh,0feh,01eh,04eh,04eh,04eh,04eh	; ad7d  ....NNNN
	defb 07eh,07eh,07eh,0feh,0feh,0feh,0feh,0feh	; ad85  ~~~.....
	defb 047h,047h,047h,047h,0feh,0feh,0feh,0feh	; ad8d  GGGG....
	defb 04eh,04eh,04eh,04eh,0feh,0feh,0feh,0feh	; ad95  NNNN....
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0aeh,01eh	; ad9d  ........
	defb 0feh,0feh,0feh,01eh,0aeh,0aeh,0aeh,01eh	; ada5  ........
	defb 0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,01eh	; adad  ........
	defb 0feh,0aeh,0a1h,0aeh,0aeh,0aeh,0aeh,01eh	; adb5  ........
	defb 0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,01eh	; adbd  ........
	defb 0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,0aeh	; adc5  ........
	defb 0feh,0f1h,0feh,0a1h,0aeh,0aeh,0aeh,0aeh	; adcd  ........
	defb 0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,0aeh	; add5  ........
	defb 0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,01eh	; addd  ........
	defb 0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,01eh	; ade5  ........
	defb 0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,0aeh,01eh	; aded  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; adf5  ........

; ----------------------------------------------------------------------
; DATOS pista_colores: Los colores de las 28 casillas de la pista; desde
;   0xAE1D, los del suelo
;   0xadfd..0xaedd  (224 bytes)
DATA_pista_colores:
	defb 0f4h,0f4h,0f4h,0f4h,0f4h,0f4h,0f4h,0f4h	; adfd  ........
	defb 0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h	; ae05  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; ae0d  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; ae15  ........
	defb 0feh,0feh,0feh,0feh,0f7h,05fh,05fh,0feh	; ae1d  .....__.
	defb 0feh,0feh,0feh,0feh,0f7h,057h,05eh,0feh	; ae25  .....W^.
	defb 0feh,0feh,0f7h,0f5h,0feh,0feh,0feh,07fh	; ae2d  ........
	defb 0feh,0feh,07eh,05eh,0feh,0feh,0feh,07eh	; ae35  ..~^...~
	defb 0feh,0feh,0feh,07eh,05fh,0feh,0feh,0feh	; ae3d  ...~_...
	defb 0feh,0feh,0feh,0feh,0feh,0feh,07eh,05fh	; ae45  ......~_
	defb 0feh,07fh,05fh,0feh,0feh,0f7h,057h,05eh	; ae4d  .._...W^
	defb 0feh,07eh,05eh,0feh,0feh,07eh,05eh,00eh	; ae55  .~^..~^.
	defb 0f7h,05fh,0efh,0feh,0feh,0feh,07fh,05fh	; ae5d  ._....._
	defb 075h,05eh,05eh,0feh,0feh,0efh,0e7h,05eh	; ae65  u^^....^
	defb 05eh,07eh,00eh,0feh,0feh,05eh,05eh,00eh	; ae6d  ^~...^^.
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0f7h,0f5h	; ae75  ........
	defb 0f7h,07fh,05fh,0feh,0feh,0feh,07eh,05eh	; ae7d  .._...~^
	defb 07eh,05eh,05eh,00eh,00eh,00eh,05eh,00eh	; ae85  ~^^...^.
	defb 0feh,0feh,0f7h,0feh,0feh,07fh,0feh,0feh	; ae8d  ........
	defb 0feh,0feh,07eh,05fh,0feh,07eh,05eh,0feh	; ae95  ..~_.~^.
	defb 0feh,0feh,07fh,0f5h,0feh,0feh,07fh,05fh	; ae9d  ......._
	defb 0feh,0feh,07eh,05eh,0feh,0feh,07eh,05eh	; aea5  ..~^..~^
	defb 0feh,0feh,0feh,0feh,0f7h,0f5h,0f7h,0f5h	; aead  ........
	defb 0feh,0feh,0feh,07fh,075h,05eh,00eh,00eh	; aeb5  ....u^..
	defb 0feh,0feh,07eh,05eh,00eh,00eh,00eh,07eh	; aebd  ..~^...~
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0f7h,0f5h	; aec5  ........
	defb 0feh,0feh,0feh,0feh,0feh,0f7h,075h,05eh	; aecd  ......u^
	defb 05eh,0feh,0feh,0feh,0feh,07eh,057h,05eh	; aed5  ^....~W^

; ----------------------------------------------------------------------
; DATOS cifras_colores: Los colores de tres casillas del marcador
;   0xaedd..0xaef5  (24 bytes)
DATA_cifras_colores:
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; aedd  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; aee5  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; aeed  ........

; ----------------------------------------------------------------------
; DATOS letras_colores: Los colores de las ocho letras grandes del marcador
;   (0x2020)
;   0xaef5..0xaf35  (64 bytes)
DATA_letras_colores:
	defb 0f4h,0f4h,0f4h,0f4h,0f4h,0f4h,0f4h,0f5h	; aef5  ........
	defb 0f4h,0f4h,0f4h,0f4h,0f5h,0f4h,0f4h,0f4h	; aefd  ........
	defb 0f5h,0f4h,0f4h,0f5h,0f4h,0f4h,0f5h,0f4h	; af05  ........
	defb 0f5h,0f5h,0f4h,0f5h,0f5h,0f4h,0f5h,0f5h	; af0d  ........
	defb 0f4h,0f5h,0f5h,0f4h,0f5h,0f5h,0f4h,0f5h	; af15  ........
	defb 0f5h,0f5h,0f4h,0f5h,0f5h,0f5h,0f5h,0f5h	; af1d  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; af25  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; af2d  ........

; ----------------------------------------------------------------------
; DATOS tramo0_nombres: Las ocho filas de arriba de la pista (el monte y la
;   nieve del fondo, 31 casillas por fila, 0xF8 bytes): el tramo 0
;   0xaf35..0xb02d  (248 bytes)
DATA_tramo0_nombres:
	defb 004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h	; af35  ...............................
	defb 084h,085h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,08ch,08dh	; af54  ...............................
	defb 003h,003h,080h,081h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,088h,089h,003h,003h	; af73  ...............................
	defb 003h,003h,003h,003h,080h,081h,007h,007h,007h,007h,007h,007h,007h,007h,007h,007h,007h,007h,007h,007h,007h,007h,007h,007h,007h,088h,089h,003h,003h,003h,003h	; af92  ...............................
	defb 003h,003h,003h,003h,003h,003h,082h,083h,008h,008h,008h,008h,008h,008h,008h,008h,008h,008h,008h,008h,008h,008h,008h,08ah,08bh,003h,003h,003h,003h,003h,003h	; afb1  ...............................
	defb 003h,003h,003h,003h,003h,003h,003h,003h,084h,085h,008h,008h,008h,008h,008h,008h,008h,008h,008h,008h,008h,08ch,08dh,003h,003h,003h,003h,003h,003h,003h,003h	; afd0  ...............................
	defb 003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,086h,087h,009h,009h,009h,009h,009h,009h,009h,08eh,08fh,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h	; afef  ...............................
	defb 003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,090h,091h,092h,093h,094h,095h,096h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h	; b00e  ...............................

; ----------------------------------------------------------------------
; DATOS tramo1_nombres: Lo que cambia en el tramo 1 (se copian 0xF8 bytes
;   desde aqui)
;   0xb02d..0xb06b  (62 bytes)
DATA_tramo1_nombres:
	defb 003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,086h,090h,091h,092h,093h,094h,095h,096h,097h,098h,08fh,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h	; b02d  ...............................
	defb 003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,099h,09ah,09bh,09ch,09dh,09eh,09fh,0a0h,099h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h	; b04c  ...............................

; ----------------------------------------------------------------------
; DATOS tramo2_nombres: Lo que cambia en el tramo 2
;   0xb06b..0xb0c8  (93 bytes)
DATA_tramo2_nombres:
	defb 003h,003h,003h,003h,003h,003h,003h,003h,084h,085h,090h,091h,092h,093h,094h,095h,096h,097h,098h,099h,09ah,08ch,08dh,003h,003h,003h,003h,003h,003h,003h,003h	; b06b  ...............................
	defb 003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,09bh,09ch,09dh,09eh,09fh,0a0h,0a1h,0a2h,0a3h,0a4h,0a5h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h	; b08a  ...............................
	defb 003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,0a6h,0a6h,0a7h,0a8h,0a9h,0a9h,0a9h,0aah,0abh,0a6h,0a6h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h	; b0a9  ...............................

; ----------------------------------------------------------------------
; DATOS tramo3_nombres: Lo que cambia en el tramo 3
;   0xb0c8..0xb144  (124 bytes)
DATA_tramo3_nombres:
	defb 003h,003h,003h,003h,003h,003h,082h,083h,090h,091h,092h,093h,094h,095h,096h,097h,098h,099h,09ah,09bh,09ch,09dh,09eh,08ah,08bh,003h,003h,003h,003h,003h,003h	; b0c8  ...............................
	defb 003h,003h,003h,003h,003h,003h,003h,003h,09fh,0a0h,0a1h,0a2h,0a3h,0a4h,0a5h,0a6h,0a7h,0a8h,0a9h,0aah,0abh,0ach,0adh,003h,003h,003h,003h,003h,003h,003h,003h	; b0e7  ...............................
	defb 003h,003h,003h,003h,003h,003h,003h,003h,0aeh,0aeh,0afh,0b0h,0b1h,0b2h,0b3h,0b4h,0b5h,0b6h,0b7h,0b8h,0b9h,0aeh,0aeh,003h,003h,003h,003h,003h,003h,003h,003h	; b106  ...............................
	defb 003h,003h,003h,003h,003h,003h,003h,003h,0aeh,0aeh,0aeh,0aeh,0bah,0bbh,0bch,0bch,0bch,0bdh,0beh,0aeh,0aeh,0aeh,0aeh,003h,003h,003h,003h,003h,003h,003h,003h	; b125  ...............................

; ----------------------------------------------------------------------
; DATOS tramo_dibujos: Los dibujos de la nieve de los cuatro tramos (60
;   casillas desde la 0x90, desde 0xB144, 0xB2BC, 0xB39C o 0xB424) y sus
;   colores 0x318 bytes mas alla
;   0xb144..0xb774  (1584 bytes)
DATA_tramo_dibujos:
	defb 000h,000h,000h,000h,03ch,0ffh,0ffh,07fh	; b144  ....<...
	defb 000h,000h,000h,000h,000h,0c0h,0f8h,0ffh	; b14c  ........
	defb 000h,000h,000h,000h,000h,001h,00fh,0ffh	; b154  ........
	defb 000h,000h,001h,00fh,07fh,0ffh,0ffh,0ffh	; b15c  ........
	defb 000h,000h,0f0h,0feh,0ffh,0ffh,0ffh,00fh	; b164  ........
	defb 000h,000h,000h,000h,000h,0c0h,0f0h,07fh	; b16c  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; b174  ........
	defb 000h,000h,000h,000h,000h,000h,000h,007h	; b17c  ........
	defb 000h,000h,000h,000h,003h,01fh,0ffh,0ffh	; b184  ........
	defb 000h,000h,000h,003h,0ffh,0ffh,0feh,0f1h	; b18c  ........
	defb 00fh,03fh,0ffh,0ffh,0ffh,09fh,07fh,0ffh	; b194  .?......
	defb 0e0h,0fch,0ffh,0ffh,0ffh,002h,0ffh,0ffh	; b19c  ........
	defb 000h,000h,080h,0f0h,0feh,0cfh,0f7h,038h	; b1a4  .......8
	defb 000h,000h,000h,000h,000h,0c0h,0f8h,0ffh	; b1ac  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; b1b4  ........
	defb 020h,00fh,003h,000h,000h,000h,000h,000h	; b1bc   .......
	defb 0ffh,0ffh,0f0h,0dch,03fh,00bh,003h,0ffh	; b1c4  ....?...
	defb 0ffh,0ffh,006h,0ffh,081h,01fh,0fch,0ffh	; b1cc  ........
	defb 0fch,0ffh,0f0h,0c3h,0efh,0e0h,07fh,0ffh	; b1d4  ........
	defb 07fh,0c0h,0f7h,0fbh,0ffh,0ffh,0ffh,0f0h	; b1dc  ........
	defb 00fh,0feh,0ffh,0fch,0ffh,0ffh,0ffh,0ffh	; b1e4  ........
	defb 01fh,0feh,03fh,078h,0f0h,0ffh,0ffh,0ffh	; b1ec  ..?x....
	defb 0c0h,0feh,0f8h,0ffh,0e0h,003h,0ffh,0ffh	; b1f4  ........
	defb 0f3h,01fh,07fh,00fh,073h,0c0h,0ffh,0ffh	; b1fc  ....s...
	defb 0ffh,0ffh,0ffh,0ffh,018h,0e0h,0cfh,0ffh	; b204  ........
	defb 0ffh,0ffh,0ffh,0ffh,01fh,0ffh,0ffh,0ffh	; b20c  ........
	defb 0ffh,0ffh,0ffh,0ffh,0c0h,00fh,0feh,0ffh	; b214  ........
	defb 000h,019h,00eh,0feh,0fch,0ffh,0f0h,0ffh	; b21c  ........
	defb 03fh,00fh,003h,0ffh,07eh,0f0h,0c0h,0ffh	; b224  ?...~...
	defb 0e3h,0efh,040h,0ffh,0ffh,0ffh,0ffh,0ffh	; b22c  ..@.....
	defb 0ffh,0ffh,0ffh,0ffh,000h,0ffh,0ffh,0ffh	; b234  ........
	defb 0c0h,0f0h,0fch,0ffh,0ffh,0ffh,0ffh,0ffh	; b23c  ........
	defb 0ffh,0ffh,00fh,0e4h,03fh,007h,003h,0ffh	; b244  ....?...
	defb 0ffh,03ch,00fh,0ffh,0ffh,0ffh,0ffh,07fh	; b24c  .<......
	defb 0ffh,0ffh,0c0h,03ch,0ffh,0ffh,0ffh,0ffh	; b254  ...<....
	defb 0ffh,0ffh,0e3h,03fh,0ffh,0ffh,0ffh,0ffh	; b25c  ...?....
	defb 0ffh,0ffh,0c0h,0ffh,0ffh,0ffh,0ffh,0ffh	; b264  ........
	defb 0ffh,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; b26c  ........
	defb 0ffh,000h,07fh,0ffh,0ffh,0ffh,0ffh,0ffh	; b274  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; b27c  ........
	defb 0ffh,0ffh,0ffh,0ffh,0fch,0f0h,0c0h,0ffh	; b284  ........
	defb 003h,00fh,03fh,0ffh,0ffh,0ffh,0ffh,0ffh	; b28c  ..?.....
	defb 03fh,00fh,043h,0ffh,0ffh,0ffh,0ffh,0ffh	; b294  ?.C.....
	defb 0ffh,000h,0ffh,0ffh,03fh,00fh,003h,0ffh	; b29c  ....?...
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; b2a4  ........
	defb 0ffh,0ffh,0ffh,0ffh,0fch,0f0h,0c0h,0ffh	; b2ac  ........
	defb 0fch,0f0h,0c0h,0ffh,0ffh,0ffh,0ffh,0ffh	; b2b4  ........
	defb 000h,000h,000h,000h,000h,000h,000h,07eh	; b2bc  .......~
	defb 000h,000h,000h,000h,000h,000h,000h,003h	; b2c4  ........
	defb 000h,000h,000h,000h,007h,03fh,0ffh,0ffh	; b2cc  .....?..
	defb 000h,000h,000h,0ffh,0ffh,0ffh,0ffh,003h	; b2d4  ........
	defb 000h,000h,000h,000h,0c0h,0f8h,0ffh,00fh	; b2dc  ........
	defb 000h,000h,000h,000h,000h,000h,000h,0e0h	; b2e4  ........
	defb 000h,000h,000h,000h,000h,001h,00fh,0ffh	; b2ec  ........
	defb 000h,000h,003h,01fh,0ffh,0ffh,0ffh,0ffh	; b2f4  ........
	defb 000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; b2fc  ........
	defb 000h,000h,080h,0f8h,0ffh,0ffh,0ffh,0ffh	; b304  ........
	defb 000h,000h,000h,000h,0c0h,0f8h,0ffh,0feh	; b30c  ........
	defb 0dfh,0f7h,0fch,0ffh,0ffh,0ffh,0ffh,0ffh	; b314  ........
	defb 0ffh,0ffh,0f0h,0bch,037h,00fh,003h,0ffh	; b31c  ....7...
	defb 0ffh,0ffh,0ffh,0ffh,001h,007h,00ch,0c0h	; b324  ........
	defb 0e0h,0f0h,07fh,0e0h,0bfh,059h,01fh,000h	; b32c  .....Y..
	defb 0feh,0ffh,0ffh,0ffh,070h,0e7h,07fh,000h	; b334  ....p...
	defb 0ffh,0e0h,0fch,0ffh,0ffh,0f8h,0ffh,000h	; b33c  ........
	defb 0ffh,0ffh,0ffh,0e7h,0ffh,07fh,0c1h,000h	; b344  ........
	defb 0f3h,0c7h,0ffh,03fh,07fh,0ffh,07fh,07fh	; b34c  ...?....
	defb 0ffh,0ffh,0ffh,03fh,0ffh,0ffh,0e0h,000h	; b354  ...?....
	defb 0c1h,0e0h,0f0h,0f4h,0fch,0f0h,0c0h,0ffh	; b35c  ........
	defb 0f4h,0f0h,0c0h,0ffh,0ffh,0ffh,0ffh,0ffh	; b364  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; b36c  ........
	defb 0c0h,0f0h,0fch,0ffh,0ffh,0ffh,0ffh,0ffh	; b374  ........
	defb 000h,000h,000h,000h,03fh,00fh,003h,000h	; b37c  ....?...
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; b384  ........
	defb 0ffh,0ffh,0ffh,0ffh,0fch,0f0h,0c0h,000h	; b38c  ........
	defb 0fch,0f0h,0bfh,0ffh,0ffh,0ffh,0ffh,0ffh	; b394  ........
	defb 000h,000h,0fch,07fh,0dfh,0f7h,0fdh,0ffh	; b39c  ........
	defb 000h,000h,007h,0ffh,0ffh,0ffh,003h,000h	; b3a4  ........
	defb 007h,03fh,0ffh,0ffh,0ffh,0fbh,0c0h,000h	; b3ac  .?......
	defb 0e0h,0fch,0ffh,0ffh,080h,0c0h,000h,000h	; b3b4  ........
	defb 000h,000h,0c0h,0ffh,0ffh,00fh,000h,000h	; b3bc  ........
	defb 003h,01fh,0ffh,0ffh,0ffh,0ffh,0f0h,000h	; b3c4  ........
	defb 0feh,0ffh,0ffh,0ffh,0fch,01eh,000h,000h	; b3cc  ........
	defb 000h,080h,0f0h,0ffh,007h,000h,000h,000h	; b3d4  ........
	defb 000h,000h,01fh,0ffh,0f3h,00fh,03fh,0ffh	; b3dc  ......?.
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; b3e4  ........
	defb 0c0h,0f0h,0fch,0ffh,0ffh,0ffh,0ffh,0ffh	; b3ec  ........
	defb 078h,0ffh,0ffh,0ffh,03fh,00fh,003h,000h	; b3f4  x...?...
	defb 0f8h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; b3fc  ........
	defb 07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; b404  ........
	defb 0c0h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; b40c  ........
	defb 0f0h,0ffh,0ffh,0ffh,0fch,0f0h,0c0h,000h	; b414  ........
	defb 033h,00fh,03fh,0ffh,0ffh,0ffh,0ffh,0ffh	; b41c  3.?.....
	defb 0c0h,0f0h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; b424  ........
	defb 000h,0f8h,0ffh,0f8h,0c7h,0f0h,0fch,0ffh	; b42c  ........
	defb 00fh,0ffh,0fch,0fch,063h,000h,000h,000h	; b434  ....c...
	defb 000h,0e1h,0ffh,023h,003h,0ffh,0ffh,0ffh	; b43c  ...#....
	defb 07ch,0ffh,0ffh,0f8h,05fh,0ffh,0ffh,0ffh	; b444  |..._...
	defb 000h,087h,0ffh,0c0h,003h,00fh,03fh,0ffh	; b44c  ......?.
	defb 0ffh,0efh,0bfh,0ffh,0ffh,0ffh,0ffh,0ffh	; b454  ........
	defb 005h,005h,005h,005h,0f5h,0f5h,0f5h,0feh	; b45c  ........
	defb 005h,005h,005h,005h,0f5h,0f5h,0f5h,0f5h	; b464  ........
	defb 005h,005h,005h,005h,005h,0f5h,0f5h,0f5h	; b46c  ........
	defb 005h,005h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; b474  ........
	defb 005h,005h,0f5h,0f5h,0f5h,0f5h,0feh,0efh	; b47c  ........
	defb 005h,005h,005h,005h,005h,0f5h,0f5h,0feh	; b484  ........
	defb 005h,005h,005h,005h,005h,005h,005h,005h	; b48c  ........
	defb 005h,005h,005h,005h,005h,005h,0f5h,0f5h	; b494  ........
	defb 005h,005h,005h,005h,0f5h,0f5h,0f5h,0f5h	; b49c  ........
	defb 005h,005h,005h,0f5h,0f5h,0f5h,0feh,0feh	; b4a4  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0feh,0feh,0f5h	; b4ac  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0efh,0feh,0feh	; b4b4  ........
	defb 005h,005h,0f5h,0f5h,0f5h,0feh,0feh,0feh	; b4bc  ........
	defb 005h,005h,005h,005h,005h,0f5h,0f5h,0f5h	; b4c4  ........
	defb 005h,005h,005h,0f5h,005h,005h,005h,0f5h	; b4cc  ........
	defb 0efh,0efh,0efh,0efh,0efh,0efh,0efh,0efh	; b4d4  ........
	defb 0f5h,0f5h,0efh,0efh,0efh,0efh,0efh,0f5h	; b4dc  ........
	defb 0feh,0f5h,0efh,0feh,0efh,0efh,0efh,0efh	; b4e4  ........
	defb 0feh,0feh,0feh,0feh,0efh,0feh,0efh,0efh	; b4ec  ........
	defb 0efh,0feh,0efh,0efh,0e5h,0e5h,0e5h,0feh	; b4f4  ........
	defb 0feh,0efh,0efh,0efh,0efh,0e5h,0e5h,0e5h	; b4fc  ........
	defb 05fh,0feh,0feh,0efh,0feh,0efh,0e5h,0e5h	; b504  _.......
	defb 05fh,0feh,0feh,0efh,0feh,0feh,0e5h,0e5h	; b50c  _.......
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0efh,0e5h	; b514  ........
	defb 0f5h,0f5h,0f5h,0f5h,0efh,0efh,0efh,0e5h	; b51c  ........
	defb 0f5h,0f5h,0f5h,0f5h,0efh,0efh,0efh,0e5h	; b524  ........
	defb 0f5h,0feh,0feh,0feh,0efh,0feh,0efh,0e5h	; b52c  ........
	defb 0efh,0efh,0efh,0feh,0feh,0feh,0feh,0efh	; b534  ........
	defb 0feh,0feh,0feh,0e5h,0efh,0efh,0efh,0f5h	; b53c  ........
	defb 0f5h,0feh,0efh,0f5h,0f5h,0f5h,0f5h,0f5h	; b544  ........
	defb 0f5h,0f5h,0f5h,0f5h,05fh,0f5h,0f5h,0f5h	; b54c  ...._...
	defb 0feh,0feh,0feh,0f5h,0f5h,0f5h,0f5h,0f5h	; b554  ........
	defb 0e5h,0e5h,07eh,07eh,07fh,07fh,07fh,0f5h	; b55c  ..~~....
	defb 0e5h,07eh,07eh,07eh,07fh,07fh,07fh,07fh	; b564  .~~~....
	defb 0e5h,0e5h,07eh,07eh,07fh,07fh,07fh,07fh	; b56c  ..~~....
	defb 0e5h,0e5h,07eh,07eh,07fh,07fh,07fh,07fh	; b574  ..~~....
	defb 0e5h,0e5h,07eh,07fh,07fh,07fh,07fh,07fh	; b57c  ..~.....
	defb 0e5h,0feh,0e5h,074h,07fh,07fh,07fh,07fh	; b584  ...t....
	defb 0e5h,0efh,0e7h,07fh,07fh,07fh,07fh,07fh	; b58c  ........
	defb 0e5h,0e5h,07fh,07fh,07fh,07fh,07fh,07fh	; b594  ........
	defb 0e5h,0e5h,0e5h,07fh,07fh,07fh,07fh,0f5h	; b59c  ........
	defb 0feh,0feh,0feh,0f5h,0f5h,0f5h,0f5h,0f5h	; b5a4  ........
	defb 07fh,07fh,07fh,0f5h,0f5h,0f5h,0f5h,0f5h	; b5ac  ........
	defb 07fh,0f7h,07fh,07fh,07fh,07fh,07fh,0f5h	; b5b4  ........
	defb 07fh,07fh,07fh,07fh,07fh,07fh,07fh,07fh	; b5bc  ........
	defb 07fh,07fh,07fh,07fh,07fh,07fh,07fh,0f5h	; b5c4  ........
	defb 07fh,07fh,07fh,0f5h,0f5h,0f5h,0f5h,0f5h	; b5cc  ........
	defb 005h,005h,005h,005h,005h,005h,005h,0f5h	; b5d4  ........
	defb 005h,005h,005h,005h,005h,005h,005h,0f5h	; b5dc  ........
	defb 0f5h,005h,005h,0f5h,0f5h,0f5h,0f5h,0f5h	; b5e4  ........
	defb 005h,005h,005h,0f5h,0f5h,0f5h,0f5h,0efh	; b5ec  ........
	defb 005h,005h,005h,005h,0f5h,0f5h,0f5h,0feh	; b5f4  ........
	defb 005h,005h,005h,005h,005h,005h,005h,0f5h	; b5fc  ........
	defb 005h,005h,005h,005h,0f5h,0f5h,0f5h,0f5h	; b604  ........
	defb 005h,005h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; b60c  ........
	defb 005h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; b614  ........
	defb 005h,005h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; b61c  ........
	defb 005h,005h,005h,005h,0f5h,0f5h,0f5h,0feh	; b624  ........
	defb 0feh,0feh,0feh,0f5h,0f5h,0f5h,0f5h,0f5h	; b62c  ........
	defb 0f5h,0f5h,0efh,0efh,0efh,0efh,07fh,0f5h	; b634  ........
	defb 0f5h,0f5h,0f5h,0f5h,0efh,0efh,07eh,0e7h	; b63c  ......~.
	defb 0feh,0feh,0efh,0feh,0efh,0feh,07eh,047h	; b644  ......~G
	defb 0efh,0e5h,0e5h,0e5h,0feh,0efh,0e7h,047h	; b64c  .......G
	defb 0f5h,0efh,0efh,0e5h,0e5h,0e7h,07eh,047h	; b654  ......~G
	defb 0f5h,0f5h,0f5h,0efh,0e5h,0e7h,07eh,047h	; b65c  ......~G
	defb 0feh,0feh,0f5h,0feh,0feh,0e5h,0e7h,07eh	; b664  .......~
	defb 0f5h,0f5h,0f5h,0efh,0e5h,0e5h,0e7h,047h	; b66c  .......G
	defb 0feh,0feh,0feh,0feh,0efh,0efh,0efh,0f5h	; b674  ........
	defb 0efh,0efh,0efh,0f5h,0f5h,0f5h,0feh,0f5h	; b67c  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; b684  ........
	defb 0f7h,07fh,0f7h,0f5h,0f5h,0f5h,0f5h,0f5h	; b68c  ........
	defb 047h,047h,047h,047h,07fh,07fh,07fh,04fh	; b694  GGGG...O
	defb 047h,047h,047h,047h,047h,047h,047h,047h	; b69c  GGGGGGGG
	defb 07fh,07fh,07fh,07fh,07fh,07fh,07fh,04fh	; b6a4  .......O
	defb 07fh,07fh,0f7h,0f5h,0f5h,0f5h,0f5h,0f5h	; b6ac  ........
	defb 005h,005h,0f5h,0f5h,0f5h,0f5h,0feh,0feh	; b6b4  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0feh,0feh,0feh	; b6bc  ........
	defb 0f5h,0f5h,0f5h,0f5h,0feh,0feh,0feh,0feh	; b6c4  ........
	defb 005h,0f5h,0f5h,0f5h,0feh,0feh,0feh,0feh	; b6cc  ........
	defb 005h,005h,0f5h,0f5h,0f5h,0feh,0feh,0feh	; b6d4  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0feh,0feh	; b6dc  ........
	defb 0f5h,0f5h,0f5h,0f5h,0feh,0feh,0feh,0feh	; b6e4  ........
	defb 005h,0f5h,0f5h,0f5h,0feh,0feh,0feh,0feh	; b6ec  ........
	defb 005h,005h,0f5h,0f5h,0feh,0feh,0feh,0f5h	; b6f4  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; b6fc  ........
	defb 0feh,0f7h,0f7h,0f5h,0f5h,0f5h,0f5h,0f5h	; b704  ........
	defb 07eh,075h,075h,075h,07fh,07fh,07fh,07fh	; b70c  ~uuu....
	defb 07eh,075h,075h,075h,075h,075h,075h,075h	; b714  ~uuuuuuu
	defb 07eh,075h,075h,075h,075h,075h,075h,075h	; b71c  ~uuuuuuu
	defb 07eh,075h,075h,075h,075h,075h,075h,075h	; b724  ~uuuuuuu
	defb 07eh,075h,075h,07fh,07fh,07fh,07fh,07fh	; b72c  ~uu.....
	defb 0feh,0f7h,0f7h,0f5h,0f5h,0f5h,0f5h,0f5h	; b734  ........
	defb 0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h,0f5h	; b73c  ........
	defb 0f5h,0f5h,0f5h,0feh,0f7h,0f7h,0f7h,0f5h	; b744  ........
	defb 0f5h,0f5h,0feh,0feh,0e7h,0f7h,0f7h,0f7h	; b74c  ........
	defb 005h,0f5h,0f5h,0feh,0e7h,075h,075h,075h	; b754  .....uuu
	defb 0f5h,0f5h,0f5h,0feh,0e7h,075h,075h,075h	; b75c  .....uuu
	defb 005h,0f5h,0f5h,0feh,0f7h,0f7h,0f7h,0f5h	; b764  ........
	defb 0f5h,0feh,0feh,0f5h,0f5h,0f5h,0f5h,0f5h	; b76c  ........

; ----------------------------------------------------------------------
; DATOS letras_grandes: Las letras grandes de CASIO y SKI COMMAND (16
;   casillas; la copia sigue 0xE0 bytes)
;   0xb774..0xb7f4  (128 bytes)
DATA_letras_grandes:
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; b774  ........
	defb 000h,00fh,03fh,030h,0c0h,0c0h,0c0h,0c0h	; b77c  ..?0....
	defb 0f0h,0f0h,00ch,00ch,00ch,00ch,0f0h,0f0h	; b784  ........
	defb 00ch,00ch,00ch,00ch,00ch,00ch,0f0h,0f0h	; b78c  ........
	defb 000h,000h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h	; b794  ........
	defb 000h,000h,006h,006h,018h,018h,060h,060h	; b79c  ......``
	defb 080h,080h,060h,060h,018h,018h,006h,006h	; b7a4  ..``....
	defb 000h,000h,0c0h,0c0h,0f0h,0f0h,0cch,0cch	; b7ac  ........
	defb 0c3h,0c3h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h	; b7b4  ........
	defb 000h,000h,00ch,00ch,00ch,00ch,00ch,00ch	; b7bc  ........
	defb 00ch,00ch,0cch,0cch,03ch,03ch,00ch,00ch	; b7c4  ....<<..
	defb 000h,000h,00ch,00ch,03ch,03ch,0cch,0cch	; b7cc  ....<<..
	defb 00ch,00ch,00ch,00ch,00ch,00ch,00ch,00ch	; b7d4  ........
	defb 000h,000h,0ffh,0ffh,0c0h,0c0h,0c0h,0c0h	; b7dc  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0ffh,0ffh	; b7e4  ........
	defb 000h,000h,0c0h,0c0h,030h,030h,00ch,00ch	; b7ec  ....00..

; ----------------------------------------------------------------------
; DATOS letras: La fuente: las cifras, la (c) y las letras, desde la 0x30 (la
;   copia lleva 0x180 bytes y acaba en 0xB974)
;   0xb7f4..0xb94c  (344 bytes)
DATA_letras:
	defb 03eh,041h,041h,041h,041h,041h,03eh,000h	; b7f4  >AAAAA>.
	defb 008h,008h,008h,008h,008h,008h,008h,000h	; b7fc  ........
	defb 07eh,001h,001h,03eh,040h,040h,07fh,000h	; b804  ~..>@@..
	defb 07eh,001h,001h,03eh,001h,001h,07eh,000h	; b80c  ~..>..~.
	defb 044h,044h,044h,044h,07fh,004h,004h,000h	; b814  DDDD....
	defb 07fh,040h,040h,07eh,001h,001h,07eh,000h	; b81c  .@@~..~.
	defb 03fh,040h,040h,03eh,041h,041h,03eh,000h	; b824  ?@@>AA>.
	defb 07fh,001h,001h,001h,001h,001h,001h,000h	; b82c  ........
	defb 03eh,041h,041h,03eh,041h,041h,03eh,000h	; b834  >AA>AA>.
	defb 03eh,041h,041h,03eh,001h,001h,07eh,000h	; b83c  >AA>..~.
	defb 000h,000h,03fh,03fh,0c0h,0c0h,0c0h,0c0h	; b844  ..??....
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,03fh,03fh	; b84c  ......??
	defb 000h,000h,0fch,0fch,000h,000h,000h,000h	; b854  ........
	defb 000h,000h,000h,000h,000h,000h,0fch,0fch	; b85c  ........
	defb 000h,004h,004h,004h,004h,004h,03ch,00ch	; b864  ......<.
	defb 00ch,00ch,01ch,03ch,074h,060h,040h,000h	; b86c  ...<t`@.
	defb 03ch,042h,099h,0a1h,0a1h,099h,042h,03ch	; b874  <B....B<
	defb 01ch,022h,041h,041h,07fh,041h,041h,000h	; b87c  ."AA.AA.
	defb 07eh,041h,041h,07eh,041h,041h,07eh,000h	; b884  ~AA~AA~.
	defb 03eh,041h,040h,040h,040h,041h,03eh,000h	; b88c  >A@@@A>.
	defb 07ch,042h,041h,041h,041h,042h,07ch,000h	; b894  |BAAAB|.
	defb 07fh,040h,040h,07fh,040h,040h,07fh,000h	; b89c  .@@.@@..
	defb 0ffh,0ffh,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h	; b8a4  ........
	defb 03eh,041h,040h,04fh,041h,041h,03eh,000h	; b8ac  >A@OAA>.
	defb 041h,041h,041h,07fh,041h,041h,041h,000h	; b8b4  AAA.AAA.
	defb 01ch,008h,008h,008h,008h,008h,01ch,000h	; b8bc  ........
	defb 000h,0c0h,0f0h,030h,00ch,00ch,00ch,00ch	; b8c4  ...0....
	defb 0fch,0fch,00ch,00ch,00ch,00ch,00ch,00ch	; b8cc  ........
	defb 040h,040h,040h,040h,040h,040h,07fh,000h	; b8d4  @@@@@@..
	defb 041h,063h,055h,049h,041h,041h,041h,000h	; b8dc  AcUIAAA.
	defb 041h,061h,051h,049h,045h,043h,041h,000h	; b8e4  AaQIECA.
	defb 00ch,00ch,00ch,00ch,030h,030h,0c0h,0c0h	; b8ec  ....00..
	defb 07eh,041h,041h,07eh,040h,040h,040h,000h	; b8f4  ~AA~@@@.
	defb 03fh,03fh,000h,000h,000h,000h,0ffh,0ffh	; b8fc  ??......
	defb 07eh,041h,041h,07eh,041h,041h,041h,000h	; b904  ~AA~AAA.
	defb 03eh,041h,040h,03eh,001h,041h,03eh,000h	; b90c  >A@>.A>.
	defb 07fh,008h,008h,008h,008h,008h,008h,000h	; b914  ........
	defb 041h,041h,041h,041h,041h,041h,03eh,000h	; b91c  AAAAAA>.
	defb 041h,041h,022h,022h,014h,014h,008h,000h	; b924  AA""....
	defb 000h,000h,003h,003h,003h,003h,003h,003h	; b92c  ........
	defb 003h,003h,003h,003h,003h,003h,003h,003h	; b934  ........
	defb 041h,041h,041h,07fh,008h,008h,008h,000h	; b93c  AAA.....
	defb 000h,000h,0f0h,0f0h,00ch,00ch,00ch,00ch	; b944  ........

; ======================================================================
; CODIGO 0xb94c..0xbbf6  (682 bytes)
; ======================================================================


canal:		; HL = el canal B (0xF002 + B x 0x20), y lo deja en su estado inicial (0xBC12)
	push bc			;b94c
	push de			;b94d
	ld hl,0f002h		;b94e   ; los canales desde 0xF002...
	ld a,b			;b951   ; ...de 32 en 32 bytes
	rrca			;b952
	rrca			;b953
	rrca			;b954   ; B por 32
	ld e,a			;b955
	ld d,000h		;b956
	add hl,de			;b958
	push hl			;b959   ; HL, el canal...
	inc hl			;b95a   ; ...y desde +2...
	inc hl			;b95b
	ex de,hl			;b95c
	ld hl,0bc12h		;b95d   ; ...30 bytes de 0xBC12
	ld bc,0001eh		;b960   ; 30 bytes
	ldir		;b963
	pop hl			;b965
	pop de			;b966
	pop bc			;b967
	ret			;b968
sonido_calla:		; Calla el sonido: los tres canales a cero, el PSG sin ruido y los volumenes a 0
	xor a			;b969
	ld (0f000h),a		;b96a   ; sin transporte
	ld b,a			;b96d   ; el canal 0...
	call canal		;b96e
	inc b			;b971   ; ...el 1...
	call canal		;b972
	inc b			;b975   ; ...y el 2
	call canal		;b976
	ld a,007h		;b979   ; el registro 7 del PSG (RDPSG)...
	call 00096h		;b97b
	and 0c0h		;b97e   ; ...los dos bits de los puertos se quedan...
	or 038h		;b980   ; ...los tonos apagados (0x38)...
	ld e,a			;b982
	ld a,007h		;b983
	call 00093h		;b985   ; ...WRTPSG
	xor a			;b988   ; los tres canales, callados
	ld (0f004h),a		;b989   ; ninguno suena
	ld (0f024h),a		;b98c
	ld (0f044h),a		;b98f
	ld b,002h		;b992   ; tres canales
	ld ix,0f002h		;b994
sonido_calla_uno:		; Cada canal: sin vibrato ni barrido y el volumen a 0
	call canal_para		;b998   ; cada uno...
	ld de,00020h		;b99b   ; ...el siguiente
	add ix,de		;b99e
	djnz sonido_calla_uno		;b9a0
canal_para:		; El canal deja de sonar: sin vibrato ni barrido...
	xor a			;b9a2
	ld (ix+012h),a		;b9a3   ; sin vibrato...
	ld (ix+013h),a		;b9a6   ; ...ni barrido
volumen:		; ...y el volumen E en el registro 8 + B del PSG
	ld e,a			;b9a9
	ld a,008h		;b9aa   ; el registro de volumen del canal
	add a,b			;b9ac
	jp 00093h		;b9ad
sonido_cuadro:		; Un cuadro del motor: los tres canales, del 2 al 0
	ld b,002h		;b9b0
	ld ix,0f002h		;b9b2   ; empieza por el 2
sonido_cuadro_uno:		; Un canal
	call canal_cuadro		;b9b6   ; el canal...
	ld de,00020h		;b9b9   ; el canal siguiente
	add ix,de		;b9bc   ; ...siguiente
	ld a,(0f001h)		;b9be   ; el numero de canal...
	ld b,a			;b9c1
	djnz sonido_cuadro_uno		;b9c2   ; ...uno menos
canal_cuadro:		; Un cuadro de un canal: el tempo, la nota, el vibrato, el barrido y la envolvente
	ld a,b			;b9c4
	ld (0f001h),a		;b9c5   ; el canal en curso
	ld a,(ix+002h)		;b9c8   ; suena?
	and a			;b9cb
	ret z			;b9cc
	dec (ix+00eh)		;b9cd   ; el tempo: cada tantos cuadros...
	ret nz			;b9d0   ; ...aun no
	ld a,(ix+00dh)		;b9d1   ; el tempo...
	ld (ix+00eh),a		;b9d4   ; ...vuelve a su cuenta
	dec (ix+007h)		;b9d7   ; ...la nota acaba?...
	jp z,nota		;b9da   ; ...la siguiente
	dec (ix+006h)		;b9dd   ; le queda de sonar?...
	jr z,canal_para		;b9e0   ; ...si no, calla
	ld a,(ix+012h)		;b9e2   ; el vibrato
	and a			;b9e5   ; hay vibrato?
	call nz,vibrato		;b9e6
	ld a,(ix+013h)		;b9e9   ; el barrido del ruido
	and a			;b9ec   ; hay barrido?
	call nz,barrido		;b9ed
	inc (ix+006h)		;b9f0   ; lo que le queda...
	dec (ix+006h)		;b9f3
	jp p,envolvente		;b9f6   ; ...si no ha acabado, la envolvente
canal_mudo:		; Ya no suena
	ld (ix+006h),000h		;b9f9   ; sin sonar
	ret			;b9fd
vibrato:		; El vibrato: el periodo del canal (RDPSG) mas el paso, si es de 16 o mas
	ld a,(0f001h)		;b9fe   ; el registro de periodo...
	add a,a			;ba01
	ld h,a			;ba02
	call 00096h		;ba03   ; RDPSG: la parte baja...
	ld l,a			;ba06
	inc h			;ba07
	ld a,h			;ba08
	call 00096h		;ba09   ; ...y la alta
	ld h,a			;ba0c
	or a			;ba0d   ; por encima de 16?
	jr nz,vibrato_suma		;ba0e
	ld a,l			;ba10
	cp 010h		;ba11
	ret c			;ba13
vibrato_suma:		; Le suma el paso (con signo)
	ld d,000h		;ba14
	ld a,(ix+012h)		;ba16   ; el paso...
	ld e,a			;ba19
	inc e			;ba1a
	dec e			;ba1b
	jp p,vibrato_pon		;ba1c   ; ...con signo
	dec d			;ba1f
vibrato_pon:		; Lo escribe
	add hl,de			;ba20
	ex de,hl			;ba21
	ld a,(0f001h)		;ba22   ; WRTPSG: la parte baja...
	add a,a			;ba25
	call 00093h		;ba26
	inc a			;ba29
	ld e,d			;ba2a   ; ...y la alta
	jp 00093h		;ba2b
barrido:		; El barrido del ruido: el registro 6 sube o baja y rebota entre 1 y 30
	ld a,006h		;ba2e   ; el periodo del ruido (RDPSG 6)
	call 00096h		;ba30
	cp 001h		;ba33   ; entre 1...
	jr c,barrido_rebota		;ba35
	cp 01fh		;ba37   ; ...y 30
	jr c,barrido_pon		;ba39
barrido_rebota:		; Rebota: el paso cambia de signo
	ld e,a			;ba3b
	ld a,(ix+013h)		;ba3c   ; el paso, al reves
	neg		;ba3f
	ld (ix+013h),a		;ba41
	ld a,e			;ba44
barrido_pon:		; Lo escribe
	ld e,a			;ba45
	ld a,(ix+013h)		;ba46   ; el ruido mas el paso
	add a,e			;ba49
	ld e,a			;ba4a
	ld a,006h		;ba4b   ; WRTPSG 6
	jp 00093h		;ba4d
envolvente:		; La envolvente: el paso que toca segun lo que le queda a la nota, y su volumen de la tabla del canal
	ld a,(ix+00bh)		;ba50
	cp 010h		;ba53   ; acabada?
	ret z			;ba55
	ld e,000h		;ba56   ; lo que le queda...
	ld h,e			;ba58
	ld l,(ix+006h)		;ba59   ; lo que le queda, por 16...
	add hl,hl			;ba5c
	add hl,hl			;ba5d
	add hl,hl			;ba5e
	add hl,hl			;ba5f
	ld d,(ix+005h)		;ba60   ; ...entre la duracion
	xor a			;ba63
	ld b,008h		;ba64   ; ocho bits
envolvente_div:		; La division, bit a bit
	push hl			;ba66
	srl d		;ba67   ; el divisor...
	rr e		;ba69
	and a			;ba6b
	sbc hl,de		;ba6c   ; ...cabe?
	ccf			;ba6e
	jr nc,envolvente_bit		;ba6f
	ex (sp),hl			;ba71
envolvente_bit:		; Un bit del cociente
	rla			;ba72
	pop hl			;ba73
	djnz envolvente_div		;ba74
	ld c,a			;ba76
	ld a,010h		;ba77   ; 16 menos el cociente: el paso de la envolvente
	sub c			;ba79
envolvente_paso:		; El paso: el volumen esta en la mitad alta o baja del byte de la tabla
	ld (ix+00bh),a		;ba7a
	cp 010h		;ba7d   ; 16: la envolvente se ha acabado
	ret z			;ba7f
	srl a		;ba80   ; el paso entre 2: el byte...
	push af			;ba82   ; el paso par o impar
	ld e,a			;ba83
	ld d,000h		;ba84
	ld l,(ix+009h)		;ba86   ; ...de la envolvente
	ld h,(ix+00ah)		;ba89   ; la envolvente del canal
	add hl,de			;ba8c
	ld a,(0f001h)		;ba8d   ; el canal
	ld b,a			;ba90
	pop af			;ba91
	ld a,(hl)			;ba92   ; el byte...
	jr c,envolvente_volumen		;ba93   ; impar: la mitad baja
	rrca			;ba95   ; ...su mitad alta o baja
	rrca			;ba96
	rrca			;ba97
	rrca			;ba98
envolvente_volumen:		; El volumen del paso por el volumen del canal, entre 16
	and 00fh		;ba99
	inc a			;ba9b   ; el volumen de la envolvente...
	ld e,a			;ba9c
	ld d,(ix+008h)		;ba9d   ; ...por el del canal
	xor a			;baa0
	ld c,008h		;baa1   ; ocho bits
envolvente_mult:		; La multiplicacion, bit a bit
	add a,a			;baa3
	rl e		;baa4
	jr nc,envolvente_mult_sig		;baa6
	add a,d			;baa8
envolvente_mult_sig:		; El bit siguiente
	dec c			;baa9
	jr nz,envolvente_mult		;baaa
	rrca			;baac   ; entre 16
	rrca			;baad
	rrca			;baae
	rrca			;baaf
	and 00fh		;bab0
	jp volumen		;bab2
nota:		; La nota siguiente de la pieza: una nota o una orden (0xF2-0xFF, tabla 0xBBF6)
	call pieza_lee		;bab5
	and a			;bab8
	jp p,nota_pon		;bab9   ; una nota?
	cpl			;babc   ; la orden: 0xFF es la 0, 0xFE la 1...
	add a,a			;babd   ; por dos
	push de			;babe
	ld e,a			;babf
	ld d,000h		;bac0
	ld hl,0bbf6h		;bac2   ; su rutina en la tabla 0xBBF6
	add hl,de			;bac5   ; la entrada
	pop de			;bac6
	push hl			;bac7
	ld hl,nota		;bac8   ; al acabar, otra nota
	ex (sp),hl			;bacb
	ld a,(hl)			;bacc   ; la rutina
	inc hl			;bacd
	ld h,(hl)			;bace
	ld l,a			;bacf
	jp (hl)			;bad0   ; a la orden
nota_pon:		; Una nota: A el numero, E la duracion, D hasta la siguiente; duracion 0 es un silencio
	ld (ix+005h),e		;bad1   ; la duracion...
	ld (ix+006h),e		;bad4   ; ...lo que le queda...
	ld (ix+007h),d		;bad7   ; ...y hasta la siguiente
	inc e			;bada   ; duracion 0: silencio
	dec e			;badb
	jp z,canal_para		;badc
	ld d,a			;badf
	ld a,(0f000h)		;bae0   ; mas el transporte
	add a,d			;bae3   ; ...mas la nota
	ld c,000h		;bae4   ; la octava
nota_octava:		; La octava: de 12 en 12
	cp 00ch		;bae6   ; de 12 en 12...
	jr c,nota_periodo		;bae8
	sub 00ch		;baea
	inc c			;baec
	jr nota_octava		;baed   ; ...una octava mas
nota_periodo:		; El periodo de la nota (0xBC24), partido por 2 por cada octava
	add a,a			;baef
	ld e,a			;baf0   ; la nota de la tabla...
	ld d,000h		;baf1
	ld hl,0bc24h		;baf3   ; ...0xBC24
	add hl,de			;baf6
	ld e,(hl)			;baf7
	inc hl			;baf8
	ld d,(hl)			;baf9
	ld a,c			;bafa   ; las octavas de mas...
	and a			;bafb
	jr z,nota_escribe		;bafc
nota_octava_baja:		; Una octava mas arriba
	srl d		;bafe   ; ...el periodo a la mitad
	rr e		;bb00
	dec a			;bb02
	jr nz,nota_octava_baja		;bb03
nota_escribe:		; El periodo en los registros 2B y 2B+1 del PSG
	ld a,b			;bb05   ; el registro 2B...
	add a,b			;bb06
	call 00093h		;bb07   ; ...la parte baja...
	ld e,d			;bb0a
	inc a			;bb0b
	call 00093h		;bb0c   ; ...y la alta
nota_envolvente:		; Si la envolvente es de las de tabla, desde el paso 0
	ld a,(ix+00ch)		;bb0f   ; la envolvente es de tabla?
	cp 010h		;bb12
	ret c			;bb14
	xor a			;bb15   ; desde el paso 0
	jp envolvente_paso		;bb16
orden_fin:		; Orden 0xFF: la pieza se acaba y el canal calla
	xor a			;bb19
	ld (ix+002h),a		;bb1a   ; el canal no suena...
	pop hl			;bb1d   ; ...fuera la vuelta a otra nota...
	jp canal_para		;bb1e   ; ...y calla
orden_repite:		; Orden 0xFC: vuelve a la marca si faltan repeticiones
	dec (ix+011h)		;bb21   ; una repeticion menos...
	ret z			;bb24   ; ...si es la ultima, sigue
orden_vuelve:		; Orden 0xFD: vuelve a la marca
	ld e,(ix+00fh)		;bb25   ; la marca...
	ld d,(ix+010h)		;bb28
orden_salta:		; Orden 0xF4: salta a DE
	ld (ix+003h),e		;bb2b   ; ...por donde va
	ld (ix+004h),d		;bb2e
orden_nada:		; Orden 0xFE: nada
	ret			;bb31
orden_marca:		; Orden 0xFB: la marca de la repeticion y cuantas veces
	ld (ix+011h),d		;bb32   ; cuantas veces...
	ld e,(ix+003h)		;bb35   ; ...y la marca es por donde va
	ld d,(ix+004h)		;bb38
	ld (ix+00fh),e		;bb3b
	ld (ix+010h),d		;bb3e
	ret			;bb41
orden_volumen:		; Orden 0xFA: el volumen del canal
	ld a,d			;bb42   ; el volumen, de 0 a 15
	and 00fh		;bb43
	ld (ix+008h),a		;bb45
	ret			;bb48
envolvente_psg:		; La envolvente del PSG: volumen 16 y los registros 11-13
	ld a,010h		;bb49   ; el volumen 16: la envolvente del PSG
	ld (ix+00bh),a		;bb4b
	call volumen		;bb4e   ; en el registro de volumen
	ld e,d			;bb51   ; la forma en el registro 13
	ld a,00dh		;bb52
	call 00093h		;bb54
	call pieza_lee		;bb57   ; los tres bytes siguientes...
	ld a,00bh		;bb5a   ; ...el periodo en los registros 11...
	call 00093h		;bb5c
	inc a			;bb5f
	ld e,d			;bb60   ; ...y 12
	jp 00093h		;bb61
orden_envolvente:		; Orden 0xF9: el tipo de envolvente: del PSG o de la tabla 0xBC3C
	ld (ix+00ch),d		;bb64   ; el tipo de envolvente...
	bit 4,d		;bb67   ; ...bit 4: de tabla
	jr z,envolvente_psg		;bb69
	ld a,d			;bb6b   ; la tabla: 8 bytes por envolvente...
	and 00fh		;bb6c
	add a,a			;bb6e
	add a,a			;bb6f
	add a,a			;bb70
	ld e,a			;bb71
	ld d,000h		;bb72
	ld hl,0bc3ch		;bb74
	add hl,de			;bb77
	ld (ix+009h),l		;bb78   ; ...desde 0xBC3C
	ld (ix+00ah),h		;bb7b
	ret			;bb7e
orden_mezcla:		; Orden 0xF6: tono y ruido del canal en el registro 7
	ld a,d			;bb7f   ; los bits de tono y ruido del canal...
	and 009h		;bb80
	ld l,a			;bb82
	ld h,009h		;bb83   ; ...la mascara
	ld a,b			;bb85
	and a			;bb86
	jr z,orden_mezcla_pon		;bb87
orden_mezcla_bit:		; Los bits del canal
	add hl,hl			;bb89   ; corridos al canal
	dec a			;bb8a
	jr nz,orden_mezcla_bit		;bb8b
orden_mezcla_pon:		; Los escribe
	ld a,007h		;bb8d   ; RDPSG 7
	call 00096h		;bb8f
	ld c,a			;bb92
	ld a,h			;bb93   ; fuera los del canal...
	cpl			;bb94
	and c			;bb95
	or l			;bb96   ; ...y los nuevos
	and 03fh		;bb97
	or 080h		;bb99   ; los puertos de E/S como estaban
	ld e,a			;bb9b
	ld a,007h		;bb9c   ; WRTPSG 7
	jp 00093h		;bb9e
orden_ruido:		; Orden 0xF5: el periodo del ruido y una nota de ruido
	pop af			;bba1   ; fuera la vuelta...
	push de			;bba2
	call pieza_lee		;bba3   ; ...y los tres bytes siguientes
	pop af			;bba6
ruido_nota:		; La nota de ruido: su duracion y el registro 6
	ld (ix+005h),e		;bba7   ; la duracion...
	ld (ix+006h),e		;bbaa
	ld (ix+007h),d		;bbad   ; ...y hasta la siguiente
	inc e			;bbb0
	dec e			;bbb1
	jp z,canal_para		;bbb2   ; 0: silencio
	ld e,a			;bbb5
	ld a,006h		;bbb6   ; WRTPSG 6: el periodo del ruido
	call 00093h		;bbb8
	jp nota_envolvente		;bbbb
pieza_lee:		; Los tres bytes siguientes de la pieza: A, E, D
	ld l,(ix+000h)		;bbbe   ; el principio de la pieza...
	ld h,(ix+001h)		;bbc1
	ld e,(ix+003h)		;bbc4   ; ...mas por donde va
	ld d,(ix+004h)		;bbc7
	add hl,de			;bbca
	inc de			;bbcb   ; tres mas
	inc de			;bbcc
	inc de			;bbcd
	ld (ix+003h),e		;bbce
	ld (ix+004h),d		;bbd1
	ld a,(0f001h)		;bbd4   ; el canal...
	ld b,a			;bbd7
	ld a,(hl)			;bbd8   ; A, E y D
	inc hl			;bbd9
	ld e,(hl)			;bbda
	inc hl			;bbdb
	ld d,(hl)			;bbdc
	ret			;bbdd
orden_vibrato:		; Orden 0xF3: el paso del vibrato y una nota
	pop af			;bbde
	push de			;bbdf
	call pieza_lee		;bbe0
	ld (ix+012h),a		;bbe3   ; el paso del vibrato
	pop af			;bbe6
	jp nota_pon		;bbe7
orden_barrido:		; Orden 0xF2: el paso del barrido y una nota de ruido
	pop af			;bbea
	push de			;bbeb
	call pieza_lee		;bbec
	ld (ix+013h),a		;bbef   ; el paso del barrido
	pop af			;bbf2
	jp ruido_nota		;bbf3

; ----------------------------------------------------------------------
; DATOS ordenes: Las catorce ordenes del motor (0xFF, 0xFE... 0xF2); la 0xF8 y
;   la 0xF7 no existen (0x0000)
;   0xbbf6..0xbc12  (28 bytes)
DATA_ordenes:
	defw 0bb19h,0bb31h	; bbf6  -> orden_fin orden_nada
	defw 0bb25h,0bb21h	; bbfa  -> orden_vuelve orden_repite
	defw 0bb32h,0bb42h	; bbfe  -> orden_marca orden_volumen
	defw 0bb64h,00000h	; bc02  -> orden_envolvente 0x0000
	defw 00000h,0bb7fh	; bc06  -> 0x0000 orden_mezcla
	defw 0bba1h,0bb2bh	; bc0a  -> orden_ruido orden_salta
	defw 0bbdeh,0bbeah	; bc0e  -> orden_vibrato orden_barrido

; ----------------------------------------------------------------------
; DATOS canal_inicio: El estado inicial de un canal (desde +2): suena, la
;   duracion, el volumen 8, la envolvente...
;   0xbc12..0xbc24  (18 bytes)
DATA_canal_inicio:
	defb 000h,000h,000h,001h,001h,001h,00fh,03ch,0bch,010h,010h,001h,001h,000h,000h,001h	; bc12  .......<........
	defb 000h,000h	; bc22

; ----------------------------------------------------------------------
; DATOS periodos: Los periodos de las doce notas de la octava mas baja (do a
;   si)
;   0xbc24..0xbc3c  (24 bytes)
DATA_periodos:
	defw 00d5ch,00c9dh,00be7h,00b3ch,00a9bh,00a02h,00973h,008ebh,0086bh,007f2h,00780h,00714h	; bc24

; ----------------------------------------------------------------------
; DATOS envolventes: Las cinco envolventes de tabla: 16 pasos de 4 bits (8
;   bytes cada una)
;   0xbc3c..0xbc64  (40 bytes)
DATA_envolventes:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bc3c  ........
	defb 0feh,0dch,0bah,098h,076h,054h,032h,010h	; bc44  ....vT2.
	defb 001h,023h,045h,067h,089h,0abh,0cdh,0efh	; bc4c  .#Eg....
	defb 089h,0abh,0cdh,0efh,0feh,0dch,0bah,098h	; bc54  ........
	defb 004h,08ch,0feh,0dch,0bah,098h,076h,054h	; bc5c  ......vT

; ======================================================================
; CODIGO 0xbc64..0xbd26  (194 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; Las musicas y los efectos: cada uno pone sus piezas en sus canales. Las musicas callan antes el sonido.
; ----------------------------------------------------------------------
musica_salida:		; La musica de salida de la ronda 1: tres canales (0xBD26, 0xBD63, 0xBD7F)
	call sonido_calla		;bc64   ; calla todo
	ld de,0bd26h		;bc67   ; el canal 0...
	ld b,000h		;bc6a
	call pieza		;bc6c
	ld de,0bd63h		;bc6f   ; ...el 1...
	ld b,001h		;bc72
	call pieza		;bc74
	ld de,0bd7fh		;bc77   ; ...y el 2
	ld b,002h		;bc7a
	jr pieza		;bc7c
musica_ronda:		; La musica de la ronda: un canal (0xBDA4)
	call sonido_calla		;bc7e
	ld de,0bda4h		;bc81
	ld b,000h		;bc84
	jr pieza		;bc86
musica_titulo:		; La musica del bonus: dos canales (0xBDF8, 0xBE29)
	call sonido_calla		;bc88   ; calla todo
	ld de,0bdf8h		;bc8b   ; el canal 0...
	ld b,000h		;bc8e
	call pieza		;bc90
	ld de,0be29h		;bc93   ; ...y el 1
	ld b,001h		;bc96
	jr pieza		;bc98
musica_game_over:		; GAME OVER: tres canales (0xBE5A, 0xBE73, 0xBE8C)
	call sonido_calla		;bc9a   ; calla todo
	ld de,0be5ah		;bc9d   ; el canal 0...
	ld b,000h		;bca0
	call pieza		;bca2
	ld de,0be73h		;bca5   ; ...el 1...
	ld b,001h		;bca8
	call pieza		;bcaa
	ld de,0be8ch		;bcad   ; ...y el 2
	ld b,002h		;bcb0
	jr pieza		;bcb2
musica_choque:		; La caida: un canal (0xBEA5)
	call sonido_calla		;bcb4
	ld de,0bea5h		;bcb7
	ld b,000h		;bcba
	jr pieza		;bcbc
musica_pattern_clear:		; PATTERN CLEAR: tres canales (0xBEBB, 0xBEEC, 0xBF1D)
	call sonido_calla		;bcbe   ; calla todo
	ld de,0bebbh		;bcc1   ; el canal 0...
	ld b,000h		;bcc4
	call pieza		;bcc6
	ld de,0beech		;bcc9   ; ...el 1...
	ld b,001h		;bccc
	call pieza		;bcce
	ld de,0bf1dh		;bcd1   ; ...y el 2
	ld b,002h		;bcd4
pieza:		; Pone la pieza DE en el canal B y la hace sonar
	call canal		;bcd6   ; el canal en su estado inicial
	ld (hl),e			;bcd9   ; el principio de la pieza...
	inc hl			;bcda
	ld (hl),d			;bcdb
	inc hl			;bcdc
	ld (hl),001h		;bcdd   ; ...y suena
	ret			;bcdf
efecto_disparo:		; El disparo (canal A del PSG, 0xBF33)
	ld b,002h		;bce0
	ld de,0bf33h		;bce2
	jr pieza		;bce5
efecto_enemigo:		; El enemigo que se acerca (canal B del PSG, 0xBF4F)
	ld b,001h		;bce7
	ld de,0bf4fh		;bce9
	jr pieza		;bcec
efecto_derribo:		; Un enemigo derribado (canal A del PSG, 0xBF77)
	ld b,002h		;bcee
	ld de,0bf77h		;bcf0
	jr pieza		;bcf3
efecto_aparato:		; El aparato que sale (canal B del PSG, 0xBF8A)
	ld b,001h		;bcf5
	ld de,0bf8ah		;bcf7
	jr pieza		;bcfa
efecto_diana:		; Una diana o el aparato tocados (canal B del PSG, 0xBFA0)
	ld b,001h		;bcfc
	ld de,0bfa0h		;bcfe
	jr pieza		;bd01
efecto_salto:		; El salto (canal A del PSG, 0xBFB6)
	ld b,002h		;bd03
	ld de,0bfb6h		;bd05
	jr pieza		;bd08
efecto_golpe:		; El aparato tocado, y el esquiador del bonus en la Y 0x48 (canal A del PSG, 0xBFC3)
	ld b,002h		;bd0a
	ld de,0bfc3h		;bd0c
	jr pieza		;bd0f
efecto_aparato_fuera:		; El aparato que se va (canal B del PSG, 0xBD62)
	ld b,001h		;bd11
	ld de,0bd62h		;bd13
	jr pieza		;bd16
efecto_bandera:		; Una bandera (canal A del PSG, 0xBFD6)
	ld b,002h		;bd18
	ld de,0bfd6h		;bd1a
	jr pieza		;bd1d
efecto_vida:		; Una vida extra (canal A del PSG, 0xBFEC)
	ld b,002h		;bd1f
	ld de,0bfech		;bd21
	jr pieza		;bd24

; ----------------------------------------------------------------------
; DATOS piezas: Las piezas de las seis musicas y los diez efectos: grupos de 3
;   bytes (nota u orden, y sus dos argumentos)
;   0xbd26..0xc000  (730 bytes)
DATA_piezas:
	defb 0fah,000h,00ch	; bd26
	defb 0f9h,000h,011h	; bd29
	defb 0fbh,000h,002h	; bd2c
	defb 02bh,007h,009h	; bd2f
	defb 02dh,007h,009h	; bd32
	defb 02dh,015h,01bh	; bd35
	defb 02dh,007h,012h	; bd38
	defb 02dh,007h,009h	; bd3b
	defb 02bh,007h,009h	; bd3e
	defb 02eh,007h,009h	; bd41
	defb 02eh,015h,01bh	; bd44
	defb 02eh,007h,012h	; bd47
	defb 02eh,007h,009h	; bd4a
	defb 0fch,000h,000h	; bd4d
	defb 034h,007h,009h	; bd50
	defb 032h,007h,009h	; bd53
	defb 032h,01bh,024h	; bd56
	defb 02fh,007h,009h	; bd59
	defb 02dh,007h,009h	; bd5c
	defb 02fh,036h,048h	; bd5f
	defb 0ffh,0fah,000h	; bd62
	defb 00ch,0f9h,000h	; bd65
	defb 011h,0fbh,000h	; bd68
	defb 00ch,01fh,009h	; bd6b
	defb 012h,0f6h,000h	; bd6e
	defb 001h,0f5h,000h	; bd71
	defb 018h,000h,009h	; bd74
	defb 012h,0f6h,000h	; bd77
	defb 008h,0fch,000h	; bd7a
	defb 000h,0ffh,0fah	; bd7d
	defb 000h,00ah,0f9h	; bd80
	defb 000h,011h,034h	; bd83
	defb 036h,048h,035h	; bd86
	defb 036h,048h,034h	; bd89
	defb 036h,048h,035h	; bd8c
	defb 036h,048h,040h	; bd8f
	defb 007h,009h,03eh	; bd92
	defb 007h,009h,03eh	; bd95
	defb 01bh,024h,03bh	; bd98
	defb 007h,009h,039h	; bd9b
	defb 007h,009h,03bh	; bd9e
	defb 036h,048h,0ffh	; bda1
	defb 0fah,000h,00ah	; bda4
	defb 0f9h,000h,011h	; bda7
	defb 0fbh,000h,002h	; bdaa
	defb 024h,007h,009h	; bdad
	defb 024h,007h,009h	; bdb0
	defb 028h,007h,009h	; bdb3
	defb 024h,007h,009h	; bdb6
	defb 0fch,000h,000h	; bdb9
	defb 0fbh,000h,002h	; bdbc
	defb 029h,007h,009h	; bdbf
	defb 029h,007h,009h	; bdc2
	defb 02dh,007h,009h	; bdc5
	defb 029h,007h,009h	; bdc8
	defb 0fch,007h,000h	; bdcb
	defb 0fbh,000h,002h	; bdce
	defb 024h,007h,009h	; bdd1
	defb 024h,007h,009h	; bdd4
	defb 028h,007h,009h	; bdd7
	defb 024h,007h,009h	; bdda
	defb 0fch,000h,000h	; bddd
	defb 0fbh,000h,002h	; bde0
	defb 01fh,007h,009h	; bde3
	defb 01fh,007h,009h	; bde6
	defb 023h,007h,009h	; bde9
	defb 01fh,007h,009h	; bdec
	defb 0fch,000h,000h	; bdef
	defb 0f4h,000h,000h	; bdf2
	defb 0ffh,000h,000h	; bdf5
	defb 0fah,000h,00ch	; bdf8
	defb 0f9h,000h,011h	; bdfb
	defb 02bh,018h,020h	; bdfe
	defb 02bh,00ch,010h	; be01
	defb 02dh,00ch,010h	; be04
	defb 02bh,00ch,010h	; be07
	defb 028h,030h,040h	; be0a
	defb 030h,00ch,010h	; be0d
	defb 02fh,018h,020h	; be10
	defb 02dh,018h,020h	; be13
	defb 02bh,00ch,010h	; be16
	defb 029h,00ch,010h	; be19
	defb 028h,018h,020h	; be1c
	defb 029h,00ch,010h	; be1f
	defb 026h,018h,020h	; be22
	defb 024h,024h,030h	; be25
	defb 0ffh,0fah,000h	; be28
	defb 00bh,0f9h,000h	; be2b
	defb 011h,024h,018h	; be2e
	defb 020h,024h,00ch	; be31
	defb 010h,026h,00ch	; be34
	defb 010h,024h,00ch	; be37
	defb 010h,021h,030h	; be3a
	defb 040h,029h,00ch	; be3d
	defb 010h,028h,018h	; be40
	defb 020h,026h,018h	; be43
	defb 020h,024h,00ch	; be46
	defb 010h,022h,00ch	; be49
	defb 010h,021h,018h	; be4c
	defb 020h,022h,00ch	; be4f
	defb 010h,029h,018h	; be52
	defb 020h,028h,024h	; be55
	defb 030h,0ffh,0fah	; be58
	defb 000h,00ch,035h	; be5b
	defb 007h,009h,034h	; be5e
	defb 007h,009h,032h	; be61
	defb 007h,009h,030h	; be64
	defb 007h,009h,032h	; be67
	defb 009h,012h,037h	; be6a
	defb 007h,012h,03ch	; be6d
	defb 036h,048h,0ffh	; be70
	defb 0fah,000h,00ch	; be73
	defb 039h,007h,009h	; be76
	defb 037h,007h,009h	; be79
	defb 035h,007h,009h	; be7c
	defb 034h,007h,009h	; be7f
	defb 035h,009h,012h	; be82
	defb 03bh,007h,012h	; be85
	defb 02bh,036h,048h	; be88
	defb 0ffh,0fah,000h	; be8b
	defb 00bh,021h,007h	; be8e
	defb 009h,01fh,007h	; be91
	defb 009h,01dh,007h	; be94
	defb 009h,01ch,007h	; be97
	defb 009h,01ah,009h	; be9a
	defb 012h,01fh,007h	; be9d
	defb 012h,018h,036h	; bea0
	defb 048h,0ffh,0fah	; bea3
	defb 000h,00fh,030h	; bea6
	defb 007h,009h,02fh	; bea9
	defb 007h,009h,02eh	; beac
	defb 007h,009h,02dh	; beaf
	defb 007h,009h,02ch	; beb2
	defb 007h,009h,02bh	; beb5
	defb 007h,009h,0ffh	; beb8
	defb 0fah,000h,00ch	; bebb
	defb 0f9h,000h,011h	; bebe
	defb 037h,007h,009h	; bec1
	defb 035h,007h,009h	; bec4
	defb 034h,007h,009h	; bec7
	defb 032h,007h,009h	; beca
	defb 035h,007h,009h	; becd
	defb 034h,007h,009h	; bed0
	defb 032h,007h,009h	; bed3
	defb 030h,007h,009h	; bed6
	defb 034h,007h,009h	; bed9
	defb 032h,007h,009h	; bedc
	defb 030h,007h,009h	; bedf
	defb 02fh,007h,009h	; bee2
	defb 02fh,009h,012h	; bee5
	defb 030h,012h,024h	; bee8
	defb 0ffh,0fah,000h	; beeb
	defb 00ch,0f9h,000h	; beee
	defb 011h,02bh,007h	; bef1
	defb 009h,029h,007h	; bef4
	defb 009h,028h,007h	; bef7
	defb 009h,026h,007h	; befa
	defb 009h,029h,007h	; befd
	defb 009h,028h,007h	; bf00
	defb 009h,026h,007h	; bf03
	defb 009h,024h,007h	; bf06
	defb 009h,028h,007h	; bf09
	defb 009h,026h,007h	; bf0c
	defb 009h,024h,007h	; bf0f
	defb 009h,023h,007h	; bf12
	defb 009h,023h,009h	; bf15
	defb 012h,024h,012h	; bf18
	defb 024h,0ffh,0fah	; bf1b
	defb 000h,00bh,0f9h	; bf1e
	defb 000h,011h,01fh	; bf21
	defb 012h,024h,01dh	; bf24
	defb 012h,024h,01ch	; bf27
	defb 012h,024h,017h	; bf2a
	defb 009h,012h,018h	; bf2d
	defb 012h,024h,0ffh	; bf30
	defb 0fah,000h,00fh	; bf33
	defb 0f6h,000h,000h	; bf36
	defb 054h,001h,001h	; bf39
	defb 0f9h,000h,011h	; bf3c
	defb 0f5h,000h,01eh	; bf3f
	defb 000h,003h,004h	; bf42
	defb 0f5h,000h,01eh	; bf45
	defb 000h,018h,024h	; bf48
	defb 0f6h,000h,008h	; bf4b
	defb 0ffh,0f6h,000h	; bf4e
	defb 000h,0fah,000h	; bf51
	defb 00ch,0f9h,000h	; bf54
	defb 012h,040h,00eh	; bf57
	defb 00eh,0f9h,000h	; bf5a
	defb 010h,03fh,003h	; bf5d
	defb 003h,03eh,002h	; bf60
	defb 002h,03dh,001h	; bf63
	defb 001h,03ch,001h	; bf66
	defb 001h,03bh,001h	; bf69
	defb 001h,03ah,001h	; bf6c
	defb 001h,0f9h,000h	; bf6f
	defb 011h,039h,020h	; bf72
	defb 020h,0ffh,0fah	; bf75
	defb 000h,00fh,0f9h	; bf78
	defb 000h,011h,00ch	; bf7b
	defb 001h,001h,0f6h	; bf7e
	defb 000h,000h,0f5h	; bf81
	defb 000h,01fh,000h	; bf84
	defb 040h,060h,0ffh	; bf87
	defb 0fah,000h,00ch	; bf8a
	defb 050h,001h,001h	; bf8d
	defb 0f6h,000h,000h	; bf90
	defb 0f2h,000h,014h	; bf93
	defb 006h,004h,004h	; bf96
	defb 0fdh,000h,000h	; bf99
	defb 0f6h,000h,008h	; bf9c
	defb 0ffh,0fah,000h	; bf9f
	defb 00fh,00ch,001h	; bfa2
	defb 001h,0f9h,000h	; bfa5
	defb 014h,0f6h,000h	; bfa8
	defb 000h,0f5h,000h	; bfab
	defb 01fh,000h,060h	; bfae
	defb 090h,0f6h,000h	; bfb1
	defb 008h,0ffh,0fah	; bfb4
	defb 000h,00ch,0f6h	; bfb7
	defb 000h,008h,0f3h	; bfba
	defb 000h,02bh,0f6h	; bfbd
	defb 015h,020h,0ffh	; bfc0
	defb 0fah,000h,00fh	; bfc3
	defb 0f9h,000h,013h	; bfc6
	defb 0f6h,000h,000h	; bfc9
	defb 0f5h,000h,01fh	; bfcc
	defb 000h,007h,009h	; bfcf
	defb 0f6h,000h,008h	; bfd2
	defb 0ffh,0f6h,000h	; bfd5
	defb 008h,0fah,000h	; bfd8
	defb 00ch,030h,002h	; bfdb
	defb 004h,02eh,002h	; bfde
	defb 004h,02fh,002h	; bfe1
	defb 004h,02dh,002h	; bfe4
	defb 004h,02bh,002h	; bfe7
	defb 004h,0ffh,0f6h	; bfea
	defb 000h,008h,03ah	; bfed
	defb 002h,006h,030h	; bff0
	defb 002h,006h,0ffh	; bff3
	defb 000h,000h,0ffh	; bff6
	defb 0ffh,0ffh,0ffh	; bff9
	defb 0ffh,0ffh,0ffh	; bffc
	defb 0ffh	; bfff
