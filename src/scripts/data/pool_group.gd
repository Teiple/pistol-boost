class_name PoolGroup

enum Type {
	PROJECTILE,
	IMPACT,
	HITSCAN_TRAIL,
}

const NAMES: Dictionary[int, String] = {
	Type.PROJECTILE: "projectile",
	Type.IMPACT: "impact",
	Type.HITSCAN_TRAIL: "hitscan_trail",
}
