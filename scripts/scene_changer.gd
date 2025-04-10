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

extends Node
# This script is autloaded as SceneChanger

enum Keys {
	MainMenu,
	World
}

const SCENE_PATHS: Dictionary[int, String] = {
	Keys.MainMenu : "res://scenes/main_menu.tscn",
	Keys.World : "res://scenes/world.tscn"
}

func _ready() -> void:
	Signals.change_scene.connect(change_scene)

func change_scene(key: Keys) -> void:
	var scene_path: String = SCENE_PATHS[key]
	var packed_scene = load(scene_path) as PackedScene
	if packed_scene:
		get_tree().change_scene_to_packed(packed_scene)

		var mouse_mode = Input.MOUSE_MODE_VISIBLE if key == Keys.MainMenu else Input.MOUSE_MODE_CAPTURED
		Input.set_mouse_mode(mouse_mode)
	else:
		printerr("Could not load scene at path: ", scene_path)
