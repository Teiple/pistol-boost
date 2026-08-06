class_name PoolGroup

enum Type {
	PROJECTILE,
	IMPACT_EFFECT,
	HITSCAN_TRAIL,
	BEAM,
	HITSCAN,
	DAMAGE_POPUP,
}

const NAMES: Dictionary[int, String] = {
	Type.PROJECTILE: "projectile",
	Type.IMPACT_EFFECT: "impact_fx",
	Type.HITSCAN_TRAIL: "hitscan_trail",
	Type.BEAM: "beam",
	Type.HITSCAN: "hitscan",
	Type.DAMAGE_POPUP: "damage_popup"
}
