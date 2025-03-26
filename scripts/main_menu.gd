extends Node3D

@onready var camera_pivot: Node3D = $CameraPivot

const ROTATION_SPEED = 2

func _process(delta: float) -> void:
	camera_pivot.rotation_degrees.y += delta * ROTATION_SPEED
