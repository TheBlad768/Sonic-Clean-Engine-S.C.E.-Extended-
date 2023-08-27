
; =============== S U B R O U T I N E =======================================

Obj_Knuckles:
		lea	(Max_speed).w,a4
		lea	(Distance_from_top).w,a5
		lea	(v_Dust).w,a6

		tst.w	(Debug_placement_mode).w
		beq.s	Knuckles_Normal
		cmpi.b	#1,(Debug_placement_type).w
		beq.s	loc_16488
		btst	#4,(Ctrl_1_pressed).w
		beq.s	loc_1646C
		move.w	#0,(Debug_placement_mode).w

loc_1646C:
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#$FB,mapping_frame(a0)
		blo.s		loc_1647E
		move.b	#0,mapping_frame(a0)

loc_1647E:
		bsr.w	Knuckles_Load_PLC
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_16488:
		jmp	(DebugMode).l
; ---------------------------------------------------------------------------

Knuckles_Normal:
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	Knuckles_Index(pc,d0.w),d1
		jmp	Knuckles_Index(pc,d1.w)
; ---------------------------------------------------------------------------

Knuckles_Index:
		dc.w Knuckles_Init-Knuckles_Index
		dc.w Knuckles_Control-Knuckles_Index
		dc.w loc_17BB6-Knuckles_Index
		dc.w loc_17C88-Knuckles_Index
		dc.w loc_17CBA-Knuckles_Index
		dc.w loc_17CCE-Knuckles_Index
		dc.w loc_17CEA-Knuckles_Index
; ---------------------------------------------------------------------------

Knuckles_Init:
		addq.b	#2,routine(a0)
		move.b	#$13,y_radius(a0)
		move.b	#9,x_radius(a0)
		move.b	#$13,default_y_radius(a0)
		move.b	#9,default_x_radius(a0)
		move.l	#Map_Knuckles,mappings(a0)
		move.w	#$100,priority(a0)
		move.b	#$18,width_pixels(a0)
		move.b	#$18,height_pixels(a0)
		move.b	#4,render_flags(a0)
		move.b	#2,character_id(a0)
		move.w	#$600,Max_speed-Max_speed(a4)
		move.w	#$C,Acceleration-Max_speed(a4)
		move.w	#$80,Deceleration-Max_speed(a4)
		tst.b	(Last_star_post_hit).w
		bne.s	Knuckles_Init_Continued

		; only happens when not starting at a checkpoint:
		move.w	#make_art_tile(ArtTile_Player_1,0,0),art_tile(a0)
		move.w	#bytes_to_word($C,$D),top_solid_bit(a0)

		; only happens when not starting at a Special Stage ring:
		move.w	x_pos(a0),(Saved_X_pos).w
		move.w	y_pos(a0),(Saved_Y_pos).w
		move.w	art_tile(a0),(Saved_art_tile).w
		move.w	top_solid_bit(a0),(Saved_solid_bits).w

Knuckles_Init_Continued:
		move.b	#0,flips_remaining(a0)
		move.b	#4,flip_speed(a0)
		move.b	#$1E,air_left(a0)
		subi.w	#$20,x_pos(a0)
		addi.w	#4,y_pos(a0)
		jsr	(Reset_Player_Position_Array).l
		addi.w	#$20,x_pos(a0)
		subi.w	#4,y_pos(a0)
		rts
; ---------------------------------------------------------------------------

Knuckles_Control:
		tst.b	(Debug_mode_flag).w
		beq.s	loc_165A2
		bclr	#6,(Ctrl_1_pressed).w
		beq.s	loc_16580
		eori.b	#1,(Reverse_gravity_flag).w

loc_16580:
		btst	#4,(Ctrl_1_pressed).w
		beq.s	loc_165A2
		move.w	#1,(Debug_placement_mode).w
		clr.b	(Ctrl_1_locked).w
		btst	#5,(Ctrl_1).w
		beq.s	locret_165A0
		move.w	#2,(Debug_placement_mode).w

locret_165A0:
		rts
; ---------------------------------------------------------------------------

loc_165A2:
		tst.b	(Ctrl_1_locked).w
		bne.s	loc_165AE
		move.w	(Ctrl_1).w,(Ctrl_1_logical).w

loc_165AE:
		btst	#0,$2E(a0)
		beq.s	loc_165BE
		move.b	#0,double_jump_flag(a0)
		bra.s	loc_165D8
; ---------------------------------------------------------------------------

loc_165BE:
		movem.l	a4-a6,-(sp)
		moveq	#0,d0
		move.b	$2A(a0),d0
		andi.w	#6,d0
		move.w	Knux_Modes(pc,d0.w),d1
		jsr	Knux_Modes(pc,d1.w)
		movem.l	(sp)+,a4-a6

loc_165D8:
		cmpi.w	#$FF00,(Camera_min_Y_pos).w
		bne.s	loc_165E8
		move.w	(Screen_Y_wrap_value).w,d0
		and.w	d0,$14(a0)

loc_165E8:
		bsr.s	Knuckles_Display
		bsr.w	Sonic_RecordPos
		bsr.w	Knuckles_Water
		move.b	(Primary_Angle).w,$3A(a0)
		move.b	(Secondary_Angle).w,$3B(a0)
		tst.b	(WindTunnel_flag).w
		beq.s	loc_16614
		tst.b	anim(a0)
		bne.s	loc_16614
		move.b	$21(a0),anim(a0)

loc_16614:
		btst	#1,$2E(a0)
		bne.s	loc_16630
		bsr.w	Animate_Knuckles
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_1662C
		eori.b	#2,4(a0)

loc_1662C:
		bsr.w	Knuckles_Load_PLC

loc_16630:
		move.b	$2E(a0),d0
		andi.b	#-$60,d0
		bne.s	locret_16640
		jsr	(TouchResponse).l

locret_16640:
		rts
; ---------------------------------------------------------------------------
Knux_Modes:	dc.w Knux_Stand_Path-Knux_Modes
		dc.w Knux_Stand_Freespace-Knux_Modes
		dc.w Knux_Spin_Path-Knux_Modes
		dc.w Knux_Spin_Freespace-Knux_Modes

; =============== S U B R O U T I N E =======================================


Knuckles_Display:
		move.b	$34(a0),d0
		beq.s	loc_16658
		subq.b	#1,$34(a0)
		lsr.b	#3,d0
		bcc.s	loc_1665E

loc_16658:
		jsr	(Draw_Sprite).w

loc_1665E:
		btst	#1,$2B(a0)
		beq.s	loc_1669A
		tst.b	$35(a0)
		beq.s	loc_1669A
		move.b	(Level_frame_counter+1).w,d0
		andi.b	#7,d0
		bne.s	loc_1669A
		subq.b	#1,$35(a0)
		bne.s	loc_1669A
		tst.b	(Level_end_flag).w						; don't change music if level is end
		bne.s	loc_16694
		tst.b	(Boss_flag).w
		bne.s	loc_16694
		cmpi.b	#$C,$2C(a0)
		blo.s		loc_16694
		move.w	(Current_music).w,d0
		jsr	(SMPS_QueueSound1).w					; stop playing invincibility theme and resume normal level music

loc_16694:
		bclr	#1,$2B(a0)

loc_1669A:
		btst	#2,$2B(a0)
		beq.s	locret_166EC
		tst.b	$36(a0)
		beq.s	locret_166EC
		move.b	(Level_frame_counter+1).w,d0
		andi.b	#7,d0
		bne.s	locret_166EC
		subq.b	#1,$36(a0)
		bne.s	locret_166EC
		move.w	#$600,(a4)
		move.w	#$C,2(a4)
		move.w	#$80,4(a4)
		bclr	#2,$2B(a0)
		music	mus_Slowdown						; run music at normal speed

locret_166EC:
		rts

; =============== S U B R O U T I N E =======================================

Knuckles_Water:
		tst.b	(Water_flag).w
		bne.s	loc_166F6

locret_166F4:
		rts
; ---------------------------------------------------------------------------

loc_166F6:
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0
		bge.s	loc_1676E
		bset	#Status_Underwater,status(a0)
		bne.s	locret_166F4
		addq.b	#1,(Water_entered_counter).w
		movea.w	a0,a1
		bsr.w	Player_ResetAirTimer
		move.l	#Obj_AirCountdown,(v_Breathing_bubbles+address).w
		move.b	#$81,(v_Breathing_bubbles+subtype).w
		move.w	a0,(v_Breathing_bubbles+parent).w
		move.w	#$300,Max_speed-Max_speed(a4)
		move.w	#6,Acceleration-Max_speed(a4)
		move.w	#$40,Deceleration-Max_speed(a4)
		tst.b	object_control(a0)
		bne.s	locret_166F4
		asr	x_vel(a0)
		asr	y_vel(a0)
		asr	y_vel(a0)
		beq.s	locret_166F4
		move.w	#$100,anim(a6)
		sfx	sfx_Splash,1				; splash sound
; ---------------------------------------------------------------------------

loc_1676E:
		bclr	#Status_Underwater,status(a0)
		beq.w	locret_166F4
		addq.b	#1,(Water_entered_counter).w
		movea.w	a0,a1
		bsr.w	Player_ResetAirTimer
		move.w	#$600,Max_speed-Max_speed(a4)
		move.w	#$C,Acceleration-Max_speed(a4)
		move.w	#$80,Deceleration-Max_speed(a4)
		cmpi.b	#4,routine(a0)
		beq.s	loc_167C4
		tst.b	object_control(a0)
		bne.s	loc_167C4
		move.w	y_vel(a0),d0
		cmpi.w	#-$400,d0
		blt.s	loc_167C4
		asl	y_vel(a0)

