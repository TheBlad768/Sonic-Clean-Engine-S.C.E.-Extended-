
; =============== S U B R O U T I N E =======================================

Obj_Knuckles:

		; load some addresses into registers
		; this is done to allow some subroutines to be
		; shared with Tails/Sonic.

		lea	(Max_speed).w,a4
		lea	(Distance_from_top).w,a5
		lea	(Dust).w,a6

	if GameDebug
		tst.w	(Debug_placement_mode).w
		beq.s	Knuckles_Normal

		; debug only code
		cmpi.b	#1,(Debug_placement_type).w									; are Knuckles in debug object placement mode?
		beq.s	loc_16488													; if so, skip to debug mode routine

		; by this point, we're assuming you're in frame cycling mode
		btst	#button_B,(Ctrl_1_pressed).w
		beq.s	loc_1646C
		clr.w	(Debug_placement_mode).w									; leave debug mode

loc_1646C:
		addq.b	#1,mapping_frame(a0)											; next frame
		cmpi.b	#((Map_Knuckles_end-Map_Knuckles)/2)-1,mapping_frame(a0)		; have we reached the end of Knuckles's frames?
		blo.s		loc_1647E
		clr.b	mapping_frame(a0)												; if so, reset to Knuckles's first frame

loc_1647E:
		bsr.w	Knuckles_Load_PLC
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_16488:
		jmp	(Debug_Mode).l
; ---------------------------------------------------------------------------

Knuckles_Normal:
	endif

		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	Knuckles_Index(pc,d0.w),d0
		jmp	Knuckles_Index(pc,d0.w)
; ---------------------------------------------------------------------------

Knuckles_Index: offsetTable
		ptrTableEntry.w Knuckles_Init			; 0
		ptrTableEntry.w Knuckles_Control		; 2
		ptrTableEntry.w Knuckles_Hurt			; 4
		ptrTableEntry.w Knuckles_Death		; 6
		ptrTableEntry.w Knuckles_Restart		; 8
		ptrTableEntry.w loc_17CCE				; A
		ptrTableEntry.w Knuckles_Drown		; C
; ---------------------------------------------------------------------------

Knuckles_Init:												; Routine 0
		addq.b	#2,routine(a0)								; => Knuckles_Control
		move.w	#bytes_to_word(38/2,18/2),y_radius(a0)			; set y_radius and x_radius	; this sets Knuckles's collision height (2*pixels)
		move.w	y_radius(a0),default_y_radius(a0)				; set default_y_radius and default_x_radius
		move.l	#Map_Knuckles,mappings(a0)
		move.w	#$100,priority(a0)
		move.w	#bytes_to_word(48/2,48/2),height_pixels(a0)		; set height and width
		move.b	#4,render_flags(a0)
		move.b	#PlayerID_Knuckles,character_id(a0)
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
		clr.b	flips_remaining(a0)
		move.b	#4,flip_speed(a0)
		move.b	#30,air_left(a0)
		subi.w	#32,x_pos(a0)
		addq.w	#4,y_pos(a0)
		jsr	Reset_Player_Position_Array(pc)
		addi.w	#32,x_pos(a0)
		subq.w	#4,y_pos(a0)
		rts
; ---------------------------------------------------------------------------

Knuckles_Control:

	if GameDebug
		tst.b	(Debug_mode_flag).w
		beq.s	loc_165A2
		bclr	#button_A,(Ctrl_1_pressed).w
		beq.s	loc_16580
		eori.b	#1,(Reverse_gravity_flag).w

loc_16580:
		btst	#button_B,(Ctrl_1_pressed).w
		beq.s	loc_165A2
		move.w	#1,(Debug_placement_mode).w
		clr.b	(Ctrl_1_locked).w									; unlock control
		btst	#button_C,(Ctrl_1_held).w
		beq.s	locret_165A0
		move.w	#2,(Debug_placement_mode).w

locret_165A0:
		rts
; ---------------------------------------------------------------------------

loc_165A2:
	endif

		tst.b	(Ctrl_1_locked).w
		bne.s	loc_165AE
		move.w	(Ctrl_1).w,(Ctrl_1_logical).w

loc_165AE:
		btst	#0,object_control(a0)
		beq.s	loc_165BE
		clr.b	double_jump_flag(a0)
		bra.s	loc_165D8
; ---------------------------------------------------------------------------

loc_165BE:
		movem.l	a4-a6,-(sp)
		moveq	#6,d0
		and.b	status(a0),d0
		move.w	Knux_Modes(pc,d0.w),d0
		jsr	Knux_Modes(pc,d0.w)					; run Knuckles's movement control code
		movem.l	(sp)+,a4-a6

loc_165D8:
		cmpi.w	#-$100,(Camera_min_Y_pos).w		; is vertical wrapping enabled?
		bne.s	.display							; if not, branch
		move.w	(Screen_Y_wrap_value).w,d0
		and.w	d0,y_pos(a0)						; perform wrapping of Knuckles's y position

.display
		bsr.s	Knuckles_Display
		bsr.w	Sonic_RecordPos
		bsr.w	Knuckles_Water
		move.b	(Primary_Angle).w,next_tilt(a0)
		move.b	(Secondary_Angle).w,tilt(a0)
		tst.b	(WindTunnel_flag).w
		beq.s	.anim
		tst.b	anim(a0)							; AniIDKnuxAni_Walk
		bne.s	.anim
		move.b	prev_anim(a0),anim(a0)

.anim
		btst	#1,object_control(a0)
		bne.s	.touch
		bsr.w	Animate_Knuckles
		tst.b	(Reverse_gravity_flag).w
		beq.s	.plc
		eori.b	#2,render_flags(a0)

.plc
		bsr.w	Knuckles_Load_PLC

.touch
		moveq	#signextendB($A0),d0
		and.b	object_control(a0),d0
		bne.s	.return
		jmp	TouchResponse(pc)
; ---------------------------------------------------------------------------

.return
		rts

; ---------------------------------------------------------------------------
; Secondary states under state Knux_Control
; ---------------------------------------------------------------------------

Knux_Modes: offsetTable
		offsetTableEntry.w Knux_MdNormal			; 0
		offsetTableEntry.w Knux_MdAir				; 2
		offsetTableEntry.w Knux_MdRoll			; 4
		offsetTableEntry.w Knux_MdJump			; 6

; =============== S U B R O U T I N E =======================================

Knuckles_Display:
		move.b	invulnerability_timer(a0),d0
		beq.s	.draw
		subq.b	#1,invulnerability_timer(a0)
		lsr.b	#3,d0
		bhs.s	Knux_ChkInvin

.draw
		jsr	(Draw_Sprite).w

Knux_ChkInvin:										; checks if invincibility has expired and disables it if it has.
		btst	#Status_Invincible,status_secondary(a0)
		beq.s	Knux_ChkShoes
		tst.b	invincibility_timer(a0)
		beq.s	Knux_ChkShoes						; if there wasn't any time left, that means we're in Super/Hyper mode
		moveq	#7,d0
		and.b	(Level_frame_counter+1).w,d0
		bne.s	Knux_ChkShoes
		subq.b	#1,invincibility_timer(a0)				; reduce invincibility_timer only on every 8th frame
		bne.s	Knux_ChkShoes						; if time is still left, branch
		tst.b	(Level_results_flag).w						; don't change music if level is end
		bne.s	Knux_RmvInvin
		tst.b	(Boss_flag).w								; don't change music if in a boss fight
		bne.s	Knux_RmvInvin
		cmpi.b	#12,air_left(a0)						; don't change music if drowning
		blo.s		Knux_RmvInvin
		move.w	(Current_music).w,d0
		jsr	(Play_Music).w							; stop playing invincibility theme and resume normal level music

Knux_RmvInvin:
		bclr	#Status_Invincible,status_secondary(a0)

Knux_ChkShoes:										; checks if Speed Shoes have expired and disables them if they have.
		btst	#Status_SpeedShoes,status_secondary(a0)	; does Sonic have speed shoes?
		beq.s	locret_166F4							; if so, branch
		tst.b	speed_shoes_timer(a0)
		beq.s	locret_166F4
		moveq	#7,d0
		and.b	(Level_frame_counter+1).w,d0
		bne.s	locret_166F4
		subq.b	#1,speed_shoes_timer(a0)				; reduce speed_shoes_timer only on every 8th frame
		bne.s	locret_166F4
		move.w	#$600,Max_speed-Max_speed(a4)		; set Max_speed
		move.w	#$C,Acceleration-Max_speed(a4)		; set Acceleration
		move.w	#$80,Deceleration-Max_speed(a4)		; set Deceleration
		bclr	#Status_SpeedShoes,status_secondary(a0)
		music	mus_Slowdown,1						; slow down tempo

