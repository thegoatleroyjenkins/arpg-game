class_name EnemyState
extends RefCounted

# Base class for enemy states
var enemy: CharacterBody2D

func _init(e: CharacterBody2D):
	enemy = e

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass
