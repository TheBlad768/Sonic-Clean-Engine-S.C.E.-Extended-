; ---------------------------------------------------------------------------
; Game Over (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_GameOver:
		tst.w	(Kos_modules_left).w
		beq.s	loc_2D5CE
		rts
; ---------------------------------------------------------------------------

loc_2D5CE:
		move.w	#$50,x_pos(a0)
		btst	#0,mapping_frame(a0)
		beq.s	loc_2D5F2
		move.w	#$1F0,x_pos(a0)

loc_2D5F2:
		move.w	#$F0,y_pos(a0)
		move.l	#Map_GameOver,mappings(a0)
		move.w	#make_art_tile(ArtTile_Shield,0,1),art_tile(a0)
		clr.w	priority(a0)
		move.l	#loc_2D612,address(a0)

loc_2D612:
		moveq	#$10,d1
		cmpi.w	#$120,x_pos(a0)
		beq.s	loc_2D62A
		bcs.s	loc_2D620
		neg.w	d1

loc_2D620:
		add.w	d1,x_pos(a0)
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_2D62A:
		move.w	#8*60,anim_frame_timer(a0)
		move.l	#loc_2D638,address(a0)

loc_2D638:
		clr.w	(Collision_response_list).w
		btst	#0,mapping_frame(a0)
		bne.w	loc_2D68A
		move.b	(Ctrl_1_pressed).w,d0
		or.b	(Ctrl_2_pressed).w,d0
		andi.b	#btnABCS,d0
		bne.s	loc_2D666
		tst.w	anim_frame_timer(a0)
		beq.s	loc_2D666
		subq.w	#1,anim_frame_timer(a0)
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_2D666:
		tst.b	(Time_over_flag).w
		bne.s	loc_2D680
		move.b	#id_ContinueScreen,(Game_mode).w		; ContinueScreen
		tst.b	(Continue_count).w
		bne.s	loc_2D68A
		move.b	#id_LevelSelectScreen,(Game_mode).w		; set Game Mode
		bra.s	loc_2D68A
; ---------------------------------------------------------------------------

loc_2D680:
		clr.l	(Saved_timer).w
		st	(Restart_level_flag).w

loc_2D68A:
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

		include "Objects/Game Over/Object Data/Map - Game Over.asm"
