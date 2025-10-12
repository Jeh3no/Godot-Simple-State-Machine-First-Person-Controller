extends State

class_name SlideState

var stateName : String = "Slide"

var cR : CharacterBody3D

var slopeAngle : float

func enter(charRef : CharacterBody3D):
	cR = charRef
	
	verifications()
	
func verifications():
	cR.moveSpeed = cR.slideSpeed
	cR.moveAccel = cR.slideAccel
	cR.moveDeccel = 0.0
	
	cR.slideDirection = cR.moveDirection.normalized() #get move direction before actually start sliding, and stick to that direction
	
	if cR.floor_snap_length != 1.0: cR.floor_snap_length = 1.0
	if cR.jumpCooldown > 0.0: cR.jumpCooldown = -1.0
	if cR.nbJumpsInAirAllowed < cR.nbJumpsInAirAllowedRef: cR.nbJumpsInAirAllowed = cR.nbJumpsInAirAllowedRef
	if cR.coyoteJumpCooldown < cR.coyoteJumpCooldownRef: cR.coyoteJumpCooldown = cR.coyoteJumpCooldownRef
	
func physics_update(delta : float):
	checkIfFloor()
	
	applies(delta)
	
	cR.gravityApply(delta)
	
	inputManagement()
	
	move(delta)
	
func checkIfFloor():
	if cR.is_on_floor():
		if cR.jumpBuffOn and cR.jumpCooldown < 0.0:
			cR.bufferedJump = true
			cR.jumpBuffOn = false
			transitioned.emit(self, "JumpState")
			
func applies(delta : float):
	#petit bug a revoir ici : parfois stop slide alors que play char sur sol plat
	if cR.lastFramePosition.y < cR.position.y: #check if play char is uphill
		cR.slideTime = -1.0
		cR.slideDirection = Vector3.ZERO
		if !raycastVerification():
			transitioned.emit(self, cR.walkOrRun)
		else:
			transitioned.emit(self, "CrouchState")
		
	#if cR.hitGroundCooldown > 0.0: cR.hitGroundCooldown -= delta
	slopeAngle = rad_to_deg(acos(cR.get_floor_normal().dot(Vector3.UP)))
	
	#if current slope angle superior than max slope angle, play char slides indefinitely while he's on the slope
	if slopeAngle < cR.maxSlopeAngle:
		if cR.slideTime > 0.0:
			if cR.is_on_floor():
				cR.slideTime -= delta
		else:
			cR.slideDirection = Vector3.ZERO
			cR.timeBefCanSlideAgain = cR.timeBefCanSlideAgainRef
			if !raycastVerification():
				transitioned.emit(self, cR.walkOrRun)
			else:
				transitioned.emit(self, "CrouchState")
		
	cR.hitbox.shape.height = lerp(cR.hitbox.shape.height, cR.slideHitboxHeight, cR.heightChangeSpeed * delta)
	cR.model.scale.y = lerp(cR.model.scale.y, cR.slideModelHeight, cR.heightChangeSpeed * delta)
	
func inputManagement():
	if Input.is_action_just_pressed(cR.jumpAction):
		#if nothing block play char when he will leave the slide state
		if (slopeAngle > cR.maxSlopeAngle or !raycastVerification()) and cR.jumpCooldown < 0.0:
			#force break slide state
			cR.slideTime = -1.0
			cR.slideDirection = Vector3.ZERO
			cR.timeBefCanSlideAgain = cR.timeBefCanSlideAgainRef
			transitioned.emit(self, "JumpState")
			
	if cR.continiousSlide: 
		#has to press slide button once to run
		if Input.is_action_just_pressed(cR.slideAction):
			cR.slideTime = -1.0
			cR.slideDirection = Vector3.ZERO
			cR.timeBefCanSlideAgain = cR.timeBefCanSlideAgainRef
			if !raycastVerification():
				transitioned.emit(self, cR.walkOrRun)
			else:
				transitioned.emit(self, "CrouchState")
	else:
		#has to continuously press slide button to crouch
		if !Input.is_action_pressed(cR.slideAction):
			if !raycastVerification():
				cR.slideTime = -1.0
				cR.slideDirection = Vector3.ZERO
				cR.timeBefCanSlideAgain = cR.timeBefCanSlideAgainRef
				if !raycastVerification():
					transitioned.emit(self, cR.walkOrRun)
				else:
					transitioned.emit(self, "CrouchState")
			
func raycastVerification():
	#check if the raycast used to check ceilings is colliding or not
	return cR.ceilingCheck.is_colliding()
	
func move(delta : float):
	#can't change direction while sliding
	if cR.slideDirection and cR.is_on_floor():
		if cR.useDesiredMoveSpeed:
			#(cR.desiredMoveSpeed - cR.amountVelocityLostPerSec * delta > 0.0) to avoir having negative move speed, and so slide in opposite direction than initial
			if slopeAngle < cR.maxSlopeAngle and (cR.desiredMoveSpeed - cR.amountVelocityLostPerSec * delta > 0.0) : cR.desiredMoveSpeed -= cR.amountVelocityLostPerSec * delta
			else: cR.desiredMoveSpeed += cR.slopeSlidingDmsIncre * delta
			
			cR.velocity.x = cR.moveDirection.x * cR.desiredMoveSpeed
			cR.velocity.z = cR.moveDirection.z * cR.desiredMoveSpeed
		else:
			if slopeAngle < cR.maxSlopeAngle and (cR.desiredMoveSpeed - cR.amountVelocityLostPerSec * delta > 0.0): cR.moveSpeed -= cR.amountVelocityLostPerSec * delta
			else: cR.moveSpeed += cR.slopeSlidingMsIncre * delta
			
			cR.velocity.x = lerp(cR.velocity.x, cR.moveDirection.x * cR.moveSpeed, cR.moveAccel * delta)
			cR.velocity.z = lerp(cR.velocity.z, cR.moveDirection.z * cR.moveSpeed, cR.moveAccel * delta)
