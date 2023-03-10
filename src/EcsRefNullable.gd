class_name EcsRefNullable

var _id: int;
var _world: EcsWorld;

func _init(id: int, world: EcsWorld):
	assert(world != null);
	assert(world.exist(id));
	_id = id;
	_world = world;

func exist() -> bool:
	return _world.exist(_id);
	
func has(component: int) -> bool:
	if !exist(): return false;
	return _world.has_component(_id, component);

func get_value(component: int) -> Variant:
	if !exist(): return null;
	return _world.get_component(_id, component);

func set_value(component: int, value: Variant) -> void:
	if !exist(): return;
	if _world.has_component(_id, component):
		_world.update_component(_id, component, value);
	else:
		_world.add_component(_id, component, value);

func add(component: int, value: Variant) -> void:
	if !exist(): return;
	_world.add_component(_id, component, value);

func remove(component: int) -> bool:
	if !exist(): return false;
	return _world.remove_component(_id, component);

func update(component: int, value: Variant) -> bool:
	if !exist(): return false;
	return _world.update_component(_id, component, value);

func destroy() -> void:
	if !exist(): return;
	_world.destroy_entity(_id);

func to_non_nullable() -> EcsRef:
	return EcsRef.new(_id, _world);
