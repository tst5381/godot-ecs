# Quick Start
## Basics
Create a `EcsWorld` instance and an entity from it.
Entities are simply integers.
```
var world: EcsWorld = EcsWorld.new()
var entity: int = world.create_entity()
```

Add a component to the entity. Component types are also integers, and values are not statically typed.
```
var component: int = 0
world.add_component(entity, component, "component's value")
```

Consider using enums or constants for better readability.
```
# Component.gd

class_name Component

const BURNING  = 0
const SPEED    = 1
const TOOLTIP  = 2
```
```
world.add_component(entity, Component.BURNING, true)
world.add_component(entity, Component.SPEED, 1.25)
```
You can get `EcsRef` from the world as a wrapper of entity integer.

`EcsRef` provides shorter and intuitive APIs for convenience.
```
var ent: EcsRef = world.create_entity_to_ref()

ent.add(Component.SPEED, 1.25)

if ent.exist() && ent.has(Component.SPEED):
  ent.update(Component.SPEED, 1.8)

var recentSpeed = ent.get_value(Component.SPEED) 
ent.remove(Component.SPEED)
```

Extend `EcsSystem` and override functions like `_on_target_added` to react to component events. 
```
# BunringSystem.gd

class_name BurningSystem;
extends EcsSystem

func _init():
  # booleans define whether this system should observe added, removed, and updated events.
  super._init(Component.BURNING, true, true, true);

func _on_target_added(entity, component, value):
  # do things when BURNING is added to entity.
  pass;

func _on_target_removed(entity, component, value):
  # do things when BURNING is removed from entity.
  pass;

func _on_target_updated(entity, component, before, after):
  # do things when BURNING is updated on entity.
  pass;
```
To use it:
```
var system: BurningSystem = BurningSystem.new()

# system will now react to events from the world.
system.include(world)

# system wil stop reacting to events from the world.
system.exclude(world)
```
## Filter
With `EcsFilter` you can query entities with conditions.
```
var filter: EcsFilter = EcsFilter.new()

# add fist condition 
filter.with(Component.BURNING)

# add second condition
filter.without(Component.SPEED)

# when a target is set, filter will be applied and updated constantly,
# and can no longer add conditions.
filter.set_target(world)

# returns an array of entities that have BURNING but not SPEED.
var entities: Array[int] = filter.get_matched_entities
```

Setup functions of `EcsFilter` can be chained.
```
var filter = EcsFilter.new().with(Component.BURNING).without(Component.SPEED).set_target(world)
```

Dispose a filter when it is no longer needed (for the sake of memory and performance.)
```
# this removes filter from the world, so it can be freed safely.
filter.reset()

# function from Object class.
filter.free()
```
## Nullable
`EcsRef` can be converted to `EcsRefNullable` and vise versa.

`EcsRefNullable` will skip operations when the entity does not exist, while `EcsRef` will throw errors.
```
var ent: EcsRef = world.create_entity_to_ref()
var nullable: EcsRefNullable = ent.to_nullable()

ent.destroy() # removes the entity from the world.

nullable.add(Component.SPEED, 1.5) # will do nothing.
ent.add(Component.SPEED, 1.5) # will throw an error.
```
