; ---------------------------------------------------------------------------
; Knuckles Animation Script
; ---------------------------------------------------------------------------

AniKnuckles:
Ani_Knuckles: offsetTable
		offsetTableEntry.w AniKnux00			; 0
		offsetTableEntry.w AniKnux01			; 1
		offsetTableEntry.w AniKnux02			; 2
		offsetTableEntry.w AniKnux03			; 3
		offsetTableEntry.w AniKnux04			; 4
		offsetTableEntry.w AniKnux05			; 5
		offsetTableEntry.w AniKnux06			; 6
		offsetTableEntry.w AniKnux07			; 7
		offsetTableEntry.w AniKnux08			; 8
		offsetTableEntry.w AniKnux09			; 9
		offsetTableEntry.w AniKnux0A			; A
		offsetTableEntry.w AniKnux0B			; B
		offsetTableEntry.w AniKnux0C			; C
		offsetTableEntry.w AniKnux0D			; D
		offsetTableEntry.w AniKnux0E			; E
		offsetTableEntry.w AniKnux0F			; F
		offsetTableEntry.w AniKnux10			; 10
		offsetTableEntry.w AniKnux11			; 11
		offsetTableEntry.w AniKnux12			; 12
		offsetTableEntry.w AniKnux13			; 13
		offsetTableEntry.w AniKnux14			; 14
		offsetTableEntry.w AniKnux15			; 15
		offsetTableEntry.w AniKnux16			; 16
		offsetTableEntry.w AniKnux17			; 17
		offsetTableEntry.w AniKnux18			; 18
		offsetTableEntry.w AniKnux19			; 19
		offsetTableEntry.w AniKnux1A			; 1A
		offsetTableEntry.w AniKnux1B			; 1B
		offsetTableEntry.w AniKnux1C			; 1C
		offsetTableEntry.w AniKnux1D			; 1D
		offsetTableEntry.w AniKnux1E			; 1E
		offsetTableEntry.w AniKnux1F			; 1F
		offsetTableEntry.w AniKnux20			; 20
		offsetTableEntry.w AniKnux21			; 21
		offsetTableEntry.w AniKnux22			; 22
		offsetTableEntry.w AniKnux23			; 23
		offsetTableEntry.w AniKnux24			; 24
		offsetTableEntry.w KnuxAni_Carry		; 25
		offsetTableEntry.w KnuxAni_Carry2		; 26

AniKnux00:	dc.b  $FF,   7,	  8,   1,   2,	 3,   4,   5,	6, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
AniKnux01:	dc.b  $FF, $21,	$22, $23, $24, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
AniKnux02:	dc.b  $FE, $9A,	$96, $9A, $97, $9A, $98, $9A, $99, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
AniKnux03:	dc.b  $FE, $9A,	$96, $9A, $97, $9A, $98, $9A, $99, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
AniKnux04:	dc.b  $FD, $CE,	$CF, $D0, $D1, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
AniKnux05:	dc.b    5, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56
			dc.b  $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56
			dc.b  $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $D2, $D2, $D2, $D3, $D3, $D3, $D2, $D2, $D2
			dc.b  $D3, $D3, $D3, $D2, $D2, $D2, $D3, $D3, $D3, $D2, $D2, $D2, $D3, $D3, $D3, $D2, $D2, $D2, $D3, $D3
			dc.b  $D3, $D2, $D2, $D2, $D3, $D3, $D3, $D2, $D2, $D2, $D3, $D3, $D3, $D2, $D2, $D2, $D3, $D3, $D3, $D2
			dc.b  $D2, $D2, $D3, $D3, $D3, $D4, $D4, $D4, $D4, $D4, $D7, $D8, $D9, $DA, $DB, $D8, $D9, $DA, $DB, $D8
			dc.b  $D9, $DA, $DB, $D8, $D9, $DA, $DB, $D8, $D9, $DA, $DB, $D8, $D9, $DA, $DB, $D8, $D9, $DA, $DB, $D8
			dc.b  $D9, $DA, $DB, $DC, 221, 220, 221, 222, 222, 216, 215, 255
