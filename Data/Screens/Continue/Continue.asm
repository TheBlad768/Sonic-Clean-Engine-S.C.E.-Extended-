; ---------------------------------------------------------------------------
; Continue
; ---------------------------------------------------------------------------

; Constants
Continue_Offset:					= *

; Variables

; RAM
	phase ramaddr(Object_load_addr_front)

_unkFA80			ds.w 1			; unused
_unkFA82			ds.b 1
_unkFA83			ds.b 1
_unkFA84			ds.w 1
_unkFA86			ds.w 1
_unkFA88			ds.b 1
_unkFA89			ds.b 1
_unkFA8A			ds.w 1
_unkFA8C			ds.w 1			; unused?
_unkFA8E			ds.w 1
_unkFA90			ds.w 1
_unkFAA4			ds.w 1
_unkFAA8			ds.b 1
_unkFAA9			ds.b 1

	dephase
	!org	Continue_Offset

Continue_VDP:
		dc.w $8004			; disable HInt, HV counter, 8-colour mode
		dc.w $8700+(0<<4)	; backdrop color is color 0 of the first palette line
		dc.w 0				; end

; =============== S U B R O U T I N E =======================================

Continue_Screen:
		music	mus_Stop
		jsr	(Clear_Kos_Module_Queue).w								; clear KosM PLCs
		jsr	(Pal_FadeToBlack).w
		disableInts
		move.l	#VInt,(V_int_addr).w
		move.l	#HInt,(H_int_addr).w
		disableScreen
		jsr	(Clear_DisplayData).w

		lea	Continue_VDP(pc),a1
		jsr	(Load_VDP).w

		clr.b	(Water_full_screen_flag).w
		clr.b	(Water_flag).w
		clr.b	(Level_started_flag).w
		clr.b	(_unkFAA9).w
		clr.b	(_unkFA88).w
		clearRAM Object_RAM, Object_RAM_end



		lea	PLC_Continue(pc),a5
		jsr	(LoadPLC_Raw_KosM).w




.waitplc
		move.b	#VintID_Fade,(V_int_routine).w
		jsr	(Process_Kos_Queue).w
		jsr	(Wait_VSync).w
		jsr	(Process_Kos_Module_Queue).w
		tst.w	(Kos_modules_left).w
		bne.s	.waitplc



		move.w	#$293,(Demo_timer).w

		lea	(Pal_Continue).l,a1
		lea	(Target_palette).w,a2
		moveq	#64/2-1,d6

.loop
		move.l	(a1)+,(a2)+
		dbf	d6,.loop

		lea	aCONTINUE(pc),a1
		move.w	#$292,d2
		move.w	#$8347,d6
		jsr	sub_5B318
		cmpi.w	#3,(Player_mode).w
		beq.s	loc_5C3FE




		bra.s	loc_5C3EE

		move.l	#Obj_Continue_SonicAlone,(Player_1).w
		bra.w	loc_5C3FE
; ---------------------------------------------------------------------------

loc_5C3EE:
		move.l	#Obj_Continue_SonicWTails,(Player_1).w
		move.l	#Obj_Continue_TailsWSonic,(Player_2).w

loc_5C3FE:
		move.l	#loc_5C838,(Reserved_object_3).w
		lea	(Dynamic_object_RAM).w,a1
		move.l	#loc_5C4D6,address(a1)
		move.w	a1,(_unkFAA4).w
		move.l	#loc_5C9DC,(Dynamic_object_RAM+object_size).w
		bsr.w	sub_5CB1C
		jsr	(Process_Sprites).w
		jsr	(Render_Sprites).w
		move.b	#VintID_Menu,(V_int_routine).w
		jsr	(Wait_VSync).w
		music	mus_Continue
		enableScreen
		jsr	(Pal_FadeFromBlack).w

loc_5C454:
		move.b	#VintID_Menu,(V_int_routine).w
		jsr	(Process_Kos_Queue).w
		jsr	(Wait_VSync).w
		jsr	(Process_Sprites).w
		jsr	(Render_Sprites).w
		jsr	(Process_Kos_Module_Queue).w
		move.b	(_unkFAA9).w,d0
		beq.s	loc_5C454
		subq.b	#1,d0
		beq.s	loc_5C48A
		move.b	#id_LevelSelectScreen,(Game_mode).w
		rts
; ---------------------------------------------------------------------------

loc_5C48A:
		move.b	#id_LevelScreen,(Game_mode).w
		move.b	#3,(Life_count).w
		moveq	#0,d0
		move.w	d0,(Ring_count).w
		move.l	d0,(Timer).w
		move.l	d0,(Score).w
		move.l	#5000,(Next_extra_life_score).w
		subq.b	#1,(Continue_count).w

