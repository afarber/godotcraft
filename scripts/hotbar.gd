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

extends Node3D

@export var mesh_lib: MeshLibrary
@export var cell_item: int = 4

@onready var cube_container: Node3D = %CubeContainer
@onready var hotbar_camera: Camera3D = %HotbarCamera
@onready var sub_viewport: SubViewport = %SubViewport

# The array of item IDs in the mesh library
var item_ids = []

# The hotbar cube meshes
var cubes = []

# The orthogonal camera will be resized according to the number of cubes
var hotbar_camera_width
var hotbar_camera_height

# Rotation speed of the selected cube
const ROTATION_SPEED := 20

# Distance between centers of two cubes of size 2 x 2 x 2
const STEP := 4.0

func _ready():
	item_ids = mesh_lib.get_item_list()
	hotbar_camera_width = item_ids.size() * STEP
	hotbar_camera_height = hotbar_camera_width / sub_viewport.size.aspect()
	# The orthogonal camera "size" by default is same as its height
	hotbar_camera.size = hotbar_camera_height
	display_hotbar_cubes()
	# Emit the signal with 1s delay, so that TabLabel is ready in world.tscn
	await get_tree().create_timer(1.0).timeout
	Signals.selected_hotbar_item.emit(cell_item)

func _process(delta: float) -> void:
	var cube_instance = cubes[cell_item]
	cube_instance.rotation_degrees.y += delta * ROTATION_SPEED

func display_hotbar_cubes():
	# Start from the left edge of the camera
	var left_x = -hotbar_camera_width / 2
	var cube_y = hotbar_camera_height / 2- 2 * STEP / 3;

	for i in range(item_ids.size()):
		var cube_mesh = mesh_lib.get_item_mesh(item_ids[i])
		if cube_mesh is Mesh:
			var cube_x = left_x + (i + 0.5) * STEP
			var cube_instance = MeshInstance3D.new()
			cube_instance.mesh = cube_mesh
			cube_instance.scale = Vector3(1.0, 1.0, 1.0)
			cube_instance.position = Vector3(cube_x, cube_y, 0)
			cube_instance.layers = 2
			cube_container.add_child(cube_instance)
			cubes.append(cube_instance)
			#print("cube_instance.position: ", cube_instance.position)

	highlight_selected()

func highlight_selected() -> void:
	for i in range(len(cubes)):
		var cube_instance = cubes[i]
		cube_instance.rotation_degrees.x = 5
		cube_instance.rotation_degrees.y = 10
		cube_instance.rotation_degrees.z = 15
		cube_instance.scale = Vector3(1.0, 1.0, 1.0)

		if i == cell_item:
			# Enlarge selected cube
			cube_instance.scale = Vector3(1.5, 1.5, 1.5)

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("tab"):
		cell_item = wrapi(cell_item + 1, 0, cubes.size())
		Signals.selected_hotbar_item.emit(cell_item)
		highlight_selected()

# The hotbar scene children are a mix of Control and Node3D
# and thus they all need to be shown or hidden individually

func hide_with_children() -> void:
	hide()
	for c in get_children():
		c.hide()

func show_with_children() -> void:
	show()
	for c in get_children():
		c.show()
