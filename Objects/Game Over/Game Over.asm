; ---------------------------------------------------------------------------
; Game Over (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_GameOver:

		; wait for KosPlusM queue to clear
		tst.w	(KosPlus_modules_left).w
		beq.s	.endplc
		rts
; ---------------------------------------------------------------------------

.endplc
		clr.w	priority(a0)
		move.l	#Map_GameOver,mappings(a0)
		move.w	#make_art_tile(ArtTile_Shield,0,1),art_tile(a0)
		move.b	#rfMulti,render_flags(a0)							; set multi-draw flag
		move.l	#.xpos,address(a0)

		; GAME/TIME (frame)
		move.w	#$80-48,x_pos(a0)
		move.w	#$80+(224/2),y_pos(a0)

		; OVER (frame)
		lea	sub2_x_pos(a0),a1
		move.w	#$80+(320+48),(a1)+
		move.w	y_pos(a0),(a1)+
		moveq	#1,d0
		move.w	d0,mainspr_childsprites(a0)						; number of child sprites
		add.b	mapping_frame(a0),d0
		move.w	d0,(a1)

.xpos
		lea	sub2_x_pos(a0),a1

		; check center
		move.w	x_pos(a0),d0
		sub.w	(a1),d0											; is center position xpos?
		beq.s	.settime											; if yes, branch

		; move sprites
		moveq	#16,d1
		add.w	d1,x_pos(a0)
		sub.w	d1,(a1)

		; draw
		bra.s	.draw
; ---------------------------------------------------------------------------

.settime
		move.w	#9*60,anim_frame_timer(a0)
		move.l	#.wait,address(a0)

.wait
		move.b	(Ctrl_1_pressed).w,d0
		or.b	(Ctrl_2_pressed).w,d0
		andi.b	#btnABCS,d0										; is A/B/C/Start pressed?
		bne.s	.end												; if yes, branch

		; wait
		tst.w	anim_frame_timer(a0)
		beq.s	.end
		subq.w	#1,anim_frame_timer(a0)

		; draw
		bra.s	.draw
; ---------------------------------------------------------------------------

.end
		tst.b	(Time_over_flag).w
		bne.s	.restart
		lea	4*3(sp),sp											; exit from object and current screen
		move.b	#GameModeID_ContinueScreen,(Game_mode).w		; load continue screen
		tst.b	(Continue_count).w
		bne.s	.draw
		move.b	#GameModeID_LevelSelectScreen,(Game_mode).w	; load level select screen
		bra.s	.draw
; ---------------------------------------------------------------------------

.restart
		clr.l	(Saved_timer).w
		st	(Restart_level_flag).w

.draw
		clr.w	(Collision_response_list).w							; reset collision response list
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

		include "Objects/Game Over/Object Data/Map - Game Over.asm"