locret_5C4D4:
		rts
; ---------------------------------------------------------------------------

loc_5C4D6:
		move.l	#loc_5C4E6,address(a0)
		clr.w	(_unkFA82).w
		move.b	#$A,(_unkFA84).w

loc_5C4E6:
		btst	#7,(Ctrl_1_pressed).w
		bne.s	loc_5C51C
		btst	#7,(Ctrl_2_pressed).w
		bne.s	loc_5C51C
		subq.w	#1,(_unkFA82).w
		bpl.s	locret_5C512
		move.w	#$3B,(_unkFA82).w
		move.b	(_unkFA84).w,d0
		subq.b	#1,d0
		bmi.s	loc_5C514
		move.b	d0,(_unkFA84).w
		bsr.w	sub_5CAAE

locret_5C512:
		rts
; ---------------------------------------------------------------------------

loc_5C514:
		move.b	#2,(_unkFAA9).w
		rts
; ---------------------------------------------------------------------------

loc_5C51C:
		move.l	#locret_5C528,address(a0)
		bset	#3,$38(a0)

locret_5C528:
		rts
; ---------------------------------------------------------------------------

Obj_Continue_SonicWTails:
		move.l	#Map_ContinueSprites,$C(a0)
		move.w	#$8C,$A(a0)
		move.w	#$280,8(a0)
		move.b	#$C,7(a0)
		move.b	#$14,6(a0)
		move.w	#$118,$10(a0)
		move.w	#$120,$14(a0)
		move.l	#loc_5C55C,address(a0)

loc_5C55C:
		movea.w	(_unkFAA4).w,a1
		btst	#3,$38(a1)
		bne.s	loc_5C582
		move.b	#0,$22(a0)
		btst	#4,(V_int_run_count+3).w
		beq.s	loc_5C57C
		move.b	#1,$22(a0)

loc_5C57C:
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_5C582:
		move.l	#loc_5C588,address(a0)

loc_5C588:
		moveq	#0,d0
		move.b	5(a0),d0
		move.w	off_5C5A2(pc,d0.w),d1
		jsr	off_5C5A2(pc,d1.w)
		jsr	(Sonic_Load_PLC).l
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

off_5C5A2: offsetTable
		offsetTableEntry.w loc_5C5AC		; 0
		offsetTableEntry.w loc_5C5D0		; 2
		offsetTableEntry.w loc_5C62C		; 4
		offsetTableEntry.w loc_5C642		; 6
		offsetTableEntry.w locret_5C65E		; 8
; ---------------------------------------------------------------------------

loc_5C5AC:
		addq.b	#2,5(a0)
		move.l	#Map_Sonic,$C(a0)
		move.w	#ArtTile_Player_1,$A(a0)
		clr.b	(Player_prev_frame).w
		move.b	#$5A,$22(a0)
		move.b	#6,$24(a0)
		rts
; ---------------------------------------------------------------------------

loc_5C5D0:
		subq.b	#1,$24(a0)
		bpl.s	locret_5C606
		move.b	#6,$24(a0)
		moveq	#0,d0
		move.b	$23(a0),d0
		addq.w	#2,d0
		cmpi.b	#$A,d0
		bhs.s	loc_5C608
		move.b	d0,$23(a0)
		lea	RawAni_5C622(pc,d0.w),a2
		move.b	(a2)+,$22(a0)
		bclr	#0,4(a0)
		tst.b	(a2)
		beq.s	locret_5C606
		bset	#0,4(a0)

locret_5C606:
		rts
; ---------------------------------------------------------------------------

loc_5C608:
		move.b	#4,5(a0)
		move.w	#1,$20(a0)
		move.w	#$600,$1C(a0)
		move.w	#$F,$2E(a0)
		rts
; ---------------------------------------------------------------------------
RawAni_5C622:	dc.b  $5A,   1, $59,   1, $55,   0, $56,   0, $57,   0
; ---------------------------------------------------------------------------

loc_5C62C:
		jsr	(Animate_Sonic).l
		subq.w	#1,$2E(a0)
		bmi.s	loc_5C63A
		rts
; ---------------------------------------------------------------------------

loc_5C63A:
		move.b	#6,5(a0)
		rts
; ---------------------------------------------------------------------------

loc_5C642:
		jsr	(Animate_Sonic).l
		addq.w	#6,$10(a0)
		cmpi.w	#$1E0,$10(a0)
		bhs.s	loc_5C656
		rts
; ---------------------------------------------------------------------------

loc_5C656:
		move.b	#8,5(a0)
		rts
; ---------------------------------------------------------------------------

locret_5C65E:
		rts
