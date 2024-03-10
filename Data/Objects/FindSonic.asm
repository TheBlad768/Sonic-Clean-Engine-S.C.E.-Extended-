
; =============== S U B R O U T I N E =======================================

Find_Sonic:
Find_SonicObject:
		lea	(Player_1).w,a1

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

; =============== S U B R O U T I N E =======================================

Find_SonicTails:
		moveq	#0,d0				; d0 = 0 if Sonic/Tails is left of object, 2 if right of object
		lea	(Player_1).w,a1
		move.w	x_pos(a0),d2
		sub.w	x_pos(a1),d2
		bpl.s	.sleft
		neg.w	d2
		addq.w	#2,d0

.sleft
		moveq	#0,d1				; d1 = 0 if Sonic/Tails is above object, 2 if below object
		lea	(Player_2).w,a2
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
