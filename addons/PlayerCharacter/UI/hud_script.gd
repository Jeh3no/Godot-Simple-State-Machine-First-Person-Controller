extends CanvasLayer

class_name HUD

#player character reference variable
@export var play_char : PlayerCharacter

#label references variables
@onready var current_state_label_text: Label = %CurrentStateLabelText
@onready var desired_move_speed_label_text: Label = %DesiredMoveSpeedLabelText
@onready var velocity_label_text: Label = %VelocityLabelText
@onready var velocity_vector_label_text : Label = %VelocityVectorLabelText
@onready var ceiling_check_label_text: Label = %CeilingCheckLabelText
@onready var jump_buffer_label_text: Label = %JumpBufferLabelText
@onready var coyote_time_label_text: Label = %CoyoteTimeLabelText
@onready var nb_jumps_in_air_allowed_label_text: Label = %NbJumpsInAirAllowedLabelText
@onready var jump_cooldown_label_text: Label = %JumpCooldownLabelText
@onready var slide_time_label_text: Label = %SlideTimeLabelText
@onready var slide_cooldown_label_text: Label = %SlideCooldownLabelText
@onready var nb_dashs_allowed_label_text: Label = %NbDashsAllowedLabelText
@onready var dash_cooldown_label_text: Label = %DashCooldownLabelText
@onready var frames_per_second_label_text: Label = %FramesPerSecondLabelText
@onready var camera_rotation_label_text: Label = %CameraRotationLabelText
@onready var current_fov_label_text: Label = %CurrentFOVLabelText
@onready var camera_bob_vertical_offset_label_text: Label = %CameraBobVerticalOffsetLabelText
@onready var speed_lines_container: ColorRect = %SpeedLinesContainer

func _process(_delta : float) -> void:
	display_current_FPS()
	
	display_properties()
	
func display_properties() -> void:
	#player character properties
	current_state_label_text.set_text(str(play_char.stateMachine.currStateName))
	desired_move_speed_label_text.set_text(str(play_char.desiredMoveSpeed))
	velocity_label_text.set_text(str(play_char.velocity.length()))
	velocity_vector_label_text.set_text(str(play_char.velocity))
	ceiling_check_label_text.set_text(str(play_char.ceilingCheck.is_colliding()))
	jump_buffer_label_text.set_text(str(play_char.jumpBuffOn))
	coyote_time_label_text.set_text(str(play_char.coyoteJumpCooldown))
	nb_jumps_in_air_allowed_label_text.set_text(str(play_char.nbJumpsInAirAllowed))
	jump_cooldown_label_text.set_text(str(play_char.jumpCooldown))
	slide_time_label_text.set_text(str(play_char.slideTime))
	slide_cooldown_label_text.set_text(str(play_char.timeBefCanSlideAgain))
	nb_dashs_allowed_label_text.set_text(str(play_char.nbDashAllowed))
	dash_cooldown_label_text.set_text(str(play_char.timeBefCanDashAgain))
	
	#camera properties
	camera_rotation_label_text.set_text(str(play_char.cam.rotation))
	current_fov_label_text.set_text(str(play_char.cam.fov))
	camera_bob_vertical_offset_label_text.set_text(str(play_char.cam.v_offset))
	
func display_current_FPS() -> void:
	frames_per_second_label_text.set_text(str(Engine.get_frames_per_second()))
	
func displaySpeedLines(value : bool) -> void:
	speed_lines_container.visible = value
	
	
	
	
	
	
