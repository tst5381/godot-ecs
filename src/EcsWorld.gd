class_name EcsWorld
extends Node

const ERROR_NOT_EXIST = "Entity #%s does not exist.";
const ERROR_ADD = "Cannot add component id '%s' since entity #%s already has one.";
const ERROR_UPDATE = "Cannot update component id '%s' since entity #%s doesn't have one.";

signal entity_created(entity: int);
signal entity_destroyed(entity: int, components: Dictionary);
signal component_added(entity: int, component: StringName, value);
signal component_removed(entity: int, component: StringName, value);
signal component_updated(entity: int, component: StringName, before, after);

var _next_id: int = 0;
var _component_pools: Dictionary = {};
var _exist_list: Array[bool] = [];
var _filters: Array[EcsFilter] = [];
var _systems: Array[EcsSystem] = [];

func add_system(system: EcsSystem):
	if not _systems.has(system): _systems.append(system);

func remove_system(system: EcsSystem):
	if _systems.has(system): _systems.erase(system);

func get_entities() -> Array[int]:
	var array: Array[int] = [];
	for id in len(_exist_list):
		if _exist_list[id] == true:
			array.append(id);
	return array;

func get_entities_to_ref() -> Array[EcsRef]:
	var array: Array[EcsRef] = [];
	for id in len(_exist_list):
		if _exist_list[id] == true:
			array.append(EcsRef.new(id, self));
	return array;

func create_entity() -> int:
	var id = _next_id;
	_exist_list.append(true);
	_next_id += 1;
	assert(_next_id == _exist_list.size());
	for filter in _filters:
		filter._on_entity_created(id);
	entity_created.emit(id);
	return id;

func create_entity_to_ref() -> EcsRef:
	return EcsRef.new(create_entity(), self);

func destroy_entity(entity: int) -> void:
	assert(exist(entity), ERROR_NOT_EXIST % entity);
	var components: Dictionary = {};
	for component in _component_pools.keys():
		var pool = _component_pools[component];
		if pool.has(entity):
			components[component] = pool[entity];
			pool.erase(entity);
	components.make_read_only();
	_exist_list[entity] = false;
	for filter in _filters:
		filter._on_entity_destroyed(entity);
	entity_destroyed.emit(entity, components);

func exist(entity: int) -> bool:
	if entity >= 0 && entity < _exist_list.size() : 
		return _exist_list[entity];
	else: 
		return false;

func has_component(entity: int, component: StringName) -> bool:
	assert(exist(entity), ERROR_NOT_EXIST % entity);
	return _get_component_pool(component).has(entity);

func get_component(entity: int, component: StringName) -> Variant:
	assert(exist(entity), ERROR_NOT_EXIST % entity);
	var pool = _get_component_pool(component);
	return pool.get(entity, null);

func add_component(entity: int, component: StringName, value: Variant) -> void:
	assert(exist(entity), ERROR_NOT_EXIST % entity);
	var pool = _get_component_pool(component);
	assert(not pool.has(entity), ERROR_ADD % [component, entity]);
	pool[entity] = value;
	for filter in _filters:
		filter._on_component_added(entity, component, value);
	for system in _systems:
		if system.observe_add && system.is_observing(component):
			system.on_added(entity, component, value);
	component_added.emit(entity, component, value);

func remove_component(entity: int, component: StringName) -> bool:
	assert(exist(entity), ERROR_NOT_EXIST % entity);
	var pool = _get_component_pool(component);
	if pool.has(entity):
		var value = pool[entity];
		pool.erase(entity);
		for filter in _filters:
			filter._on_component_removed(entity, component, value);
		for system in _systems:
			if system.observe_remove && system.is_observing(component):
				system.on_removed(entity, component, value);
		component_removed.emit(entity, component, value);
		return true;
	else:
		return false;

func update_component(entity: int, component: StringName, value: Variant) -> void:
	assert(exist(entity), ERROR_NOT_EXIST % entity);
	var pool = _get_component_pool(component);
	assert(pool.has(entity), ERROR_UPDATE % [component, entity]);
	var before = pool[entity];
	pool[entity] = value;
	for system in _systems:
		if system.observe_update && system.is_observing(component):
			system.on_updated(entity, component, before, value);
	component_updated.emit(entity, component, before, value);

func get_component_pool_copy(component: StringName) -> Dictionary:
	var copy = _get_component_pool(component).duplicate();
	copy.make_read_only();
	return copy;

func _get_component_pool(component: StringName) -> Dictionary:
	var pool = _component_pools.get(component, null);
	if pool != null: return pool;
	else:
		_component_pools[component] = {};
		return _component_pools[component];
