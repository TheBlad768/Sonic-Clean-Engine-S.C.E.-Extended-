; ===========================================================================
; Level object pointers
; ===========================================================================

Obj_Index:
		dc.l Obj_Ring							; $00
		dc.l Obj_Monitor						; $01
		dc.l Obj_PathSwap					; $02
		dc.l Delete_Current_Sprite				; $03
		dc.l Delete_Current_Sprite				; $04
		dc.l Delete_Current_Sprite				; $05
		dc.l Delete_Current_Sprite				; $06
		dc.l Obj_Spring						; $07
		dc.l Obj_Spikes						; $08
		dc.l Delete_Current_Sprite				; $09
		dc.l Delete_Current_Sprite				; $0A
		dc.l Delete_Current_Sprite				; $0B
		dc.l Delete_Current_Sprite				; $0C
		dc.l Delete_Current_Sprite				; $0D
		dc.l Delete_Current_Sprite				; $0E
		dc.l Delete_Current_Sprite				; $0F
		dc.l Delete_Current_Sprite				; $10
		dc.l Delete_Current_Sprite				; $11
		dc.l Delete_Current_Sprite				; $12
		dc.l Delete_Current_Sprite				; $13
		dc.l Delete_Current_Sprite				; $14
		dc.l Delete_Current_Sprite				; $15
		dc.l Delete_Current_Sprite				; $16
		dc.l Delete_Current_Sprite				; $17
		dc.l Delete_Current_Sprite				; $18
		dc.l Delete_Current_Sprite				; $19
		dc.l Delete_Current_Sprite				; $1A
		dc.l Delete_Current_Sprite				; $1B
		dc.l Delete_Current_Sprite				; $1C
		dc.l Delete_Current_Sprite				; $1D
		dc.l Delete_Current_Sprite				; $1E
		dc.l Delete_Current_Sprite				; $1F
		dc.l Delete_Current_Sprite				; $20
		dc.l Delete_Current_Sprite				; $21
		dc.l Delete_Current_Sprite				; $22
		dc.l Delete_Current_Sprite				; $23
		dc.l Delete_Current_Sprite				; $24
		dc.l Delete_Current_Sprite				; $25
		dc.l Obj_AutoSpin						; $26
		dc.l Delete_Current_Sprite				; $27
		dc.l Obj_Invisible_SolidBlock			; $28
		dc.l Delete_Current_Sprite				; $29
		dc.l Delete_Current_Sprite				; $2A
		dc.l Delete_Current_Sprite				; $2B
		dc.l Delete_Current_Sprite				; $2C
		dc.l Delete_Current_Sprite				; $2D
		dc.l Delete_Current_Sprite				; $2E
		dc.l Delete_Current_Sprite				; $2F
		dc.l Delete_Current_Sprite				; $30
		dc.l Delete_Current_Sprite				; $31
		dc.l Delete_Current_Sprite				; $32
		dc.l Obj_Button						; $33
		dc.l Obj_StarPost						; $34
		dc.l Delete_Current_Sprite				; $35
		dc.l Delete_Current_Sprite				; $36
		dc.l Delete_Current_Sprite				; $37
		dc.l Delete_Current_Sprite				; $38
		dc.l Delete_Current_Sprite				; $39
		dc.l Delete_Current_Sprite				; $3A
		dc.l Delete_Current_Sprite				; $3B
		dc.l Delete_Current_Sprite				; $3C
		dc.l Delete_Current_Sprite				; $3D
		dc.l Delete_Current_Sprite				; $3E
		dc.l Delete_Current_Sprite				; $3F
		dc.l Delete_Current_Sprite				; $40
		dc.l Delete_Current_Sprite				; $41
		dc.l Delete_Current_Sprite				; $42
		dc.l Delete_Current_Sprite				; $43
		dc.l Delete_Current_Sprite				; $44
		dc.l Delete_Current_Sprite				; $45
		dc.l Delete_Current_Sprite				; $46
		dc.l Delete_Current_Sprite				; $47
		dc.l Delete_Current_Sprite				; $48
		dc.l Delete_Current_Sprite				; $49
		dc.l Delete_Current_Sprite				; $4A
		dc.l Delete_Current_Sprite				; $4B
		dc.l Delete_Current_Sprite				; $4C
		dc.l Delete_Current_Sprite				; $4D
		dc.l Delete_Current_Sprite				; $4E
		dc.l Delete_Current_Sprite				; $4F
		dc.l Delete_Current_Sprite				; $50
		dc.l Delete_Current_Sprite				; $51
		dc.l Delete_Current_Sprite				; $52
		dc.l Delete_Current_Sprite				; $53
		dc.l Obj_Bubbler						; $54
		dc.l Delete_Current_Sprite				; $55
		dc.l Delete_Current_Sprite				; $56
		dc.l Delete_Current_Sprite				; $57
		dc.l Delete_Current_Sprite				; $58
		dc.l Delete_Current_Sprite				; $59
		dc.l Delete_Current_Sprite				; $5A
		dc.l Delete_Current_Sprite				; $5B
		dc.l Delete_Current_Sprite				; $5C
		dc.l Delete_Current_Sprite				; $5D
		dc.l Delete_Current_Sprite				; $5E
		dc.l Delete_Current_Sprite				; $5F
		dc.l Delete_Current_Sprite				; $60
		dc.l Delete_Current_Sprite				; $61
		dc.l Delete_Current_Sprite				; $62
		dc.l Delete_Current_Sprite				; $63
		dc.l Delete_Current_Sprite				; $64
		dc.l Delete_Current_Sprite				; $65
		dc.l Delete_Current_Sprite				; $66
		dc.l Delete_Current_Sprite				; $67
		dc.l Delete_Current_Sprite				; $68
		dc.l Delete_Current_Sprite				; $69
		dc.l Obj_Invisible_HurtBlock			; $6A
		dc.l Obj_Invisible_KillBlock				; $6B
		dc.l Delete_Current_Sprite				; $6C
		dc.l Obj_Invisible_ShockBlock			; $6D
		dc.l Obj_Invisible_LavaBlock			; $6E
		dc.l Delete_Current_Sprite				; $6F
		dc.l Delete_Current_Sprite				; $70
		dc.l Delete_Current_Sprite				; $71
		dc.l Delete_Current_Sprite				; $72
		dc.l Delete_Current_Sprite				; $73
		dc.l Delete_Current_Sprite				; $74
		dc.l Delete_Current_Sprite				; $75
		dc.l Delete_Current_Sprite				; $76
		dc.l Delete_Current_Sprite				; $77
		dc.l Delete_Current_Sprite				; $78
		dc.l Delete_Current_Sprite				; $79
		dc.l Delete_Current_Sprite				; $7A
		dc.l Delete_Current_Sprite				; $7B
		dc.l Delete_Current_Sprite				; $7C
		dc.l Delete_Current_Sprite				; $7D
		dc.l Delete_Current_Sprite				; $7E
		dc.l Delete_Current_Sprite				; $7F
		dc.l Obj_HiddenMonitor				; $80
		dc.l Obj_EggCapsule					; $81
		dc.l Delete_Current_Sprite				; $82
		dc.l Delete_Current_Sprite				; $83
		dc.l Delete_Current_Sprite				; $84
		dc.l Delete_Current_Sprite				; $85
		dc.l Delete_Current_Sprite				; $86
		dc.l Delete_Current_Sprite				; $87
		dc.l Delete_Current_Sprite				; $88
		dc.l Delete_Current_Sprite				; $89
		dc.l Delete_Current_Sprite				; $8A
		dc.l Obj_SpriteMask					; $8B
		dc.l Delete_Current_Sprite				; $8C
		dc.l Delete_Current_Sprite				; $8D
		dc.l Delete_Current_Sprite				; $8E
		dc.l Delete_Current_Sprite				; $8F
		dc.l Delete_Current_Sprite				; $90
		dc.l Delete_Current_Sprite				; $91
		dc.l Delete_Current_Sprite				; $92
		dc.l Delete_Current_Sprite				; $93
		dc.l Delete_Current_Sprite				; $94
		dc.l Delete_Current_Sprite				; $95
		dc.l Delete_Current_Sprite				; $96
		dc.l Delete_Current_Sprite				; $97
		dc.l Delete_Current_Sprite				; $98
		dc.l Delete_Current_Sprite				; $99
		dc.l Delete_Current_Sprite				; $9A
		dc.l Delete_Current_Sprite				; $9B
		dc.l Delete_Current_Sprite				; $9C
		dc.l Delete_Current_Sprite				; $9D
		dc.l Delete_Current_Sprite				; $9E
		dc.l Delete_Current_Sprite				; $9F
		dc.l Delete_Current_Sprite				; $A0
		dc.l Delete_Current_Sprite				; $A1
		dc.l Delete_Current_Sprite				; $A2
		dc.l Delete_Current_Sprite				; $A3
		dc.l Obj_Spikebonker					; $A4
		dc.l Delete_Current_Sprite				; $A5
		dc.l Delete_Current_Sprite				; $A6
		dc.l Delete_Current_Sprite				; $A7
		dc.l Delete_Current_Sprite				; $A8
		dc.l Delete_Current_Sprite				; $A9
		dc.l Delete_Current_Sprite				; $AA
		dc.l Delete_Current_Sprite				; $AB
		dc.l Delete_Current_Sprite				; $AC
		dc.l Delete_Current_Sprite				; $AD
		dc.l Delete_Current_Sprite				; $AE
		dc.l Delete_Current_Sprite				; $AF
		dc.l Delete_Current_Sprite				; $B0
		dc.l Delete_Current_Sprite				; $B1
		dc.l Delete_Current_Sprite				; $B2
		dc.l Obj_StartNewLevel				; $B3
		dc.l Delete_Current_Sprite				; $B4
		dc.l Delete_Current_Sprite				; $B5
		dc.l Delete_Current_Sprite				; $B6
		dc.l Delete_Current_Sprite				; $B7
		dc.l Delete_Current_Sprite				; $B8
		dc.l Delete_Current_Sprite				; $B9
		dc.l Delete_Current_Sprite				; $BA
		dc.l Delete_Current_Sprite				; $BB
		dc.l Delete_Current_Sprite				; $BC
		dc.l Delete_Current_Sprite				; $BD
		dc.l Delete_Current_Sprite				; $BE
		dc.l Delete_Current_Sprite				; $BF
		dc.l Delete_Current_Sprite				; $C0
		dc.l Delete_Current_Sprite				; $C1
		dc.l Delete_Current_Sprite				; $C2
		dc.l Delete_Current_Sprite				; $C3
		dc.l Delete_Current_Sprite				; $C4
		dc.l Delete_Current_Sprite				; $C5
		dc.l Delete_Current_Sprite				; $C6
		dc.l Delete_Current_Sprite				; $C7
		dc.l Delete_Current_Sprite				; $C8
		dc.l Delete_Current_Sprite				; $C9
		dc.l Delete_Current_Sprite				; $CA
		dc.l Delete_Current_Sprite				; $CB
		dc.l Delete_Current_Sprite				; $CC
		dc.l Delete_Current_Sprite				; $CD
		dc.l Delete_Current_Sprite				; $CE
		dc.l Delete_Current_Sprite				; $CF
		dc.l Delete_Current_Sprite				; $D0
		dc.l Delete_Current_Sprite				; $D1
		dc.l Delete_Current_Sprite				; $D2
		dc.l Delete_Current_Sprite				; $D3
		dc.l Delete_Current_Sprite				; $D4
		dc.l Delete_Current_Sprite				; $D5
		dc.l Delete_Current_Sprite				; $D6
		dc.l Delete_Current_Sprite				; $D7
		dc.l Delete_Current_Sprite				; $D8
		dc.l Delete_Current_Sprite				; $D9
		dc.l Delete_Current_Sprite				; $DA
		dc.l Delete_Current_Sprite				; $DB
		dc.l Delete_Current_Sprite				; $DC
		dc.l Delete_Current_Sprite				; $DD
		dc.l Delete_Current_Sprite				; $DE
		dc.l Delete_Current_Sprite				; $DF
		dc.l Delete_Current_Sprite				; $E0
		dc.l Delete_Current_Sprite				; $E1
		dc.l Delete_Current_Sprite				; $E2
		dc.l Delete_Current_Sprite				; $E3
		dc.l Delete_Current_Sprite				; $E4
		dc.l Delete_Current_Sprite				; $E5
		dc.l Delete_Current_Sprite				; $E6
		dc.l Delete_Current_Sprite				; $E7
		dc.l Delete_Current_Sprite				; $E8
		dc.l Delete_Current_Sprite				; $E9
		dc.l Delete_Current_Sprite				; $EA
		dc.l Delete_Current_Sprite				; $EB
		dc.l Delete_Current_Sprite				; $EC
		dc.l Delete_Current_Sprite				; $ED
		dc.l Delete_Current_Sprite				; $EE
		dc.l Delete_Current_Sprite				; $EF
		dc.l Delete_Current_Sprite				; $F0
		dc.l Delete_Current_Sprite				; $F1
		dc.l Delete_Current_Sprite				; $F2
		dc.l Delete_Current_Sprite				; $F3
		dc.l Delete_Current_Sprite				; $F4
		dc.l Delete_Current_Sprite				; $F5
		dc.l Delete_Current_Sprite				; $F6
		dc.l Delete_Current_Sprite				; $F7
		dc.l Delete_Current_Sprite				; $F8
		dc.l Delete_Current_Sprite				; $F9
		dc.l Delete_Current_Sprite				; $FA
		dc.l Delete_Current_Sprite				; $FB
		dc.l Delete_Current_Sprite				; $FC
		dc.l Delete_Current_Sprite				; $FD
		dc.l Delete_Current_Sprite				; $FE
		dc.l Delete_Current_Sprite				; $FF
