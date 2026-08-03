class_name HealthRing
extends TextureProgressBar

var _player: Player


func _ready() -> void:
	_player = Global.get_player()
	var health_module := HealthModule.find_on(_player)
	Assert.not_null(health_module)

	health_module.health_changed.connect(update_health)

	update_health(health_module)


func _process(_delta: float) -> void:
	position = _player.get_unprojected_position() - size * 0.5


func update_health(health_module: HealthModule):
	min_value = 0
	max_value = health_module.get_max_health()
	value = health_module.get_current_health()
