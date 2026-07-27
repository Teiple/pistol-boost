class_name EnemyTurret
extends Enemy

@export var firing_angle_tolerance_degrees := 0.001
@export_range(-90, 270) var cannon_angle_degrees_min := -30.0
@export_range(-90, 270) var cannon_angle_degrees_max := 210.0
@export_range(-90, 270) var cannon_neutral_angle_degrees := 90.0
@export var firing_config: FiringConfig

@export_flags_3d_physics var firing_collision_mask: int = 3

var statemachine: StateMachine = null
var firing_controller: EnemyFiringController = null

@onready var cannon: Node3D = $Cannon
@onready var cannon_muzzle: Node3D = $Cannon/CannonMuzzle


func _ready() -> void:
	firing_controller = EnemyFiringController.new(firing_collision_mask, cannon_muzzle)
	statemachine = StateMachine.new()
	statemachine.init_states(TurretState.get_all_states(self))
	statemachine.goto(TurretState.State.IDLE)


func _process(delta: float) -> void:
	firing_controller.update(delta)
	statemachine.update(delta)
