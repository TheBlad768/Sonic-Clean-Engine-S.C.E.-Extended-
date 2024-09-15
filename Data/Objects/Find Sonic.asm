; ---------------------------------------------------------------------------
; Find Sonic subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Find_SonicObject:
		lea	(Player_1).w,a1			; a1=character

Find_OtherObject:
		moveq	#0,d0				; d0 = 0 if other object is left of calling object, 2 if right of it
		move.w	x_pos(a0),d2
		sub.w	x_pos(a1),d2
		bpl.s	.left
		neg.w	d2
		addq.w	#2,d0

.left
		moveq	#0,d1				; d1 = 0 if other object is above calling object, 2 if below it
		move.w	y_pos(a0),d3
		sub.w	y_pos(a1),d3
		bpl.s	.up
		neg.w	d3
		addq.w	#2,d1

.up
		rts

; ---------------------------------------------------------------------------
; Find Sonic and Tails subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Find_SonicTails:
		moveq	#0,d0				; d0 = 0 if Sonic/Tails is left of object, 2 if right of object
		lea	(Player_1).w,a1			; a1=character
		move.w	x_pos(a0),d2
		sub.w	x_pos(a1),d2
		bpl.s	.sleft
		neg.w	d2
		addq.w	#2,d0

.sleft
		moveq	#0,d1				; d1 = 0 if Sonic/Tails is above object, 2 if below object
		lea	(Player_2).w,a2			; a2=character
		move.w	x_pos(a0),d3
		sub.w	x_pos(a2),d3
		bpl.s	.tleft
		neg.w	d3
		addq.w	#2,d1

.tleft
		cmp.w	d3,d2
		bls.s		.ypos
		movea.w	a2,a1
		move.w	d1,d0
		move.w	d3,d2

.ypos
		moveq	#0,d1
		move.w	y_pos(a0),d3
		sub.w	y_pos(a1),d3
		bpl.s	.up
		neg.w	d3
		addq.w	#2,d1

.up
		rts

; ---------------------------------------------------------------------------
; Find Sonic and Tails subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Find_SonicTails8Way:
		bsr.s	Find_SonicTails		; this routine seems bugged slightly. Shouldn't the first two cmpi instructions look at d3 and not d2?
		cmp.w	d2,d3
		beq.s	loc_853E2
		bhi.s	loc_853BC
		swap	d3					; if y distance is closer to object
		clr.w	d3
		divu.w	d2,d3
		tst.w	d0
		beq.s	loc_853AE
		cmpi.w	#$8000,d2			; if y was closer and Sonic is to right of object
		blo.s		loc_853FE
		tst.w	d0
		beq.s	loc_853FA
		bra.s	loc_85402
; ---------------------------------------------------------------------------

loc_853AE:
		cmpi.w	#$8000,d2			; if y was closer and Sonic is to left of object
		blo.s		loc_8540E
		tst.w	d1
		bne.s	loc_8540A
		bra.s	loc_85412
; ---------------------------------------------------------------------------

loc_853BC:
		swap	d2					; if x distance is closer to object
		clr.w	d2
		divu.w	d3,d2
		tst.w	d1
		bne.s	loc_853D4
		cmpi.w	#$8000,d2
		blo.s		loc_853F6
		tst.w	d0
		bne.s	loc_853FA
		bra.s	loc_85412
; ---------------------------------------------------------------------------

loc_853D4:
		cmpi.w	#$8000,d2
		blo.s		loc_85406
		tst.w	d0
		bne.s	loc_85402
		bra.s	loc_8540A
; ---------------------------------------------------------------------------

loc_853E2:
		tst.w	d0					; if X and Y distance are identical
		beq.s	loc_853EE
		tst.w	d1
		beq.s	loc_853FA
		bra.s	loc_85402
; ---------------------------------------------------------------------------

loc_853EE:
		tst.w	d1
		bne.s	loc_8540A
		bra.s	loc_85412
; ---------------------------------------------------------------------------

loc_853F6:
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_853FA:
		moveq	#1,d4
		rts
; ---------------------------------------------------------------------------

loc_853FE:
		moveq	#2,d4
		rts
; ---------------------------------------------------------------------------

loc_85402:
		moveq	#3,d4
		rts
; ---------------------------------------------------------------------------

loc_85406:
		moveq	#4,d4
		rts
; ---------------------------------------------------------------------------

loc_8540A:
		moveq	#5,d4
		rts
; ---------------------------------------------------------------------------

loc_8540E:
		moveq	#6,d4
		rts
; ---------------------------------------------------------------------------

loc_85412:
		moveq	#7,d4
		rts
