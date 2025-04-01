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

# The array of item IDs in the mesh library
var item_ids = []

# The hotbar cube meshes
var cubes = []

func _ready():
	Signals.selected_hotbar_item.emit(cell_item)
	item_ids = mesh_lib.get_item_list()
	display_hotbar_cubes()

func display_hotbar_cubes():
	print("hotbar_camera.size: ", hotbar_camera.size)
	print("hotbar_camera.transform: ", hotbar_camera.transform)
	print("cube_container.transform: ", cube_container.transform)

	# Effective size of scaled cube (2x2x2 * 0.5)
	var cube_size = 1.0
	var total_cube_width = item_ids.size() * cube_size
	var hotbar_width = hotbar_camera.size
	# Start from the left edge of the camera
	var start_x = -hotbar_width / 2.0
	var step = cube_size

	for i in range(item_ids.size()):
		var cube_mesh = mesh_lib.get_item_mesh(item_ids[i])
		if cube_mesh is Mesh:
			var cube_instance = MeshInstance3D.new()
			cube_instance.mesh = cube_mesh
			cube_instance.scale = Vector3(0.5, 0.5, 0.5)

			# Calculate cube's x position relative to the camera center
			# Center cubes in their slots
			var cube_x = start_x + (i + 0.5) * step
			# Position relative to camera
			cube_instance.position = Vector3(cube_x, 0, 0)

			cube_instance.layers = 2
			cube_instance.rotate_x(5)
			cube_instance.rotate_y(10)
			cube_instance.rotate_z(15)
			cube_container.add_child(cube_instance)
			cubes.append(cube_instance)
			print("cube_instance.position: ", cube_instance.position)

	highlight_selected()


func highlight_selected() -> void:
	for i in range(len(cubes)):
		if i == cell_item:
			# Enlarge selected cube
			cubes[i].scale = Vector3(0.7, 0.7, 0.7)
		else:
			# Back to default size
			cubes[i].scale = Vector3(0.5, 0.5, 0.5)

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_left"):
		cell_item = wrapi(cell_item - 1, 0, cubes.size())
		Signals.selected_hotbar_item.emit(cell_item)
		highlight_selected()
	elif event.is_action_pressed("ui_right"):
		cell_item = wrapi(cell_item + 1, 0, cubes.size())
		Signals.selected_hotbar_item.emit(cell_item)
		highlight_selected()

# The hotbar scene children are a mix of Control and Node3D
# and thus they need to be shown or hidden individually

func hide_with_children() -> void:
	hide()
	for c in get_children():
		c.hide()

func show_with_children() -> void:
	show()
	for c in get_children():
		c.show()
