class_name EnemyHealthBar
extends TextureProgressBar

@export var world_anchor: Node3D


func _ready() -> void:
	var health_module := HealthModule.find_on(owner)
	Assert.not_null(health_module)
	health_module.health_changed.connect(update_health)
	update_health(health_module)


func _process(_delta: float) -> void:
	var cam := Global.get_camera()
	var pos := cam.unproject_position(world_anchor.global_position)
	position = pos - size * Vector2(0.5, 1)


func update_health(health_module: HealthModule) -> void:
	max_value = health_module.get_max_health()
	min_value = 0
	value = health_module.get_current_health()
