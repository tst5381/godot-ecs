class_name EcsWorld
extends Node

const ERROR_NOT_EXIST = "Entity #%s does not exist.";

var _next_id: int = 0;
var _entities: Dictionary = {};
var _filters: Array[EcsFilter] = [];

signal entity_created(entity: int);
signal entity_destroyed(entity: int, components: Dictionary);
signal component_added(entity: int, component: int, value);
signal component_removed(entity: int, component: int, value);
signal component_updated(entity: int, component: int, before, after);

func get_entities() -> Array[int]:
	var array: Array[int] = [];
	array.append_array(_entities.keys());
	return array;

func get_entities_to_ref() -> Array[EcsRef]:
	var array: Array[EcsRef] = [];
	for key in _entities.keys():
		array.append(EcsRef.new(key, self));
	return array;

func create_entity() -> int:
	var id = _next_id;
	_entities[id] = {}; # dictionary as component's id-value pairs 
	_next_id += 1;
	for filter in _filters:
		filter._on_entity_created(id);
	entity_created.emit(id);
	return id;
	
func create_entity_to_ref() -> EcsRef:
	return EcsRef.new(create_entity(), self);

func destroy_entity(entity: int) -> void:
	assert(_entities.has(entity), ERROR_NOT_EXIST % entity);
	var components: Dictionary = _entities[entity];
	components.make_read_only();
	_entities.erase(entity);
	for filter in _filters:
		filter._on_entity_destroyed(entity);
	entity_destroyed.emit(entity, components);

func exist(entity: int) -> bool:
	return _entities.has(entity);

func has_component(entity: int, component: int) -> bool:
	assert(_entities.has(entity), ERROR_NOT_EXIST % entity);
	return _entities[entity].has(component);

func get_component(entity: int, component: int) -> Variant:
	assert(_entities.has(entity), ERROR_NOT_EXIST % entity);
	if _entities[entity].has(component):
		return _entities[entity][component];
	else:
		return null;

func add_component(entity: int, component: int, value: Variant) -> void:
	assert(_entities.has(entity), ERROR_NOT_EXIST % entity);
	assert(!_entities[entity].has(component)
	, "Cannot add component id '%s' since entity #%s already has one." % [component, entity])
	_entities[entity][component] = value;
	for filter in _filters:
		filter._on_component_added(entity, component, value);
	component_added.emit(entity, component, value);

func remove_component(entity: int, component: int) -> bool:
	assert(_entities.has(entity), ERROR_NOT_EXIST % entity);
	if _entities[entity].has(component):
		var value = _entities[entity][component];
		_entities[entity].erase(component);
		for filter in _filters:
			filter._on_component_removed(entity, component, value);
		component_removed.emit(entity, component, value);
		return true;
	else:
		return false;
		
func update_component(entity: int, component: int, value: Variant) -> void:
	assert(_entities.has(entity), ERROR_NOT_EXIST % entity);
	assert(_entities[entity].has(component)
	, "Cannot update component id '%s' since entity #%s doesn't have one." % [component, entity])
	if _entities[entity].has(component):
		var before = _entities[entity][component];
		_entities[entity][component] = value;
		component_updated.emit(entity, component, before, value);
