extends State

class_name FlyState

var stateName : String = "Fly"

var cR : CharacterBody3D

var flySpeed : float = 0.0
var flyAccel : float = 0.0
var flyDeccel : float = 0.0

func enter(charRef : CharacterBody3D):
	cR = charRef
	
	verifications()
	
func verifications():
	cR.moveSpeed = cR.flySpeed
	cR.moveAccel = cR.flyAccel
	cR.moveDeccel = cR.flyDeccel
	
	cR.floor_snap_length = 1.0
	if cR.jumpCooldown > 0.0: cR.jumpCooldown = -1.0
	if cR.nbJumpsInAirAllowed < cR.nbJumpsInAirAllowedRef: cR.nbJumpsInAirAllowed = cR.nbJumpsInAirAllowedRef
	if cR.coyoteJumpCooldown < cR.coyoteJumpCooldownRef: cR.coyoteJumpCooldown = cR.coyoteJumpCooldownRef
	
func physics_update(delta : float):
	checkIfFloor()
	
	applies(delta)
	
	inputManagement()
	
	move(delta)
	
func checkIfFloor():
	pass
			
func applies(delta : float):
	if cR.hitGroundCooldown > 0.0: cR.hitGroundCooldown -= delta
	
	cR.hitbox.shape.height = lerp(cR.hitbox.shape.height, cR.baseHitboxHeight, cR.heightChangeSpeed * delta)
	cR.model.scale.y = lerp(cR.model.scale.y, cR.baseModelHeight, cR.heightChangeSpeed * delta)
	
func inputManagement():
	if Input.is_action_just_pressed(cR.flyAction):
		transitioned.emit(self, "InairState")
		
	if Input.is_action_just_pressed(cR.runAction):
		cR.flyBoostOn = !cR.flyBoostOn
		
func move(delta : float):
	cR.inputDirection = Input.get_vector(cR.moveLeftAction, cR.moveRightAction, cR.moveForwardAction, cR.moveBackwardAction)
	#need to get the cam reference directly, and not the cam holder one, because only the cam is rotating
	cR.moveDirection = (cR.cam.global_transform.basis * Vector3(cR.inputDirection.x, 0.0, cR.inputDirection.y))
	
	flySpeed = cR.flySpeed * cR.flyBoostMultiplier if cR.flyBoostOn else cR.flySpeed
	flyAccel = cR.flySpeed * cR.flyBoostMultiplier if cR.flyBoostOn else cR.flyAccel
	flyDeccel = cR.flySpeed * cR.flyBoostMultiplier if cR.flyBoostOn else cR.flyDeccel
	
	if cR.moveDirection:
		cR.velocity = lerp(cR.velocity, cR.moveDirection * flySpeed, flyAccel * delta)
	else:
		cR.velocity = lerp(cR.velocity, cR.moveDirection * flySpeed, flyDeccel * delta)
		
	if cR.desiredMoveSpeed >= cR.maxSpeed: cR.desiredMoveSpeed = cR.maxSpeed
