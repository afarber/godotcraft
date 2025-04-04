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

@tool
extends Node3D

@onready var grid_map: GridMap = $GridMap
@onready var grid_container: GridContainer = %GridContainer

@export var generate_previews: bool = false:
	set(value):
		print("generate_previews value: ", value)
		generate_previews = value
		if value:
			generate_item_previews()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneManager.change_scene(SceneManager.Keys.MainMenu)

func generate_item_previews():
	print("Engine.is_editor_hint(): ", Engine.is_editor_hint())
	if not Engine.is_editor_hint():
		return

	# Remove previous previews if any
	grid_container.clear()

	for item_id in grid_map.mesh_library.get_item_list():
		print("item_id: ", item_id)
		var preview := grid_map.mesh_library.get_item_preview(item_id)
		if preview is Texture2D:
			var tex_rect := TextureRect.new()
			tex_rect.texture = preview
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			grid_container.add_child(tex_rect)
