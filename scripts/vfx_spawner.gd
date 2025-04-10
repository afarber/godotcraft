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
# This script is autloaded as VfxSpawner

enum Keys {
	CubeDestroyVfx,
	CubeCreateVfx
}

const SCENE_PACKED: Dictionary[int, PackedScene] = {
	Keys.CubeDestroyVfx : preload("res://scenes/cube_destroy_vfx.tscn"),
	Keys.CubeCreateVfx : preload("res://scenes/cube_create_vfx.tscn")
}

func _ready() -> void:
	Signals.spawn_vfx.connect(spawn_vfx)

func spawn_vfx(scene:PackedScene, tform:Transform3D, ttl:int = 0):
	var vfx := scene.instantiate()
	vfx.global_transform = tform
	
	for c in vfx.get_children():
		if c is GPUParticles3D:
			c.emitting = true

	# If time to live in seconds is set
	if ttl > 0:
		get_tree().create_timer(ttl, false).timeout.connect(vfx.queue_free)
