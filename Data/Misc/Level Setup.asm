; ---------------------------------------------------------------------------
; Level events
; ---------------------------------------------------------------------------

; Used:
; d7 = Plane base address (.w)
; a0 = Plane buffer (.l)
; a2 = Block address (.l)
; a3 = Layout address (.l)

; don't overwrite these registers!

; =============== S U B R O U T I N E =======================================

Level_Setup:
		move.w	#$FFF,(Screen_Y_wrap_value).w
		move.w	#$FF0,(Camera_Y_pos_mask).w
		move.w	#$7C,(Layout_row_index_mask).w
		move.w	(Camera_X_pos).w,(Camera_X_pos_copy).w
		move.w	(Camera_Y_pos).w,(Camera_Y_pos_copy).w
		lea	(Plane_buffer).w,a0
		movea.l	(Block_table_addr_ROM).w,a2
		movea.l	(Level_layout_addr2_ROM).w,a3
		move.w	#vram_fg,d7
		movea.l	(Level_data_addr_RAM.ScreenInit).w,a1
		jsr	(a1)
		addq.w	#2,a3
		move.w	#vram_bg,d7
		movea.l	(Level_data_addr_RAM.BackgroundInit).w,a1
		jsr	(a1)
		move.w	(Camera_Y_pos_copy).w,(V_scroll_value).w
		move.w	(Camera_Y_pos_BG_copy).w,(V_scroll_value_BG).w
		rts

; =============== S U B R O U T I N E =======================================

Screen_Events:
		move.w	(Camera_X_pos).w,(Camera_X_pos_copy).w
		move.w	(Camera_Y_pos).w,(Camera_Y_pos_copy).w
		lea	(Plane_buffer).w,a0
		movea.l	(Block_table_addr_ROM).w,a2
		movea.l	(Level_layout_addr2_ROM).w,a3
		move.w	#vram_fg,d7
		movea.l	(Level_data_addr_RAM.ScreenEvent).w,a1
		jsr	(a1)
		addq.w	#2,a3
		move.w	#vram_bg,d7
		movea.l	(Level_data_addr_RAM.BackgroundEvent).w,a1
		jsr	(a1)
		move.w	(Camera_Y_pos_copy).w,(V_scroll_value).w
		move.w	(Camera_Y_pos_BG_copy).w,(V_scroll_value_BG).w
		rts
