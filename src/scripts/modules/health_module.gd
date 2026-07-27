class_name HealthModule
extends Module

signal damage_taken(health_component)
signal died(health_component)
signal healed(health_component)

@export var _max_health := 100.0
@export var _invincible := false

var _current_health := 100.0
var _is_dead := false
var _last_hit: Attack.Hit = null


static func find_on(_node: Node) -> HealthModule:
	return _find_on(_node, _name())


static func _name() -> String:
	return "HealthModule"


func _ready() -> void:
	super._ready()
	_current_health = _max_health


func take_hit(hit: Attack.Hit) -> void:
	if _is_dead:
		return
	_last_hit = hit
	if !_invincible:
		_current_health -= hit.damage
	if _current_health <= 0:
		_current_health = 0
		die()
		return
	damage_taken.emit(self)


func heal(amount: float):
	if _current_health >= _max_health:
		return
	_current_health += amount
	_current_health = clampf(_current_health, 0, _max_health)
	healed.emit(self)


func die():
	if _is_dead:
		return
	_is_dead = true
	died.emit(self)


func get_last_hit() -> Attack.Hit:
	return _last_hit
