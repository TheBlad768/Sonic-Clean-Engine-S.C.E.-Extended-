; ---------------------------------------------------------------------------
; Subroutine to initialise game
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Game_Program:
		tst.w	(VDP_control_port).l
		move.w	#$4EF9,d0										; machine code for jmp
		move.w	d0,(V_int_jump).w
		move.w	d0,(H_int_jump).w
		move.l	#VInt,(V_int_addr).w
		move.l	#HInt,(H_int_addr).w

.wait
		moveq	#2,d0
		and.w	(VDP_control_port).l,d0
		bne.s	.wait											; wait till a DMA is completed

		; clear some RAM on every boot and reset
		clearRAM RAM_start, CrossResetRAM						; clear RAM

		; check
		btst	#6,(HW_Expansion_Control).l
		beq.s	.skip
		cmpi.l	#Ref_Checksum_String,(Checksum_string).w			; has checksum routine already run?
		beq.s	.init												; if yes, branch

.skip

	if ChecksumCheck
		bsr.s	Test_Checksum
	endif

		; clear some RAM only on a coldboot
		clearRAM CrossResetRAM, CrossResetRAM_end				; clear RAM

		; get region setting
		moveq	#signextendB($C0),d0
		and.b	(HW_Version).l,d0
		move.b	d0,(Graphics_flags).w

		; set checksum string
		move.l	#Ref_Checksum_String,(Checksum_string).w			; set flag so checksum won't run again

.init
		jsr	(Init_DMA_Queue).w
		jsr	(Init_VDP).w
		jsr	(SndDrvInit).w
		jsr	(Init_Controllers).w
		move.b	#GameModeID_LevelSelectScreen,(Game_mode).w	; set screen mode to Level Select (SCE)

.loop
		moveq	#$7C,d0											; limit Game Mode value to $7C max
		and.b	(Game_mode).w,d0								; load Game Mode
		movea.l	Game_Modes(pc,d0.w),a0
		jsr	(a0)
		bra.s	.loop

; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

Game_Modes:
		GameModeEntry LevelSelectScreen							; Level select mode (SCE)
		GameModeEntry LevelScreen								; Zone play mode
		GameModeEntry ContinueScreen							; Continue mode
