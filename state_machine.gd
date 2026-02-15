class_name StateMachine
extends RefCounted

var states: Dictionary = {}
var current_state: EnemyState = null
var enemy: CharacterBody2D

func _init(e: CharacterBody2D):
	enemy = e

func add_state(state_name: String, state: EnemyState):
	states[state_name] = state

func change_state(new_state_name: String):
	if current_state:
		current_state.exit()
	
	if states.has(new_state_name):
		current_state = states[new_state_name]
		current_state.enter()

func update(delta: float):
	if current_state:
		current_state.update(delta)

func physics_update(delta: float):
	if current_state:
		current_state.physics_update(delta)
