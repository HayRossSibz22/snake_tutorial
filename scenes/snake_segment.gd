
extends Panel

class_name SnakeSegment

@export var special: String  # e.g., "standard", "ghost_train", etc.
@export var head: String 

# Static cost table for each type
const TYPE_COSTS = {
	"standard": 1,
	"ghost_train": 5,
	"armor": 5,
	"slow_down": 5,
}
@onready var standard = ("res://standard.tres")
@onready var ghost = ("res://standard.tres")
@onready var red = ("res://standard.tres")

var LOOK = {
	"standard": standard,
	"ghost": ghost,
	"red": red
}

const HEADS = ["red"]

func _ready() -> void:
	look()
	
func look() -> void:
	var new_stylebox_normal = get_theme_stylebox("normal").duplicate()

	if is_head():
		new_stylebox_normal = LOOK.get(head)
	elif is_special():
		new_stylebox_normal = LOOK.get(special)
	else:
		new_stylebox_normal = LOOK.get(standard)
	add_theme_stylebox_override("panel", new_stylebox_normal)
	

#func _init(special: String, is_head: bool): #maybe not needed
#	special = special
#	head = is_head
	
	#if head==true:
		#StyleBoxFlat

func is_special() -> bool:
	return special != "standard"

func get_cost() -> int:
	return TYPE_COSTS.get(special, 1) # default to 1 if unknown type

func get_special_type() -> String:
	return special

func is_head() -> bool:
	if head in HEADS:
		return true
	return false
		
