class_name AimResolverResult

enum Resolution {
	DIRECT,
	INTERCEPT,
}

var resolution: Resolution = Resolution.DIRECT
var predicted_position: Vector3
var resolved_aim_direction: Vector3
