# Snake.gd
extends Node

class_name Snake

@export var snake_scene: PackedScene
@export var cell_size: int = 50
@export var start_pos: Vector2 = Vector2(9, 9)

var segments: Array = []
var segment_positions: Array = []
var old_positions: Array = []

func _ready():
	# Optionally auto-generate here, or call externally
	pass

func generate_initial_snake():
	old_positions.clear()
	segment_positions.clear()
	segments.clear()

	_add_segment(start_pos, true)
	for i in range(3):
		_add_segment(start_pos + Vector2(0, i + 1), false)

func _add_segment(grid_pos: Vector2, is_head: bool):
	var segment = snake_scene.instantiate()
	segment.special = "standard"
	segment.head = "red" if is_head else "standard"
	segment.apply_look()
	segment.position = (grid_pos * cell_size) + Vector2(0, cell_size)

	add_child(segment)
	segments.append(segment)
	segment_positions.append(grid_pos)

func move_snake(direction: Vector2):
	old_positions = segment_positions.duplicate()
	segment_positions[0] += direction
	for i in range(segment_positions.size()):
		if i > 0:
			segment_positions[i] = old_positions[i - 1]
		segments[i].position = (segment_positions[i] * cell_size) + Vector2(0, cell_size)

func grow():
	_add_segment(old_positions[-1], false)

func get_head_position() -> Vector2:
	return segment_positions[0]
	

func save_to_dict() -> Dictionary:
	var saved_data: Array = []
	for i in range(segments.size()):
		saved_data.append({
			"grid_pos": segment_positions[i],
			"special": segments[i].special,
			"head": segments[i].head
		})
	return {"segments": saved_data}

func load_from_dict(data: Dictionary):
	clear_snake()
	var saved_segments = data.get("segments", [])
	for i in range(saved_segments.size()):
		var seg = saved_segments[i]
		var offset = Vector2(0, -3)  # Example offset to move snake "up"
		var new_pos = seg["grid_pos"] + offset
		_add_segment(new_pos, seg["head"] == "red")
		segments[-1].special = seg["special"]
		segments[-1].head = seg["head"]
		segments[-1].apply_look()

func clear_snake():
	for seg in segments:
		if is_instance_valid(seg):
			seg.queue_free()
	segments.clear()
	segment_positions.clear()
	old_positions.clear()
