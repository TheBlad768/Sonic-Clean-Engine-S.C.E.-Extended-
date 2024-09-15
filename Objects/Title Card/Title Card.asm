; ---------------------------------------------------------------------------
; TitleCard (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

TitleCardAct_Index:
		dc.l ArtKosPM_TitleCardNum1		; 0
		dc.l ArtKosPM_TitleCardNum2		; 1
		dc.l ArtKosPM_TitleCardNum3		; 2
		dc.l ArtKosPM_TitleCardNum4		; 3
; ---------------------------------------------------------------------------

Obj_TitleCard:

		; load general art
		QueueKosPlusModule	ArtKosPM_TitleCardRedAct, $500

		; load act number art
		moveq	#0,d0
		move.b	(Current_act).w,d0
		add.w	d0,d0													; multiply by 4
		add.w	d0,d0
		movea.l	TitleCardAct_Index(pc,d0.w),a1
		move.w	#tiles_to_bytes($53D),d2
		jsr	(Queue_KosPlus_Module).w

		; load zone name art
		moveq	#0,d0
		move.b	(Current_zone).w,d0										; otherwise, just use current zone
		add.w	d0,d0													; multiply by 4
		add.w	d0,d0
		movea.l	.levelgfx(pc,d0.w),a1
		move.w	#tiles_to_bytes($54D),d2
		jsr	(Queue_KosPlus_Module).w

		; next
		move.w	#1*60+30,objoff_2E(a0)									; set wait value
		clr.w	objoff_32(a0)
		st	objoff_48(a0)
		move.l	#.create,address(a0)
		rts

; ---------------------------------------------------------------------------
; The letters for the name of the zone
; Exception: ENOZ/ZONE. These letters are already in VRAM
; ---------------------------------------------------------------------------

.levelgfx
		dc.l ArtKosPM_DEZTitleCard	; DEZ

		zonewarning .levelgfx,4
; ---------------------------------------------------------------------------

.create
		tst.w	(KosPlus_modules_left).w
		bne.s	.return													; don't load the objects until the art has been loaded
		jsr	(Create_New_Sprite3).w
		bne.s	.return
		lea	ObjArray_TtlCard(pc),a2
		move.w	(a2)+,d1													; make objects

.loop
		addq.w	#1,objoff_30(a0)
		move.l	(a2)+,address(a1)
		move.w	(a2)+,objoff_46(a1)
		move.w	(a2)+,x_pos(a1)
		move.w	(a2)+,y_pos(a1)
		move.b	(a2)+,mapping_frame(a1)
		move.b	(a2)+,width_pixels(a1)
		move.w	(a2)+,d2
		move.b	d2,objoff_28(a1)
		move.b	#rfMulti,render_flags(a1)
		move.l	#Map_TitleCard,mappings(a1)
		move.w	#make_art_tile($500,0,0),art_tile(a1)
		move.w	a0,parent2(a1)
		jsr	(Create_New_Sprite4).w
		dbne	d1,.loop

		; next
		move.l	#.wait,address(a0)

.return
		rts
; ---------------------------------------------------------------------------

.wait
		tst.w	objoff_34(a0)
		beq.s	.branch
		clr.w	objoff_34(a0)
		rts
; ---------------------------------------------------------------------------

.branch
		tst.w	objoff_3E(a0)
		beq.s	.skiplevel

		; reset level flags
		clr.l	(Timer).w													; if using in-level title card
		clr.w	(Ring_count).w											; reset HUD rings and timer
		clr.b	(Extra_life_flags).w											; reset extra life ring flag
		st	(Update_HUD_timer).w
		st	(Update_HUD_ring_count).w									; start updating timer and rings again
		moveq	#30,d0
		move.b	d0,(Player_1+air_left).w									; reset air
		move.b	d0,(Player_2+air_left).w									; reset air
		jsr	(Restore_LevelMusic).w										; play music

.skiplevel
		clr.w	objoff_48(a0)
		move.l	#.wait2,address(a0)
		rts
; ---------------------------------------------------------------------------

.wait2
		tst.w	objoff_2E(a0)
		beq.s	.endtimer
		subq.w	#1,objoff_2E(a0)
		rts
; ---------------------------------------------------------------------------

.endtimer
		tst.w	objoff_30(a0)
		beq.s	.branch2
		addq.w	#1,objoff_32(a0)
		rts
; ---------------------------------------------------------------------------

.branch2
		tst.b	objoff_44(a0)
		bne.s	.delete
		tst.w	objoff_3E(a0)
		beq.s	.skiplevel2
		st	(End_of_level_flag).w											; if in-level, set end of title card flag
		bra.s	.skiplevel3
; ---------------------------------------------------------------------------

.skiplevel2

		; load second main plc
		lea	(PLC2_Sonic).l,a5
		jsr	(LoadPLC_Raw_KosPlusM).w
		movea.l	(Level_data_addr_RAM.PLC2).w,a5
		jsr	(LoadPLC_Raw_KosPlusM).w									; load main art

.skiplevel3
		movea.l	(Level_data_addr_RAM.PLCAnimals).w,a5
		jsr	(LoadPLC_Raw_KosPlusM).w									; load animals art
		moveq	#1,d0
		move.b	d0,(HUD_RAM.status).w									; load HUD
		move.b	d0,(Update_HUD_timer).w									; update time counter
		clr.w	(Ctrl_1_locked).w											; unlock control 1 and control 2

.delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_TitleCardRedBanner:
		movea.w	parent2(a0),a1
		move.w	objoff_32(a1),d0
		beq.s	.loc_2D90A
		tst.b	render_flags(a0)												; is the object visible on the screen?
		bmi.s	.loc_2D8FC												; if yes, branch
		subq.w	#1,objoff_30(a1)
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

.loc_2D8FC
		cmp.b	objoff_28(a0),d0
		blo.s		.loc_2D920
		subi.w	#32,y_pos(a0)
		bra.s	.loc_2D920
; ---------------------------------------------------------------------------

.loc_2D90A
		move.w	y_pos(a0),d0
		cmp.w	objoff_46(a0),d0
		beq.s	.loc_2D920
		addi.w	#16,d0
		move.w	d0,y_pos(a0)
		st	objoff_34(a1)

.loc_2D920
		move.b	#224/2,height_pixels(a0)
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_TitleCardName:
		move.b	(Current_zone).w,d0
		add.b	d0,mapping_frame(a0)
		move.l	#Obj_TitleCardElement,address(a0)

; =============== S U B R O U T I N E =======================================

Obj_TitleCardElement:
		movea.w	parent2(a0),a1
		move.w	objoff_32(a1),d0
		beq.s	.loc_2D984
		tst.b	render_flags(a0)												; is the object visible on the screen?
		bmi.s	.loc_2D976												; if yes, branch
		subq.w	#1,objoff_30(a1)
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

.loc_2D976
		cmp.b	objoff_28(a0),d0
		blo.s		.loc_2D99A
		addi.w	#32,x_pos(a0)
		bra.s	.loc_2D99A
; ---------------------------------------------------------------------------

.loc_2D984
		move.w	x_pos(a0),d0
		cmp.w	objoff_46(a0),d0
		beq.s	.loc_2D99A
		subi.w	#16,d0
		move.w	d0,x_pos(a0)
		st	objoff_34(a1)

.loc_2D99A
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_TitleCardAct:
		move.l	#Obj_TitleCardElement,address(a0)
		bra.s	Obj_TitleCardElement

		; delete
;		movea.w	parent2(a0),a1											; remove a number of the act, if not needed
;		subq.w	#1,objoff_30(a1)
;		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

ObjArray_TtlCard: titlecardresultsheader
	titlecardresultsobjdata	Obj_TitleCardName, 160, 480, 96, 4, 256, 3			; 1
	titlecardresultsobjdata	Obj_TitleCardElement, 252, 636, 128, 3, 72, 5			; 2
	titlecardresultsobjdata	Obj_TitleCardAct, 260, 708, 160, 2, 56, 7				; 3
	titlecardresultsobjdata	Obj_TitleCardRedBanner, 64, 96, 16-128, 1, 0, 1		; 4
ObjArray_TtlCard_end

ObjArray_TtlCardBonus: titlecardresultsheader
	titlecardresultsobjdata	Obj_TitleCardElement, 72, 264, 104, $13, 256, 1		; 1
	titlecardresultsobjdata	Obj_TitleCardElement, 168, 360, 104, $14, 256, 1		; 2
ObjArray_TtlCardBonus_end
; ---------------------------------------------------------------------------

		include "Objects/Title Card/Object Data/Map - Title Card.asm"
