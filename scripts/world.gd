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
@onready var panel_container: PanelContainer = $PanelContainer
@onready var grid_container: GridContainer = %GridContainer
@onready var tab_label: Label = %TabLabel
@onready var fps_label: Label = %FpsLabel

# _ready() is run in the game and in the editor
func _ready() -> void:
	Signals.selected_hotbar_item.connect(selected_hotbar_item)
	generate_item_previews()

func selected_hotbar_item(index:int):
	# Do not change the label text in the editor, because of git
	if not Engine.is_editor_hint():
		tab_label.text = "TAB: " + str(index + 1)

func _process(delta: float) -> void:
	# Do not change the label text in the editor, because of git
	if not Engine.is_editor_hint():
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

# _input(), _unhandled_input() , _process() never run in editor
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Signals.change_scene.emit(SceneChanger.Keys.MainMenu)
	elif event.is_action_pressed("inventory_2d"):
		panel_container.visible = !panel_container.visible

func generate_item_previews():
	print("generate_item_previews Engine.is_editor_hint(): ", Engine.is_editor_hint())

	# Remove previous previews if any
	for c in grid_container.get_children():
		grid_container.remove_child(c)

	for item_id in grid_map.mesh_library.get_item_list():
		# print("generating preview texture for item_id: ", item_id)
		var preview := grid_map.mesh_library.get_item_preview(item_id)
		if preview is Texture2D:
			var text_rect := TextureRect.new()
			text_rect.texture = preview
			text_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			grid_container.add_child(text_rect)
