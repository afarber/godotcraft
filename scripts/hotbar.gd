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
@export var cube_spacing: float = 2.5
@export var selected_index: int = 4

@onready var cube_container: Node3D = %CubeContainer

# The array of item IDs in the mesh library
var item_ids = []

# The hotbar cube meshes
var cubes = []

func _ready():
	Signals.selected_mesh_lib_index.emit(selected_index)
	item_ids = mesh_lib.get_item_list()
	display_hotbar_cubes()

func display_hotbar_cubes():
	for i in range(item_ids.size()):
		var cube_mesh = mesh_lib.get_item_mesh(item_ids[i])  # Get mesh using item ID
		if cube_mesh:
			var cube_instance = MeshInstance3D.new()
			cube_instance.mesh = cube_mesh
			cube_instance.scale = Vector3(0.5, 0.5, 0.5)  # Make cubes smaller
			cube_instance.position = Vector3(i * cube_spacing, 0, 0)  # Position in a line
			cube_instance.layers = 2  # Ensure it's rendered by your second camera
			cube_instance.rotate_x(5)
			cube_instance.rotate_y(10)
			cube_instance.rotate_z(15)
			cube_container.add_child(cube_instance)
			cubes.append(cube_instance)

	highlight_selected()

func highlight_selected() -> void:
	for i in range(len(cubes)):
		if i == selected_index:
			# Enlarge selected cube
			cubes[i].scale = Vector3(0.7, 0.7, 0.7)
		else:
			# Back to default size
			cubes[i].scale = Vector3(0.5, 0.5, 0.5)

func hide_with_children() -> void:
	hide()
	for c in get_children():
		c.hide()

func show_with_children() -> void:
	show()
	for c in get_children():
		c.show()

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_left"):
		selected_index = wrapi(selected_index - 1, 0, cubes.size())
		Signals.selected_mesh_lib_index.emit(selected_index)
		highlight_selected()
	elif event.is_action_pressed("ui_right"):
		selected_index = wrapi(selected_index + 1, 0, cubes.size())
		Signals.selected_mesh_lib_index.emit(selected_index)
		highlight_selected()
