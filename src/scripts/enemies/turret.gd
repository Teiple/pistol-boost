class_name EnemyTurret
extends Enemy

@export var firing_angle_tolerance_degrees := 0.001

@export_group("Firing")
@export var firing_config: FiringConfig

@export_group("Cannon Rotation")
@export_range(-180.0, 180.0) var cannon_yaw_neutral_degrees := 0.0
@export_range(-90.0, 90.0) var cannon_pitch_degrees_min := -30.0
@export_range(-90.0, 90.0) var cannon_pitch_degrees_max := 90.0
@export_range(-90.0, 90.0) var cannon_pitch_neutral_degrees := 90.0

@export_flags_3d_physics var firing_collision_mask: int = 3

var statemachine: StateMachine = null
var firing_controller: EnemyFiringController = null

@onready var cannon_pivot: Node3D = %BoneRotationOffsetHead
@onready var cannon_muzzle: Node3D = %CannonMuzzle
@onready var cannon_yaw_offset: BoneRotationOffset = %BoneRotationOffsetBody
@onready var cannon_pitch_offset: BoneRotationOffset = %BoneRotationOffsetHead
@onready var firing_sound_player: AudioStreamPlayer3D = $FiringSoundPlayer


func _ready() -> void:
	Assert.check(
		cannon_pitch_degrees_min < cannon_pitch_degrees_max,
		"Cannon minimum pitch should be less than its maximum pitch",
	)
	Assert.check(
		cannon_pitch_neutral_degrees >= cannon_pitch_degrees_min
		&& cannon_pitch_neutral_degrees <= cannon_pitch_degrees_max,
		"Cannon neutral pitch should be within its pitch limits",
	)

	firing_controller = EnemyFiringController.new(
		firing_collision_mask,
		cannon_muzzle,
		firing_sound_player,
	)
	statemachine = StateMachine.new()
	statemachine.init_states(TurretState.get_all_states(self))
	statemachine.goto(TurretState.State.TRACK)


func _process(delta: float) -> void:
	firing_controller.update(delta)
	statemachine.update(delta)
