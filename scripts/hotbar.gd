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

@export var cube_spacing: float = 2.5  # Spacing between cubes
@export var selected_index: int = 4  # Default selected item

@onready var cube_container: Node3D = %CubeContainer

var cubes = []  # Stores hotbar cube instances

func _ready():
	display_hotbar_cubes()

func display_hotbar_cubes():
	var item_ids = mesh_lib.get_item_list()  # Get array of item IDs
	var cube_count = item_ids.size()  # Count the number of items

	for i in range(cube_count):
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
			cube_container.add_child(cube_instance)  # Add to CubeContainer
			cubes.append(cube_instance)

	highlight_selected()

func highlight_selected():
	for i in range(len(cubes)):
		if i == selected_index:
			cubes[i].scale = Vector3(0.7, 0.7, 0.7)  # Enlarge selected cube
		else:
			cubes[i].scale = Vector3(0.5, 0.5, 0.5)  # Default size
