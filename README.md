# Quick Start
## Basics

To start, attach `EcsWorld.gd` to a node and reference it in other scripts.

You can also create an instance of `EcsWorld` by code:
```python
var world:EcsWorld = EcsWorld.new()
```

Create an entity from the world. Entities are simply integers.
```python
var entity:int = world.create_entity()
```

Add a component to the entity. Component types are also integers, and values are not statically typed.
```python
var component_type:int = 0
world.add_component(entity, component_type, "component's value")
```

Consider defining component types by enum for better readability.
```python
# Ecs.gd
class_name Ecs

enum
{
  BURNING,
  SPEED,
  TOOLTIP,
}
```
```python
world.add_component(entity, Ecs.BURNING, true)
world.add_component(entity, Ecs.SPEED, 1.25)
```
You can get `EcsRef` from the world as a wrapper of entity integer.

`EcsRef` provides shorter and intuitive APIs for convenience.
```python
var ent:EcsRef = world.create_entity_to_ref()

ent.add(Ecs.SPEED, 1.25)

if ent.exist() && ent.has(Ecs.SPEED):
  ent.update(Ecs.SPEED, 1.8)

var recentSpeed = ent.get_value(Ecs.SPEED) 
ent.remove(Ecs.SPEED)
```

Extend `EcsSystem` and override functions like `is_observing` to react to component events. 
```python
# BurningSystem.gd
extends EcsSystem

func is_observing(component) -> bool:
  return component == Ecs.BURNING

func on_added(entity, component, value):
  # do things when component is added to entity.

func on_removed(entity, component, value):
  # do things when component is removed from entity.

func on_updated(entity, component, before, after):
  # do things when component is updated on entity.

```
To use it, attach `BurningSystem.gd` to a node, and link `EcsWorld` node via the editor.


## Filter
With `EcsFilter` you can query entities with conditions.
```python
var filter:EcsFilter = EcsFilter.new()

# add first condition.
filter.include(Ecs.BURNING)

# add second condition.
filter.exclude(Ecs.SPEED)

# when a target is set, filter will be applied and updated constantly,
# and can no longer add conditions.
filter.set_target(world)

# returns an array of entities that have BURNING but not SPEED.
var entities:Array[int] = filter.get_matched_entities
```

Setup functions can be chained.
```python
var filter = EcsFilter.new().include(Ecs.BURNING).exclude(Ecs.SPEED).set_target(world)
```

Dispose a filter when it is no longer needed (for the sake of memory and performance.)
```python
# this removes filter from the world, so it can be freed safely.
filter.reset()

# function from Object class.
filter.free()
```
## Nullable
`EcsRef` can be converted to `EcsRefNullable` and vise versa.

`EcsRefNullable` will skip operations when the entity does not exist, while `EcsRef` will throw errors.
```python
var ent:EcsRef = world.create_entity_to_ref()
var nullable:EcsRefNullable = ent.to_nullable()

ent.destroy() # removes the entity from the world.

nullable.add(Ecs.SPEED, 1.5) # will do nothing.
ent.add(Ecs.SPEED, 1.5) # will throw an error.
```
