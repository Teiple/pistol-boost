class_name PoolRegistry

var id: String
var group: PoolGroup.Type
var pool: Pool


func _init(
		_group: PoolGroup.Type,
		_id: String,
		_pool: Pool,
) -> void:
	self.group = _group
	self.id = _id
	self.pool = _pool