; =============== S U B R O U T I N E =======================================

Knuckles_Water:
		tst.b	(Water_flag).w									; does level have water?
		bne.s	Knuckles_InWater								; if yes, branch

locret_166F4:
		rts
; ---------------------------------------------------------------------------

Knuckles_InWater:
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0
		bge.s	loc_1676E
		bset	#Status_Underwater,status(a0)
		bne.s	locret_166F4
		addq.b	#1,(Water_entered_counter).w
		movea.w	a0,a1
		bsr.w	Player_ResetAirTimer
		move.l	#Obj_AirCountdown,(Breathing_bubbles+address).w
		move.w	a0,(Breathing_bubbles+parent).w
		move.w	#$300,Max_speed-Max_speed(a4)
		move.w	#6,Acceleration-Max_speed(a4)
		move.w	#$40,Deceleration-Max_speed(a4)
		tst.b	object_control(a0)
		bne.s	locret_166F4
		asr.w	x_vel(a0)
		asr.w	y_vel(a0)
		asr.w	y_vel(a0)
		beq.s	locret_166F4
		move.w	#bytes_to_word(1,0),anim(a6)		; splash animation, write 1 to anim and clear prev_anim
		sfx	sfx_Splash,1							; splash sound
; ---------------------------------------------------------------------------

loc_1676E:
		bclr	#Status_Underwater,status(a0)
		beq.s	locret_166F4
		addq.b	#1,(Water_entered_counter).w
		movea.w	a0,a1
		bsr.w	Player_ResetAirTimer
		move.w	#$600,Max_speed-Max_speed(a4)
		move.w	#$C,Acceleration-Max_speed(a4)
		move.w	#$80,Deceleration-Max_speed(a4)
		cmpi.b	#PlayerID_Hurt,routine(a0)
		beq.s	loc_167C4
		tst.b	object_control(a0)
		bne.s	loc_167C4
		move.w	y_vel(a0),d0
		cmpi.w	#-$400,d0
		blt.s		loc_167C4
		asl.w	y_vel(a0)

loc_167C4:
		cmpi.b	#AniIDSonAni_Blank,anim(a0)		; is Knuckles in his 'blank' animation
		beq.w	locret_166F4						; if so, branch
		tst.w	y_vel(a0)
		beq.w	locret_166F4
		move.w	#bytes_to_word(1,0),anim(a6)		; splash animation, write 1 to anim and clear prev_anim
		cmpi.w	#-$1000,y_vel(a0)
		bgt.s	loc_167EA
		move.w	#-$1000,y_vel(a0)

loc_167EA:
		sfx	sfx_Splash,1							; splash sound

; =============== S U B R O U T I N E =======================================

Knux_MdNormal:
		bsr.w	SonicKnux_Spindash
		bsr.w	Knux_Jump
		bsr.w	Player_SlopeResist
		bsr.w	Knux_InputAcceleration_Path
		bsr.w	SonicKnux_Roll
		bsr.w	Player_LevelBound
		jsr	(MoveSprite2_TestGravity).w
		bsr.w	Call_Player_AnglePos
		bsr.w	Player_SlopeRepel

		; check flag
		tst.b	(Background_collision_flag).w
		beq.s	locret_1684A
		jsr	(sub_F846).w
		tst.w	d1
		bmi.w	Kill_Character
		movem.l	a4-a6,-(sp)
		jsr	(CheckLeftWallDist).w
		tst.w	d1
		bpl.s	loc_1683A
		sub.w	d1,x_pos(a0)

loc_1683A:
		jsr	(CheckRightWallDist).w
		tst.w	d1
		bpl.s	loc_16846
		add.w	d1,x_pos(a0)

loc_16846:
		movem.l	(sp)+,a4-a6

locret_1684A:
		rts

; ---------------------------------------------------------------------------
; Start of subroutine Knux_MdAir
; Called if Knuckles is airborne, but not in a ball (thus, probably not jumping)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

; Knux_Stand_Freespace:
Knux_MdAir:
		tst.b	double_jump_flag(a0)
		bne.s	Knux_Glide_Freespace

	if RollInAir
		bsr.w	Sonic_ChgFallAnim
	endif

		bsr.w	Knux_JumpHeight
		bsr.w	Knux_ChgJumpDir
		bsr.w	Player_LevelBound
		jsr	(MoveSprite_TestGravity).w
		btst	#Status_Underwater,status(a0)
		beq.s	loc_16872
		subi.w	#$28,y_vel(a0)

loc_16872:
		cmpi.w	#$1000,y_vel(a0)
		ble.s		.maxy
		move.w	#$1000,y_vel(a0)

.maxy
		bsr.w	Player_JumpAngle
		bra.w	SonicKnux_DoLevelCollision
; ---------------------------------------------------------------------------

Knux_Glide_Freespace:
		bsr.w	Knuckles_Move_Glide
		bsr.w	Player_LevelBound
		jsr	(MoveSprite2_TestGravity).w

; =============== S U B R O U T I N E =======================================

Knuckles_Glide:
		move.b	double_jump_flag(a0),d0
		beq.s	.return
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

		moveq	#button_A_mask|button_B_mask|button_C_mask,d0
		and.b	(Ctrl_1_logical).w,d0
		bne.s	.continueGliding

		; The player has let go of the jump button, so exit the gliding state
		; and enter the falling state.
		move.b	#2,double_jump_flag(a0)
		move.b	#$21,anim(a0)					; put Knuckles in his falling animation
		bclr	#Status_Facing,status(a0)
		tst.w	x_vel(a0)
		bpl.s	.skip1
		bset	#Status_Facing,status(a0)

.skip1:
		; Divide Knuckles' X velocity by 4.
		asr.w	x_vel(a0)
		asr.w	x_vel(a0)
		move.w	default_y_radius(a0),y_radius(a0)	; set default_y_radius and default_x_radius

.return
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
+		moveq	#$20,d0
		add.b	angle(a0),d0
		andi.b	#$C0,d0
		beq.s	loc_1693E
		move.w	ground_vel(a0),x_vel(a0)
		clr.w	y_vel(a0)
		bra.w	Knux_TouchFloor
; ---------------------------------------------------------------------------

loc_1693E:
		move.b	#3,double_jump_flag(a0)
		move.b	#$CC,mapping_frame(a0)
		move.b	#$7F,anim_frame_timer(a0)
		clr.b	anim_frame(a0)

		; The drowning countdown uses the dust clouds' VRAM, so don't create
		; dust if Knuckles is drowning.
		cmpi.b	#12,air_left(a0)						; check air remaining
		blo.s		.return								; if less than 12, branch

		; Create dust clouds.
		move.l	#DashDust_CheckSkid,address(a6)		; Dust
		move.b	#$15,mapping_frame(a6)				; Dust

.return
		rts
; ---------------------------------------------------------------------------

Knuckles_Gliding_HitWall:
		tst.b	(Disable_wall_grab).w
		bmi.w	.fail

		move.b	lrb_solid_bit(a0),d5
		moveq	#$40,d0
		add.b	double_jump_property(a0),d0
		bpl.s	.right

;.left:
		bset	#Status_Facing,status(a0)
		bsr.w	CheckLeftCeilingDist
		or.w	d0,d1
		bne.s	.checkFloorLeft
		addq.w	#1,x_pos(a0)
		bra.s	.success
; ---------------------------------------------------------------------------

.right:
		bclr	#Status_Facing,status(a0)
		bsr.w	CheckRightCeilingDist
		or.w	d0,d1
		bne.w	.checkFloorRight

.success:
		sfx	sfx_Grab
		clr.l	x_vel(a0)
		clr.w	ground_vel(a0)
		move.b	#4,double_jump_flag(a0)
		move.b	#$B7,mapping_frame(a0)
		move.b	#$7F,anim_frame_timer(a0)
		clr.b	anim_frame(a0)
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
		jsr	(ChkFloorEdge_Part3).w

		tst.w	d1
		bmi.s	.fail
		cmpi.w	#12,d1
		bhs.s	.fail
		add.w	d1,y_pos(a0)
		bra.s	.success
