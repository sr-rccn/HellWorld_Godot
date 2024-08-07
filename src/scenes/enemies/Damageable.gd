extends Node

class_name Damageable

func _ready():
	print(get_parent().get("health"))

func hit(damage : int):
	var state_machine = $"../AnimationTree".get("parameters/playback")
	state_machine.travel("attack")
	print(state_machine.get_current_node())
	
	var health = get_parent().get("health")
	SignalBus.emit_signal("on_health_changed", get_parent(), -1 * damage)
	get_parent().set("health", health - damage)
	
	#if health <= 0 and state_machine.current != "death":
	#if health <= 0:
		#state_machine.travel("death")
		#get_parent().queue_free()
