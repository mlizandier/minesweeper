extends Node2D

const REVEALED_TILE_COORD: Vector2i = Vector2i(0, 0)
const BOMB_TILE_COORD: Vector2i = Vector2i(3, 0)
const HIDDEN_TILE_COORD: Vector2i = Vector2i(2, 0)
const FLAG_TILE_COORD: Vector2i = Vector2i(1, 0)
@onready var bottom_layer := $BottomLayer
@onready var top_layer := $TopLayer

var revealed_cells: Dictionary = {}
var flagged_cells: Dictionary = {}

func _ready() -> void:
	for i in 9:
		for j in 9:
			bottom_layer.set_cell(Vector2i(i, j), 0, REVEALED_TILE_COORD)
			top_layer.set_cell(Vector2i(i, j), 0, HIDDEN_TILE_COORD)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		place_flag()
	if event.is_action_pressed("left_click"):
		reveal_block()

func get_local_position() -> Vector2i:
	var mouse_world_pos = get_global_mouse_position()
	return top_layer.local_to_map(mouse_world_pos)

func place_flag() -> void:
	var cell_coord = get_local_position()
	if flagged_cells.has(cell_coord):
		top_layer.set_cell(cell_coord, 0, HIDDEN_TILE_COORD)
		flagged_cells.erase(cell_coord)
		return
	if not revealed_cells.has(cell_coord):
		top_layer.set_cell(cell_coord, 0, FLAG_TILE_COORD)
		flagged_cells[cell_coord] = true

func reveal_block() -> void:
	var cell_coord = get_local_position()
	if not flagged_cells.has(cell_coord):
		top_layer.erase_cell(cell_coord)
		revealed_cells[cell_coord] = true
