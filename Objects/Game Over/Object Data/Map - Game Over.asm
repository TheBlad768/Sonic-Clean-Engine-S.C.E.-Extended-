; ---------------------------------------------------------------------------
; Sprite mappings - "GAME OVER" and "TIME OVER"
; ---------------------------------------------------------------------------

Map_GameOver:
		dc.w word_2EDD8-Map_GameOver		; GAME (ignored by multi-draw)
		dc.w word_2EDD8-Map_GameOver		; GAME
		dc.w word_2EDE6-Map_GameOver		; OVER
		dc.w word_2EDF4-Map_GameOver		; TIME
		dc.w word_2EE02-Map_GameOver		; OVER
word_2EDD8:
		dc.w 2
		dc.b $F8, $D, 0, 0, $FF, $B8
		dc.b $F8, $D, 0, 8, $FF, $D8
word_2EDE6:
		dc.w 2
		dc.b $F8, $D, 0, $14, 0, 8
		dc.b $F8, $D, 0, $C, 0, $28
word_2EDF4:
		dc.w 2
		dc.b $F8, 9, 0, $1C, $FF, $BA
		dc.b $F8, $D, 0, 8, $FF, $D2
word_2EE02:
		dc.w 2
		dc.b $F8, $D, 0, $14, 0, 2
		dc.b $F8, $D, 0, $C, 0, $22
	even