loc_167C4:
		cmpi.b	#$1C,anim(a0)
		beq.w	locret_166F4
		tst.w	y_vel(a0)
		beq.w	locret_166F4
		move.w	#$100,anim(a6)
		cmpi.w	#-$1000,y_vel(a0)
		bgt.s	loc_167EA
		move.w	#-$1000,y_vel(a0)

loc_167EA:
		sfx	sfx_Splash,1				; splash sound

; =============== S U B R O U T I N E =======================================

Knux_Stand_Path:
		bsr.w	SonicKnux_Spindash
		bsr.w	Knux_Jump
		bsr.w	Player_SlopeResist
		bsr.w	Knux_InputAcceleration_Path
		bsr.w	SonicKnux_Roll
		bsr.w	Player_LevelBound
		jsr	(MoveSprite2_TestGravity).w
		bsr.w	Call_Player_AnglePos
		bra.w	Player_SlopeRepel
; ---------------------------------------------------------------------------

Knux_Stand_Freespace:
		tst.b	double_jump_flag(a0)
		bne.s	Knux_Glide_Freespace
	if RollInAir
		bsr.w	Sonic_ChgFallAnim
	endif
		bsr.w	Knux_JumpHeight
		bsr.w	Knux_ChgJumpDir
		bsr.w	Player_LevelBound
		jsr	(MoveSprite_TestGravity).w
		btst	#6,$2A(a0)
		beq.s	loc_16872
		subi.w	#$28,$1A(a0)

loc_16872:
		bsr.w	Player_JumpAngle
		bra.w	Player_DoLevelCollision
; ---------------------------------------------------------------------------

Knux_Glide_Freespace:
		bsr.w	Knuckles_Move_Glide
		bsr.w	Player_LevelBound
		jsr	(MoveSprite2_TestGravity).w
		bsr.w	Knuckles_Glide

locret_1688E:
		rts

; =============== S U B R O U T I N E =======================================

Knuckles_Glide:
		move.b	double_jump_flag(a0),d0
		beq.s	locret_1688E
		cmpi.b	#2,d0
		beq.w	Knuckles_Fall_From_Glide
		cmpi.b	#3,d0
		beq.w	Knuckles_Sliding
		cmpi.b	#4,d0
		beq.w	Knuckles_Wall_Climb
		cmpi.b	#5,d0
		beq.w	Knuckles_Climb_Ledge

		; This function updates 'Gliding_collision_flags'.
		bsr.w	Knux_DoLevelCollision_CheckRet

		btst	#Status_InAir,(Gliding_collision_flags).w
		beq.s	Knux_Gliding_HitFloor

		btst	#Status_Push,(Gliding_collision_flags).w
		bne.w	Knuckles_Gliding_HitWall

		move.b	(Ctrl_1_logical).w,d0
		andi.b	#button_A_mask|button_B_mask|button_C_mask,d0
		bne.s	.continueGliding

		; The player has let go of the jump button, so exit the gliding state
		; and enter the falling state.
		move.b	#2,double_jump_flag(a0)
		move.b	#$21,anim(a0)
		bclr	#Status_Facing,status(a0)
		tst.w	x_vel(a0)
		bpl.s	.skip1
		bset	#Status_Facing,status(a0)

.skip1:
		; Divide Knuckles' X velocity by 4.
		asr.w	x_vel(a0)
		asr.w	x_vel(a0)

		move.b	default_y_radius(a0),y_radius(a0)
		move.b	default_x_radius(a0),x_radius(a0)

		rts
; ---------------------------------------------------------------------------
; loc_1690A:
.continueGliding:
		bra.w	Knuckles_Set_Gliding_Animation
; ---------------------------------------------------------------------------

Knux_Gliding_HitFloor:
		bclr	#Status_Facing,status(a0)
		tst.w	x_vel(a0)
		bpl.s	+
		bset	#Status_Facing,status(a0)
+
		move.b	angle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_1693E

		move.w	ground_vel(a0),x_vel(a0)
		move.w	#0,y_vel(a0)

		bra.w	Knux_TouchFloor
; ---------------------------------------------------------------------------

loc_1693E:
		move.b	#3,double_jump_flag(a0)
		move.b	#$CC,mapping_frame(a0)
		move.b	#$7F,anim_frame_timer(a0)
		move.b	#0,anim_frame(a0)

		; The drowning countdown uses the dust clouds' VRAM, so don't create
		; dust if Knuckles is drowning.
		cmpi.b	#12,air_left(a0)
		blo.s	+
		; Create dust clouds.
		move.b	#6,routine(a6)
		move.b	#$15,mapping_frame(a6)
+
		rts
; ---------------------------------------------------------------------------

Knuckles_Gliding_HitWall:
		tst.b	(Disable_wall_grab).w
		bmi.w	.fail

		move.b	lrb_solid_bit(a0),d5
		move.b	double_jump_property(a0),d0
		addi.b	#$40,d0
		bpl.s	.right

;.left:
		bset	#Status_Facing,status(a0)

		bsr.w	CheckLeftCeilingDist
		or.w	d0,d1
		bne.s	.checkFloorLeft

		addq.w	#1,x_pos(a0)
		bra.s	.success

.right:
		bclr	#Status_Facing,status(a0)

		bsr.w	CheckRightCeilingDist
		or.w	d0,d1
		bne.w	.checkFloorRight
; loc_169A6:
.success:
		sfx	sfx_Grab
		move.w	#0,ground_vel(a0)
		move.w	#0,x_vel(a0)
		move.w	#0,y_vel(a0)
		move.b	#4,double_jump_flag(a0)
		move.b	#$B7,mapping_frame(a0)
		move.b	#$7F,anim_frame_timer(a0)
		move.b	#0,anim_frame(a0)
		move.b	#3,double_jump_property(a0)
		; 'x_pos+2' holds the X coordinate that Knuckles was at when he first
		; latched onto the wall.
		move.w	x_pos(a0),x_pos+2(a0)
		rts
; ---------------------------------------------------------------------------
; loc_16A00:
.checkFloorLeft:
		; This adds the Y radius to the X coordinate...
		; This appears to be a bug, but, luckily, the X and Y radius are both
		; 10, so this is harmless.
		move.w	x_pos(a0),d3
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		subq.w	#1,d3

		tst.b	(Reverse_gravity_flag).w
		bne.s	.reverseGravity
; loc_16A14:
.checkFloorCommon:
		move.w	y_pos(a0),d2
		subi.w	#11,d2
		jsr	(ChkFloorEdge_Part3).l

		tst.w	d1
		bmi.s	.fail
		cmpi.w	#12,d1
		bhs.s	.fail
		add.w	d1,y_pos(a0)
		bra.w	.success
; ---------------------------------------------------------------------------
; loc_16A34:
.reverseGravity:
		move.w	y_pos(a0),d2
		addi.w	#11,d2
		eori.w	#$F,d2
		jsr	(ChkFloorEdge_ReverseGravity_Part2).l

		tst.w	d1
		bmi.s	.fail
		cmpi.w	#12,d1
		bhs.s	.fail
		sub.w	d1,y_pos(a0)
		bra.w	.success
; ---------------------------------------------------------------------------
; loc_16A58:
.checkFloorRight:
		; This adds the Y radius to the X coordinate...
		; This appears to be a bug, but, luckily, the X and Y radius are both
		; 10, so this is harmless.
		move.w	x_pos(a0),d3
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		addq.w	#1,d3

		tst.b	(Reverse_gravity_flag).w
		bne.s	Knuckles_Gliding_HitWall.reverseGravity

		bra.s	.checkFloorCommon
; ---------------------------------------------------------------------------
; loc_16A6E:
.fail:
		move.b	#2,double_jump_flag(a0)
		move.b	#$21,anim(a0)
		move.b	default_y_radius(a0),y_radius(a0)
		move.b	default_x_radius(a0),x_radius(a0)
		bset	#Status_InAir,(Gliding_collision_flags).w
		rts
; ---------------------------------------------------------------------------

Knuckles_Fall_From_Glide:
		bsr.w	Knux_ChgJumpDir

		; Apply gravity.
		addi.w	#$38,y_vel(a0)

		; Fall slower when underwater.
		btst	#Status_Underwater,status(a0)
		beq.s	.skip1
		subi.w	#$28,y_vel(a0)

.skip1:
		; This function updates 'Gliding_collision_flags'.
		bsr.w	Knux_DoLevelCollision_CheckRet

		btst	#Status_InAir,(Gliding_collision_flags).w
		bne.s	.return

		; Knuckles has touched the ground.
		move.w	#0,ground_vel(a0)
		move.w	#0,x_vel(a0)
		move.w	#0,y_vel(a0)

		move.b	y_radius(a0),d0
		sub.b	default_y_radius(a0),d0
		ext.w	d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	.skip2
		neg.w	d0

.skip2:
		add.w	d0,y_pos(a0)
		sfx	sfx_GlideLand
		move.b	angle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	.skip3
		bra.w	Knux_TouchFloor

.skip3:
		bsr.w	Knux_TouchFloor
		move.w	#$F,move_lock(a0)
		move.b	#$23,anim(a0)
; locret_16B04:
.return:
		rts
; ---------------------------------------------------------------------------

Knuckles_Sliding:
		move.b	(Ctrl_1_logical).w,d0
		andi.b	#button_A_mask|button_B_mask|button_C_mask,d0
		beq.s	.getUp

		tst.w	x_vel(a0)
		bpl.s	.goingRight

;.goingLeft:
		addi.w	#$20,x_vel(a0)
		bmi.s	.continueSliding2

		bra.s	.getUp
; ---------------------------------------------------------------------------
; loc_16B20:
.continueSliding2:
		bra.s	.continueSliding
