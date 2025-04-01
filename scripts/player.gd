# MIT License
# 
# Copyright (c) 2025 Alexander Farber
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends CharacterBody3D

const SPEED := 8.0
const JUMP_VELOCITY := 12.0
const GRAVITY_FACTOR := 2.5
const SENSITIVITY := 0.002

const BOB_FREQ := 2.4
const BOB_AMP := 0.08

var t_bob := 0.0
var selected_index := 0

@onready var head: Node3D = $Head
@onready var main_camera: Camera3D = $Head/MainCamera
@onready var ray_cast: RayCast3D = $Head/MainCamera/RayCast3D
@onready var hotbar: Node3D = $Hotbar

func _enter_tree() -> void:
	Signals.selected_mesh_lib_index.connect(selected_mesh_lib_index)

func selected_mesh_lib_index(index:int):
	selected_index = index

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		# The hotbar scene children are a mix of Control and Node3D
		# and thus they need to be shown or hidden individually
		if hotbar.visible:
			hotbar.hide_with_children()
		else:
			hotbar.show_with_children()

func _unhandled_input(event: InputEvent) -> void:
	# Disable camera movement when hotbar is visible
	if hotbar.visible:
		return

	if event is InputEventMouseMotion:
		rotation.y = rotation.y - event.relative.x * SENSITIVITY
		main_camera.rotation.x = main_camera.rotation.x - event.relative.y * SENSITIVITY
		main_camera.rotation.x = clamp(main_camera.rotation.x, deg_to_rad(-70), deg_to_rad(80))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += GRAVITY_FACTOR * get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration
	# But only move if the 3D hotbar is not visible
	if not hotbar.visible:
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		velocity.x = direction.x * SPEED if direction else 0
		velocity.z = direction.z * SPEED if direction else 0

	# Handle mouse clicks
	if Input.is_action_just_pressed("left_click"):
		if hotbar.visible:
			hotbar.hide_with_children()
		elif ray_cast.is_colliding():
			if ray_cast.get_collider().has_method("destroy_block"):
				# get the coordinate inside of the touched block, by subtracting its normal
				ray_cast.get_collider().destroy_block(ray_cast.get_collision_point() - 
														ray_cast.get_collision_normal())

	elif Input.is_action_just_pressed("right_click"):
		if hotbar.visible:
			hotbar.hide_with_children()
		elif ray_cast.is_colliding():
			if ray_cast.get_collider().has_method("create_block"):
				# get the coordinate outside of the touched block, by adding its normal
				ray_cast.get_collider().create_block(ray_cast.get_collision_point() + 
														ray_cast.get_collision_normal(), selected_index)

	move_and_slide()

func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
