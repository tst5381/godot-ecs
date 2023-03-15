class_name EcsFilter
extends Object

var _world: EcsWorld = null;
var _includes: Array[StringName] = [];
var _excludes: Array[StringName] = [];
var _entities_matched: Dictionary = {};

# call this before freeing the object
func reset():
	if _world != null:
		_world._filters.erase(self);
		_world = null;
	_includes.clear();
	_excludes.clear();
	_entities_matched.clear();

func has_target() -> bool:
	return _world != null;

func set_target(world: EcsWorld) -> EcsFilter:
	assert(world != null, "Provided filter target is null.");
	assert(_world == null, "Filter target is already set.")
	assert(_includes.size() + _excludes.size() > 0
	, "Filter must have at least one condition.")
	_world = world;
	_world._filters.append(self);
	_entities_matched.clear();
	for entity in _world.get_entities():
		if is_matched(entity):
			_entities_matched[entity] = null;
	return self;

func include(component: StringName) -> EcsFilter:
	assert(_world == null, "Cannot add conditions after setting a target.");
	assert(not _excludes.has(component), "Filter already excludes component %s." % component);
	if not _includes.has(component):
		_includes.append(component);
	return self;

func exclude(component: StringName) -> EcsFilter:
	assert(_world == null, "Cannot add conditions after setting a target.");
	assert(not _includes.has(component), "Filter already includes component %s." % component);
	if not _excludes.has(component):
		_excludes.append(component);
	return self;

func get_matched_entities() -> Array[int]:
	var array: Array[int] = [];
	array.append_array(_entities_matched.keys());
	return array;

func get_matched_entities_to_ref() -> Array[EcsRef]:
	var array: Array[EcsRef] = [];
	for key in _entities_matched.keys():
		array.append(EcsRef.new(key, _world));
	return array;

func get_matched_size() -> int:
	return _entities_matched.size();

func is_matched(entity: int) -> bool:
	assert(_world != null, "Filter target is not set.");
	for component in _includes:
		if not _world.has_component(entity, component):
			return false;
	for component in _excludes:
		if _world.has_component(entity, component):
			return false;
	return true;

func _on_entity_created(entity: int):
	if not _entities_matched.has(entity) && is_matched(entity):
		_join(entity);

func _on_entity_destroyed(entity: int):
	if _entities_matched.has(entity):
		_kick(entity);

func _on_component_added(entity: int, _component: StringName, _value: Variant):
	if not _entities_matched.has(entity) && is_matched(entity):
		_join(entity);
	elif _entities_matched.has(entity) && not is_matched(entity):
		_kick(entity);

func _on_component_removed(entity: int, _component: StringName, _value: Variant):
	if not _entities_matched.has(entity) && is_matched(entity):
		_join(entity);
	elif _entities_matched.has(entity) && not is_matched(entity):
		_kick(entity);

func _join(entity: int):
	assert(not _entities_matched.has(entity));
	_entities_matched[entity] = null; # only the key is needed.
	## print("entity #%s is joined." % entity);

func _kick(entity: int):
	assert(_entities_matched.has(entity));
	_entities_matched.erase(entity);
	## print("entity #%s is kicked." % entity);
