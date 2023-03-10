class_name EcsSystem
extends Node

var _target_component : int;
var _observe_add: bool;
var _observe_remove: bool;
var _observe_update: bool;

func _init(component: int, observe_add: bool, observe_remove: bool, observe_update: bool):
	_target_component = component;
	_observe_add = observe_add;
	_observe_remove = observe_remove;
	_observe_update = observe_update;

func include(world : EcsWorld):
	if _observe_add:
		world.component_added.connect(_on_component_added);
	if _observe_remove:
		world.component_removed.connect(_on_component_removed);
	if _observe_update:
		world.component_updated.connect(_on_component_updated);

func exclude(world : EcsWorld):
	if _observe_add:
		world.component_added.disconnect(_on_component_added);
	if _observe_remove:
		world.component_removed.disconnect(_on_component_removed);
	if _observe_update:
		world.component_updated.disconnect(_on_component_updated);

func _on_component_added(entity: int, component: int, value):
	if component == _target_component:
		_on_target_added(entity, component, value);

func _on_component_removed(entity: int, component: int, value):
	if component == _target_component:
		_on_target_removed(entity, component, value);

func _on_component_updated(entity: int, component: int, before, after):
	if component == _target_component:
		_on_target_updated(entity, component, before, after);

func _on_target_added(entity: int, component: int, value):
	print("component id '%s' value = '%s' is added to entity #%s" % [component, value, entity]);
	return;

func _on_target_removed(entity: int, component: int, value):
	print("component id '%s' value = '%s' is removed from entity #%s" % [component, value, entity]);
	return;

func _on_target_updated(entity: int, component: int, before, after):
	print("component id '%s' value is updated from '%s' to '%s' on entity #%s" % [component, before, after, entity]);
	return;