AniKnux06:	dc.b    3, $9F, $9F, $A0, $A0, $A1, $A1, $A2, $A2, $A3, $A3, $A4, $A4, $A5, $A5, $A5, $A5, $A5, $A5, $A5
			dc.b  $A5, $A5, $A5, $A5, $A5, $A5, $A5, $A5, $A6, $A6, $A6, $A7, $A7, $A7, $A8, $A8, $A9, $A9, $AA, $AA
			dc.b  $FE,   6
AniKnux07:	dc.b	5, $D5,	$D6, $FE,   1
AniKnux08:	dc.b	5, $9B,	$9C, $FE,   1
AniKnux09:	dc.b	0, $86,	$87, $86, $88, $86, $89, $86, $8A, $86,	$8B, $FF
AniKnux0A:	dc.b    9, $BA, $C5, $C6, $C6, $C6, $C6, $C6, $C6, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7
			dc.b  $C7, $FD,   0
AniKnux0B:	dc.b   $F, $8F,	$FF
AniKnux0C:	dc.b    3, $A1, $A1, $A2, $A2, $A3, $A3, $A4, $A4, $A5, $A5, $A5, $A5, $A5, $A5, $A5, $A5, $A5, $A5, $A5
			dc.b  $A5, $A5, $A5, $A5, $A6, $A6, $A6, $A7, $A7, $A7, $A8, $A8, $A9, $A9, $AA, $AA, $FE,   6
AniKnux0D:	dc.b	3, $9D,	$9E, $9F, $A0, $FD,   0
AniKnux0E:	dc.b	7, $C0,	$FF
AniKnux0F:	dc.b	5, $C0,	$C1, $C2, $C3, $C4, $C5, $C6, $C7, $C8,	$C9, $FF
AniKnux10:	dc.b  $2F, $8E,	$FD,   0
AniKnux11:	dc.b	1, $AE,	$AF, $FF
AniKnux12:	dc.b   $F, $43,	$43, $43, $FE,	 1
AniKnux13:	dc.b	5, $B1,	$B2, $B2, $B2, $B3, $B4, $FE,	1
AniKnux14:	dc.b  $13, $91,	$FF
AniKnux15:	dc.b   $B, $B0,	$B0,   3,   4, $FD,   0
AniKnux16:	dc.b  $20, $AC,	$FF
AniKnux17:	dc.b  $20, $AD,	$FF
AniKnux18:	dc.b  $20, $AB,	$FF
AniKnux19:	dc.b	9, $8C,	$FF
AniKnux1A:	dc.b  $40, $8D,	$FF
AniKnux1B:	dc.b	9, $8C,	$FF
AniKnux1C:	dc.b  $77,   0,	$FF
AniKnux1D:	dc.b  $13, $D0,	$D1, $FF
AniKnux1E:	dc.b	3, $CF,	$C8, $C9, $CA, $CB, $FE,   4
AniKnux20:	dc.b  $1F, $C0,	$FF
AniKnux21:	dc.b	7, $CA,	$CB, $FE,   1
AniKnux22:	dc.b   $F, $CD,	$FD,   0
AniKnux23:	dc.b   $F, $9C,	$FD,   0
AniKnux24:	dc.b	7, $B1,	$B3, $B3, $B3, $B3, $B3, $B3, $B2, $B3,	$B4, $B3, $FE,	 4
AniKnux1F:	dc.b	2, $EB,	$EB, $EC, $ED, $EC, $ED, $EC, $ED, $EC,	$ED, $EC, $ED, $FD,   0
KnuxAni_Carry:		dc.b   $B, $90, $91, $92, $91, $FF
KnuxAni_Carry2:		dc.b   $B, $90, $91, $92, $91, $FD,   0
	even
