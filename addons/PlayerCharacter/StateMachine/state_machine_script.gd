extends Node

@export var initialState : State

var currState : State
var currStateName  : String
var states : Dictionary = {}

@onready var play_char : CharacterBody3D = $".."

signal change_fov

func _ready() -> void:
	#get all the state childrens
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_state_child_transition)
			
	#if initial state, transition to it
	if initialState:
		initialState.enter(play_char)
		currState = initialState
		currStateName = currState.stateName
		
func _process(delta : float) -> void:
	if currState: currState.update(delta)
	
func _physics_process(delta: float) -> void:
	if currState: currState.physics_update(delta)
	
func on_state_child_transition(state : State, newStateName : String) -> void:
	#manage the transition from one state to another
	
	if state != currState: return
	
	var newState = states.get(newStateName.to_lower())
	if !newState: return
	
	#exit the current state
	if currState: currState.exit()
	
	#enter the new state
	newState.enter(play_char)
	
	currState = newState
	currStateName = currState.stateName
	
	emit_signal("change_fov")
