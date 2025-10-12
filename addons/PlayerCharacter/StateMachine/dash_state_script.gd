extends State

class_name DashState

var stateName : String = "Dash"

var cR : CharacterBody3D

func enter(charRef : CharacterBody3D):
	cR = charRef
	
	verifications()
	
func verifications():
	cR.velocityPreDash = cR.velocity #get the velocity the play char has right before dashing, to apply it again right after the dash ended
	cR.dashDirection = cR.moveDirection.normalized() #get move direction before actually start dashing, and stick to that direction
	cR.hud.displaySpeedLines(true)
	
	cR.nbDashAllowed -= 1
	
	if cR.coyoteJumpCooldown < cR.coyoteJumpCooldownRef: cR.coyoteJumpCooldown = cR.coyoteJumpCooldownRef
	
func physics_update(delta : float):
	applies(delta)
	
	move()
	
func applies(delta : float):
	if cR.dashTime > 0.0: 
		cR.dashTime -= delta
	else:
		cR.timeBefCanDashAgain = cR.timeBefCanDashAgainRef
		cR.velocity = cR.velocityPreDash
		cR.hud.displaySpeedLines(false)
		
		if cR.is_on_floor():
			transitioned.emit(self, cR.walkOrRun)
		else:
			transitioned.emit(self, "InairState")
			
	cR.hitbox.shape.height = lerp(cR.hitbox.shape.height, cR.slideHitboxHeight, cR.heightChangeSpeed * delta)
	cR.model.scale.y = lerp(cR.model.scale.y, cR.slideModelHeight, cR.heightChangeSpeed * delta)
	
func raycastVerification():
	#check if the raycast used to check ceilings is colliding or not
	return cR.ceilingCheck.is_colliding()
	
func move():
	#can't change direction while dashing
	if cR.dashDirection != Vector3.ZERO:
		cR.velocity.x = cR.moveDirection.x * cR.dashSpeed
		cR.velocity.z = cR.moveDirection.z * cR.dashSpeed
