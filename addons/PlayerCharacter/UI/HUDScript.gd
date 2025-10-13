extends CanvasLayer

class_name HUD

#label references variables
@onready var currentStateLT = %CurrentStateLabelText
@onready var desiredMoveSpeedLT = %DesiredMoveSpeedLabelText
@onready var velocityLT = %VelocityLabelText
@onready var nbJumpsInAirAllowedLT = %NbJumpsInAirAllowedLabelText
@onready var framesPerSecondLT = %FramesPerSecondLabelText

func _process(_delta):
	displayCurrentFPS()
	
func displayCurrentState(currentState : String):
	currentStateLT.set_text(str(currentState))
	
func displayDesiredMoveSpeed(desiredMoveSpeed : float):
	desiredMoveSpeedLT.set_text(str(desiredMoveSpeed))
	
func displayVelocity(velocity : float):
	velocityLT.set_text(str(velocity))
	
func displayNbJumpsInAirAllowed(nbJumpsInAirAllowed : int):
	nbJumpsInAirAllowedLT.set_text(str(nbJumpsInAirAllowed))
	
func displayCurrentFPS():
	framesPerSecondLT.set_text(str(Engine.get_frames_per_second()))
	
	
	
	
	
