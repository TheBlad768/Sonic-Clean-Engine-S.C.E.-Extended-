; ---------------------------------------------------------------------------
; Sprite mappings - starpost
; ---------------------------------------------------------------------------

Map_StarPost:
		dc.w word_2D36C-Map_StarPost
		dc.w word_2D380-Map_StarPost
		dc.w word_2D388-Map_StarPost
word_2D36C:
		dc.w 3
		dc.b $E8, 1, 0, $E, $FF, $FC
		dc.b $F8, 3, 0, $10, $FF, $F8
		dc.b $F8, 3, 8, $10, 0, 0
word_2D380:
		dc.w 1
		dc.b $F8, 5, 0, 6, $FF, $F8
word_2D388:
		dc.w 1
		dc.b $F8, 5, 0, $A, $FF, $F8
	even