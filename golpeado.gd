extends RigidBody2D

func _ready():
	pass

func  _process(delta):
	pass

func _on_area_2d_area_entered(area):
	if area.is_in_group("Hit"):
		print("hit!!!!")
	else:
		pass # Replace with function body.
