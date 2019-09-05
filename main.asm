;== Include MemoryMap, HeaderInfo, and interrupt Vector table ==
.INCLUDE "header.inc"

;== Include Library Routines ==
.INCLUDE "InitSNES.asm"
.INCLUDE "LoadGraphics.asm"

;==========================================
; Main Code
;==========================================

.BANK 0 SLOT 0
.ORG 0
.SECTION "MainCode"

Main:
    InitializeSNES							;Initialize the SNES

    rep #$10								;Set X/Y to 16-bit
    sep #$20								;Set A to 8-bit

	lda #$80
	sta $2115

	jsr PlaceScreen

    LoadPalette SwitchPalette, 0, 16			;Load the background palette

    LoadBlockToVRAM SwitchTiles, $0000, SwitchTilesEnd-SwitchTiles	;Load the background tiles

    jsr SetupVideo							;Setup video

	lda #$81
	sta $4200								;Enable NMI and Joypad Auto-Read

	lda #$0F
    sta $2100      							; Turn on screen, full Brightness

	jsr MosaicEffect						; Do the mosaic effect
	
Infinity:

	wai				;Wait for interrupt
    jmp Infinity	;Jump to Infinity

;============================================================================
VBlank:
    rep #$30        ; A/mem=16 bits, X/Y=16 bits (to push all 16 bits)
    phb
	pha
	phx
	phy
	phd
	
	sep #$20		;Set A to 8-bit
	rep #$10		;Set X/Y to 16-bit

    lda $4210       ; Clear NMI flag

	ldx #$0000

	lda $00		;Load $0002 into A
	sta $210D		;Store A into the low byte of $210D (BG1HOFS)
	stx $210D		;Store X into the high byte of $210D

	lda $00
	sta $210E		;Store A into the low byte of $210E (BG1VOFS)
	stx $210E		;Store X into the high byte of $210E

	lda $0002
	sta $210F
	stx $210F
	
	lda $0003
	sta $2110
	stx $2110

	rep #$20		;Set A to 16-bit

	;sep #$10

    pld 
	ply 
	plx 
	pla 
	plb 

    sep #$30
    rti
;============================================================================

MosaicEffect:
	lda #$FF
	sta $2106
Loop:
	sbc #$10
	sta $2106
	wai
	wai
	wai
	wai
	wai
	wai
	wai
	wai
	cmp #$0F
	bne Loop
	rts

PlaceScreen:
	rep #$10								;Set X/Y to 16-bit
    sep #$20								;Set A to 8-bit
	ldx #$4000
	stx $2116
	ldx #$0000
PlaceScreenLoop:
	stx $2118
	inx
	cpx #$0380
	beq Done
	jmp PlaceScreenLoop
Done:
	rts

;============================================================================
; SetupVideo -- Sets up the video mode and tile-related registers
;----------------------------------------------------------------------------
; In: None
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
SetupVideo:

    lda #$01
    sta $2105      ; Set Video mode 1

    lda #$40      
    sta $2107	   ; Set BG1's Tile Map offset to $1C00 (Word address)

    lda #$01       ; Enable BG1
    sta $212C

    rts

.ENDS
;============================================================================

.BANK 1 SLOT 0
.ORG 0
.SECTION "CharacterData"

.INCLUDE "switch.inc"

.ENDS