; ---------------------------------------------------------------------------
; loc_16B22:
.goingRight:
		subi.w	#$20,x_vel(a0)
		bpl.s	.continueSliding
; loc_16B2A:
.getUp:
		move.w	#0,ground_vel(a0)
		move.w	#0,x_vel(a0)
		move.w	#0,y_vel(a0)

		move.b	y_radius(a0),d0
		sub.b	default_y_radius(a0),d0
		ext.w	d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	.skip1
		neg.w	d0

.skip1:
		add.w	d0,y_pos(a0)

		bsr.w	Knux_TouchFloor

		move.w	#$F,move_lock(a0)
		move.b	#$22,anim(a0)

		rts
; ---------------------------------------------------------------------------
; loc_16B64:
.continueSliding:
		bsr.w	Knux_DoLevelCollision_CheckRet

		; Get distance from floor in 'd1', and angle of floor in 'd3'.
		bsr.w	sub_11FD6

		; If the distance from the floor is suddenly really high, then
		; Knuckles must have slid off a ledge, so make him enter his falling
		; state.
		cmpi.w	#14,d1
		bge.s	.fail

		tst.b	(Reverse_gravity_flag).w
		beq.s	.skip2
		neg.w	d1

.skip2:
		add.w	d1,y_pos(a0)
		move.b	d3,angle(a0)

		; Play the sliding sound every 8 frames.
		move.b	(Level_frame_counter+1).w,d0
		andi.b	#7,d0
		bne.s	.skip3
		sfx	sfx_GroundSlide

.skip3:
		rts
; ---------------------------------------------------------------------------
; loc_16B96:
.fail:
		move.b	#2,double_jump_flag(a0)
		move.b	#$21,anim(a0)

		move.b	default_y_radius(a0),y_radius(a0)
		move.b	default_x_radius(a0),x_radius(a0)

		bset	#Status_InAir,(Gliding_collision_flags).w
		rts
; ---------------------------------------------------------------------------

Knuckles_Wall_Climb:
		tst.b	(Disable_wall_grab).w
		bmi.w	Knuckles_LetGoOfWall

		; If Knuckles' X coordinate is no longer the same as when he first
		; latched onto the wall, then detach him from the wall. This is
		; probably intended to detach Knuckles from the wall if something
		; physically pushes him away from it.
		move.w	x_pos(a0),d0
		cmp.w	x_pos+2(a0),d0
		bne.w	Knuckles_LetGoOfWall

		; If an object is now carrying Knuckles, then detach him from the
		; wall.
		btst	#Status_OnObj,status(a0)
		bne.w	Knuckles_LetGoOfWall

		move.w	#0,ground_vel(a0)
		move.w	#0,x_vel(a0)
		move.w	#0,y_vel(a0)

		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$D,lrb_solid_bit(a0)
		beq.s	+
		move.l	(Secondary_collision_addr).w,(Collision_addr).w
+
		move.b	lrb_solid_bit(a0),d5

		moveq	#0,d1	; Climbing animation delta: make the animation pause.

		btst	#button_up,(Ctrl_1_logical).w
		beq.w	.notClimbingUp

;.climbingUp:
		tst.b	(Reverse_gravity_flag).w
		bne.w	.climbingUp_ReverseGravity

		; Get Knuckles' distance from the wall in 'd1'.
		move.w	y_pos(a0),d2
		subi.w	#11,d2
		bsr.w	GetDistanceFromWall

		; If the wall is far away from Knuckles, then we must have reached a
		; ledge, so make Knuckles climb up onto it.
		cmpi.w	#4,d1
		bge.w	Knuckles_ClimbUp

		; If Knuckles has encountered a small dip in the wall, then make him
		; stop.
		tst.w	d1
		bne.w	.notMoving

		; Get Knuckles' distance from the ceiling in 'd1'.
		move.b	lrb_solid_bit(a0),d5
		move.w	y_pos(a0),d2
		subq.w	#8,d2
		move.w	x_pos(a0),d3
		bsr.w	CheckCeilingDist_WithRadius

		; Check if Knuckles has room above him.
		tst.w	d1
		bpl.s	.moveUp

		; Knuckles is bumping into the ceiling, so push him out.
		sub.w	d1,y_pos(a0)

		moveq	#1,d1	; Climbing animation delta: make the animation play forwards.
		bra.w	.finishMoving
; ---------------------------------------------------------------------------
; loc_16C4C:
.moveUp:
		subq.w	#1,y_pos(a0)

		moveq	#1,d1	; Climbing animation delta: make the animation play forwards.

		; Don't let Knuckles climb through the level's upper boundary.
		move.w	(Camera_min_Y_pos).w,d0

		; If the level wraps vertically, then don't bother with any of this.
		cmpi.w	#-$100,d0
		beq.w	.finishMoving

		; Check if Knuckles is over the level's top boundary.
		addi.w	#16,d0
		cmp.w	y_pos(a0),d0
		ble.w	.finishMoving

		; Knuckles is climbing over the level's top boundary: push him back
		; down.
		move.w	d0,y_pos(a0)
		bra.w	.finishMoving
; ---------------------------------------------------------------------------
; loc_16C7C:
.climbingDown_ReverseGravity:
		; Knuckles is climbing down.

		; ...I'm not sure what this code is for.
		cmpi.b	#$BD,mapping_frame(a0)
		bne.s	.skip3
		move.b	#$B7,mapping_frame(a0)
		subq.w	#3,y_pos(a0)
		subq.w	#3,x_pos(a0)
		btst	#Status_Facing,status(a0)
		beq.s	.skip3
		addq.w	#3*2,x_pos(a0)

.skip3:
		; Get Knuckles' distance from the wall in 'd1'.
		move.w	y_pos(a0),d2
		subi.w	#11,d2
		bsr.w	GetDistanceFromWall

		; If Knuckles is no longer against the wall (he has climbed off the
		; bottom of it) then make him let go.
		tst.w	d1
		bne.w	Knuckles_LetGoOfWall

		; Get Knuckles' distance from the floor in 'd1'.
		move.b	top_solid_bit(a0),d5
		move.w	y_pos(a0),d2
		subi.w	#9,d2
		move.w	x_pos(a0),d3
		bsr.w	CheckCeilingDist_WithRadius

		; Check if Knuckles has room below him.
		tst.w	d1
		bpl.s	.moveDown_ReverseGravity

		; Knuckles has reached the floor.
		sub.w	d1,y_pos(a0)
		move.b	(Primary_Angle).w,d0
		addi.b	#$40,d0
		neg.b	d0
		subi.b	#$40,d0
		move.b	d0,angle(a0)

		move.w	#0,ground_vel(a0)
		move.w	#0,x_vel(a0)
		move.w	#0,y_vel(a0)

		bsr.w	Knux_TouchFloor

		move.b	#5,anim(a0)

		rts
; ---------------------------------------------------------------------------
; loc_16CFC:
.moveDown_ReverseGravity:
		subq.w	#1,y_pos(a0)

		moveq	#-1,d1	; Climbing animation delta: make the animation play backwards.
		bra.w	.finishMoving
; ---------------------------------------------------------------------------
; loc_16D10:
.notClimbingUp:
		btst	#button_down,(Ctrl_1_logical).w
		beq.w	.finishMoving

;.climbingDown:
		tst.b	(Reverse_gravity_flag).w
		bne.w	.climbingDown_ReverseGravity

		; ...I'm not sure what this code is for.
		cmpi.b	#$BD,mapping_frame(a0)
		bne.s	.skip4
		move.b	#$B7,mapping_frame(a0)
		addq.w	#3,y_pos(a0)
		subq.w	#3,x_pos(a0)
		btst	#Status_Facing,status(a0)
		beq.s	.skip4
		addq.w	#3*2,x_pos(a0)

.skip4:
		; Get Knuckles' distance from the wall in 'd1'.
		move.w	y_pos(a0),d2
		addi.w	#11,d2
		bsr.w	GetDistanceFromWall

		; If Knuckles is no longer against the wall (he has climbed off the
		; bottom of it) then make him let go.
		tst.w	d1
		bne.w	Knuckles_LetGoOfWall

		; Get Knuckles' distance from the floor in 'd1'.
		move.b	top_solid_bit(a0),d5
		move.w	y_pos(a0),d2
		addi.w	#9,d2
		move.w	x_pos(a0),d3
		bsr.w	sub_F828

		; Check if Knuckles has room below him.
		tst.w	d1
		bpl.s	.moveDown
; loc_16D6E:
.reachedFloor:
		; Knuckles has reached the floor.
		add.w	d1,y_pos(a0)
		move.b	(Primary_Angle).w,angle(a0)

		move.w	#0,ground_vel(a0)
		move.w	#0,x_vel(a0)
		move.w	#0,y_vel(a0)

		bsr.w	Knux_TouchFloor

		move.b	#5,anim(a0)

		rts
; ---------------------------------------------------------------------------
; loc_16D96:
.moveDown:
		addq.w	#1,y_pos(a0)

		moveq	#-1,d1	; Climbing animation delta: make the animation play backwards.
		bra.s	.finishMoving
