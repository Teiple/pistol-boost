@abstract
class_name BulletConfig
extends Resource

@export_group("General")
@export var bullet_id: String = "plasma_1"
@export var damage: float = 10.0
@export var max_distance: float = 20.0
@export var impact_force: float = 5.0
@export var impact_fx: IdPackedScene = null
## Default to Environment, Player and PhysicalObjects
@export_flags_3d_physics var collision_mask: int = 7
