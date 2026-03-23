extends Node2D

const HIDDEN_TILE_COORD: Vector2 = Vector2(2, 3)
const FLAG_TILE_COORD: Vector2 = Vector2(2, 0)
@onready var bottom_layer := $BottomLayer
@onready var top_layer := $TopLayer

func _ready() -> void:
	for i in 9:
		for j in 9:
			bottom_layer.set_cell(Vector2(i, j), 0, HIDDEN_TILE_COORD)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		var mouse_world_pos = get_global_mouse_position()
		var grid_cell_coord = top_layer.local_to_map(mouse_world_pos)
		top_layer.set_cell(grid_cell_coord, 0, FLAG_TILE_COORD)