; ---------------------------------------------------------------------------
; loc_16A34:
.reverseGravity:
		moveq	#11,d2
		add.w	y_pos(a0),d2
		eori.w	#$F,d2
		jsr	(ChkFloorEdge_ReverseGravity_Part2).w

		tst.w	d1
		bmi.s	.fail
		cmpi.w	#12,d1
		bhs.s	.fail
		sub.w	d1,y_pos(a0)
		bra.s	.success
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
		move.b	#$21,anim(a0)						; put Knuckles in his falling animation
		move.w	default_y_radius(a0),y_radius(a0)		; set default_y_radius and default_x_radius
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
		clr.l	x_vel(a0)
		clr.w	ground_vel(a0)

		move.b	y_radius(a0),d0
		sub.b	default_y_radius(a0),d0
		ext.w	d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	.skip2
		neg.w	d0

.skip2:
		add.w	d0,y_pos(a0)
		sfx	sfx_GlideLand
		moveq	#$20,d0
		add.b	angle(a0),d0
		andi.b	#$C0,d0
		beq.s	.skip3
		bra.w	Knux_TouchFloor
; ---------------------------------------------------------------------------

.skip3:
		bsr.w	Knux_TouchFloor
		move.w	#15,move_lock(a0)
		move.b	#$23,anim(a0)
; locret_16B04:
.return:
		rts
; ---------------------------------------------------------------------------

Knuckles_Sliding:
		moveq	#button_A_mask|button_B_mask|button_C_mask,d0
		and.b	(Ctrl_1_logical).w,d0
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
		clr.l	x_vel(a0)
		clr.w	ground_vel(a0)

		move.b	y_radius(a0),d0
		sub.b	default_y_radius(a0),d0
		ext.w	d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	.skip1
		neg.w	d0

.skip1:
		add.w	d0,y_pos(a0)

		bsr.w	Knux_TouchFloor

		move.w	#15,move_lock(a0)
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
		moveq	#7,d0
		and.b	(Level_frame_counter+1).w,d0
		bne.s	.skip3
		sfx	sfx_GroundSlide

.skip3:
		rts
; ---------------------------------------------------------------------------
; loc_16B96:
.fail:
		move.b	#2,double_jump_flag(a0)
		move.b	#$21,anim(a0)						; put Knuckles in his falling animation
		move.w	default_y_radius(a0),y_radius(a0)		; set default_y_radius and default_x_radius
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

		clr.l	x_vel(a0)
		clr.w	ground_vel(a0)

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
		moveq	#$40,d0
		add.b	(Primary_Angle).w,d0
		neg.b	d0
		subi.b	#$40,d0
		move.b	d0,angle(a0)
		clr.l	x_vel(a0)
		clr.w	ground_vel(a0)
		bsr.w	Knux_TouchFloor
		move.b	#AniIDSonAni_Wait,anim(a0)
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
		; get Knuckles' distance from the wall in 'd1'
		moveq	#11,d2
		add.w	y_pos(a0),d2
		bsr.w	GetDistanceFromWall

		; if Knuckles is no longer against the wall (he has climbed off the bottom of it) then make him let go
		tst.w	d1
		bne.w	Knuckles_LetGoOfWall

		; get Knuckles' distance from the floor in 'd1'
		move.b	top_solid_bit(a0),d5
		moveq	#9,d2
		add.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		bsr.w	sub_F828

		; check if Knuckles has room below him
		tst.w	d1
		bpl.s	.moveDown
; loc_16D6E:
.reachedFloor:

		; Knuckles has reached the floor
		add.w	d1,y_pos(a0)
		move.b	(Primary_Angle).w,angle(a0)
		clr.l	x_vel(a0)
		clr.w	ground_vel(a0)
		bsr.w	Knux_TouchFloor
		move.b	#AniIDSonAni_Wait,anim(a0)
		rts
; ---------------------------------------------------------------------------
; loc_16D96:
.moveDown:
		addq.w	#1,y_pos(a0)

		moveq	#-1,d1	; climbing animation delta: make the animation play backwards.
		bra.s	.finishMoving
; ---------------------------------------------------------------------------
; loc_16DA8:
.climbingUp_ReverseGravity:

		; get Knuckles' distance from the wall in 'd1'
		moveq	#11,d2
		add.w	y_pos(a0),d2
		bsr.w	GetDistanceFromWall

		; if the wall is far away from Knuckles, then we must have reached a
		; ledge, so make Knuckles climb up onto it.
		cmpi.w	#4,d1
		bge.w	Knuckles_ClimbUp

		; if Knuckles has encountered a small dip in the wall, then make him
		; stop.
		tst.w	d1
		bne.w	.notMoving

		; get Knuckles' distance from the ceiling in 'd1'
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
		bra.s	.finishMoving
; ---------------------------------------------------------------------------
; loc_16DE2:
.moveUp_ReverseGravity:
		addq.w	#1,y_pos(a0)

		moveq	#1,d1	; Climbing animation delta: make the animation play forwards.

		; Don't let Knuckles climb through the level's upper boundary.

		; If the level wraps vertically, then don't bother with any of this.
		cmpi.w	#-$100,(Camera_min_Y_pos).w
		beq.s	.finishMoving

		; Check if Knuckles is over the level's top boundary.
		move.w	(Camera_max_Y_pos).w,d0
		addi.w	#$D0,d0
		cmp.w	y_pos(a0),d0
		bge.s	.finishMoving

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
		moveq	#button_up_mask|button_down_mask,d0
		and.b	(Ctrl_1_held_logical).w,d0
		bne.s	.isMovingUpOrDown

		; Get Knuckles' distance from the floor in 'd1'.
		move.b	top_solid_bit(a0),d5
		moveq	#9,d2
		add.w	y_pos(a0),d2
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
		bls.s		.noLoop2
		move.b	#$B7,d1

.noLoop2:
		; Apply the frame.
		move.b	d1,mapping_frame(a0)
; loc_16E60:
.notMoving:
		move.b	#$20,anim_frame_timer(a0)
		clr.b	anim_frame(a0)

		moveq	#button_A_mask|button_B_mask|button_C_mask,d0
		and.w	(Ctrl_1_logical).w,d0
		beq.s	.hasNotJumped

		; Knuckles has jumped off the wall.
		move.l	#words_to_long($400,-$380),x_vel(a0)	; x_vel and y_vel

		bchg	#Status_Facing,status(a0)
		bne.s	.goingRight
		neg.w	x_vel(a0)

.goingRight:
		bset	#Status_InAir,status(a0)
		move.b	#1,jumping(a0)
		move.w	#bytes_to_word(28/2,14/2),y_radius(a0)		; set y_radius and x_radius
		move.b	#AniIDSonAni_Roll,anim(a0)
		bset	#Status_Roll,status(a0)
		clr.b	double_jump_flag(a0)

; locret_16EB8:
.hasNotJumped:
		rts
; ---------------------------------------------------------------------------
; loc_16EBA:
Knuckles_ClimbUp:
		move.b	#5,double_jump_flag(a0)

		cmpi.b	#$BD,mapping_frame(a0)
		beq.s	Knuckles_LetGoOfWall.return

		clr.b	double_jump_property(a0)
		bra.s	Knuckles_DoLedgeClimbingAnimation
; ---------------------------------------------------------------------------
; loc_16ED2:
Knuckles_LetGoOfWall:
		move.b	#2,double_jump_flag(a0)
		move.w	#bytes_to_word($21,$21),anim(a0)
		move.b	#$CB,mapping_frame(a0)
		move.b	#7,anim_frame_timer(a0)
		move.b	#1,anim_frame(a0)
		move.w	default_y_radius(a0),y_radius(a0)	; set default_y_radius and default_x_radius

.return
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
		clr.b	anim_frame(a0)
		rts

; ---------------------------------------------------------------------------
; Strangely, the last frame uses frame $D2. It will never be seen, however,
; because it is immediately overwritten by Knuckles' waiting animation.
; ---------------------------------------------------------------------------