; ---------------------------------------------------------------------------

Obj_Continue_SonicAlone:
		moveq	#0,d0
		move.b	5(a0),d0
		move.w	off_5C67A(pc,d0.w),d1
		jsr	off_5C67A(pc,d1.w)
		jsr	(Sonic_Load_PLC).l
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

off_5C67A: offsetTable
		offsetTableEntry.w loc_5C684		; 0
		offsetTableEntry.w loc_5C6B6		; 2
		offsetTableEntry.w loc_5C6E0		; 4
		offsetTableEntry.w loc_5C6F4		; 6
		offsetTableEntry.w locret_5C716		; 8
; ---------------------------------------------------------------------------

loc_5C684:
		move.b	#2,5(a0)
		move.l	#Map_Sonic,$C(a0)
		move.w	#ArtTile_Player_1,$A(a0)
		move.w	#$280,8(a0)
		move.b	#$C,7(a0)
		move.b	#$14,6(a0)
		move.w	#$120,$10(a0)
		move.w	#$120,$14(a0)

loc_5C6B6:
		movea.w	(_unkFAA4).w,a1
		btst	#2,$38(a1)
		bne.s	loc_5C6CC
		lea	byte_5CBC5(pc),a1
		jmp	(Animate_RawNoSSTCheckResult).w
; ---------------------------------------------------------------------------

loc_5C6CC:
		move.b	#4,5(a0)
		move.b	#-$46,$22(a0)
		move.w	#7,$2E(a0)
		rts
; ---------------------------------------------------------------------------

loc_5C6E0:
		subq.w	#1,$2E(a0)
		bpl.s	locret_5C6F2
		move.b	#6,5(a0)
		move.b	#$21,$22(a0)

locret_5C6F2:
		rts
; ---------------------------------------------------------------------------

loc_5C6F4:
		addq.w	#6,$10(a0)
		cmpi.w	#$1E0,$10(a0)
		bhs.s	loc_5C70A
		lea	byte_5CBB4(pc),a1
		jmp	(Animate_RawNoSSTCheckResult).w
; ---------------------------------------------------------------------------

loc_5C70A:
		move.b	#8,5(a0)
		move.b	#1,(_unkFAA9).w

locret_5C716:
		rts
; ---------------------------------------------------------------------------

Obj_Continue_TailsWSonic:
		move.l	#Map_ContinueSprites,$C(a0)
		move.w	#$8C,$A(a0)
		move.w	#$200,8(a0)
		move.b	#$10,7(a0)
		move.b	#$14,6(a0)
		move.w	#$12C,$10(a0)
		move.w	#$120,$14(a0)
		move.l	#loc_5C74A,address(a0)

loc_5C74A:
		movea.w	(_unkFAA4).w,a1
		btst	#3,$38(a1)
		bne.s	loc_5C770
		move.b	#5,$22(a0)
		btst	#5,(V_int_run_count+3).w
		beq.s	loc_5C76A
		move.b	#6,$22(a0)

loc_5C76A:
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_5C770:
		move.l	#loc_5C790,address(a0)
		addq.w	#4,$14(a0)
		lea	(v_Tails_tails).w,a1
		move.l	#Obj_Tails_Tail,address(a1)
		move.w	a0,$30(a1)
		move.l	#loc_5C82C,(v_Dust).w

loc_5C790:
		moveq	#0,d0
		move.b	5(a0),d0
		move.w	off_5C7AA(pc,d0.w),d1
		jsr	off_5C7AA(pc,d1.w)
		jsr	(Tails_Load_PLC).l
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

off_5C7AA: offsetTable
		offsetTableEntry.w loc_5C7B2		; 0
		offsetTableEntry.w loc_5C7E2		; 2
		offsetTableEntry.w loc_5C802		; 4
		offsetTableEntry.w loc_5C814		; 6
; ---------------------------------------------------------------------------

loc_5C7B2:
		addq.b	#2,5(a0)
		move.l	#Map_Tails,$C(a0)
		move.w	#ArtTile_Player_2,$A(a0)
		move.w	#$280,8(a0)
		clr.b	(Player_prev_frame_P2).w
		move.w	#$500,$20(a0)
		move.w	#-$5300,$22(a0)
		move.w	#$27,$2E(a0)
		rts
; ---------------------------------------------------------------------------

loc_5C7E2:
		subq.w	#1,$2E(a0)
		bpl.w	locret_5C4D4
		move.b	#4,5(a0)
		move.b	#0,$20(a0)
		move.w	#$600,$1C(a0)
		move.w	#$13,$2E(a0)

loc_5C802:
		subq.w	#1,$2E(a0)
		bpl.s	loc_5C80E
		move.b	#6,5(a0)

