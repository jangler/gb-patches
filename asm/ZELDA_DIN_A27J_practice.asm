# this makes hearts display used interaction slots instead of health.
# might be helpful for practicing rooster adventure.

02/:
	define rSVBK,70
	define TILE_HEART_EMPTY,0b
	define TILE_HEART_FULL,0f
	define queueDmaTransfer,0566

02/52ff/:
	call overwriteHeartDisplay

02/overwriteHeartDisplay:
	push bc
	push de
	push hl

	# get bitset from objects bank
	ld a,01
	ld (ff00+rSVBK),a
	call getInteractionSlots
	ld a,04
	ld (ff00+rSVBK),a

	# top row
	ld hl,d24d
	ld a,01
	.loop1
	ld (hl),TILE_HEART_EMPTY
	ld e,a
	and b
	ld a,e
	jr z,.empty1
	ld (hl),TILE_HEART_FULL
	.empty1
	inc l
	add a,a
	jr nz,.loop1

	# bottom row
	ld l,6d
	ld a,01
	.loop2
	ld (hl),TILE_HEART_EMPTY
	ld e,a
	and c
	ld a,e
	jr z,.empty2
	ld (hl),TILE_HEART_FULL
	.empty2
	inc l
	add a,a
	jr nz,.loop2

	ld bc,0304
	ld de,9fc0
	ld hl,d240
	call queueDmaTransfer

	pop hl
	pop de
	pop bc

	ld a,(cbe9)
	ret

# return bc where each bit is a flag indicating whether dx40 is nonzero.
# starts at d240 for rooster adventure purposes, returns in heart order.
02/getInteractionSlots:
	ld bc,0000
	push de
	push hl

	# 2-8
	ld a,01
	ld hl,d240
	.loop1
	bit 0,(hl)
	jr z,.empty1
	ld e,a
	or b
	ld b,a
	ld a,e
	.empty1
	inc h
	add a,a
	cp a,80
	jr nz,.loop1

	# 9-f
	ld a,01
	.loop2
	bit 0,(hl)
	jr z,.empty2
	ld e,a
	or c
	ld c,a
	ld a,e
	.empty2
	inc h
	add a,a
	cp a,80
	jr nz,.loop2

	pop hl
	pop de
	ret
