extends Node

class_name Damageable

#@export var health : float = 0:
	#get:
		#return get_parent().get("health")
	#set(value):
		#SignalBus.emit_signal("on_health_changed", get_parent(), value - health)
		#get_parent().set("health", health)
		#health = value

func _ready():
	print(get_parent().get("health"))

func hit(damage : int):
	var state_machine = $"../AnimationTree".get("parameters/playback")
	print(state_machine.get_current_node())
	
	var health = get_parent().get("health")
	SignalBus.emit_signal("on_health_changed", get_parent(), -1 * damage)
	get_parent().set("health", health - damage)
	
	#if health <= 0 and state_machine.current != "death":
	#if health <= 0:
		#state_machine.travel("death")
		#get_parent().queue_free()
