; ===========================================================================
; Palette pointers
; ===========================================================================

PalPointers:				; palette address, RAM address, colours

; Main
ptr_Pal_Sonic:			palp	Pal_Sonic, Normal_palette_line_1, 16			; 0 - Sonic
ptr_Pal_WaterSonic:		palp	Pal_WaterSonic, Water_palette_line_1, 16		; 1 - Water Sonic
ptr_Pal_Knuckles:			palp	Pal_Knuckles, Normal_palette_line_1, 16			; 2 - Knuckles
ptr_Pal_WaterKnuckles:	palp	Pal_WaterKnuckles, Water_palette_line_1, 16		; 3 - Water Knuckles

; Levels
ptr_Pal_DEZ:			palp	Pal_DEZ, Normal_palette_line_2, 48				; 4 - DEZ1
ptr_Pal_WaterDEZ:		palp	Pal_WaterDEZ, Water_palette_line_2, 48		; 5 - Water DEZ1
; ---------------------------------------------------------------------------

; Main
palid_Sonic:				equ (ptr_Pal_Sonic-PalPointers)/8					; 0 - Sonic
palid_WaterSonic:		equ (ptr_Pal_WaterSonic-PalPointers)/8				; 1 - Water Sonic
palid_Knuckles:			equ (ptr_Pal_Knuckles-PalPointers)/8				; 2 - Knuckles
palid_WaterKnuckles:		equ (ptr_Pal_WaterKnuckles-PalPointers)/8			; 3 - Water Knuckles

; Levels
palid_DEZ:				equ (ptr_Pal_DEZ-PalPointers)/8					; 4 - DEZ1
palid_WaterDEZ:			equ (ptr_Pal_WaterDEZ-PalPointers)/8				; 5 - Water DEZ1