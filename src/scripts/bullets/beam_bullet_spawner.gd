class_name BeamBulletSpawner
extends BulletSpawner


func spawn_bullet(spawn_context: BulletSpawnContext) -> Beam:
    Assert.not_null(spawn_context, "Bullet spawn context should not be null")
    Assert.not_null(spawn_context.muzzle_point, "Beam bullet required muzzle point to be specified")

    var bullet_config := spawn_context.bullet_config

    var beam := Pools.get_instance(
        PoolGroup.Type.BEAM,
        bullet_config.bullet.id,
    ) as Beam

    beam.launch(
        spawn_context.muzzle_point,
        spawn_context.collision_mask,
    )

    return beam
