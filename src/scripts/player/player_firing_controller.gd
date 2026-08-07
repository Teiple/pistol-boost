class_name PlayerFiringController
extends Node

@export var _primary_config: FiringConfig = null
@export var _secondary_config: FiringConfig = null

@export_flags_3d_physics var _collision_mask: int = 1

var _rapid_fire_handler: RapidFiringHandler
var _standard_fire_handler: StandardFiringHandler
var _burst_fire_handler: BurstFiringHandler
var _primary_fire_hold_timer := 0.0
var _secondary_fire_hold_timer := 0.0

@onready var _player: Player = owner as Player


func _ready() -> void:
	_rapid_fire_handler = RapidFiringHandler.new(self)
	_standard_fire_handler = StandardFiringHandler.new(self)
	_burst_fire_handler = BurstFiringHandler.new(self)

	var health_module := HealthModule.find_on(_player)
	Assert.not_null(health_module)
	health_module.died.connect(_on_player_died)


func _process(delta: float) -> void:
	_burst_fire_handler.update(delta)

	# Primary fire
	if (Input.is_action_just_pressed("primary_fire") || Input.is_action_pressed("primary_fire")):
		var handler := _get_handler(_primary_config)
		if Input.is_action_just_pressed("primary_fire"):
			handler.on_fire_pressed(_primary_config)

		_primary_fire_hold_timer += delta
		handler.on_fire_held(_primary_config, _primary_fire_hold_timer)
	else:
		if _primary_fire_hold_timer > 0:
			_get_handler(_primary_config).on_fire_released(_primary_config, _primary_fire_hold_timer)
		_primary_fire_hold_timer = 0.0

	# Secondary fire
	if (Input.is_action_just_pressed("secondary_fire") || Input.is_action_pressed("secondary_fire")):
		var handler := _get_handler(_secondary_config)
		if Input.is_action_just_pressed("secondary_fire"):
			handler.on_fire_pressed(_secondary_config)

		_secondary_fire_hold_timer += delta
		handler.on_fire_held(_secondary_config, _secondary_fire_hold_timer)
	else:
		if _secondary_fire_hold_timer > 0:
			_get_handler(_secondary_config).on_fire_released(_secondary_config, _secondary_fire_hold_timer)
		_secondary_fire_hold_timer = 0.0


func get_muzzle_point() -> Node3D:
	return _player.get_muzzle_point()


func get_collision_mask() -> int:
	return _collision_mask


func notify_shot_fired(recoil_force: float, firing_sound: Sound) -> void:
	_player.on_shot_fired(recoil_force, firing_sound)


func _on_player_died(_health_module: HealthModule):
	_get_handler(_primary_config).on_weapon_interrupted()
	_get_handler(_secondary_config).on_weapon_interrupted()

	set_process(false)


func _get_handler(firing_config: FiringConfig) -> PlayerFiringHandler:
	Assert.not_null(firing_config, "Firing config should not be null")
	if firing_config is BurstFiringConfig:
		return _burst_fire_handler
	if firing_config is RapidFiringConfig:
		return _rapid_fire_handler
	if firing_config is StandardFiringConfig:
		return _standard_fire_handler

	Assert.unreachable("Not implemented fire handler")
	return null
