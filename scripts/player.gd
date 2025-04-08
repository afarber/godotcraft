# MIT License
# 
# Copyright (c) 2023 LegionGames
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

const JUMP_VELOCITY := 6.4
const SENSITIVITY := 0.004
const WALK_SPEED := 5.0
const SPRINT_SPEED := 8.0
var speed := WALK_SPEED

# Head bob
const BOB_FREQ := 2.4
const BOB_AMP := 0.08
var head_bob_time := 0.0

# Field of view
const BASE_FOV := 75.0
const FOV_CHANGE := 1.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# The item selected in the grid map
var cell_item := GridMap.INVALID_CELL_ITEM

@onready var head: Node3D = $Head
@onready var main_camera: Camera3D = $Head/MainCamera
@onready var ray_cast: RayCast3D = $Head/MainCamera/RayCast3D
@onready var destroy_preview: MeshInstance3D = $DestroyPreview
@onready var create_preview: MeshInstance3D = $CreatePreview

func _enter_tree() -> void:
	Signals.selected_hotbar_item.connect(selected_hotbar_item)

func selected_hotbar_item(index:int):
	cell_item = index

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		main_camera.rotate_x(-event.relative.y * SENSITIVITY)
		main_camera.rotation.x = clamp(main_camera.rotation.x, deg_to_rad(-70), deg_to_rad(80))

func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle Sprint
	speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	# Head bob
	head_bob_time += delta * velocity.length() * float(is_on_floor())
	main_camera.transform.origin = headbob(head_bob_time)

	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	main_camera.fov = lerp(main_camera.fov, target_fov, delta * 8.0)

	# Handle mouse clicks
	if Input.is_action_just_pressed("left_click"):
		if ray_cast.is_colliding():
			var target = ray_cast.get_collider()
			if target.has_method("destroy_block"):
				var destroy_pos = ray_cast.get_collision_point() - ray_cast.get_collision_normal()
				target.destroy_block(destroy_pos)

	elif Input.is_action_just_pressed("right_click"):
		if ray_cast.is_colliding():
			var target = ray_cast.get_collider()
			if target.has_method("create_block"):
				var create_pos = ray_cast.get_collision_point() + ray_cast.get_collision_normal()
				target.create_block(create_pos, cell_item)

	# Handle previews
	if ray_cast.is_colliding():
		var pos = ray_cast.get_collision_point()
		var normal = ray_cast.get_collision_normal()
		var target = ray_cast.get_collider()

		if target is GridMap:
			var grid_map := target as GridMap

			# Create preview
			if grid_map.has_method("create_block"):
				var create_pos = pos + normal
				var create_world_pos = grid_map.get_snapped_position(create_pos)
				create_preview.global_transform.origin = create_world_pos
				create_preview.visible = true
			else:
				create_preview.visible = false

			# Destroy preview
			if grid_map.has_method("destroy_block"):
				var destroy_pos = pos - normal
				var destroy_world_pos = grid_map.get_snapped_position(destroy_pos)
				destroy_preview.global_transform.origin = destroy_world_pos
				destroy_preview.visible = true
			else:
				destroy_preview.visible = false
	else:
		create_preview.visible = false
		destroy_preview.visible = false

	move_and_slide()

func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
