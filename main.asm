; jump to the main os boot
SET PC, os_boot

msg_os_boot:
  .dat "Booting...", 0

color_white:
  .dat 0xF100

; main os boot
os_boot:

; find hardware
JSR hw_find

; map video ram
SET A, 0
SET B, 0x8000
HWI [hw_lem1802]

; set the border color
SET A, 3
SET B, 0
HWI [hw_lem1802]

; output the boot message
SET A, msg_os_boot
SET B, [color_white]
SET C, 0
SET X, 0
JSR puts

; hang function
hang:
SET PC, hang

; ===============
; = SUBROUTINES =
; ===============

; puts
; Sets memory starting at 0x8000+c to zero-terminated string started at A, color B.
; If X is 1 then the string is blinking.
puts:
SET PUSH, C
.loop:
SET PUSH, A
ADD A, C
SET A, [A]
JSR putc
ADD C, 1
SET A, POP
SET PUSH, A
ADD A, C
IFE [A], 0
  SET PC, .done
SET A, POP
SET PC, .loop
.done:
SET A, POP
SET C, POP
SET PC, POP

; puts
; Set [0x8000+c] to char A color B. If X is 1 then the char is blinking.
putc:
SET PUSH, A
SET PUSH, B
AND A, 0x7F
AND B, 0xFF00
BOR A, B
IFE X, 1
  BOR A, 0x80
SET [0x8000+C], A
SET B, POP
SET A, POP
SET PC, POP

; sets the hw_(name) values in memory to
; the hardware's ID for interrupts
hw_find:
HWN I
SET J, 0

.loop:
HWQ J

IFE A, 0xf615
  IFE B, 0x7349
    SET [hw_lem1802], J

IFE A, 0x7406
  IFE B, 0x30cf
    SET [hw_generickeyboard], J

IFE A, 0x24c5
  IFE B, 0x4fd5
    SET [hw_m35fd], J

ADD J, 1
IFN I, J
  SET PC, .loop

SET PC, POP

:hw_lem1802
  .dat 0
:hw_generickeyboard
  .dat 0
:hw_m35fd
  .dat 0
