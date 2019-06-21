# this patch alternates overworld delay between one and two frames, effectively
# increasing the speed of everything in the overworld by 1/3. this uses bit 0
# of WRAM address $cfbd and the end of bank $25.

_967b0:
	call 7fa1

_97fa1:
	ld a,(cfbd)
	bit 0,a
	jr z,.next
	and a,fe
	ld (cfbd),a
	ld a,02
	ret
.next
	or a,01
	ld (cfbd),a
	ld a,01
	ret
