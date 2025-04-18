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

extends GridMap

func destroy_block(world_coordinate: Vector3) -> void:
	var map_coordinate := local_to_map(world_coordinate)
	set_cell_item(map_coordinate, INVALID_CELL_ITEM)
	
func create_block(world_coordinate: Vector3, cell_item: int) -> void:
	var map_coordinate := local_to_map(world_coordinate)
	set_cell_item(map_coordinate, cell_item)

# Take global position of a ray cast colliding point plus/minus surface normal
# and then return adjusted global position and rotation, aligned to the grid map.
# That is used to align meshes not contained in the grid map to align with it.
func get_snapped_transform(world_coordinate: Vector3) -> Transform3D:
	var map_coordinate := local_to_map(world_coordinate)
	var local_position := map_to_local(map_coordinate)
	var global_position := to_global(local_position)
	# the grid map rotation/scale + the preview/effect mesh translation
	return Transform3D(global_transform.basis, global_position)
