class_name ImpactEffect
extends Node3D

@export var _impact_effects: Array[Node3D] = []

@onready var pooled_node_module: PooledNodeModule = $PooledNodeModule


func play_at(pos: Vector3, up_dir: Vector3) -> void:
	Orientation.lookat_direction(self, up_dir, Vector3.UP)
	global_position = pos
	_play()


func _play() -> void:
	var duration := 0.0
	for impact in _impact_effects:
		if impact is CPUParticles3D:
			var cpu_impact := impact as CPUParticles3D
			cpu_impact.restart()
			duration = cpu_impact.lifetime
		elif impact is GPUParticles3D:
			var gpu_impact := impact as GPUParticles3D
			gpu_impact.restart()
			duration = gpu_impact.lifetime
		else:
			Assert.unreachable("Impact effect should be of type CPUParticles3D or GPUParticles3D")
	duration += .1

	await get_tree().create_timer(duration, false).timeout

	pooled_node_module.return_to_pool()
