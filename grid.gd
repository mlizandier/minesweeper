extends Node2D

# ---- EXPORTS ----
@export var height: int;
@export var width: int;

# ---- CONST ----
const EMPTY_TILE_COORD: Vector2i = Vector2i(0, 0)
const BOMB_TILE_COORD: Vector2i = Vector2i(3, 0)
const HIDDEN_TILE_COORD: Vector2i = Vector2i(2, 0)
const FLAG_TILE_COORD: Vector2i = Vector2i(1, 0)
const TILE_MAP: Dictionary = {
	0: EMPTY_TILE_COORD,
	1: Vector2i(0, 1),
	2: Vector2i(1, 1),
	3: Vector2i(2, 1),
	4: Vector2i(3, 1),
	5: Vector2i(0, 2),
	6: Vector2i(1, 2),
	7: Vector2i(2, 2),
	8: Vector2i(3, 2),
}
const NEIGHBOURS = [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(-1,  0),                  Vector2i(1,  0),
	Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1),
]

# ---- VARS ----
@onready var bottom_layer := $BottomLayer
@onready var top_layer := $TopLayer
var revealed_cells: Dictionary = {}
var flagged_cells: Dictionary = {}
var board: Array[Vector2i]

func _ready() -> void:
	var tiles_amount = height * width
	var mines_amount = int((tiles_amount) * randf_range(0.15, 0.19))
	setup_board(tiles_amount, mines_amount)
	paint_board()

func setup_board(tiles_amount: int, mines_amount: int) -> void:
	board.resize(tiles_amount)
	board.fill(EMPTY_TILE_COORD)

	var indices: Array[int] = []
	for i in tiles_amount:
		indices.append(i)
	indices.shuffle()
	
	for i in mines_amount:
		board[indices[i]] = BOMB_TILE_COORD
	
	for i in height:
		for j in height:
			if board[i * width + j] == BOMB_TILE_COORD:
				continue
			var bombs_around = 0
			for neighbour in NEIGHBOURS:
				var neighbour_x = i + neighbour.x
				var neighbour_y = j + neighbour.y
				if neighbour_x < 0 or neighbour_x >= height or neighbour_y < 0 or neighbour_y >= width:
					continue
				if board[neighbour_x * width + neighbour_y] == BOMB_TILE_COORD:
					bombs_around += 1
			if bombs_around > 0:
				board[i* width +j] = TILE_MAP[bombs_around]

func paint_board() -> void:
	for i in height:
		for j in width:
			var index = i * width + j
			bottom_layer.set_cell(Vector2i(i, j), 0, board[index])
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
		if board[cell_coord.x * width + cell_coord.y] == EMPTY_TILE_COORD:
			reveal_empty_neighbours(cell_coord)
		top_layer.erase_cell(cell_coord)
		revealed_cells[cell_coord] = true

func reveal_empty_neighbours(cell_coord: Vector2i) -> void:
	for neighbour in NEIGHBOURS:
		var neighbour_x = cell_coord.x + neighbour.x
		var neighbour_y = cell_coord.y + neighbour.y
		var tile_coordinates = Vector2i(neighbour_x, neighbour_y)
		if neighbour_x < 0 or neighbour_x >= height or neighbour_y < 0 or neighbour_y >= width:
			continue
		if revealed_cells.has(tile_coordinates):
			continue
		top_layer.erase_cell(Vector2i(neighbour_x, neighbour_y))
		revealed_cells[tile_coordinates] = true
		if board[neighbour_x * width + neighbour_y] == EMPTY_TILE_COORD:
			reveal_empty_neighbours(tile_coordinates)
