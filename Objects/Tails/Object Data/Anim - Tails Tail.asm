; ---------------------------------------------------------------------------
; Tails Tail Animation Script
; ---------------------------------------------------------------------------

AniTails_Tail:
Ani_Tails_Tail: offsetTable
		offsetTableEntry.w AniTails_Tail00			; 0
		offsetTableEntry.w AniTails_Tail01			; 1
		offsetTableEntry.w AniTails_Tail02			; 2
		offsetTableEntry.w AniTails_Tail03			; 3
		offsetTableEntry.w AniTails_Tail04			; 4
		offsetTableEntry.w AniTails_Tail05			; 5
		offsetTableEntry.w AniTails_Tail06			; 6
		offsetTableEntry.w AniTails_Tail07			; 7
		offsetTableEntry.w AniTails_Tail08			; 8
		offsetTableEntry.w AniTails_Tail09			; 9
		offsetTableEntry.w AniTails_Tail0A			; A
		offsetTableEntry.w AniTails_Tail0B			; B
		offsetTableEntry.w AniTails_Tail0C			; C

AniTails_Tail00:	dc.b  $20,   0,	$FF
AniTails_Tail01:	dc.b	7, $22,	$23, $24, $25, $26, $FF
AniTails_Tail02:	dc.b	3, $22,	$23, $24, $25, $26, $FD,   1
AniTails_Tail03:	dc.b  $FC,   5,	  6,   7,   8, $FF
AniTails_Tail04:	dc.b	3,   9,	 $A,  $B,  $C, $FF
AniTails_Tail05:	dc.b	3,  $D,	 $E,  $F, $10, $FF
AniTails_Tail06:	dc.b	3, $11,	$12, $13, $14, $FF
AniTails_Tail07:	dc.b	2,   1,	  2,   3,   4, $FF
AniTails_Tail08:	dc.b	2, $1A,	$1B, $1C, $1D, $FF
AniTails_Tail09:	dc.b	9, $1E,	$1F, $20, $21, $FF
AniTails_Tail0A:	dc.b	9, $29,	$2A, $2B, $2C, $FF
AniTails_Tail0B:	dc.b	1, $27,	$28, $FF
AniTails_Tail0C:	dc.b	0, $27,	$28, $FF
	even