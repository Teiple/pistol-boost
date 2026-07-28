class_name PlayerContactScanner
extends Node3D

@export var _enemy_hit_force := 4.0
@export var _enemy_hit_damage := 2.0
@export var _enemy_hit_cooldown := 0.5
@export var _contact_check: ShapeCast3D

@export_flags_3d_physics var _enemy_hitbox_layer := 1
@export_flags_3d_physics var _environment_layer := 1

var _player: Player
var _enemy_hit_cooldown_timer := 0.0


func _ready() -> void:
	_player = owner as Player
	Assert.not_null(_player, "PlayerContactScanner should be owned by the player")

	Assert.check(_enemy_hit_cooldown >= 0.0, "Enemy hit cooldown should not be negative")


func _physics_process(delta: float) -> void:
	_enemy_hit_cooldown_timer = maxf(_enemy_hit_cooldown_timer - delta, 0.0)
	if _enemy_hit_cooldown_timer > 0.0:
		return

	var _player_health = HealthModule.find_on(_player)
	Assert.not_null(_player_health, "Player should have a HealthModule")

	for contact in get_contacts(_enemy_hitbox_layer, Vector3.ZERO):
		var enemy_hitbox := (contact.collider as Node3D) as HitBoxModule
		if enemy_hitbox == null:
			continue

		var atk_hit := Attack.Hit.new(
			_enemy_hit_damage,
			Attack.DamageType.TOUCH,
			contact.position,
			contact.normal,
			contact.normal,
			_enemy_hit_force,
		)

		_player_health.take_hit(atk_hit)
		_enemy_hit_cooldown_timer = _enemy_hit_cooldown
		return


func get_contacts(col_mask: int, cast_direction: Vector3 = Vector3.ZERO, max_colliders: int = -1) -> Array[Contact]:
	Assert.non_empty_array(
		_player.get_collision_shapes(),
		"Collision shape array should have been set",
	)
	var contacts: Dictionary[CollisionObject3D, Contact] = { }

	for col in _player.get_collision_shapes():
		var prev_margin := col.shape.margin

		Assert.greaterf(
			prev_margin,
			0.01,
			"Ground check margin should be smaller than collision shape margin",
		)
		col.shape.margin = 0.01

		_contact_check.shape = col.shape
		_contact_check.global_transform = col.global_transform
		_contact_check.target_position = _contact_check.global_basis.inverse() * cast_direction
		_contact_check.collision_mask = col_mask

		_contact_check.force_shapecast_update()

		col.shape.margin = prev_margin

		if _contact_check.is_colliding():
			for i in _contact_check.get_collision_count():
				var collider := _contact_check.get_collider(i) as CollisionObject3D
				if collider == null || contacts.has(collider):
					continue

				contacts[collider] = Contact.new(
					_contact_check.get_collision_point(i),
					_contact_check.get_collision_normal(i),
					collider,
				)
				if max_colliders > 0 && contacts.size() >= max_colliders:
					return contacts.values()

	return contacts.values()


func is_on_floor() -> bool:
	return get_contacts(_environment_layer, Vector3.DOWN * 0.1, 1).size() > 0


class Contact:
	var normal := Vector3.ZERO
	var position := Vector3.ZERO
	var collider: CollisionObject3D = null


	func _init(_position: Vector3, _normal: Vector3, _collider: CollisionObject3D) -> void:
		position = _position
		normal = _normal
		collider = _collider
