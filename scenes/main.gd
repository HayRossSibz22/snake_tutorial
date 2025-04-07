extends Node

@export var snake_scene : PackedScene

#game variables
var score : int
var game_started : bool = false

#grid variables
var cells : int = 20
var cell_size : int = 50

#food variables
var food_pos : Vector2
var regen_food : bool = true

#snake variables
var old_data : Array
var snake_data : Array
var snake : Array #make a class outside of main -> more oo

#movement variables
var start_pos = Vector2(9, 9)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var move_direction : Vector2
var can_move: bool

#level logic
var current_level : int = 1
var store_open : bool = false
var needed_score = 10
var score_mult = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	
func new_game():
	needed_score = current_level * score_mult
	get_tree().paused = false
	get_tree().call_group("segments", "queue_free")
	$GameOverMenu.hide()
	score = 0
	$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
	move_direction = up
	can_move = true
	generate_snake()
	move_food()
	
func generate_snake():
	old_data.clear() #if level != 1 change to save else load new 
	snake_data.clear()
	snake.clear()
	#starting with the start_pos, create tail segments vertically down
	add_head(start_pos)
	for i in range(3):
		add_segment(start_pos + Vector2(0, i+1))
		
func add_head(pos):
	snake_data.append(pos) #change to save
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.head = "red"
	SnakeSegment.special = "standard"
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	SnakeSegment.look() #remove if I can call this on _ready
	add_child(SnakeSegment)
	snake.append(SnakeSegment)
	
func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.head = "standard"
	SnakeSegment.special = "standard"
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	SnakeSegment.look() #remove if I can call this on _ready
	add_child(SnakeSegment)
	snake.append(SnakeSegment)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_snake()
	
func move_snake():
	if can_move:
		#update movement from keypresses
		if Input.is_action_just_pressed("move_down") and move_direction != up:
			move_direction = down
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_up") and move_direction != down:
			move_direction = up
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_left") and move_direction != right:
			move_direction = left
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_right") and move_direction != left:
			move_direction = right
			can_move = false
			if not game_started:
				start_game()

func start_game():
	game_started = true
	$MoveTimer.start()


func _on_move_timer_timeout():
	#allow snake movement
	can_move = true
	#use the snake's previous position to move the segments
	old_data = [] + snake_data
	snake_data[0] += move_direction
	for i in range(len(snake_data)):
		#move all the segments along by one
		if i > 0:
			snake_data[i] = old_data[i - 1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)
	check_out_of_bounds()
	check_self_eaten()
	check_food_eaten()
	
func check_out_of_bounds():
	if snake_data[0].x < 0 or snake_data[0].x > cells - 1 or snake_data[0].y < 0 or snake_data[0].y > cells - 1:
		end_game()
		
func check_self_eaten():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i]:
			end_game()
			
func check_food_eaten():
	if snake_data[0] == food_pos:
		score += 1
		$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
		add_segment(old_data[-1])
		move_food()
		
		if score >= needed_score:
			open_store()
	
func move_food():
	while regen_food:
		regen_food = false
		food_pos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
		for i in snake_data:
			if food_pos == i:
				regen_food = true
	$Food.position = (food_pos * cell_size)+ Vector2(0, cell_size)
	regen_food = true
	
func open_store():
	store_open = true
	game_started = false
	get_tree().paused = true

	var store_scene = preload("res://scenes/Store.tscn")
	var store_instance = store_scene.instantiate()
	add_child(store_instance)

	store_instance.connect("store_closed", Callable(self, "_on_store_closed"))

func end_game():
	$GameOverMenu.show()
	$MoveTimer.stop()
	game_started = false
	get_tree().paused = true


func _on_game_over_menu_restart():
	new_game()
