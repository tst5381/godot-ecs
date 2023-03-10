class_name EcsFilter
extends Object

var _world: EcsWorld = null;
var _condition_with: Array[int] = [];
var _condition_without: Array[int] = [];
var _entities_matched: Dictionary = {};

# call this before freeing the object
func reset():
	if _world != null:
		_world._filters.erase(self);
		_world = null;
	_condition_with.clear();
	_condition_without.clear();
	_entities_matched.clear();

func has_target() -> bool:
	return _world != null;

func set_target(world: EcsWorld) -> EcsFilter:
	assert(world != null, "Provided filter target is null.");
	assert(_world == null, "Filter target is already set.")
	assert(_condition_with.size() + _condition_without.size() > 0
	, "Filter must have at least one condition.")
	_world = world;
	_world._filters.append(self);
	_entities_matched.clear();
	for entity in _world.get_entities():
		if is_matched(entity):
			_entities_matched[entity] = null;
	return self;

func with(component: int) -> EcsFilter:
	assert(_world == null, "Cannot add conditions after setting a target.");
	assert(!_condition_without.has(component), "Filter already excludes component %s." % component);
	if !_condition_with.has(component):
		_condition_with.append(component);
	return self;

func without(component: int) -> EcsFilter:
	assert(_world == null, "Cannot add conditions after setting a target.");
	assert(!_condition_with.has(component), "Filter already includes component %s." % component);
	if !_condition_without.has(component):
		_condition_without.append(component);
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
	for component in _condition_with:
		if !_world.has_component(entity, component):
			return false;
	for component in _condition_without:
		if _world.has_component(entity, component):
			return false;
	return true;

func _on_entity_created(entity: int):
	if !_entities_matched.has(entity) && is_matched(entity):
		_join(entity);

func _on_entity_destroyed(entity: int):
	if _entities_matched.has(entity):
		_kick(entity);

func _on_component_added(entity: int, _component: int, _value: Variant):
	if !_entities_matched.has(entity) && is_matched(entity):
		_join(entity);
	elif _entities_matched.has(entity) && !is_matched(entity):
		_kick(entity);

func _on_component_removed(entity: int, _component: int, _value: Variant):
	if !_entities_matched.has(entity) && is_matched(entity):
		_join(entity);
	elif _entities_matched.has(entity) && !is_matched(entity):
		_kick(entity);

func _join(entity: int):
	assert(!_entities_matched.has(entity));
	_entities_matched[entity] = null; # only the key is needed.
	## print("entity #%s is joined." % entity);

func _kick(entity: int):
	assert(_entities_matched.has(entity));
	_entities_matched.erase(entity);
	## print("entity #%s is kicked." % entity);
