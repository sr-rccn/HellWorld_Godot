extends Area2D

#@onready var animation_tree = $AnimationTree
@onready var state_machine = $"../AnimationTree".get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	#var state_machine = $"../AnimationTree".get("parameters/playback")
	if body.name.contains("Kara"):
		get_parent().set("attacking", true)

func _on_body_exited(body):
	get_parent().set("attacking", false)
