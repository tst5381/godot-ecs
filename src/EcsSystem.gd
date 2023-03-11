class_name EcsSystem
extends Node

@export var world: EcsWorld;
@export var observe_add: bool;
@export var observe_remove: bool;
@export var observe_update: bool;

func _ready():
	if world != null: world.add_system(self);

# override to react to specific component events.
func is_observing(_component: int) -> bool:
	return false;

# override to do things on event.
func on_added(_entity: int, _component: int, _value):
	pass;

# override to do things on event.
func on_removed(_entity: int, _component: int, _value):
	pass;

# override to do things on event.
func on_updated(_entity: int, _component: int, _before, _after):
	pass;