Knuckles_ClimbLedge_Frames:

	; mapping_frame, x_pos, y_pos, anim_frame_timer
	dc.b $BD, 3, -3, 6
	dc.b $BE, 8, -10, 6
	dc.b $BF, -8, -12, 6
	dc.b $D2, 8, -5, 6
Knuckles_ClimbLedge_Frames_End

; =============== S U B R O U T I N E =======================================

; sub_16F4E:
GetDistanceFromWall:
		move.b	lrb_solid_bit(a0),d5
		btst	#Status_Facing,status(a0)
		bne.s	.facingLeft

;.facingRight:
		move.w	x_pos(a0),d3
		jmp	(sub_FAA4).w
; ---------------------------------------------------------------------------
; loc_16F62:
.facingLeft:
		move.w	x_pos(a0),d3
		subq.w	#1,d3
		jmp	(sub_FDC8).w
; ---------------------------------------------------------------------------

Knuckles_Climb_Ledge:
		tst.b	anim_frame_timer(a0)
		bne.s	.return
		bsr.s	Knuckles_DoLedgeClimbingAnimation

		; Have we reached the end of the ledge-climbing animation?
		cmpi.b	#Knuckles_ClimbLedge_Frames_End-Knuckles_ClimbLedge_Frames,double_jump_property(a0)
		bne.s	.return

		; Yes.
		clr.l	x_vel(a0)
		clr.w	ground_vel(a0)

		btst	#Status_Facing,status(a0)
		beq.s	.notflipx
		subq.w	#1,x_pos(a0)

.notflipx
		bsr.w	Knux_TouchFloor
		move.b	#AniIDSonAni_Wait,anim(a0)

.return
		rts

; =============== S U B R O U T I N E =======================================

Knuckles_Set_Gliding_Animation:
		move.b	#$20,anim_frame_timer(a0)
		clr.b	anim_frame(a0)
		move.w	#bytes_to_word($20,$20),anim(a0)
		bclr	#Status_Push,status(a0)
		bclr	#Status_Facing,status(a0)

		; update Knuckles' frame, depending on where he's facing.
		moveq	#$10,d0
		add.b	double_jump_property(a0),d0
		lsr.w	#5,d0
		move.b	RawAni_Knuckles_GlideTurn(pc,d0.w),d1
		move.b	d1,mapping_frame(a0)
		cmpi.b	#$C4,d1
		bne.s	.return
		bset	#Status_Facing,status(a0)
		move.b	#$C0,mapping_frame(a0)

.return
		rts
; ---------------------------------------------------------------------------

RawAni_Knuckles_GlideTurn:	dc.b $C0, $C1, $C2, $C3, $C4, $C3, $C2, $C1
	even

; =============== S U B R O U T I N E =======================================

Knuckles_Move_Glide:
		cmpi.b	#1,double_jump_flag(a0)
		bne.w	.doNotKillspeed

		mvabs.w	ground_vel(a0),d0		; fix breakable wall glide
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
		moveq	#$7F,d1
		and.b	double_jump_property(a0),d1
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
		beq.s	.doNotKillspeed

		addi.w	#$10,d0
		cmp.w	y_pos(a0),d0
		ble.s		.doNotKillspeed
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
; Start of subroutine Knux_MdRoll
; Called if Knuckles is in a ball, but not airborne (thus, probably rolling)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

; Knux_Spin_Path:
Knux_MdRoll:
		tst.b	spin_dash_flag(a0)
		bne.s	loc_170CC
		bsr.w	Knux_Jump

loc_170CC:
		bsr.w	Player_RollRepel
		bsr.w	Knux_RollSpeed
		bsr.w	Player_LevelBound
		jsr	(MoveSprite2_TestGravity).w
		bsr.w	Call_Player_AnglePos
		bsr.w	Player_SlopeRepel

		; check flag
		tst.b	(Background_collision_flag).w
		beq.s	locret_17116
		jsr	(sub_F846).w
		tst.w	d1
		bmi.w	Kill_Character
		movem.l	a4-a6,-(sp)
		jsr	(CheckLeftWallDist).w
		tst.w	d1
		bpl.s	loc_17106
		sub.w	d1,x_pos(a0)

loc_17106:
		jsr	(CheckRightWallDist).w
		tst.w	d1
		bpl.s	loc_17112
		add.w	d1,x_pos(a0)

loc_17112:
		movem.l	(sp)+,a4-a6

locret_17116:
		rts

; ---------------------------------------------------------------------------
; Start of subroutine Knux_MdJump
; Called if Knuckles is in a ball and airborne (he could be jumping but not necessarily)
; Notes: This is identical to Knux_MdAir, at least at this outer level.
; Why they gave it a separate copy of the code, I don't know.
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

; Knux_Spin_Freespace:
Knux_MdJump:
		bsr.w	Knux_JumpHeight
		bsr.w	Knux_ChgJumpDir
		bsr.w	Player_LevelBound
		jsr	(MoveSprite_TestGravity).w
		btst	#Status_Underwater,status(a0)		; is Knuckles underwater?
		beq.s	loc_17138					; if not, branch
		subi.w	#$28,y_vel(a0)				; reduce gravity by $28 ($38-$28=$10)

loc_17138:
		cmpi.w	#$1000,y_vel(a0)
		ble.s		.maxy
		move.w	#$1000,y_vel(a0)

.maxy
		bsr.w	Player_JumpAngle
		bra.w	SonicKnux_DoLevelCollision

; =============== S U B R O U T I N E =======================================

Knux_InputAcceleration_Path:
		move.w	Max_speed-Max_speed(a4),d6
		move.w	Acceleration-Max_speed(a4),d5
		move.w	Deceleration-Max_speed(a4),d4
		tst.b	status_secondary(a0)
		bmi.w	loc_17364
		tst.w	move_lock(a0)
		bne.w	loc_1731C
		btst	#button_left,(Ctrl_1_logical).w
		beq.s	loc_17168
		bsr.w	sub_17428

loc_17168:
		btst	#button_right,(Ctrl_1_logical).w
		beq.s	loc_17174
		bsr.w	sub_174B4

loc_17174:
		move.w	(Camera_H_scroll_shift).w,d1
		beq.s	+
		bclr	#Status_Facing,status(a0)
		tst.w	d1
		bpl.s	+
		bset	#Status_Facing,status(a0)
