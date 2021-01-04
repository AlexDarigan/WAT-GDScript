extends Node
tool

signal finished
var context

func launch(tests: Array) -> void:
	context = EditorLaunch.new() if Engine.is_editor_hint() else GameLaunch.new()
	context.connect("finished", self, "_on_launch_finished")
	add_child(context)
	context.launch(tests)
	
func _on_launch_finished() -> void:
	context.queue_free()
	emit_signal("finished")
	
class EditorLaunch extends Node:
	signal finished
	const TestRunner: String = "res://addons/WAT/core/test_runner/TestRunner.tscn"
	var editor
	
	func launch(tests: Array) -> void:
		var instance = load(TestRunner).instance()
		instance.tests = tests
		var scene = PackedScene.new()
		scene.pack(instance)
		ResourceSaver.save(TestRunner, scene)
		editor = ClassDB.instance("EditorPlugin").get_editor_interface()
		editor.reload_scene_from_path(TestRunner)
		editor.play_custom_scene(TestRunner)
	
	func _process(delta: float) -> void:
		if _is_done():
			_reset()

			
	func _is_done() -> bool:
		return editor != null and not editor.is_playing_scene()
		
	func _reset() -> void:
		var instance = load(TestRunner).instance()
		# We want to make sure we clear the testrunner after each run 
		# ..especially when dealing with exported tests
		instance.tests = []
		var scene = PackedScene.new()
		scene.pack(instance)
		ResourceSaver.save(TestRunner, scene)
		editor = ClassDB.instance("EditorPlugin").get_editor_interface()
		editor.reload_scene_from_path(TestRunner)
		emit_signal("finished")
	
class GameLaunch extends Node:
	signal finished
	const TestRunner: String = "res://addons/WAT/core/test_runner/TestRunner.tscn"
	
	func launch(tests: Array) -> void:
		var instance = load(TestRunner).instance()
		instance.is_editor = false
		instance.tests = tests
		instance.connect("finished", self, "emit_signal", ["finished"])
		add_child(instance)