loc_5C80E:
		jmp	(Animate_Tails).l
; ---------------------------------------------------------------------------

loc_5C814:
		addq.w	#6,$10(a0)
		cmpi.w	#$1E0,$10(a0)
		blo.s	loc_5C826
		move.b	#1,(_unkFAA9).w

loc_5C826:
		jmp	(Animate_Tails).l
; ---------------------------------------------------------------------------

loc_5C82C:
		bclr	#2,(v_Tails_tails+render_flags).w
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

loc_5C838:
		cmpi.w	#3,(Player_mode).w
		beq.s	loc_5C854
		lea	loc_5C8C8(pc),a1
		move.l	a1,address(a0)
		move.w	#$40,$10(a0)
		move.w	#$120,$14(a0)
		jmp	(a1)
; ---------------------------------------------------------------------------

loc_5C854:
		lea	loc_5C85A(pc),a1
		move.l	a1,address(a0)

loc_5C85A:
		move.l	#Map_ContinueSprites,$C(a0)
		move.w	#$608C,$A(a0)
		move.w	#$200,8(a0)
		move.b	#$10,7(a0)
		move.b	#$18,6(a0)
		move.w	#$11C,$10(a0)
		move.w	#$120,$14(a0)
		move.l	#loc_5C88C,address(a0)

loc_5C88C:
		move.w	#$2F,$2E(a0)
		movea.w	(_unkFAA4).w,a1
		btst	#3,$38(a1)
		beq.s	loc_5C8AC
		move.l	#loc_5C8AC,address(a0)
		move.l	#loc_5C972,(Dynamic_object_RAM+(object_size*13)).w

loc_5C8AC:
		subq.w	#1,$2E(a0)
		bpl.s	loc_5C8B8
		move.l	#loc_5C8C8,address(a0)

loc_5C8B8:
		lea	byte_5CBC0(pc),a1
		jsr	(Animate_RawNoSST).w
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_5C8C8:
		moveq	#0,d0
		move.b	5(a0),d0
		move.w	off_5C8E2(pc,d0.w),d1
		jsr	off_5C8E2(pc,d1.w)
		jsr	(Knuckles_Load_PLC_661E0).l
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

off_5C8E2: offsetTable
		offsetTableEntry.w loc_5C8EA		; 0
		offsetTableEntry.w loc_5C91E		; 2
		offsetTableEntry.w loc_5C932		; 4
		offsetTableEntry.w locret_5C970		; 6
; ---------------------------------------------------------------------------

loc_5C8EA:
		addq.b	#2,5(a0)
		move.l	#Map_Knuckles,$C(a0)
		move.w	#make_art_tile(ArtTile_CutsceneKnux,3,0),$A(a0)
		move.w	#$80,8(a0)
		move.b	#7,$22(a0)
		move.b	#$20,7(a0)
		move.b	#$30,6(a0)
		clr.b	$24(a0)
		clr.b	$23(a0)
		rts
; ---------------------------------------------------------------------------

loc_5C91E:
		movea.w	(_unkFAA4).w,a1
		btst	#3,$38(a1)
		bne.s	loc_5C92C
		rts
; ---------------------------------------------------------------------------

loc_5C92C:
		move.b	#4,5(a0)

loc_5C932:
		move.w	$10(a0),d0
		addq.w	#6,d0
		move.w	d0,$10(a0)
		movea.w	(_unkFAA4).w,a1
		cmpi.w	#$120,d0
		blo.s	loc_5C94C
		bset	#2,$38(a1)

loc_5C94C:
		cmpi.w	#$1E0,d0
		bhs.s	loc_5C95C
		lea	byte_5CBB4(pc),a1
		jmp	(Animate_RawNoSSTCheckResult).w
; ---------------------------------------------------------------------------

loc_5C95C:
		move.b	#6,5(a0)
		cmpi.w	#3,(Player_mode).w
		bne.s	locret_5C970
		move.b	#1,(_unkFAA9).w

locret_5C970:
		rts
; ---------------------------------------------------------------------------

loc_5C972:
		lea	ObjDat3_919A6(pc),a1
		jsr	(SetUp_ObjAttributes).w
		bclr	#2,4(a0)
		bset	#0,4(a0)
		move.l	#Obj_Continue_EggRobo_5C9C4,address(a0)
		move.w	#$60,$10(a0)
		move.w	#$F0,$14(a0)
		move.w	#$600,$18(a0)
		jsr	(Swing_Setup1).w
		lea	ChildObjDat_919D0(pc),a2
		jsr	(CreateChild1_Normal).w
		lea	(ArtKosM_EggRoboBadnik).l,a1
		move.w	#$A000,d2
		jmp	(Queue_Kos_Module).w