; ---------------------------------------------------------------------------
; loc_16DA8:
.climbingUp_ReverseGravity:
		; Get Knuckles' distance from the wall in 'd1'.
		move.w	y_pos(a0),d2
		addi.w	#11,d2
		bsr.w	GetDistanceFromWall

		; If the wall is far away from Knuckles, then we must have reached a
		; ledge, so make Knuckles climb up onto it.
		cmpi.w	#4,d1
		bge.w	Knuckles_ClimbUp

		; If Knuckles has encountered a small dip in the wall, then make him
		; stop.
		tst.w	d1
		bne.w	.notMoving

		; Get Knuckles' distance from the ceiling in 'd1'.
		move.b	lrb_solid_bit(a0),d5
		move.w	y_pos(a0),d2
		addq.w	#8,d2
		move.w	x_pos(a0),d3
		bsr.w	sub_F828

		; Check if Knuckles has room above him.
		tst.w	d1
		bpl.s	.moveUp_ReverseGravity

		; Knuckles is bumping into the ceiling, so push him out.
		add.w	d1,y_pos(a0)

		moveq	#1,d1	; Climbing animation delta: make the animation play forwards.
		bra.w	.finishMoving
; ---------------------------------------------------------------------------
; loc_16DE2:
.moveUp_ReverseGravity:
		addq.w	#1,y_pos(a0)

		moveq	#1,d1	; Climbing animation delta: make the animation play forwards.

		; Don't let Knuckles climb through the level's upper boundary.

		; If the level wraps vertically, then don't bother with any of this.
		cmpi.w	#-$100,(Camera_min_Y_pos).w
		beq.w	.finishMoving

		; Check if Knuckles is over the level's top boundary.
		move.w	(Camera_max_Y_pos).w,d0
		addi.w	#$D0,d0
		cmp.w	y_pos(a0),d0
		bge.w	.finishMoving

		; Knuckles is climbing over the level's top boundary: push him back
		; down.
		move.w	d0,y_pos(a0)
; loc_16E10:
.finishMoving:
		; This block of code was not here in KiS2.
		; This code detaches Knuckles from the wall if there is
		; ground directly below him. Note that this code specifically
		; does not run if the player is holding up or down: this is
		; because similar code already runs if either of those
		; buttons are being held. Presumably, this check was added so
		; that Knuckles would properly detach from the wall if a
		; rising floor (think Marble Garden Zone Act 2) came up from
		; under him. With that said, KiS2 lacks this logic, and yet
		; Knuckles seems to detach from the wall in Hill Top Zone's
		; rising wall section just fine, so I'm not sure whether this
		; code was ever actually needed in the first place.
		move.b	(Ctrl_1_held_logical).w,d0
		andi.b	#button_up_mask|button_down_mask,d0
		bne.s	.isMovingUpOrDown

		; Get Knuckles' distance from the floor in 'd1'.
		move.b	top_solid_bit(a0),d5
		move.w	y_pos(a0),d2
		addi.w	#9,d2
		move.w	x_pos(a0),d3
		bsr.w	sub_F828

		; Check if Knuckles has room below him.
		tst.w	d1
		bmi.w	.reachedFloor

		; Bug! 'd1' has been overwritten by 'sub_F828', but the code
		; after this needs it for updating Knuckles' animation. This
		; bug is the reason why Knuckles resets to his first climbing
		; frame when the player is not holding up or down.

.isMovingUpOrDown:
		; If Knuckles has not moved, skip this.
		tst.w	d1
		beq.s	.notMoving

		; Only animate every 4 frames.
		subq.b	#1,double_jump_property(a0)
		bpl.s	.notMoving
		move.b	#3,double_jump_property(a0)

		; Add delta to animation frame.
		add.b	mapping_frame(a0),d1

	; Make the animation loop.
		cmpi.b	#$B7,d1
		bhs.s	.noLoop1
		move.b	#$BC,d1

.noLoop1:
		cmpi.b	#$BC,d1
		bls.s	.noLoop2
		move.b	#$B7,d1

.noLoop2:
		; Apply the frame.
		move.b	d1,mapping_frame(a0)
; loc_16E60:
.notMoving:
		move.b	#$20,anim_frame_timer(a0)
		move.b	#0,anim_frame(a0)

		move.w	(Ctrl_1_logical).w,d0
		andi.w	#button_A_mask|button_B_mask|button_C_mask,d0
		beq.s	.hasNotJumped

		; Knuckles has jumped off the wall.
		move.w	#-$380,y_vel(a0)
		move.w	#$400,x_vel(a0)

		bchg	#Status_Facing,status(a0)
		bne.s	.goingRight
		neg.w	x_vel(a0)

.goingRight:
		bset	#Status_InAir,status(a0)
		move.b	#1,jumping(a0)

		move.b	#$E,y_radius(a0)
		move.b	#7,x_radius(a0)

		move.b	#2,anim(a0)
		bset	#Status_Roll,status(a0)
		move.b	#0,double_jump_flag(a0)
; locret_16EB8:
.hasNotJumped:
		rts
; ---------------------------------------------------------------------------
; loc_16EBA:
Knuckles_ClimbUp:
		move.b	#5,double_jump_flag(a0)

		cmpi.b	#$BD,mapping_frame(a0)
		beq.s	+

		move.b	#0,double_jump_property(a0)
		bsr.s	Knuckles_DoLedgeClimbingAnimation
+
		rts
; ---------------------------------------------------------------------------
; loc_16ED2:
Knuckles_LetGoOfWall:
		move.b	#2,double_jump_flag(a0)

		move.w	#$2121,anim(a0)
		move.b	#$CB,mapping_frame(a0)
		move.b	#7,anim_frame_timer(a0)
		move.b	#1,anim_frame(a0)

		move.b	default_y_radius(a0),y_radius(a0)
		move.b	default_x_radius(a0),x_radius(a0)

		rts

; =============== S U B R O U T I N E =======================================

; sub_16EFE:
Knuckles_DoLedgeClimbingAnimation:
		moveq	#0,d0
		move.b	double_jump_property(a0),d0
		lea	Knuckles_ClimbLedge_Frames(pc,d0.w),a1

		move.b	(a1)+,mapping_frame(a0)

		move.b	(a1)+,d0
		ext.w	d0
		btst	#Status_Facing,status(a0)
		beq.s	+
		neg.w	d0
+
		add.w	d0,x_pos(a0)

		move.b	(a1)+,d1
		ext.w	d1
		tst.b	(Reverse_gravity_flag).w
		beq.s	+
		neg.w	d1
+
		add.w	d1,y_pos(a0)

		move.b	(a1)+,anim_frame_timer(a0)

		addq.b	#4,double_jump_property(a0)
		move.b	#0,anim_frame(a0)
		rts
; ---------------------------------------------------------------------------
; Strangely, the last frame uses frame $D2. It will never be seen, however,
; because it is immediately overwritten by Knuckles' waiting animation.

Knuckles_ClimbLedge_Frames:
	; mapping_frame, x_pos, y_pos, anim_frame_timer
	dc.b  $BD,    3,   -3,    6
	dc.b  $BE,    8,  -10,    6
	dc.b  $BF,   -8,  -12,    6
	dc.b  $D2,    8,   -5,    6
Knuckles_ClimbLedge_Frames_End:

; =============== S U B R O U T I N E =======================================

; sub_16F4E:
GetDistanceFromWall:
		move.b	lrb_solid_bit(a0),d5
		btst	#Status_Facing,status(a0)
		bne.s	.facingLeft

;.facingRight:
		move.w	x_pos(a0),d3
		bra.w	loc_FAA4
; ---------------------------------------------------------------------------
; loc_16F62:
.facingLeft:
		move.w	x_pos(a0),d3
		subq.w	#1,d3
		bra.w	loc_FDC8
; ---------------------------------------------------------------------------

Knuckles_Climb_Ledge:
		tst.b	anim_frame_timer(a0)
		bne.s	locret_16FA6

		bsr.w	Knuckles_DoLedgeClimbingAnimation

		; Have we reached the end of the ledge-climbing animation?
		cmpi.b	#Knuckles_ClimbLedge_Frames_End-Knuckles_ClimbLedge_Frames,double_jump_property(a0)
		bne.s	locret_16FA6

		; Yes.
		move.w	#0,ground_vel(a0)
		move.w	#0,x_vel(a0)
		move.w	#0,y_vel(a0)

		btst	#Status_Facing,status(a0)
		beq.s	+
		subq.w	#1,x_pos(a0)
+
		bsr.w	Knux_TouchFloor
		move.b	#5,anim(a0)

locret_16FA6:
		rts

; =============== S U B R O U T I N E =======================================

Knuckles_Set_Gliding_Animation:
		move.b	#$20,anim_frame_timer(a0)
		move.b	#0,anim_frame(a0)
		move.w	#$2020,anim(a0)
		bclr	#Status_Push,status(a0)
		bclr	#Status_Facing,status(a0)

		; Update Knuckles' frame, depending on where he's facing.
		moveq	#0,d0
		move.b	double_jump_property(a0),d0
		addi.b	#$10,d0
		lsr.w	#5,d0
		move.b	RawAni_Knuckles_GlideTurn(pc,d0.w),d1
		move.b	d1,mapping_frame(a0)
		cmpi.b	#$C4,d1
		bne.s	+
		bset	#Status_Facing,status(a0)
		move.b	#$C0,mapping_frame(a0)
+
		rts
; ---------------------------------------------------------------------------

RawAni_Knuckles_GlideTurn:
		dc.b $C0
		dc.b $C1
		dc.b $C2
		dc.b $C3
		dc.b $C4
		dc.b $C3
		dc.b $C2
		dc.b $C1

; =============== S U B R O U T I N E =======================================

Knuckles_Move_Glide:
		cmpi.b	#1,double_jump_flag(a0)
		bne.w	.doNotKillspeed

		move.w	ground_vel(a0),d0
		cmpi.w	#$400,d0
		bhs.s	.mediumSpeed

;.lowSpeed:
		; Increase Knuckles' speed.
		addq.w	#8,d0
		bra.s	.applySpeed
