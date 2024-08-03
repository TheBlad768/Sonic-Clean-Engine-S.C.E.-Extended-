; ---------------------------------------------------------------------------
; Palette cycling routine loading subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_Palette:
		tst.w	(Palette_fade_timer).w
		bmi.s	AnimateTiles_NULL
		beq.s	.load
		subq.w	#1,(Palette_fade_timer).w
		jmp	(Pal_FromBlack).w
; ---------------------------------------------------------------------------

.load
		move.l	(Level_data_addr_RAM.AnPal).w,d0
		beq.s	AnimateTiles_NULL
		movea.l	d0,a0
		jmp	(a0)