; ---------------------------------------------------------------------------

Obj_Continue_EggRobo_5C9C4:
		jsr	(Swing_UpAndDown).w
		jsr	(MoveSprite2).w
		jsr	sub_91988
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

sub_91988:
		moveq	#1,d0
		btst	#0,(V_int_run_count+3).w
		beq.s	loc_91994
		moveq	#3,d0

loc_91994:
		move.b	d0,$22(a0)
		rts

; =============== S U B R O U T I N E =======================================

loc_5C9DC:
		move.l	#Map_ContinueSprites,$C(a0)
		move.w	#$408C,$A(a0)
		move.w	#$380,8(a0)
		move.b	#7,$22(a0)
		move.b	#8,7(a0)
		move.b	#8,6(a0)
		move.w	#$120,$10(a0)
		move.w	#$F5,$14(a0)
		move.l	#loc_5CA14,address(a0)

loc_5CA14:
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

loc_5CA1A:
		move.l	#Map_ContinueIcons,$C(a0)
		move.w	#$D9,$A(a0)
		cmpi.w	#3,(Player_mode).w
		bne.s	loc_5CA36
		move.w	#$60D9,$A(a0)

loc_5CA36:
		move.w	#$380,8(a0)
		move.b	#8,7(a0)
		move.b	#8,6(a0)
		bsr.w	sub_5CB4A
		move.w	#$D8,$14(a0)
		move.l	#loc_5CA5C,address(a0)
		bsr.w	sub_5CB6A

loc_5CA5C:
		moveq	#0,d0
		btst	#4,(V_int_run_count+3).w
		beq.s	loc_5CA68
		addq.w	#1,d0

loc_5CA68:
		movea.l	$30(a0),a1
		move.b	(a1,d0.w),$22(a0)
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Knuckles_Load_PLC_661E0:
		moveq	#0,d0
		move.b	$22(a0),d0
		cmp.b	$3A(a0),d0
		beq.s	locret_66234
		move.b	d0,$3A(a0)
		lea	(DPLC_Knuckles).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d5
		subq.w	#1,d5
		bmi.s	locret_66234
		move.w	#tiles_to_bytes(ArtTile_CutsceneKnux),d4
		move.l	#ArtUnc_Knux>>1,d6

loc_6620C:
		moveq	#0,d1
		move.w	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#4,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(Add_To_DMA_Queue).w
		dbf	d5,loc_6620C

locret_66234:
		rts

; =============== S U B R O U T I N E =======================================

Obj_5CA78:
		move.l	#Map_ContinueIcons,$C(a0)
		move.w	#$D9,$A(a0)
		move.w	#$280,8(a0)
		move.b	#8,7(a0)
		move.b	#8,6(a0)
		move.l	#loc_5CA9E,address(a0)

loc_5CA9E:
		lea	byte_5CBBB(pc),a1
		jsr	(Animate_RawNoSST).w
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

sub_5CAAE:
		move.b	(_unkFA84).w,d0
		move.b	d0,d1
		andi.w	#$F0,d0
		lsr.w	#3,d0
		andi.w	#$F,d1
		add.w	d1,d1
		move.w	#1,d2
		lea	(RAM_start+$2000).l,a1
		add.w	d2,d0
		move.w	d0,(a1)+
		add.w	d2,d1
		move.w	d1,(a1)+
		addq.w	#1,d0
		move.w	d0,(a1)+
		addq.w	#1,d1
		move.w	d1,(a1)+
		disableInts
		lea	(VDP_data_port).l,a6
		move.w	#$C726,d2
		swap	d2
		clr.w	d2
		swap	d2
		lsl.l	#2,d2
		lsr.w	#2,d2
		ori.w	#$4000,d2
		swap	d2
		move.l	d2,d3
		addi.l	#$800000,d3
		lea	(RAM_start+$2000).l,a1
		move.l	d2,VDP_control_port-VDP_data_port(a6)
		move.w	(a1)+,(a6)
		move.w	(a1)+,(a6)
		move.l	d3,VDP_control_port-VDP_data_port(a6)
		move.w	(a1)+,(a6)
		move.w	(a1)+,(a6)
		enableInts
		rts

; =============== S U B R O U T I N E =======================================

sub_5B318:
		bsr.w	sub_5B36C
		disableInts
		lea	(VDP_data_port).l,a6
		addi.w	#$C000,d2
		swap	d2
		clr.w	d2
		swap	d2
		lsl.l	#2,d2
		lsr.w	#2,d2
		ori.w	#$4000,d2
		swap	d2
		move.l	d2,d3
		addi.l	#$800000,d3
		lea	(RAM_start+$7000).l,a1
		move.l	d2,4(a6)
		subq.w	#1,d0
		move.w	d0,d1