; ---------------------------------------------------------------------------
; loc_1700E:
.mediumSpeed:
		; If Knuckles is at his speed limit, then don't increase his speed.
		cmpi.w	#$1800,d0
		bhs.s	.applySpeed

		; If Knuckles is turning, then don't increase his speed either.
		move.b	double_jump_property(a0),d1
		andi.b	#$7F,d1
		bne.s	.applySpeed

		; Increase Knuckles' speed.
		addq.w	#4,d0

; loc_17028:
.applySpeed:
		move.w	d0,ground_vel(a0)

		move.b	double_jump_property(a0),d0
		btst	#button_left,(Ctrl_1_logical).w
		beq.s	.notHoldingLeft

;.holdingLeft:
		; Playing is holding left.
		cmpi.b	#$80,d0
		beq.s	.notHoldingLeft
		tst.b	d0
		bpl.s	.doNotNegate1
		neg.b	d0

.doNotNegate1:
		addq.b	#2,d0
		bra.s	.setNewTurningValue
; ---------------------------------------------------------------------------
; loc_17048:
.notHoldingLeft:
		btst	#button_right,(Ctrl_1_logical).w
		beq.s	.notHoldingRight

;.holdingRight:
		; Playing is holding right.
		tst.b	d0
		beq.s	.notHoldingRight
		bmi.s	.doNotNegate2
		neg.b	d0

.doNotNegate2:
		addq.b	#2,d0
		bra.s	.setNewTurningValue
; ---------------------------------------------------------------------------
; loc_1705C:
.notHoldingRight:
		move.b	d0,d1
		andi.b	#$7F,d1
		beq.s	.setNewTurningValue
		addq.b	#2,d0
; loc_17066:
.setNewTurningValue:
		move.b	d0,double_jump_property(a0)

		move.b	double_jump_property(a0),d0
		jsr	(GetSineCosine).w
		muls.w	ground_vel(a0),d1
		asr.l	#8,d1
		move.w	d1,x_vel(a0)

		; Is Knuckles is falling at a high speed, then create a parachute
		; effect, where gliding makes Knuckles fall slower.
		cmpi.w	#$80,y_vel(a0)
		blt.s	.fallingSlow
		subi.w	#$20,y_vel(a0)
		bra.s	.fallingFast
; ---------------------------------------------------------------------------
; loc_1708E:
.fallingSlow:
		; Apply gravity.
		addi.w	#$20,y_vel(a0)
; loc_17094:
.fallingFast:
		; If Knuckles is above the level's top boundary, then kill his
		; horizontal speed.
		move.w	(Camera_min_Y_pos).w,d0
		cmpi.w	#-$100,d0
		beq.w	.doNotKillspeed

		addi.w	#$10,d0
		cmp.w	y_pos(a0),d0
		ble.w	.doNotKillspeed

		asr.w	x_vel(a0)
		asr.w	ground_vel(a0)
; loc_170B4:
.doNotKillspeed:
		cmpi.w	#$60,(a5)
		beq.s	.doNotModifyBias
		bhs.s	.goUp
		addq.w	#2*2,(a5)

.goUp:
		subq.w	#2,(a5)
; locret_170C0:
.doNotModifyBias:
		rts
; ---------------------------------------------------------------------------

Knux_Spin_Path:
		tst.b	$3D(a0)
		bne.s	loc_170CC
		bsr.w	Knux_Jump

loc_170CC:
		bsr.w	Player_RollRepel
		bsr.w	Knux_RollSpeed
		bsr.w	Player_LevelBound
		jsr	(MoveSprite2_TestGravity).w
		bsr.w	Call_Player_AnglePos
		bra.w	Player_SlopeRepel
; ---------------------------------------------------------------------------

Knux_Spin_Freespace:
		bsr.w	Knux_JumpHeight
		bsr.w	Knux_ChgJumpDir
		bsr.w	Player_LevelBound
		jsr	(MoveSprite_TestGravity).w
		btst	#6,$2A(a0)
		beq.s	loc_17138
		subi.w	#$28,$1A(a0)

loc_17138:
		bsr.w	Player_JumpAngle
		bra.w	Player_DoLevelCollision

; =============== S U B R O U T I N E =======================================

Knux_InputAcceleration_Path:
		move.w	(a4),d6
		move.w	2(a4),d5
		move.w	4(a4),d4
		tst.b	$2B(a0)
		bmi.w	loc_17364
		tst.w	$32(a0)
		bne.w	loc_1731C
		btst	#2,(Ctrl_1_logical).w
		beq.s	loc_17168
		bsr.w	sub_17428

loc_17168:
		btst	#3,(Ctrl_1_logical).w
		beq.s	loc_17174
		bsr.w	sub_174B4

