class_name AimResolver

var _resolver: Callable
var _bullet_config: BulletConfig


func _init(resolver: Callable, bullet_config: BulletConfig) -> void:
	_resolver = resolver
	_bullet_config = bullet_config


func resolve(from: Node3D, to: Node3D) -> AimResolverResult:
	return _resolver.call(from, to, _bullet_config)
