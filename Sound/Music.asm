; ---------------------------------------------------------------------------
; Music metadata (pointers, speed shoes tempos, flags)
; ---------------------------------------------------------------------------
MusicIndex:
; Levels
ptr_mus_dez1:		SMPS_MUSIC_METADATA	Music_DEZ1, s3TempotoS1($FF), 0			; DEZ 1

; Boss
ptr_mus_boss:		SMPS_MUSIC_METADATA	Music_Boss, s3TempotoS1($FF), 0			; Boss
ptr_mus_boss2:		SMPS_MUSIC_METADATA	Music_Boss2, s3TempotoS1($FF), 0			; Boss 2

; Misc
ptr_mus_invin:		SMPS_MUSIC_METADATA	Music_Invin, s3TempotoS1($FF), 0			; Invincible
ptr_mus_through:	SMPS_MUSIC_METADATA	Music_Through, s3TempotoS1($FF), 0		; End of Act
ptr_mus_drowning:	SMPS_MUSIC_METADATA	Music_Drowning, s3TempotoS1($02), SMPS_MUSIC_METADATA_FORCE_PAL_SPEED	; Drowning
ptr_mus_gameover:	SMPS_MUSIC_METADATA	Music_GameOver, s3TempotoS1($FF), 0		; Game Over
ptr_mus_extralife:	SMPS_MUSIC_METADATA	Music_ExtraLife, s3TempotoS1($FF), 0		; Extra Life
ptr_mus_continue:	SMPS_MUSIC_METADATA	Music_Continue, s3TempotoS1($FF), 0		; Continue

ptr_musend

; ---------------------------------------------------------------------------
; Music data ($01-$3F)
; ---------------------------------------------------------------------------

Music_DEZ1:			include "Sound/Music/Mus - DEZ1.asm"
	even
Music_Boss:			include "Sound/Music/Mus - Miniboss.asm"
	even
Music_Boss2:			include "Sound/Music/Mus - Zone Boss.asm"
	even
Music_Invin:			include "Sound/Music/Mus - Invincibility.asm"
	even
Music_Through: 		include "Sound/Music/Mus - Sonic Got Through.asm"
	even
Music_Drowning:		include "Sound/Music/Mus - Drowning.asm"
	even
Music_GameOver:	include "Sound/Music/Mus - Game Over.asm"
	even
Music_ExtraLife:		include "Sound/Music/Mus - Extra Life.asm"
	even
Music_Continue:		include "Sound/Music/Mus - Continue.asm"
	even