loc_17174:
		move.b	$26(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.w	loc_1731C
		tst.w	$1C(a0)
		bne.w	loc_1731C
		bclr	#5,$2A(a0)
		move.b	#5,anim(a0)
		btst	#3,$2A(a0)
		beq.w	loc_1722C
		movea.w	$42(a0),a1
		tst.b	$2A(a1)
		bmi.w	loc_172A8
		moveq	#0,d1
		move.b	7(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#2,d2
		add.w	$10(a0),d1
		sub.w	$10(a1),d1
		cmpi.w	#2,d1
		blt.s	loc_171FE
		cmp.w	d2,d1
		bge.s	loc_171D0
		bra.w	loc_172A8
; ---------------------------------------------------------------------------

loc_171D0:
		btst	#0,$2A(a0)
		bne.s	loc_171E2
		move.b	#6,anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_171E2:
		bclr	#0,$2A(a0)
		move.b	#0,$24(a0)
		move.b	#4,$23(a0)
		move.w	#$606,anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_171FE:
		btst	#0,$2A(a0)
		beq.s	loc_17210
		move.b	#6,anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_17210:
		bset	#0,$2A(a0)
		move.b	#0,$24(a0)
		move.b	#4,$23(a0)
		move.w	#$606,anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_1722C:
		move.w	$10(a0),d3
		bsr.w	ChooseChkFloorEdge
		cmpi.w	#$C,d1
		blt.w	loc_172A8
		cmpi.b	#3,$3A(a0)
		bne.s	loc_17272
		btst	#0,$2A(a0)
		bne.s	loc_17256
		move.b	#6,anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_17256:
		bclr	#0,$2A(a0)
		move.b	#0,$24(a0)
		move.b	#4,$23(a0)
		move.w	#$606,anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_17272:
		cmpi.b	#3,$3B(a0)
		bne.s	loc_172A8
		btst	#0,$2A(a0)
		beq.s	loc_1728C
		move.b	#6,anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_1728C:
		bset	#0,$2A(a0)
		move.b	#0,$24(a0)
		move.b	#4,$23(a0)
		move.w	#$606,anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_172A8:
		btst	#1,(Ctrl_1_logical).w
		beq.s	loc_172E2
		move.b	#8,anim(a0)
		addq.b	#1,$39(a0)
		cmpi.b	#$78,$39(a0)
		blo.s	loc_17322
		move.b	#$78,$39(a0)
		tst.b	(Reverse_gravity_flag).w
		bne.s	loc_172D8
		cmpi.w	#8,(a5)
		beq.s	loc_1732E
		subq.w	#2,(a5)
		bra.s	loc_1732E
; ---------------------------------------------------------------------------

loc_172D8:
		cmpi.w	#$D8,(a5)
		beq.s	loc_1732E
		addq.w	#2,(a5)
		bra.s	loc_1732E
; ---------------------------------------------------------------------------

loc_172E2:
		btst	#0,(Ctrl_1_logical).w
		beq.s	loc_1731C
		move.b	#7,anim(a0)
		addq.b	#1,$39(a0)
		cmpi.b	#$78,$39(a0)
		blo.s	loc_17322
		move.b	#$78,$39(a0)
		tst.b	(Reverse_gravity_flag).w
		bne.s	loc_17312
		cmpi.w	#$C8,(a5)
		beq.s	loc_1732E
		addq.w	#2,(a5)
		bra.s	loc_1732E
; ---------------------------------------------------------------------------

loc_17312:
		cmpi.w	#$18,(a5)
		beq.s	loc_1732E
		subq.w	#2,(a5)
		bra.s	loc_1732E
; ---------------------------------------------------------------------------

loc_1731C:
		move.b	#0,$39(a0)

loc_17322:
		cmpi.w	#$60,(a5)
		beq.s	loc_1732E
		bcc.s	loc_1732C
		addq.w	#4,(a5)

loc_1732C:
		subq.w	#2,(a5)

loc_1732E:
		move.b	(Ctrl_1_logical).w,d0
		andi.b	#$C,d0
		bne.s	loc_17364
		move.w	$1C(a0),d0
		beq.s	loc_17364
		bmi.s	loc_17358
		sub.w	d5,d0
		bcc.s	loc_17352
		move.w	#0,d0

loc_17352:
		move.w	d0,$1C(a0)
		bra.s	loc_17364
; ---------------------------------------------------------------------------

loc_17358:
		add.w	d5,d0
		bcc.s	loc_17360
		move.w	#0,d0

loc_17360:
		move.w	d0,$1C(a0)

loc_17364:
		move.b	$26(a0),d0
		jsr	(GetSineCosine).w
		muls.w	$1C(a0),d1
		asr.l	#8,d1
		move.w	d1,$18(a0)
		muls.w	$1C(a0),d0
		asr.l	#8,d0
		move.w	d0,$1A(a0)

loc_17382:
		btst	#6,$2E(a0)
		bne.w	locret_17426
		move.b	$26(a0),d0
		andi.b	#$3F,d0
		beq.s	loc_173A2
		move.b	$26(a0),d0
		addi.b	#$40,d0
		bmi.w	locret_17426

loc_173A2:
		move.b	#$40,d1
		tst.w	$1C(a0)
		beq.s	locret_17426
		bmi.s	loc_173B0
		neg.w	d1

loc_173B0:
		move.b	$26(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	sub_F61C
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_17426
		asl.w	#8,d1
		cmpi.b	#8,(Current_zone).w
		bne.s	loc_173D2
		tst.b	d0
		bpl.s	loc_173D2
		subq.b	#1,d0

loc_173D2:
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_17422
		cmpi.b	#$40,d0
		beq.s	loc_17408
		cmpi.b	#$80,d0
		beq.s	loc_17402
		add.w	d1,$18(a0)
		move.w	#0,$1C(a0)
		btst	#0,$2A(a0)
		bne.s	locret_17400
		bset	#5,$2A(a0)

locret_17400:
		rts
; ---------------------------------------------------------------------------

loc_17402:
		sub.w	d1,$1A(a0)
		rts
; ---------------------------------------------------------------------------

loc_17408:
		sub.w	d1,$18(a0)
		move.w	#0,$1C(a0)
		btst	#0,$2A(a0)
		beq.s	locret_17400
		bset	#5,$2A(a0)
		rts
; ---------------------------------------------------------------------------

loc_17422:
		add.w	d1,$1A(a0)

locret_17426:
		rts

; =============== S U B R O U T I N E =======================================

sub_17428:
		move.w	$1C(a0),d0
		beq.s	loc_17430
		bpl.s	loc_17462

loc_17430:
		bset	#0,$2A(a0)
		bne.s	loc_17444
		bclr	#5,$2A(a0)
		move.b	#1,$21(a0)

loc_17444:
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_17456
		add.w	d5,d0
		cmp.w	d1,d0
		ble.s	loc_17456
		move.w	d1,d0

loc_17456:
		move.w	d0,$1C(a0)
		move.b	#0,anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_17462:
		sub.w	d4,d0
		bcc.s	loc_1746A
		move.w	#-$80,d0

loc_1746A:
		move.w	d0,$1C(a0)
		move.b	$26(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_174B2
		cmpi.w	#$400,d0
		blt.s	locret_174B2
		tst.b	$2D(a0)
		bmi.s	locret_174B2
		sfx	sfx_Skid
		move.b	#$D,anim(a0)
		bclr	#0,$2A(a0)
		cmpi.b	#$C,$2C(a0)
		blo.s	locret_174B2
		move.b	#6,5(a6)
		move.b	#$15,$22(a6)

locret_174B2:
		rts

; =============== S U B R O U T I N E =======================================

sub_174B4:
		move.w	$1C(a0),d0
		bmi.s	loc_174E8
		bclr	#0,$2A(a0)
		beq.s	loc_174CE
		bclr	#5,$2A(a0)
		move.b	#1,$21(a0)

loc_174CE:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_174DC
		sub.w	d5,d0
		cmp.w	d6,d0
		bge.s	loc_174DC
		move.w	d6,d0

loc_174DC:
		move.w	d0,$1C(a0)
		move.b	#0,anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_174E8:
		add.w	d4,d0
		bcc.s	loc_174F0
		move.w	#$80,d0

loc_174F0:
		move.w	d0,$1C(a0)
		move.b	$26(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_17538
		cmpi.w	#$FC00,d0
		bgt.s	locret_17538
		tst.b	$2D(a0)
		bmi.s	locret_17538
		sfx	sfx_Skid
		move.b	#$D,anim(a0)
		bset	#0,$2A(a0)
		cmpi.b	#$C,$2C(a0)
		blo.s	locret_17538
		move.b	#6,5(a6)
		move.b	#$15,$22(a6)

locret_17538:
		rts

; =============== S U B R O U T I N E =======================================

Knux_RollSpeed:
		move.w	(a4),d6
		asl.w	#1,d6
		move.w	2(a4),d5
		asr.w	#1,d5
		move.w	#$20,d4
		tst.b	$3D(a0)
		bmi.w	loc_175F8
		tst.b	$2B(a0)
		bmi.w	loc_175F8
		tst.w	$32(a0)
		bne.s	loc_17580
		btst	#2,(Ctrl_1_logical).w
		beq.s	loc_17574
		bsr.w	sub_1763A

loc_17574:
		btst	#3,(Ctrl_1_logical).w
		beq.s	loc_17580
		bsr.w	sub_1765E

loc_17580:
		move.w	$1C(a0),d0
		beq.s	loc_175A2
		bmi.s	loc_17596
		sub.w	d5,d0
		bcc.s	loc_17590
		move.w	#0,d0

loc_17590:
		move.w	d0,$1C(a0)
		bra.s	loc_175A2
; ---------------------------------------------------------------------------

loc_17596:
		add.w	d5,d0
		bcc.s	loc_1759E
		move.w	#0,d0

loc_1759E:
		move.w	d0,$1C(a0)

loc_175A2:
		move.w	$1C(a0),d0
		bpl.s	loc_175AA
		neg.w	d0

loc_175AA:
		cmpi.w	#$80,d0
		bhs.s	loc_175F8
		tst.b	$3D(a0)
		bne.s	loc_175E6
		bclr	#2,$2A(a0)
		move.b	$1E(a0),d0
		move.b	$44(a0),$1E(a0)
		move.b	$45(a0),$1F(a0)
		move.b	#5,anim(a0)
		sub.b	$44(a0),d0
		ext.w	d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_175E0
		neg.w	d0

loc_175E0:
		add.w	d0,$14(a0)
		bra.s	loc_175F8
; ---------------------------------------------------------------------------

loc_175E6:
		move.w	#$400,$1C(a0)
		btst	#0,$2A(a0)
		beq.s	loc_175F8
		neg.w	$1C(a0)

loc_175F8:
		cmpi.w	#$60,(a5)
		beq.s	loc_17604
		bcc.s	loc_17602
		addq.w	#4,(a5)

loc_17602:
		subq.w	#2,(a5)

loc_17604:
		move.b	$26(a0),d0
		jsr	(GetSineCosine).w
		muls.w	$1C(a0),d0
		asr.l	#8,d0
		move.w	d0,$1A(a0)
		muls.w	$1C(a0),d1
		asr.l	#8,d1
		cmpi.w	#$1000,d1
		ble.s	loc_17628
		move.w	#$1000,d1

loc_17628:
		cmpi.w	#-$1000,d1
		bge.s	loc_17632
		move.w	#-$1000,d1

loc_17632:
		move.w	d1,$18(a0)
		bra.w	loc_17382

; =============== S U B R O U T I N E =======================================

sub_1763A:
		move.w	$1C(a0),d0
		beq.s	loc_17642
		bpl.s	loc_17650

loc_17642:
		bset	#0,$2A(a0)
		move.b	#2,anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_17650:
		sub.w	d4,d0
		bcc.s	loc_17658
		move.w	#-$80,d0

loc_17658:
		move.w	d0,$1C(a0)
		rts

; =============== S U B R O U T I N E =======================================

sub_1765E:
		move.w	$1C(a0),d0
		bmi.s	loc_17672
		bclr	#0,$2A(a0)
		move.b	#2,anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_17672:
		add.w	d4,d0
		bcc.s	loc_1767A
		move.w	#$80,d0

loc_1767A:
		move.w	d0,$1C(a0)
		rts

; =============== S U B R O U T I N E =======================================

; sub_17680:
Knux_ChgJumpDir:
		move.w	(a4),d6
		move.w	2(a4),d5
		asl.w	#1,d5
		btst	#4,$2A(a0)
		bne.s	loc_176D4
		move.w	$18(a0),d0
		btst	#2,(Ctrl_1_logical).w
		beq.s	loc_176B4
		bset	#0,$2A(a0)
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_176B4
		add.w	d5,d0
		cmp.w	d1,d0
		ble.s	loc_176B4
		move.w	d1,d0

loc_176B4:
		btst	#3,(Ctrl_1_logical).w
		beq.s	loc_176D0
		bclr	#0,$2A(a0)
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_176D0
		sub.w	d5,d0
		cmp.w	d6,d0
		bge.s	loc_176D0
		move.w	d6,d0

loc_176D0:
		move.w	d0,$18(a0)

loc_176D4:
		cmpi.w	#$60,(a5)
		beq.s	loc_176E0
		bcc.s	loc_176DE
		addq.w	#4,(a5)

loc_176DE:
		subq.w	#2,(a5)

loc_176E0:
		cmpi.w	#-$400,$1A(a0)
		blo.s	locret_1770E
		move.w	$18(a0),d0
		move.w	d0,d1
		asr.w	#5,d1
		beq.s	locret_1770E
		bmi.s	loc_17702
		sub.w	d1,d0
		bcc.s	loc_176FC
		move.w	#0,d0

loc_176FC:
		move.w	d0,$18(a0)
		rts
; ---------------------------------------------------------------------------

loc_17702:
		sub.w	d1,d0
		bcs.s	loc_1770A
		move.w	#0,d0

loc_1770A:
		move.w	d0,$18(a0)

locret_1770E:
		rts

; =============== S U B R O U T I N E =======================================

Knux_Jump:
		move.b	(Ctrl_1_pressed_logical).w,d0
		andi.b	#$70,d0
		beq.w	locret_177E0
		moveq	#0,d0
		move.b	$26(a0),d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17732
		addi.b	#$40,d0
		neg.b	d0
		subi.b	#$40,d0

loc_17732:
		addi.b	#-$80,d0
		movem.l	a4-a6,-(sp)
		jsr	(CalcRoomOverHead).l
		movem.l	(sp)+,a4-a6
		cmpi.w	#6,d1
		blt.w	locret_177E0
		move.w	#$600,d2
		btst	#6,$2A(a0)
		beq.s	loc_1775C
		move.w	#$300,d2

loc_1775C:
		moveq	#0,d0
		move.b	$26(a0),d0
		subi.b	#$40,d0
		jsr	(GetSineCosine).w
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,$18(a0)
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,$1A(a0)
		bset	#1,$2A(a0)
		bclr	#5,$2A(a0)
		addq.l	#4,sp
		move.b	#1,$40(a0)
		clr.b	$3C(a0)
		sfx	sfx_Jump
		move.b	$44(a0),$1E(a0)
		move.b	$45(a0),$1F(a0)
		btst	#2,$2A(a0)
		bne.s	loc_177E2
		move.b	#$E,$1E(a0)
		move.b	#7,$1F(a0)
		move.b	#2,anim(a0)
		bset	#2,$2A(a0)
		move.b	$1E(a0),d0
		sub.b	$44(a0),d0
		ext.w	d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_177DC
		neg.w	d0

loc_177DC:
		sub.w	d0,$14(a0)

locret_177E0:
		rts
; ---------------------------------------------------------------------------

loc_177E2:
		bset	#4,$2A(a0)
		rts

; =============== S U B R O U T I N E =======================================

Knux_JumpHeight:
		tst.b	$40(a0)
		beq.s	loc_17818
		move.w	#-$400,d1
		btst	#6,$2A(a0)
		beq.s	loc_17800
		move.w	#-$200,d1

loc_17800:
		cmp.w	$1A(a0),d1
		ble.w	Knux_Test_For_Glide
		move.b	(Ctrl_1_logical).w,d0
		andi.b	#$70,d0
		bne.s	locret_17816
		move.w	d1,$1A(a0)

locret_17816:
		rts
; ---------------------------------------------------------------------------

loc_17818:
		tst.b	$3D(a0)
		bne.s	locret_1782C
		cmpi.w	#-$FC0,$1A(a0)
		bge.s	locret_1782C
		move.w	#-$FC0,$1A(a0)

locret_1782C:
		rts
; ---------------------------------------------------------------------------

Knux_Test_For_Glide:
		tst.b	double_jump_flag(a0)
		bne.w	locret_178CC
		move.b	(Ctrl_1_pressed_logical).w,d0
		andi.b	#$70,d0
		beq.w	locret_178CC

		bclr	#2,$2A(a0)
		move.b	#$A,$1E(a0)
		move.b	#$A,$1F(a0)
		bclr	#4,$2A(a0)
		move.b	#1,double_jump_flag(a0)
		addi.w	#$200,$1A(a0)
		bpl.s	loc_17898
		move.w	#0,$1A(a0)

loc_17898:
		moveq	#0,d1
		move.w	#$400,d0
		move.w	d0,$1C(a0)
		btst	#0,$2A(a0)
		beq.s	loc_178AE
		neg.w	d0
		moveq	#-$80,d1

loc_178AE:
		move.w	d0,$18(a0)
		move.b	d1,$25(a0)
		move.w	#0,$26(a0)
		move.b	#0,(Gliding_collision_flags).w
		bset	#Status_InAir,(Gliding_collision_flags).w
		bsr.w	Knuckles_Set_Gliding_Animation

locret_178CC:
		rts

; =============== S U B R O U T I N E =======================================

Knux_DoLevelCollision_CheckRet:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,$46(a0)
		beq.s	loc_17952
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

loc_17952:
		move.b	$47(a0),d5
		move.w	$18(a0),d1
		move.w	$1A(a0),d2
		jsr	(GetArcTan).w
		subi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	loc_179DA
		cmpi.b	#$80,d0
		beq.w	loc_17A62
		cmpi.b	#$C0,d0
		beq.w	loc_17AB0
		bsr.w	CheckLeftWallDist
		tst.w	d1
		bpl.s	loc_1799C
		sub.w	d1,$10(a0)
		move.w	#0,$18(a0)
		bset	#Status_Push,(Gliding_collision_flags).w

loc_1799C:
		bsr.w	CheckRightWallDist
		tst.w	d1
		bpl.s	loc_179B4
		add.w	d1,$10(a0)
		move.w	#0,$18(a0)
		bset	#Status_Push,(Gliding_collision_flags).w

loc_179B4:
		bsr.w	sub_11FD6
		tst.w	d1
		bpl.s	locret_179D8
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_179C4
		neg.w	d1

loc_179C4:
		add.w	d1,$14(a0)
		move.b	d3,$26(a0)
		move.w	#0,$1A(a0)
		bclr	#Status_InAir,(Gliding_collision_flags).w

locret_179D8:
		rts
; ---------------------------------------------------------------------------

loc_179DA:
		bsr.w	CheckLeftWallDist
		tst.w	d1
		bpl.s	loc_179F2
		sub.w	d1,$10(a0)
		move.w	#0,$18(a0)
		bset	#Status_Push,(Gliding_collision_flags).w

loc_179F2:
		bsr.w	sub_11FEE
		tst.w	d1
		bpl.s	loc_17A36
		neg.w	d1
		cmpi.w	#$14,d1
		bhs.s	loc_17A1C
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17A0A
		neg.w	d1

loc_17A0A:
		add.w	d1,$14(a0)
		tst.w	$1A(a0)
		bpl.s	locret_17A1A
		move.w	#0,$1A(a0)

locret_17A1A:
		rts
; ---------------------------------------------------------------------------

loc_17A1C:
		bsr.w	CheckRightWallDist
		tst.w	d1
		bpl.s	locret_17A34
		add.w	d1,$10(a0)
		move.w	#0,$18(a0)
		bset	#Status_Push,(Gliding_collision_flags).w

locret_17A34:
		rts
; ---------------------------------------------------------------------------

loc_17A36:
		tst.w	$1A(a0)
		bmi.s	locret_17A60
		bsr.w	sub_11FD6
		tst.w	d1
		bpl.s	locret_17A60
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17A4C
		neg.w	d1

loc_17A4C:
		add.w	d1,$14(a0)
		move.b	d3,$26(a0)
		move.w	#0,$1A(a0)
		bclr	#Status_InAir,(Gliding_collision_flags).w

locret_17A60:
		rts
; ---------------------------------------------------------------------------

loc_17A62:
		bsr.w	CheckLeftWallDist
		tst.w	d1
		bpl.s	loc_17A7A
		sub.w	d1,$10(a0)
		move.w	#0,$18(a0)
		bset	#Status_Push,(Gliding_collision_flags).w

loc_17A7A:
		jsr	(CheckRightWallDist).l
		tst.w	d1
		bpl.s	loc_17A94
		add.w	d1,$10(a0)
		move.w	#0,$18(a0)
		bset	#Status_Push,(Gliding_collision_flags).w

loc_17A94:
		bsr.w	sub_11FEE
		tst.w	d1
		bpl.s	locret_17AAE
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17AA4
		neg.w	d1

loc_17AA4:
		sub.w	d1,$14(a0)
		move.w	#0,$1A(a0)

locret_17AAE:
		rts
; ---------------------------------------------------------------------------

loc_17AB0:
		jsr	(CheckRightWallDist).l
		tst.w	d1
		bpl.s	loc_17ACA
		add.w	d1,$10(a0)
		move.w	#0,$18(a0)
		bset	#Status_Push,(Gliding_collision_flags).w

loc_17ACA:
		bsr.w	sub_11FEE
		tst.w	d1
		bpl.s	loc_17AEC
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17ADA
		neg.w	d1

loc_17ADA:
		sub.w	d1,$14(a0)
		tst.w	$1A(a0)
		bpl.s	locret_17AEA
		move.w	#0,$1A(a0)

locret_17AEA:
		rts
; ---------------------------------------------------------------------------

loc_17AEC:
		tst.w	$1A(a0)
		bmi.s	locret_17B16
		bsr.w	sub_11FD6
		tst.w	d1
		bpl.s	locret_17B16
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17B02
		neg.w	d1

loc_17B02:
		add.w	d1,$14(a0)
		move.b	d3,$26(a0)
		move.w	#0,$1A(a0)
		bclr	#Status_InAir,(Gliding_collision_flags).w

locret_17B16:
		rts

; =============== S U B R O U T I N E =======================================

Knux_TouchFloor:
		move.b	$1E(a0),d0
		move.b	$44(a0),$1E(a0)
		move.b	$45(a0),$1F(a0)
		btst	#2,$2A(a0)
		beq.s	loc_17B6A
		bclr	#2,$2A(a0)
		move.b	#0,anim(a0)
		sub.b	$44(a0),d0
		ext.w	d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17B56
		neg.w	d0

loc_17B56:
		move.w	d0,-(sp)
		move.b	$26(a0),d0
		addi.b	#$40,d0
		bpl.s	loc_17B64
		neg.w	(sp)

loc_17B64:
		move.w	(sp)+,d0
		add.w	d0,$14(a0)

loc_17B6A:
		bclr	#1,$2A(a0)
		bclr	#5,$2A(a0)
		bclr	#4,$2A(a0)
		move.b	#0,$40(a0)
		move.w	#0,(Chain_bonus_counter).w
		move.b	#0,$27(a0)
		move.b	#0,$2D(a0)
		move.b	#0,$30(a0)
		move.b	#0,$39(a0)
		move.b	#0,double_jump_flag(a0)
		cmpi.b	#$20,anim(a0)
		blo.s	locret_17BB4
		move.b	#0,anim(a0)

locret_17BB4:
		rts
; ---------------------------------------------------------------------------

loc_17BB6:
		tst.b	(Debug_mode_flag).w
		beq.s	loc_17BD0
		btst	#4,(Ctrl_1_pressed).w
		beq.s	loc_17BD0
		move.w	#1,(Debug_placement_mode).w
		clr.b	(Ctrl_1_locked).w
		rts
; ---------------------------------------------------------------------------

loc_17BD0:
		jsr	(MoveSprite2_TestGravity).w
		addi.w	#$30,$1A(a0)
		btst	#6,$2A(a0)
		beq.s	loc_17BEA
		subi.w	#$20,$1A(a0)

loc_17BEA:
		cmpi.w	#-$100,(Camera_min_Y_pos).w
		bne.s	loc_17BFA
		move.w	(Screen_Y_wrap_value).w,d0
		and.w	d0,$14(a0)

loc_17BFA:
		bsr.w	sub_17C10
		bsr.w	Player_LevelBound
		bsr.w	Sonic_RecordPos
		bsr.w	sub_17D1E
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

sub_17C10:
		tst.b	(Disable_death_plane).w
		bne.s	loc_17C3C
		tst.b	(Reverse_gravity_flag).w
		bne.s	loc_17C2E
		move.w	(Camera_max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	$14(a0),d0
		blt.w	loc_17C82
		bra.s	loc_17C3C
; ---------------------------------------------------------------------------

loc_17C2E:
		move.w	(Camera_min_Y_pos).w,d0
		cmp.w	$14(a0),d0
		blt.s	loc_17C3C
		bra.w	loc_17C82
; ---------------------------------------------------------------------------

loc_17C3C:
		movem.l	a4-a6,-(sp)
		bsr.w	Player_DoLevelCollision
		movem.l	(sp)+,a4-a6
		btst	#1,$2A(a0)
		bne.s	locret_17C80
		moveq	#0,d0
		move.w	d0,$1A(a0)
		move.w	d0,$18(a0)
		move.w	d0,$1C(a0)
		move.b	d0,$2E(a0)
		move.b	#0,anim(a0)
		move.w	#$100,8(a0)
		move.b	#2,5(a0)
		move.b	#$78,$34(a0)
		move.b	#0,$3D(a0)

locret_17C80:
		rts
; ---------------------------------------------------------------------------

loc_17C82:
		jmp	(Kill_Character).l
; ---------------------------------------------------------------------------

loc_17C88:
		tst.b	(Debug_mode_flag).w
		beq.s	loc_17CA2
		btst	#4,(Ctrl_1_pressed).w
		beq.s	loc_17CA2
		move.w	#1,(Debug_placement_mode).w
		clr.b	(Ctrl_1_locked).w
		rts
; ---------------------------------------------------------------------------

loc_17CA2:
		bsr.w	sub_123C2
		jsr	(MoveSprite_TestGravity).w
		bsr.w	Sonic_RecordPos
		bsr.w	sub_17D1E
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_17CBA:
		tst.w	$3E(a0)
		beq.s	locret_17CCC
		subq.w	#1,$3E(a0)
		bne.s	locret_17CCC
		st	(Restart_level_flag).w

locret_17CCC:
		rts
; ---------------------------------------------------------------------------

loc_17CCE:
		tst.w	(Camera_RAM).w
		bne.s	loc_17CE0
		tst.w	(V_scroll_amount).w
		bne.s	loc_17CE0
		move.b	#2,5(a0)

loc_17CE0:
		bsr.w	sub_17D1E
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_17CEA:
		tst.b	(Debug_mode_flag).w
		beq.s	loc_17D04
		btst	#4,(Ctrl_1_pressed).w
		beq.s	loc_17D04
		move.w	#1,(Debug_placement_mode).w
		clr.b	(Ctrl_1_locked).w
		rts
; ---------------------------------------------------------------------------

loc_17D04:
		jsr	(MoveSprite2_TestGravity).w
		addi.w	#$10,$1A(a0)
		bsr.w	Sonic_RecordPos
		bsr.w	sub_17D1E
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

sub_17D1E:
		bsr.s	Animate_Knuckles
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17D2C
		eori.b	#2,4(a0)

loc_17D2C:
		bra.w	Knuckles_Load_PLC

; =============== S U B R O U T I N E =======================================

Animate_Knuckles:
		lea	(AniKnuckles).l,a1
		moveq	#0,d0
		move.b	anim(a0),d0
		cmp.b	$21(a0),d0
		beq.s	loc_17D58
		move.b	d0,$21(a0)
		move.b	#0,$23(a0)
		move.b	#0,$24(a0)
		bclr	#5,$2A(a0)

loc_17D58:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1
		move.b	(a1),d0
		bmi.s	loc_17DC8
		move.b	$2A(a0),d1
		andi.b	#1,d1
		andi.b	#-4,4(a0)
		or.b	d1,4(a0)
		subq.b	#1,$24(a0)
		bpl.s	locret_17D96
		move.b	d0,$24(a0)

loc_17D7E:
		moveq	#0,d1
		move.b	$23(a0),d1
		move.b	1(a1,d1.w),d0
		cmpi.b	#-4,d0
		bhs.s	loc_17D98

loc_17D8E:
		move.b	d0,$22(a0)
		addq.b	#1,$23(a0)

locret_17D96:
		rts
; ---------------------------------------------------------------------------

loc_17D98:
		addq.b	#1,d0
		bne.s	loc_17DA8
		move.b	#0,$23(a0)
		move.b	1(a1),d0
		bra.s	loc_17D8E
; ---------------------------------------------------------------------------

loc_17DA8:
		addq.b	#1,d0
		bne.s	loc_17DBC
		move.b	2(a1,d1.w),d0
		sub.b	d0,$23(a0)
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0
		bra.s	loc_17D8E
; ---------------------------------------------------------------------------

loc_17DBC:
		addq.b	#1,d0
		bne.s	locret_17DC6
		move.b	2(a1,d1.w),anim(a0)

locret_17DC6:
		rts
; ---------------------------------------------------------------------------

loc_17DC8:
		addq.b	#1,d0
		bne.w	loc_17E84
		moveq	#0,d0
		tst.b	$2D(a0)
		bmi.w	loc_127C0
		move.b	$27(a0),d0
		bne.w	loc_127C0
		moveq	#0,d1
		move.b	$26(a0),d0
		bmi.s	loc_17DEC
		beq.s	loc_17DEC
		subq.b	#1,d0

loc_17DEC:
		move.b	$2A(a0),d2
		andi.b	#1,d2
		bne.s	loc_17DF8
		not.b	d0

loc_17DF8:
		addi.b	#$10,d0
		bpl.s	loc_17E00
		moveq	#3,d1

loc_17E00:
		andi.b	#-4,4(a0)
		eor.b	d1,d2
		or.b	d2,4(a0)
		btst	#5,$2A(a0)
		bne.w	loc_17ECC
		lsr.b	#4,d0
		andi.b	#6,d0
		move.w	$1C(a0),d2
		bpl.s	loc_17E24
		neg.w	d2

loc_17E24:
		tst.b	$2B(a0)
		bpl.w	loc_17E2E
		add.w	d2,d2

loc_17E2E:
		lea	(byte_17F48).l,a1
		cmpi.w	#$600,d2
		bhs.s	loc_17E42
		lea	(byte_17F3E).l,a1
		add.b	d0,d0

loc_17E42:
		add.b	d0,d0
		move.b	d0,d3
		moveq	#0,d1
		move.b	$23(a0),d1
		move.b	1(a1,d1.w),d0
		cmpi.b	#-1,d0
		bne.s	loc_17E60
		move.b	#0,$23(a0)
		move.b	1(a1),d0

loc_17E60:
		move.b	d0,$22(a0)
		add.b	d3,$22(a0)
		subq.b	#1,$24(a0)
		bpl.s	locret_17E82
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	loc_17E78
		moveq	#0,d2

loc_17E78:
		lsr.w	#8,d2
		move.b	d2,$24(a0)
		addq.b	#1,$23(a0)

locret_17E82:
		rts
; ---------------------------------------------------------------------------

loc_17E84:
		move.b	$2A(a0),d1
		andi.b	#1,d1
		andi.b	#-4,4(a0)
		or.b	d1,4(a0)
		subq.b	#1,$24(a0)
		bpl.w	locret_17D96
		move.w	$1C(a0),d2
		bpl.s	loc_17EA6
		neg.w	d2

loc_17EA6:
		lea	(byte_17F5C).l,a1
		cmpi.w	#$600,d2
		bhs.s	loc_17EB8
		lea	(byte_17F52).l,a1

loc_17EB8:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	loc_17EC2
		moveq	#0,d2

loc_17EC2:
		lsr.w	#8,d2
		move.b	d2,$24(a0)
		bra.w	loc_17D7E
; ---------------------------------------------------------------------------

loc_17ECC:
		subq.b	#1,$24(a0)
		bpl.w	locret_17D96
		move.w	$1C(a0),d2
		bmi.s	loc_17EDC
		neg.w	d2

loc_17EDC:
		addi.w	#$800,d2
		bpl.s	loc_17EE4
		moveq	#0,d2

loc_17EE4:
		lsr.w	#8,d2
		move.b	d2,$24(a0)
		lea	(byte_17F66).l,a1
		bra.w	loc_17D7E

; =============== S U B R O U T I N E =======================================

Knuckles_Load_PLC:
		moveq	#0,d0
		move.b	mapping_frame(a0),d0

Knuckles_Load_PLC2:
		cmp.b	(Player_prev_frame).w,d0
		beq.s	locret_18162
		move.b	d0,(Player_prev_frame).w
		move.w	#tiles_to_bytes(ArtTile_Player_1),d4

loc_18122:
		lea	(DPLC_Knuckles).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d5
		subq.w	#1,d5
		bmi.s	locret_18162
		move.l	#ArtUnc_Knux>>1,d6

loc_1813A:
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
		dbf	d5,loc_1813A

locret_18162:
		rts