loc_5B350:
		move.w	(a1)+,(a6)
		dbf	d0,loc_5B350
		lea	(RAM_start+$7080).l,a1
		move.l	d3,VDP_control_port-VDP_data_port(a6)

loc_5B360:
		move.w	(a1)+,(a6)
		dbf	d1,loc_5B360
		enableInts
		rts

; =============== S U B R O U T I N E =======================================

sub_5CB1C:
		moveq	#0,d0
		move.b	(Continue_count).w,d0
		beq.s	loc_5CB2A
		cmpi.b	#10,d0
		bls.s		loc_5CB2C

loc_5CB2A:
		moveq	#10,d0

loc_5CB2C:
		lea	(Dynamic_object_RAM+(object_size*2)).w,a1
		moveq	#0,d1

loc_5CB32:
		subq.b	#1,d0
		beq.w	locret_5C4D4
		move.l	#loc_5CA1A,address(a1)
		move.b	d1,$2C(a1)
		addq.w	#2,d1
		lea	next_object(a1),a1
		bra.s	loc_5CB32

; =============== S U B R O U T I N E =======================================

sub_5CB4A:
		moveq	#0,d0
		move.b	$2C(a0),d0
		move.w	word_5CB58(pc,d0.w),$10(a0)
		rts
; ---------------------------------------------------------------------------

word_5CB58:
		dc.w $120
		dc.w $138
		dc.w $108
		dc.w $150
		dc.w $F0
		dc.w $168
		dc.w $D8
		dc.w $180
		dc.w $C0

; =============== S U B R O U T I N E =======================================

loc_916A8:
		lea	word_919BE(pc),a1
		jsr	(SetUp_ObjAttributes3).w
		movea.w	$46(a0),a1
		btst	#2,4(a1)
		bne.s	loc_916C4
		bclr	#2,4(a0)

loc_916C4:
		move.l	#loc_916CC,address(a0)
		rts
; ---------------------------------------------------------------------------

loc_916CC:
		jsr	(Refresh_ChildPositionAdjusted).w
		moveq	#6,d0
		move.w	$1A(a1),d1
		bmi.s	loc_916E4
		moveq	#5,d0
		cmpi.w	#$20,d1
		blo.s	loc_916E4
		moveq	#4,d0

