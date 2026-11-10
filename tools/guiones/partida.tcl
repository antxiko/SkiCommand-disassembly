# Una partida con el teclado: la barra en el cuadro 150 empieza; luego el disparo (barra) cada 9 cuadros y
# una direccion distinta cada 40 (fila 8: 0x10 izquierda, 0x20 arriba, 0x40 abajo, 0x80 derecha). 4000 cuadros.
proc guion {n} {
    if {$n == 150} { keymatrixdown 8 0x01 }
    if {$n == 156} { keymatrixup 8 0x01 }
    if {$n > 300} {
        if {$n % 9 == 0} { keymatrixdown 8 0x01 }
        if {$n % 9 == 4} { keymatrixup 8 0x01 }
        if {$n % 40 == 0} {
            keymatrixup 8 0xF0
            keymatrixdown 8 [lindex {0x10 0x80 0x40 0x20 0x10 0x80} [expr {($n / 40) % 6}]]
        }
    }
    return [expr {$n >= 4000}]
}
