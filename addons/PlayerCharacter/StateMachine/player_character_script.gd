class_name PlayerCharacter
extends CharacterBody3D

@export_group("Movement variables")
var moveSpeed: float
@export var desiredMoveSpeedCurve: Curve
@export var maxSpeed: float
@export var inAirMoveSpeedCurve: Curve
@export var hitGroundCooldown: float #amount of time the character keep his accumulated speed before losing it (while being on ground)
@export var bunnyHopDmsIncre: float #bunny hopping desired move speed incrementer
@export var autoBunnyHop: bool = false
#for crouch visible changes
@export var baseHitboxHeight: float
@export var baseModelHeight: float
@export var heightChangeSpeed: float

@export_group("Crouch variables")
@export var crouchSpeed: float
@export var crouchAccel: float
@export var crouchDeccel: float
@export var continiousCrouch: bool = false #if true, doesn't need to keep crouch button on to crouch
@export var crouchHitboxHeight: float
@export var crouchModelHeight: float

@export_group("Walk variables")
@export var walkSpeed: float
@export var walkAccel: float
@export var walkDeccel: float

@export_group("Run variables")
@export var runSpeed: float
@export var runAccel: float
@export var runDeccel: float
@export var continiousRun: bool = false #if true, doesn't need to keep run button on to run

@export_group("Jump variables")
@export var jumpHeight: float
@export var jumpTimeToPeak: float
@export var jumpTimeToFall: float
@export var jumpCooldown: float
@export var nbJumpsInAirAllowed: int
@export var coyoteJumpCooldown: float
@export_range(0.1, 1.0, 0.05) var inAirInputMultiplier: float = 1.0

@export_group("Fly variables")
@export var flySpeed: float
@export var flyAccel: float
@export var flyDeccel: float
@export var flyBoostMultiplier: float

@export_group("Slide variables")
var slideDirection: Vector3 = Vector3.ZERO
@export var useDesiredMoveSpeed: bool = false
@export var slideSpeed: float
@export var slideAccel: float
@export var slideTime: float
@export var timeBefCanSlideAgain: float
@export var maxSlopeAngle: float #max slope angle where the slide time operate
@export var amountVelocityLostPerSec: float
@export var slopeSlidingDmsIncre: float #slope sliding desired move speed incrementer
@export var slopeSlidingMsIncre: float #slope sliding slide speed incrementer
@export var priorityOverCrouch: bool = true #if enabled, give priority over crouch state (because crouch and slide actions are assigned at the same input action)
@export var continiousSlide: bool = true
@export var slideHitboxHeight: float
@export var slideModelHeight: float

@export_group("Dash variables")
var dashDirection: Vector3 = Vector3.ZERO
@export var dashSpeed: float
@export var dashTime: float
@export var nbDashAllowed: int
@export var timeBefCanDashAgain: float
@export var timeBefReloadDash: float

@export_group("Gravity variables")
@onready var jumpGravity: float = (-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)

@export_group("Keybind variables")
@export var moveForwardAction: String = ""
@export var moveBackwardAction: String = ""
@export var moveLeftAction: String = ""
@export var moveRightAction: String = ""
@export var runAction: String = ""
@export var crouchAction: String = ""
@export var jumpAction: String = ""
@export var slideAction: String = ""
@export var dashAction: String = ""
@export var flyAction: String = ""

var moveAccel: float
var moveDeccel: float
var desiredMoveSpeed: float
var inputDirection: Vector2
var moveDirection: Vector3
var hitGroundCooldownRef: float
var lastFramePosition: Vector3
var lastFrameVelocity: Vector3
var wasOnFloor: bool
var walkOrRun: String = "WalkState" #keep in memory if play char was walking or running before being in the air
var jumpCooldownRef: float
var nbJumpsInAirAllowedRef: int
var jumpBuffOn: bool = false
var bufferedJump: bool = false
var coyoteJumpCooldownRef: float
var coyoteJumpOn: bool = false
var flyBoostOn: bool = false
var slideTimeRef: float
var timeBefCanSlideAgainRef: float
var slideBuffOn: bool = false
var dashTimeRef: float
var nbDashAllowedRef: int
var timeBefCanDashAgainRef: float
var timeBefReloadDashRef: float
var velocityPreDash: Vector3

@onready var jumpVelocity: float = (2.0 * jumpHeight) / jumpTimeToPeak
@onready var fallGravity: float = (-2.0 * jumpHeight) / (jumpTimeToFall * jumpTimeToFall)
#references variables
@onready var camHolder: Node3D = $CameraHolder
@onready var cam: Camera3D = %Camera
@onready var model: MeshInstance3D = $Model
@onready var hitbox: CollisionShape3D = $Hitbox
@onready var stateMachine: Node = $StateMachine
@onready var hud: CanvasLayer = $HUD
@onready var ceilingCheck: RayCast3D = %CeilingCheck
@onready var floorCheck: RayCast3D = %FloorCheck
@onready var slideFloorCheck: RayCast3D = %SlideFloorCheck


func _ready():
	#set move variables, and value references
	moveSpeed = walkSpeed
	moveAccel = walkAccel
	moveDeccel = walkDeccel

	hitGroundCooldownRef = hitGroundCooldown
	jumpCooldownRef = jumpCooldown
	jumpCooldown = -1.0
	nbJumpsInAirAllowedRef = nbJumpsInAirAllowed
	coyoteJumpCooldownRef = coyoteJumpCooldown
	slideTimeRef = slideTime
	timeBefCanSlideAgainRef = timeBefCanSlideAgain
	timeBefCanSlideAgain = -1.0
	timeBefCanDashAgainRef = timeBefCanDashAgain
	timeBefCanDashAgain = -1.0
	timeBefReloadDashRef = timeBefReloadDash
	timeBefReloadDash = -1.0
	nbDashAllowedRef = nbDashAllowed


func _process(delta: float):
	slideTimers(delta)

	dashTimers(delta)


func _physics_process(_delta: float):
	modifyPhysicsProperties()

	move_and_slide()


func slideTimers(delta: float):
	if timeBefCanSlideAgain > 0.0: timeBefCanSlideAgain -= delta
	else:
		#can only reset slide time when not sliding
		if stateMachine.currStateName != "Slide":
			slideTime = slideTimeRef


func dashTimers(delta: float):
	#reloads dash every *timeBefReloadDash* time, to avoid dash spamming
	#if you want to be able to spam dashes, set timeBefReloadDash to 0.0
	if nbDashAllowed < nbDashAllowedRef:
		if timeBefReloadDash > 0.0: timeBefReloadDash -= delta
		else:
			timeBefReloadDash = timeBefReloadDashRef
			nbDashAllowed += 1

	if timeBefCanDashAgain > 0.0: timeBefCanDashAgain -= delta
	else:
		#can only reset slide time when not dashing
		if stateMachine.currStateName != "Dash":
			dashTime = dashTimeRef


func modifyPhysicsProperties():
	lastFramePosition = position #get play char position every frame
	lastFrameVelocity = velocity #get play char velocity every frame
	wasOnFloor = !is_on_floor() #check if play char was on floor every frame


func gravityApply(delta: float):
	#if play char goes up, apply jump gravity
	#otherwise, apply fall gravity
	if velocity.y >= 0.0: velocity.y += jumpGravity * delta
	elif velocity.y < 0.0: velocity.y += fallGravity * delta
