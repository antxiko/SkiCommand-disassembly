# Tres rondas enteras sin chocar: los dos sitios que apuntan el choque (0x899A y 0x8A30, "ld (0xE8FA),a") se saltan.
# La barra en el cuadro 150 empieza; el disparo cada 9 cuadros, a izquierda y derecha a tramos de 40 y un salto
# (GRAPH) cada 300. 13000 cuadros.
debug set_bp 0x899A {} { reg pc 0x899D }
debug set_bp 0x8A30 {} { reg pc 0x8A33 }
proc guion {n} {
    if {$n == 150} { keymatrixdown 8 0x01 }
    if {$n == 156} { keymatrixup 8 0x01 }
    if {$n > 300} {
        if {$n % 9 == 0} { keymatrixdown 8 0x01 }
        if {$n % 9 == 4} { keymatrixup 8 0x01 }
        if {$n % 40 == 0} {
            keymatrixup 8 0xF0
            keymatrixdown 8 [lindex {0x10 0x80 0x80 0x10} [expr {($n / 40) % 4}]]
        }
        if {$n % 300 == 0} { keymatrixdown 6 0x04 }
        if {$n % 300 == 10} { keymatrixup 6 0x04 }
    }
    return [expr {$n >= 13000}]
}