+		moveq	#$20,d0
		add.b	angle(a0),d0
		andi.b	#$C0,d0
		bne.w	loc_1731C
		tst.w	ground_vel(a0)
		bne.w	loc_1731C
		bclr	#Status_Push,status(a0)
		move.b	#AniIDSonAni_Wait,anim(a0)
		btst	#Status_OnObj,status(a0)
		beq.w	loc_1722C
		movea.w	interact(a0),a1
		tst.b	status(a1)
		bmi.w	loc_172A8
		moveq	#0,d1
		move.b	width_pixels(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#2,d2
		add.w	x_pos(a0),d1
		sub.w	x_pos(a1),d1
		cmpi.w	#2,d1
		blt.s		loc_171FE
		cmp.w	d2,d1
		bge.s	loc_171D0
		bra.w	loc_172A8
; ---------------------------------------------------------------------------

loc_171D0:
		btst	#0,status(a0)
		bne.s	loc_171E2
		move.b	#AniIDSonAni_Balance,anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_171E2:
		bclr	#0,status(a0)
		clr.b	anim_frame_timer(a0)
		move.b	#4,anim_frame(a0)
		move.w	#bytes_to_word(AniIDSonAni_Balance,AniIDSonAni_Balance),anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_171FE:
		btst	#0,status(a0)
		beq.s	loc_17210
		move.b	#AniIDSonAni_Balance,anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_17210:
		bset	#0,status(a0)
		clr.b	anim_frame_timer(a0)
		move.b	#4,anim_frame(a0)
		move.w	#bytes_to_word(AniIDSonAni_Balance,AniIDSonAni_Balance),anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_1722C:
		move.w	x_pos(a0),d3
		bsr.w	ChooseChkFloorEdge
		cmpi.w	#$C,d1
		blt.s		loc_172A8
		cmpi.b	#3,next_tilt(a0)
		bne.s	loc_17272
		btst	#0,status(a0)
		bne.s	loc_17256
		move.b	#AniIDSonAni_Balance,anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_17256:
		bclr	#0,status(a0)
		clr.b	anim_frame_timer(a0)
		move.b	#4,anim_frame(a0)
		move.w	#bytes_to_word(AniIDSonAni_Balance,AniIDSonAni_Balance),anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_17272:
		cmpi.b	#3,tilt(a0)
		bne.s	loc_172A8
		btst	#0,status(a0)
		beq.s	loc_1728C
		move.b	#AniIDSonAni_Balance,anim(a0)
		bra.w	loc_1731C
; ---------------------------------------------------------------------------

loc_1728C:
		bset	#0,status(a0)
		clr.b	anim_frame_timer(a0)
		move.b	#4,anim_frame(a0)
		move.w	#bytes_to_word(AniIDSonAni_Balance,AniIDSonAni_Balance),anim(a0)
		bra.s	loc_1731C
; ---------------------------------------------------------------------------

loc_172A8:
		tst.w	(Camera_H_scroll_shift).w
		bne.s	loc_172E2
		btst	#button_down,(Ctrl_1_logical).w
		beq.s	loc_172E2
		move.b	#AniIDSonAni_Duck,anim(a0)
		addq.b	#1,scroll_delay_counter(a0)
		cmpi.b	#2*60,scroll_delay_counter(a0)
		blo.s		loc_17322
		move.b	#2*60,scroll_delay_counter(a0)
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
		btst	#button_up,(Ctrl_1_logical).w
		beq.s	loc_1731C
		move.b	#AniIDSonAni_LookUp,anim(a0)
		addq.b	#1,scroll_delay_counter(a0)
		cmpi.b	#2*60,scroll_delay_counter(a0)
		blo.s		loc_17322
		move.b	#2*60,scroll_delay_counter(a0)
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
		clr.b	scroll_delay_counter(a0)

loc_17322:
		cmpi.w	#$60,(a5)
		beq.s	loc_1732E
		bhs.s	loc_1732C
		addq.w	#4,(a5)

loc_1732C:
		subq.w	#2,(a5)

loc_1732E:
		moveq	#btnLR,d0
		and.b	(Ctrl_1_logical).w,d0
		bne.s	loc_17364
		move.w	ground_vel(a0),d0
		beq.s	loc_17364
		bmi.s	loc_17358
		sub.w	d5,d0
		bhs.s	loc_17352
		moveq	#0,d0

loc_17352:
		move.w	d0,ground_vel(a0)
		bra.s	loc_17364
; ---------------------------------------------------------------------------

loc_17358:
		add.w	d5,d0
		bhs.s	loc_17360
		moveq	#0,d0

loc_17360:
		move.w	d0,ground_vel(a0)

loc_17364:
		move.b	angle(a0),d0
		jsr	(GetSineCosine).w
		muls.w	ground_vel(a0),d1
		asr.l	#8,d1
		move.w	d1,x_vel(a0)
		muls.w	ground_vel(a0),d0
		asr.l	#8,d0
		move.w	d0,y_vel(a0)

loc_17382:
		btst	#6,object_control(a0)
		bne.s	locret_17400
		moveq	#$3F,d0
		and.b	angle(a0),d0
		beq.s	loc_173A2
		moveq	#$40,d0
		add.b	angle(a0),d0
		bmi.s	locret_17400

loc_173A2:
		move.b	#$40,d1
		tst.w	ground_vel(a0)
		beq.s	locret_17400
		bmi.s	loc_173B0
		neg.w	d1

loc_173B0:
		move.b	angle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		jsr	(CalcRoomInFront).w
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_17400
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_17422
		cmpi.b	#$40,d0
		beq.s	loc_17408
		cmpi.b	#$80,d0
		beq.s	loc_17402
		add.w	d1,x_vel(a0)
		clr.w	ground_vel(a0)
		btst	#0,status(a0)
		bne.s	locret_17400
		bset	#Status_Push,status(a0)

locret_17400:
		rts
; ---------------------------------------------------------------------------

loc_17402:
		sub.w	d1,y_vel(a0)
		rts
; ---------------------------------------------------------------------------

loc_17408:
		sub.w	d1,x_vel(a0)
		clr.w	ground_vel(a0)
		btst	#0,status(a0)
		beq.s	locret_17400
		bset	#Status_Push,status(a0)
		rts
; ---------------------------------------------------------------------------

loc_17422:
		add.w	d1,y_vel(a0)
		rts

; =============== S U B R O U T I N E =======================================

sub_17428:
		move.w	ground_vel(a0),d0
		beq.s	loc_17430
		bpl.s	loc_17462

loc_17430:
		tst.w	(Camera_H_scroll_shift).w
		bne.s	loc_17444
		bset	#0,status(a0)
		bne.s	loc_17444
		bclr	#Status_Push,status(a0)
		move.b	#AniIDSonAni_Run,prev_anim(a0)

loc_17444:
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_17456
		add.w	d5,d0
		cmp.w	d1,d0
		ble.s		loc_17456
		move.w	d1,d0

loc_17456:
		move.w	d0,ground_vel(a0)
		clr.b	anim(a0)	; AniIDKnuxAni_Walk
		rts
; ---------------------------------------------------------------------------

loc_17462:
		sub.w	d4,d0
		bhs.s	loc_1746A
		moveq	#-$80,d0

loc_1746A:
		move.w	d0,ground_vel(a0)
		moveq	#$20,d1
		add.b	angle(a0),d1
		andi.b	#$C0,d1
		bne.s	locret_174B2
		cmpi.w	#$400,d0
		blt.s		locret_174B2
		tst.b	flip_type(a0)
		bmi.s	locret_174B2
		sfx	sfx_Skid
		move.b	#AniIDSonAni_Stop,anim(a0)
		bclr	#0,status(a0)
		cmpi.b	#12,air_left(a0)						; check air remaining
		blo.s		locret_174B2							; if less than 12, branch
		move.l	#DashDust_CheckSkid,address(a6)		; Dust
		move.b	#$15,mapping_frame(a6)				; Dust

locret_174B2:
		rts

; =============== S U B R O U T I N E =======================================

sub_174B4:
		move.w	ground_vel(a0),d0
		bmi.s	loc_174E8
		bclr	#0,status(a0)
		beq.s	loc_174CE
		bclr	#Status_Push,status(a0)
		move.b	#AniIDSonAni_Run,prev_anim(a0)

loc_174CE:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s		loc_174DC
		sub.w	d5,d0
		cmp.w	d6,d0
		bge.s	loc_174DC
		move.w	d6,d0

loc_174DC:
		move.w	d0,ground_vel(a0)
		clr.b	anim(a0)	; AniIDKnuxAni_Walk
		rts
; ---------------------------------------------------------------------------

loc_174E8:
		add.w	d4,d0
		bhs.s	loc_174F0
		move.w	#$80,d0

loc_174F0:
		move.w	d0,ground_vel(a0)
		moveq	#$20,d1
		add.b	angle(a0),d1
		andi.b	#$C0,d1
		bne.s	locret_17538
		cmpi.w	#-$400,d0
		bgt.s	locret_17538
		tst.b	flip_type(a0)
		bmi.s	locret_17538
		sfx	sfx_Skid
		move.b	#AniIDSonAni_Stop,anim(a0)
		bset	#0,status(a0)
		cmpi.b	#12,air_left(a0)						; check air remaining
		blo.s		locret_17538							; if less than 12, branch
		move.l	#DashDust_CheckSkid,address(a6)		; Dust
		move.b	#$15,mapping_frame(a6)				; Dust

locret_17538:
		rts

; =============== S U B R O U T I N E =======================================

Knux_RollSpeed:
		move.w	Max_speed-Max_speed(a4),d6
		asl.w	d6
		move.w	Acceleration-Max_speed(a4),d5
		asr.w	d5
		moveq	#$20,d4
		tst.b	spin_dash_flag(a0)
		bmi.w	loc_175F8
		tst.b	status_secondary(a0)
		bmi.w	loc_175F8
		tst.w	move_lock(a0)
		bne.s	loc_17580
		tst.w	(Camera_H_scroll_shift).w
		bne.s	loc_17580
		btst	#button_left,(Ctrl_1_logical).w
		beq.s	loc_17574
		bsr.w	sub_1763A

loc_17574:
		btst	#button_right,(Ctrl_1_logical).w
		beq.s	loc_17580
		bsr.w	sub_1765E

loc_17580:
		move.w	ground_vel(a0),d0
		beq.s	loc_175A2
		bmi.s	loc_17596
		sub.w	d5,d0
		bhs.s	loc_17590
		moveq	#0,d0

loc_17590:
		move.w	d0,ground_vel(a0)
		bra.s	loc_175A2
; ---------------------------------------------------------------------------

loc_17596:
		add.w	d5,d0
		bhs.s	loc_1759E
		moveq	#0,d0

loc_1759E:
		move.w	d0,ground_vel(a0)

loc_175A2:
		mvabs.w	ground_vel(a0),d0
		cmpi.w	#$80,d0
		bhs.s	loc_175F8
		tst.b	spin_dash_flag(a0)
		bne.s	loc_175E6
		bclr	#Status_Roll,status(a0)
		move.b	y_radius(a0),d0
		move.w	default_y_radius(a0),y_radius(a0)	; set default_y_radius and default_x_radius
		move.b	#AniIDSonAni_Wait,anim(a0)
		sub.b	default_y_radius(a0),d0
		ext.w	d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_175E0
		neg.w	d0

loc_175E0:
		add.w	d0,y_pos(a0)
		bra.s	loc_175F8
; ---------------------------------------------------------------------------

loc_175E6:
		move.w	#$400,ground_vel(a0)
		btst	#0,status(a0)
		beq.s	loc_175F8
		neg.w	ground_vel(a0)

loc_175F8:
		cmpi.w	#$60,(a5)
		beq.s	loc_17604
		bhs.s	loc_17602
		addq.w	#4,(a5)

loc_17602:
		subq.w	#2,(a5)

loc_17604:
		move.b	angle(a0),d0
		jsr	(GetSineCosine).w
		move.w	ground_vel(a0),d2		; devon fix
		cmpi.w	#$1000,d2
		ble.s		loc_17628
		move.w	#$1000,d2

loc_17628:
		cmpi.w	#-$1000,d2
		bge.s	loc_17632
		move.w	#-$1000,d2

loc_17632:
		muls.w	d2,d0
		asr.l	#8,d0
		move.w	d0,y_vel(a0)
		muls.w	d2,d1
		asr.l	#8,d1
		move.w	d1,x_vel(a0)
		bra.w	loc_17382

; =============== S U B R O U T I N E =======================================

sub_1763A:
		move.w	ground_vel(a0),d0
		beq.s	loc_17642
		bpl.s	loc_17650

loc_17642:
		bset	#0,status(a0)
		move.b	#AniIDSonAni_Roll,anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_17650:
		sub.w	d4,d0
		bhs.s	loc_17658
		moveq	#-$80,d0

loc_17658:
		move.w	d0,ground_vel(a0)
		rts

; =============== S U B R O U T I N E =======================================

sub_1765E:
		move.w	ground_vel(a0),d0
		bmi.s	loc_17672
		bclr	#0,status(a0)
		move.b	#AniIDSonAni_Roll,anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_17672:
		add.w	d4,d0
		bhs.s	loc_1767A
		move.w	#$80,d0

loc_1767A:
		move.w	d0,ground_vel(a0)
		rts

; =============== S U B R O U T I N E =======================================

; sub_17680:
Knux_ChgJumpDir:
		move.w	Max_speed-Max_speed(a4),d6
		move.w	Acceleration-Max_speed(a4),d5
		asl.w	d5
		btst	#Status_RollJump,status(a0)
		bne.s	loc_176D4
		move.w	x_vel(a0),d0
		btst	#button_left,(Ctrl_1_logical).w
		beq.s	loc_176B4
		bset	#0,status(a0)
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_176B4
		add.w	d5,d0
		cmp.w	d1,d0
		ble.s		loc_176B4
		move.w	d1,d0

loc_176B4:
		btst	#button_right,(Ctrl_1_logical).w
		beq.s	loc_176D0
		bclr	#0,status(a0)
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s		loc_176D0
		sub.w	d5,d0
		cmp.w	d6,d0
		bge.s	loc_176D0
		move.w	d6,d0

loc_176D0:
		move.w	d0,x_vel(a0)

loc_176D4:
		cmpi.w	#$60,(a5)
		beq.s	loc_176E0
		bhs.s	loc_176DE
		addq.w	#4,(a5)

loc_176DE:
		subq.w	#2,(a5)

loc_176E0:
		cmpi.w	#-$400,y_vel(a0)
		blo.s		locret_1770E
		move.w	x_vel(a0),d0
		move.w	d0,d1
		asr.w	#5,d1
		beq.s	locret_1770E
		bmi.s	loc_17702
		sub.w	d1,d0
		bhs.s	loc_176FC
		moveq	#0,d0

loc_176FC:
		move.w	d0,x_vel(a0)
		rts
; ---------------------------------------------------------------------------

loc_17702:
		sub.w	d1,d0
		blo.s		loc_1770A
		moveq	#0,d0

loc_1770A:
		move.w	d0,x_vel(a0)

locret_1770E:
		rts

; =============== S U B R O U T I N E =======================================

Knux_Jump:
		moveq	#btnABC,d0
		and.b	(Ctrl_1_pressed_logical).w,d0
		beq.s	locret_1770E
		moveq	#0,d0
		move.b	angle(a0),d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17732
		addi.b	#$40,d0
		neg.b	d0
		subi.b	#$40,d0

loc_17732:
		addi.b	#$80,d0
		movem.l	a4-a6,-(sp)
		jsr	(CalcRoomOverHead).w
		movem.l	(sp)+,a4-a6
		cmpi.w	#6,d1
		blt.s		locret_1770E
		move.w	#$600,d2
		btst	#Status_Underwater,status(a0)
		beq.s	loc_1775C
		move.w	#$300,d2

loc_1775C:
		moveq	#-$40,d0
		add.b	angle(a0),d0
		jsr	(GetSineCosine).w
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,x_vel(a0)
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,y_vel(a0)
		bset	#Status_InAir,status(a0)
		bclr	#Status_Push,status(a0)
		addq.w	#4,sp
		move.b	#1,jumping(a0)
		clr.b	stick_to_convex(a0)
		sfx	sfx_Jump
		move.w	default_y_radius(a0),y_radius(a0)			; set default_y_radius and default_x_radius
		btst	#Status_Roll,status(a0)
		bne.s	locret_177E0
		move.w	#bytes_to_word(28/2,14/2),y_radius(a0)		; set y_radius and x_radius
		move.b	#AniIDSonAni_Roll,anim(a0)
		bset	#Status_Roll,status(a0)
		move.b	y_radius(a0),d0
		sub.b	default_y_radius(a0),d0
		ext.w	d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_177DC
		neg.w	d0

loc_177DC:
		sub.w	d0,y_pos(a0)

locret_177E0:
		rts

; =============== S U B R O U T I N E =======================================

Knux_JumpHeight:
		tst.b	jumping(a0)
		beq.s	loc_17818
		move.w	#-$400,d1
		btst	#Status_Underwater,status(a0)
		beq.s	loc_17800
		move.w	#-$200,d1

loc_17800:
		cmp.w	y_vel(a0),d1
		ble.s		Knux_Test_For_Glide
		moveq	#btnABC,d0
		and.b	(Ctrl_1_logical).w,d0
		bne.s	locret_17816
		move.w	d1,y_vel(a0)

locret_17816:
		rts
; ---------------------------------------------------------------------------

loc_17818:
		tst.b	spin_dash_flag(a0)
		bne.s	locret_1782C
		cmpi.w	#-$FC0,y_vel(a0)
		bge.s	locret_1782C
		move.w	#-$FC0,y_vel(a0)

locret_1782C:
		rts
; ---------------------------------------------------------------------------

Knux_Test_For_Glide:
		tst.b	double_jump_flag(a0)
		bne.s	locret_1782C
		moveq	#btnABC,d0
		and.b	(Ctrl_1_pressed_logical).w,d0
		beq.s	locret_1782C
		bclr	#Status_Roll,status(a0)
		move.w	#bytes_to_word(20/2,20/2),y_radius(a0)	; set y_radius and x_radius
		bclr	#Status_RollJump,status(a0)
		move.b	#1,double_jump_flag(a0)
		addi.w	#$200,y_vel(a0)
		bpl.s	loc_17898
		clr.w	y_vel(a0)

loc_17898:
		moveq	#0,d1
		move.w	#$400,d0
		move.w	d0,ground_vel(a0)
		btst	#0,status(a0)
		beq.s	loc_178AE
		neg.w	d0
		moveq	#-$80,d1

loc_178AE:
		move.w	d0,x_vel(a0)
		move.b	d1,double_jump_property(a0)
		clr.w	angle(a0)
		clr.b	(Gliding_collision_flags).w
		bset	#Status_InAir,(Gliding_collision_flags).w
		bra.w	Knuckles_Set_Gliding_Animation

; =============== S U B R O U T I N E =======================================

Knux_DoLevelCollision_CheckRet:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	loc_17952
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

loc_17952:
		move.b	lrb_solid_bit(a0),d5
		move.w	x_vel(a0),d1
		move.w	y_vel(a0),d2
		jsr	(GetArcTan).w
		subi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.s	loc_179DA
		cmpi.b	#$80,d0
		beq.w	loc_17A62
		cmpi.b	#$C0,d0
		beq.w	loc_17AB0
		jsr	(CheckLeftWallDist).w
		tst.w	d1
		bpl.s	loc_1799C
		sub.w	d1,x_pos(a0)
		clr.w	x_vel(a0)
		bset	#Status_Push,(Gliding_collision_flags).w

loc_1799C:
		jsr	(CheckRightWallDist).w
		tst.w	d1
		bpl.s	loc_179B4
		add.w	d1,x_pos(a0)
		clr.w	x_vel(a0)
		bset	#Status_Push,(Gliding_collision_flags).w

loc_179B4:
		bsr.w	sub_11FD6
		tst.w	d1
		bpl.s	locret_179D8
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_179C4
		neg.w	d1

loc_179C4:
		add.w	d1,y_pos(a0)
		move.b	d3,angle(a0)
		clr.w	y_vel(a0)
		bclr	#Status_InAir,(Gliding_collision_flags).w

locret_179D8:
		rts
; ---------------------------------------------------------------------------

loc_179DA:
		jsr	(CheckLeftWallDist).w
		tst.w	d1
		bpl.s	loc_179F2
		sub.w	d1,x_pos(a0)
		clr.w	x_vel(a0)
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
		add.w	d1,y_pos(a0)
		tst.w	y_vel(a0)
		bpl.s	locret_17A1A
		clr.w	y_vel(a0)

locret_17A1A:
		rts
; ---------------------------------------------------------------------------

loc_17A1C:
		jsr	(CheckRightWallDist).w
		tst.w	d1
		bpl.s	locret_17A34
		add.w	d1,x_pos(a0)
		clr.w	x_vel(a0)
		bset	#Status_Push,(Gliding_collision_flags).w

locret_17A34:
		rts
; ---------------------------------------------------------------------------

loc_17A36:
		tst.w	y_vel(a0)
		bmi.s	locret_17A60
		bsr.w	sub_11FD6
		tst.w	d1
		bpl.s	locret_17A60
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17A4C
		neg.w	d1

loc_17A4C:
		add.w	d1,y_pos(a0)
		move.b	d3,angle(a0)
		clr.w	y_vel(a0)
		bclr	#Status_InAir,(Gliding_collision_flags).w

locret_17A60:
		rts
; ---------------------------------------------------------------------------

loc_17A62:
		jsr	(CheckLeftWallDist).w
		tst.w	d1
		bpl.s	loc_17A7A
		sub.w	d1,x_pos(a0)
		clr.w	x_vel(a0)
		bset	#Status_Push,(Gliding_collision_flags).w

loc_17A7A:
		jsr	(CheckRightWallDist).w
		tst.w	d1
		bpl.s	loc_17A94
		add.w	d1,x_pos(a0)
		clr.w	x_vel(a0)
		bset	#Status_Push,(Gliding_collision_flags).w

loc_17A94:
		bsr.w	sub_11FEE
		tst.w	d1
		bpl.s	locret_17AAE
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17AA4
		neg.w	d1

loc_17AA4:
		sub.w	d1,y_pos(a0)
		clr.w	y_vel(a0)

locret_17AAE:
		rts
; ---------------------------------------------------------------------------

loc_17AB0:
		jsr	(CheckRightWallDist).w
		tst.w	d1
		bpl.s	loc_17ACA
		add.w	d1,x_pos(a0)
		clr.w	x_vel(a0)
		bset	#Status_Push,(Gliding_collision_flags).w

loc_17ACA:
		bsr.w	sub_11FEE
		tst.w	d1
		bpl.s	loc_17AEC
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17ADA
		neg.w	d1

loc_17ADA:
		sub.w	d1,y_pos(a0)
		tst.w	y_vel(a0)
		bpl.s	locret_17AEA
		clr.w	y_vel(a0)

locret_17AEA:
		rts
; ---------------------------------------------------------------------------

loc_17AEC:
		tst.w	y_vel(a0)
		bmi.s	locret_17B16
		bsr.w	sub_11FD6
		tst.w	d1
		bpl.s	locret_17B16
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17B02
		neg.w	d1

loc_17B02:
		add.w	d1,y_pos(a0)
		move.b	d3,angle(a0)
		clr.w	y_vel(a0)
		bclr	#Status_InAir,(Gliding_collision_flags).w

locret_17B16:
		rts

; =============== S U B R O U T I N E =======================================

Knux_TouchFloor_Check_Spindash:
		tst.b	spin_dash_flag(a0)
		bne.s	loc_17B6A
		clr.b	anim(a0)									; AniIDKnuxAni_Walk

Knux_TouchFloor:
		move.b	y_radius(a0),d0
		move.w	default_y_radius(a0),y_radius(a0)			; set y_radius and x_radius
		btst	#Status_Roll,status(a0)
		beq.s	loc_17B6A
		bclr	#Status_Roll,status(a0)
		clr.b	anim(a0)									; AniIDKnuxAni_Walk
		sub.b	default_y_radius(a0),d0
		ext.w	d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17B56
		neg.w	d0

loc_17B56:
		move.w	d0,-(sp)
		moveq	#$40,d0
		add.b	angle(a0),d0
		bpl.s	loc_17B64
		neg.w	(sp)

loc_17B64:
		move.w	(sp)+,d0
		add.w	d0,y_pos(a0)

loc_17B6A:
		bclr	#Status_InAir,status(a0)
		bclr	#Status_Push,status(a0)
		bclr	#Status_RollJump,status(a0)
		moveq	#0,d0
		move.b	d0,jumping(a0)
		move.w	d0,(Chain_bonus_counter).w
		move.b	d0,flip_angle(a0)
		move.b	d0,flip_type(a0)
		move.b	d0,flips_remaining(a0)
		move.b	d0,scroll_delay_counter(a0)
		move.b	d0,double_jump_flag(a0)
		cmpi.b	#$20,anim(a0)
		blo.s		locret_17BB4
		move.b	d0,anim(a0)

locret_17BB4:
		rts
; ---------------------------------------------------------------------------

Knuckles_Hurt:

	if GameDebug
		tst.b	(Debug_mode_flag).w
		beq.s	loc_17BD0
		btst	#button_B,(Ctrl_1_pressed).w
		beq.s	loc_17BD0
		move.w	#1,(Debug_placement_mode).w
		clr.b	(Ctrl_1_locked).w								; unlock control
		rts
; ---------------------------------------------------------------------------

loc_17BD0:
	endif

		jsr	(MoveSprite2_TestGravity).w
		addi.w	#$30,y_vel(a0)
		btst	#Status_Underwater,status(a0)
		beq.s	loc_17BEA
		subi.w	#$20,y_vel(a0)

loc_17BEA:
		cmpi.w	#-$100,(Camera_min_Y_pos).w
		bne.s	loc_17BFA
		move.w	(Screen_Y_wrap_value).w,d0
		and.w	d0,y_pos(a0)

loc_17BFA:
		bsr.s	sub_17C10
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
		addi.w	#224,d0
		cmp.w	y_pos(a0),d0
		blt.s		loc_17C82
		bra.s	loc_17C3C
; ---------------------------------------------------------------------------

loc_17C2E:
		move.w	(Camera_min_Y_pos).w,d0
		cmp.w	y_pos(a0),d0
		blt.s		loc_17C3C
		bra.s	loc_17C82
; ---------------------------------------------------------------------------

loc_17C3C:
		movem.l	a4-a6,-(sp)
		bsr.w	SonicKnux_DoLevelCollision
		movem.l	(sp)+,a4-a6
		btst	#Status_InAir,status(a0)
		bne.s	locret_17C80
		moveq	#0,d0
		move.l	d0,x_vel(a0)
		move.w	d0,ground_vel(a0)
		move.b	d0,object_control(a0)
		move.b	d0,anim(a0)		; AniIDKnuxAni_Walk
		move.b	d0,spin_dash_flag(a0)
		move.w	#$100,priority(a0)
		move.b	#PlayerID_Control,routine(a0)
		move.b	#2*60,invulnerability_timer(a0)

locret_17C80:
		rts
; ---------------------------------------------------------------------------

loc_17C82:
		movea.w	a0,a2
		jmp	Kill_Character(pc)
; ---------------------------------------------------------------------------

Knuckles_Death:

	if GameDebug
		tst.b	(Debug_mode_flag).w
		beq.s	loc_17CA2
		btst	#button_B,(Ctrl_1_pressed).w
		beq.s	loc_17CA2
		move.w	#1,(Debug_placement_mode).w
		clr.b	(Ctrl_1_locked).w								; unlock control
		rts
; ---------------------------------------------------------------------------

loc_17CA2:
	endif

		bsr.w	sub_123C2
		jsr	(MoveSprite_TestGravity).w
		bsr.w	Sonic_RecordPos
		bsr.s	sub_17D1E
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

Knuckles_Restart:
		tst.w	restart_timer(a0)
		beq.s	locret_17CCC
		subq.w	#1,restart_timer(a0)
		bne.s	locret_17CCC
		st	(Restart_level_flag).w

locret_17CCC:
		rts
; ---------------------------------------------------------------------------

loc_17CCE:
		tst.w	(H_scroll_amount).w
		bne.s	loc_17CE0
		tst.w	(V_scroll_amount).w
		bne.s	loc_17CE0
		move.b	#PlayerID_Control,routine(a0)

loc_17CE0:
		bsr.s	sub_17D1E
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

Knuckles_Drown:

	if GameDebug
		tst.b	(Debug_mode_flag).w
		beq.s	loc_17D04
		btst	#button_B,(Ctrl_1_pressed).w
		beq.s	loc_17D04
		move.w	#1,(Debug_placement_mode).w
		clr.b	(Ctrl_1_locked).w								; unlock control
		rts
; ---------------------------------------------------------------------------

loc_17D04:
	endif

		jsr	(MoveSprite2_TestGravity).w
		addi.w	#$10,y_vel(a0)
		bsr.w	Sonic_RecordPos
		bsr.s	sub_17D1E
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

sub_17D1E:
		bsr.s	Animate_Knuckles
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_17D2C
		eori.b	#2,render_flags(a0)

loc_17D2C:
		bra.w	Knuckles_Load_PLC

; =============== S U B R O U T I N E =======================================

Animate_Knuckles:
		lea	(AniKnuckles).l,a1
		moveq	#0,d0
		move.b	anim(a0),d0
		cmp.b	prev_anim(a0),d0
		beq.s	loc_17D58
		move.b	d0,prev_anim(a0)
		clr.b	anim_frame(a0)
		clr.b	anim_frame_timer(a0)
		bclr	#Status_Push,status(a0)

loc_17D58:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1
		move.b	(a1),d0
		bmi.s	loc_17DC8
		moveq	#1,d1
		and.b	status(a0),d1
		andi.b	#-4,render_flags(a0)
		or.b	d1,render_flags(a0)
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	locret_17D96
		move.b	d0,anim_frame_timer(a0)

loc_17D7E:
		moveq	#0,d1
		move.b	anim_frame(a0),d1
		move.b	1(a1,d1.w),d0
		cmpi.b	#-4,d0
		bhs.s	loc_17D98

loc_17D8E:
		move.b	d0,mapping_frame(a0)
		addq.b	#1,anim_frame(a0)

locret_17D96:
		rts
; ---------------------------------------------------------------------------

loc_17D98:
		addq.b	#1,d0
		bne.s	loc_17DA8
		clr.b	anim_frame(a0)
		move.b	1(a1),d0
		bra.s	loc_17D8E
; ---------------------------------------------------------------------------

loc_17DA8:
		addq.b	#1,d0
		bne.s	loc_17DBC
		move.b	2(a1,d1.w),d0
		sub.b	d0,anim_frame(a0)
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
		tst.b	flip_type(a0)
		bmi.w	loc_127C0
		move.b	flip_angle(a0),d0
		bne.w	loc_127C0
		moveq	#0,d1
		move.b	angle(a0),d0
		bmi.s	loc_17DEC
		beq.s	loc_17DEC
		subq.b	#1,d0

loc_17DEC:
		moveq	#1,d2
		and.b	status(a0),d2
		bne.s	loc_17DF8
		not.b	d0

loc_17DF8:
		addi.b	#$10,d0
		bpl.s	loc_17E00
		moveq	#3,d1

loc_17E00:
		andi.b	#-4,render_flags(a0)
		eor.b	d1,d2
		or.b	d2,render_flags(a0)
		btst	#Status_Push,status(a0)
		bne.w	loc_17ECC
		lsr.b	#4,d0
		andi.b	#6,d0
		mvabs.w	ground_vel(a0),d2
		add.w	(Camera_H_scroll_shift).w,d2
		tst.b	status_secondary(a0)
		bpl.s	loc_17E2E
		add.w	d2,d2

loc_17E2E:
		lea	(KnuxAni_Run).l,a1 	; use running animation
		cmpi.w	#$600,d2
		bhs.s	loc_17E42
		lea	(KnuxAni_Walk).l,a1 	; use walking animation
		add.b	d0,d0

loc_17E42:
		add.b	d0,d0
		move.b	d0,d3
		moveq	#0,d1
		move.b	anim_frame(a0),d1
		move.b	1(a1,d1.w),d0
		cmpi.b	#-1,d0
		bne.s	loc_17E60
		clr.b	anim_frame(a0)
		move.b	1(a1),d0

loc_17E60:
		move.b	d0,mapping_frame(a0)
		add.b	d3,mapping_frame(a0)
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	locret_17E82
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	loc_17E78
		moveq	#0,d2

loc_17E78:
		lsr.w	#8,d2
		move.b	d2,anim_frame_timer(a0)
		addq.b	#1,anim_frame(a0)

locret_17E82:
		rts
; ---------------------------------------------------------------------------

loc_17E84:
		moveq	#1,d1
		and.b	status(a0),d1
		andi.b	#-4,render_flags(a0)
		or.b	d1,render_flags(a0)
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	locret_17E82
		mvabs.w	ground_vel(a0),d2
		add.w	(Camera_H_scroll_shift).w,d2
		lea	(KnuxAni_Roll2).l,a1 	; use roll 2 animation
		cmpi.w	#$600,d2
		bhs.s	loc_17EB8
		lea	(KnuxAni_Roll).l,a1 	; use roll animation

loc_17EB8:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	loc_17EC2
		moveq	#0,d2

loc_17EC2:
		lsr.w	#8,d2
		move.b	d2,anim_frame_timer(a0)
		bra.w	loc_17D7E
; ---------------------------------------------------------------------------

loc_17ECC:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	locret_17E82
		move.w	ground_vel(a0),d2
		bmi.s	loc_17EDC
		neg.w	d2

loc_17EDC:
		addi.w	#$800,d2
		bpl.s	loc_17EE4
		moveq	#0,d2

loc_17EE4:
		lsr.w	#8,d2
		move.b	d2,anim_frame_timer(a0)
		lea	(KnuxAni_Push).l,a1		; use push animation
		bra.w	loc_17D7E

; =============== S U B R O U T I N E =======================================

Knuckles_Load_PLC:
		moveq	#0,d0
		move.b	mapping_frame(a0),d0

Knuckles_Load_PLC2:
		cmp.b	(Player_prev_frame).w,d0
		beq.s	.return
		move.b	d0,(Player_prev_frame).w
		add.w	d0,d0
		lea	(DPLC_Knuckles).l,a2
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d5
		subq.w	#1,d5
		bmi.s	.return
		move.l	#dmaSource(ArtUnc_Knuckles),d6
		move.w	#tiles_to_bytes(ArtTile_Player_1),d4

.loop
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
		dbf	d5,.loop

.return
		rts
