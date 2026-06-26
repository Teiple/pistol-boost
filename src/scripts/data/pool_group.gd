class_name PoolGroup

enum Type {
	PROJECTILE,
	IMPACT_EFFECT,
	HITSCAN_TRAIL,
}

const NAMES: Dictionary[int, String] = {
	Type.PROJECTILE: "projectile",
	Type.IMPACT_EFFECT: "impact_fx",
	Type.HITSCAN_TRAIL: "hitscan_trail",
}
