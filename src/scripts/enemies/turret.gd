class_name EnemyTurret
extends Node3D

@export var firing_angle_tolerance_degrees := 10.0
@export var firing_config: FiringConfig

var statemachine: StateMachine = null

@onready var cannon: Node3D = $Cannon
@onready var cannon_muzzle: Node3D = $CannonMuzzle


func _ready() -> void:
	statemachine = StateMachine.new()
	statemachine.init_states([TurretState.IdleState.new(self)])


func _process(delta: float) -> void:
	statemachine.update(delta)