loc_916E4:
		move.b	d0,$22(a0)
		jmp	(Child_Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

loc_916EE:
		lea	word_919C4(pc),a1
		jsr	(SetUp_ObjAttributes3).w
		movea.w	$46(a0),a1
		btst	#2,4(a1)
		bne.s	loc_9170A
		bclr	#2,4(a0)

loc_9170A:
		move.l	#loc_91712,address(a0)
		rts
; ---------------------------------------------------------------------------

loc_91712:
		bsr.w	sub_91930
		btst	#1,$38(a1)
		beq.s	loc_91734
		move.l	#loc_9173A,address(a0)
		move.w	#$5F,$2E(a0)
		lea	ChildObjDat_919DE(pc),a2
		jsr	(CreateChild10_NormalAdjusted).w

loc_91734:
		jmp	(Child_Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_9173A:
		subq.w	#1,$2E(a0)
		bpl.s	loc_91750
		move.l	#loc_91712,address(a0)
		movea.w	$46(a0),a1
		bclr	#1,$38(a1)

loc_91750:
		jmp	(Child_Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

loc_91756:
		lea	word_919CA(pc),a1
		jsr	(SetUp_ObjAttributes3).w
		move.l	#loc_9176C,address(a0)
		move.w	#$1F,$2E(a0)

loc_9176C:
		moveq	#0,d0
		btst	#0,(V_int_run_count+3).w
		beq.s	loc_91778
		moveq	#7,d0

loc_91778:
		move.b	d0,$22(a0)
		subq.w	#1,$2E(a0)
		bpl.s	loc_917AE
		move.l	#loc_917B4,address(a0)
		move.b	#7,$22(a0)
		move.b	#-$64,$28(a0)
		move.w	#-$800,d0
		btst	#0,4(a0)
		beq.s	loc_917A2
		neg.w	d0

loc_917A2:
		move.w	d0,$18(a0)
		sfx	sfx_Laser

loc_917AE:
		jmp	(Child_DrawTouch_Sprite).w
; ---------------------------------------------------------------------------

loc_917B4:
		jsr	(MoveSprite2).w
		jmp	(Sprite_CheckDeleteTouch).w

; =============== S U B R O U T I N E =======================================

sub_91930:
		movea.w	parent3(a0),a1
		move.w	x_pos(a1),d0
		move.b	child_dx(a0),d1
		ext.w	d1
		bclr	#0,render_flags(a0)
		btst	#0,render_flags(a1)
		beq.s	loc_91954
		neg.w	d1
		bset	#0,render_flags(a0)

loc_91954:
		add.w	d1,d0
		move.w	d0,x_pos(a0)
		move.w	$32(a1),d0
		bne.s	loc_91964
		move.w	y_pos(a1),d0

loc_91964:
		move.b	child_dy(a0),d1
		ext.w	d1
		bclr	#1,render_flags(a0)
		btst	#1,render_flags(a1)
		beq.s	loc_91980
		neg.w	d1
		bset	#1,render_flags(a0)

loc_91980:
		add.w	d1,d0
		move.w	d0,y_pos(a0)

locret_5B316:
		rts

; =============== S U B R O U T I N E =======================================

sub_5B36C:
		lea	(RAM_start+$7000).l,a2
		lea	(RAM_start+$7080).l,a3
		moveq	#0,d0

loc_5B37A:
		moveq	#0,d1
		move.b	(a1)+,d1
		beq.s	locret_5B316
		cmpi.b	#' ',d1				; Space
		beq.w	loc_5B420
		cmpi.b	#'?',d1				; ?
		beq.w	loc_5B418
		cmpi.b	#'!',d1				; !
		beq.s	loc_5B410
		cmpi.b	#'&',d1				; &
		beq.s	loc_5B408
		cmpi.b	#')',d1				; )
		beq.s	loc_5B400
		cmpi.b	#'(',d1				; (
		beq.s	loc_5B3F8
		cmpi.b	#'.',d1				; .
		beq.s	loc_5B3F0
		cmpi.b	#'I',d1				; I
		beq.s	loc_5B3DC
		addq.w	#2,d0
		subi.b	#'A',d1				; A
		lsl.w	#3,d1
		lea	CreditsText_PlaneMap(pc),a4
		adda.w	d1,a4

loc_5B3C2:
		move.w	(a4)+,d5
		add.w	d6,d5
		move.w	d5,(a2)+
		move.w	(a4)+,d5
		add.w	d6,d5
		move.w	d5,(a2)+
		move.w	(a4)+,d5
		add.w	d6,d5
		move.w	d5,(a3)+
		move.w	(a4)+,d5
		add.w	d6,d5
		move.w	d5,(a3)+
		bra.s	loc_5B37A
; ---------------------------------------------------------------------------

loc_5B3DC:
		addq.w	#1,d0
		lea	CreditsText_PlaneMap.LetterI(pc),a4

loc_5B3E2:
		move.w	(a4)+,d5
		add.w	d6,d5
		move.w	d5,(a2)+
		move.w	(a4)+,d5
		add.w	d6,d5
		move.w	d5,(a3)+
		bra.s	loc_5B37A
; ---------------------------------------------------------------------------

loc_5B3F0:
		addq.w	#1,d0
		lea	CreditsText_PlaneMap.Period(pc),a4
		bra.s	loc_5B3E2
; ---------------------------------------------------------------------------

loc_5B3F8:
		addq.w	#1,d0
		lea	CreditsText_PlaneMap.LeftBracket(pc),a4
		bra.s	loc_5B3E2
; ---------------------------------------------------------------------------

loc_5B400:
		addq.w	#1,d0
		lea	CreditsText_PlaneMap.RightBracket(pc),a4
		bra.s	loc_5B3E2
; ---------------------------------------------------------------------------

loc_5B408:
		addq.w	#2,d0
		lea	CreditsText_PlaneMap.Ampersand(pc),a4
		bra.s	loc_5B3C2
; ---------------------------------------------------------------------------

loc_5B410:
		addq.w	#1,d0
		lea	CreditsText_PlaneMap.Exclamation(pc),a4
		bra.s	loc_5B3E2
; ---------------------------------------------------------------------------

loc_5B418:
		addq.w	#2,d0
		lea	CreditsText_PlaneMap.QuestionMark(pc),a4
		bra.s	loc_5B3C2
; ---------------------------------------------------------------------------

loc_5B420:
		addq.w	#1,d0
		clr.w	(a2)+
		clr.w	(a3)+
		bra.w	loc_5B37A
; ---------------------------------------------------------------------------

CreditsText_PlaneMap:
		dc.w      0,  $800,     1,     2	; A
		dc.w      3,     4,     5,     6	; B
		dc.w      7,     8,     9,    $A	; C
		dc.w      3,  $807,    $B,  $809	; D
		dc.w      3,    $C,     5,    $D	; E
		dc.w      3,    $C,    $E,    $F	; F
		dc.w      7,     8,     9,   $10	; G
		dc.w    $11,  $811,    $E, $180B	; H
.LetterI:	dc.w    $11,   $12,     0,     0	; I
		dc.w    $13,  $811,   $14,   $15	; J
		dc.w    $16,   $17,   $18,   $19	; K
		dc.w    $11,   $13,    $B,   $1A	; L
		dc.w    $1B,   $1C,   $1D,   $1E	; M
		dc.w    $1B,  $811,   $1D,   $1F	; N
		dc.w      7,  $807,     9,  $809	; O
		dc.w    $20,   $21,   $22,   $23	; P
		dc.w      7,  $807,     9,   $24	; Q
		dc.w    $20,   $21,   $25,   $26	; R
		dc.w   $821,    $C,   $27,     6	; S
		dc.w    $28,   $29,   $2A,   $2B	; T
		dc.w    $11,  $811,  $815,   $15	; U
		dc.w    $2C,  $82C,   $2D,  $82D	; V
		dc.w    $2E,  $811,   $2F,   $30	; W
		dc.w    $31,  $831,   $32,  $832	; X
		dc.w    $31,   $33,   $2A,   $2B	; Y
		dc.w   $80C,   $34,   $35,   $36	; Z
.Period:	dc.w    $13,   $37			; .
.LeftBracket:	dc.w    $38, $1038			; (
.RightBracket:	dc.w   $838, $1838			; )
.Ampersand:	dc.w    $39,   $3A,   $3B,   $3C	; &
.Exclamation:	dc.w   $812,   $3D			; !
.QuestionMark:	dc.w  $180A,   $3E,   $3F,   $40	; ?

; =============== S U B R O U T I N E =======================================

sub_5CB6A:
		move.w	(Player_mode).w,d4
		cmpi.b	#2,d4
		bne.s	loc_5CB7E
		lea	ChildObjDat_5CB88(pc),a2
		jsr	(CreateChild6_Simple).w

loc_5CB7E:
		lsl.w	#2,d4
		move.l	off_5CB8E(pc,d4.w),$30(a0)
		rts
; ---------------------------------------------------------------------------

ChildObjDat_5CB88:
		dc.w 1-1
		dc.l Obj_5CA78
off_5CB8E:
		dc.l byte_5CBAE
		dc.l byte_5CBAE
		dc.l byte_5CBB0
		dc.l byte_5CBB2
aCONTINUE:		dc.b "C O N T I N U E",0
	even

ObjDat3_919A6:
		dc.l Map_EggRobo
		dc.w $8500
		dc.w $280
		dc.b $14
		dc.b $18
		dc.b 1
		dc.b 6
byte_5CBAE:
		dc.b 0
		dc.b 1
byte_5CBB0:
		dc.b 2
		dc.b 3
byte_5CBB2:
		dc.b 7
		dc.b 8
byte_5CBB4:
		dc.b 2
		dc.b $21
		dc.b $22
		dc.b $23
		dc.b $24
		dc.b $FF
		dc.b $FC
byte_5CBBB:
		dc.b 8
		dc.b 4
		dc.b 5
		dc.b 6
		dc.b $FC
byte_5CBC0:
		dc.b $B
		dc.b 2
		dc.b 2
		dc.b 4
		dc.b $FC
byte_5CBC5:
		dc.b $B
		dc.b $BD
		dc.b $BE
		dc.b $FF
		dc.b $FC
ChildObjDat_919D0:
		dc.w 1
		dc.l loc_916A8
		dc.b $F4
		dc.b $1C
		dc.l loc_916EE
		dc.b $E4
		dc.b $FC
ChildObjDat_919DE:
		dc.w 0
		dc.l loc_91756
		dc.b $B
		dc.b $FC

word_919BE:
		dc.w $280
		dc.b $C
		dc.b $10
		dc.b 6
		dc.b 0
word_919C4:
		dc.w $280
		dc.b $10
		dc.b $C
		dc.b 2
		dc.b 0
word_919CA:
		dc.w $280
		dc.b $20
		dc.b 4
		dc.b 7
		dc.b 0

PLC_Continue: plrlistheader
		plreq 1, ArtKosM_ContinueDigits
		plreq $8C, ArtKosM_ContinueSprites
		plreq $D9, ArtKosM_ContinueIcons
		plreq $347, ArtKosM_CreditsText
PLC_Continue_end
; ---------------------------------------------------------------------------

		include "Data/Screens/Continue/Object Data/Map - Player Sprites.asm"
		include "Data/Screens/Continue/Object Data/Map - Player Icons.asm"
