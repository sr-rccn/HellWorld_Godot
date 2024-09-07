extends Area2D
var simultaneous_scene = preload("res://src/scenes/scenarios/Level2.tscn").instantiate()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	print(body)
	print(body.name.contains("Kara"))
	#if body.name.contains("Kara"):
		#get_tree().change_scene_to_file("res://src/scenes/scenarios/Level2.tscn")
		#get_tree().root.add_child(simultaneous_scene)


