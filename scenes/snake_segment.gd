
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
	"laser": 5
}

var standard = preload("res://standard.tres")
var ghost = preload("res://ghost.tres")
var red = preload("res://red.tres")

var flats = {
	"standard": standard,
	"ghost": ghost,
	"red": red
}

const HEADS = ["red"]
	
func apply_look() -> void:
	var style_box = ("normal")
	if is_head():
		style_box = flats.get(head)
		print(style_box)
		add_theme_stylebox_override("normal", style_box)
	elif is_special():
		style_box = flats.get(special)
		add_theme_stylebox_override("normal", style_box)
	#else:
		#add_theme_stylebox_override("normal", style_box)
	

#func _init(special: String, is_head: bool): #maybe not needed
#	special = specials
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

		
