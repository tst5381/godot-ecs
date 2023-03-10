# Quick Start

Create a world instance and an entity from it.
Entities are simply integers.
```
var world: EcsWorld = EcsWorld.new()
var entity: int = world.create_entity()
```

Add a component to an entity. 
Component types are also integers. Component values are not statically typed.

```
var component: int = 0
world.add_component(entity, component, "component's value")
```

Consider using enums or constants for better readability.
```
enum Component { BURNING, SPEED }

world.add_component(entity, Component.BURNING, true)
world.add_component(entity, Component.SPEED, 1.25)
```

You can get EcsRef from the world as a wrapper of entity integer.

EcsRef provides more intuitive and shorter APIs for convenience.
```
var entity: EcsRef = world.create_entity_to_ref()

entity.remove(Component.SPEED)
entity.add(Component.SPEED, 1.25)

if entity.exist() && entity.has(Component.SPEED):
  entity.update(Component.SPEED, 1.8)

var recentSpeed = entity.get_value(Component.SPEED) 
```
