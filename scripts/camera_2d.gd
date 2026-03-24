extends Camera2D


@export var follow_speed = 0.5
@export var dead_zone = 150
@export var boundary_extension = 3
@export var zoom_value = 0.1

var min_bounds: Vector2
var max_bounds: Vector2

const MAX_ZOOM_VALUE = 3
const MIN_ZOOM_VALUE = 0.75

func setup_bounds(board_height: int, board_width: int, tile_map_layer: TileMapLayer) -> void:
	min_bounds = tile_map_layer.map_to_local(Vector2i(0, 0))
	max_bounds = tile_map_layer.map_to_local(Vector2i(board_height - 1, board_width - 1))

func _process(delta: float) -> void:
	var target = get_global_mouse_position()
	var distance = position.distance_to(target)
	if distance > dead_zone:
		position = position.lerp(target, follow_speed * delta)
	position.x = clamp(position.x, min_bounds.x - boundary_extension, max_bounds.x + boundary_extension)
	position.y = clamp(position.y, min_bounds.y - boundary_extension, max_bounds.y + boundary_extension)

func _input(event: InputEvent) -> void:
	if event.is_action("zoom_in"):
		zoom.x = clamp(zoom.x + zoom_value, MIN_ZOOM_VALUE, MAX_ZOOM_VALUE)
		zoom.y = clamp(zoom.y + zoom_value, MIN_ZOOM_VALUE, MAX_ZOOM_VALUE)
	if event.is_action("zoom_out"):
		zoom.x = clamp(zoom.x - zoom_value, MIN_ZOOM_VALUE, MAX_ZOOM_VALUE)
		zoom.y = clamp(zoom.y - zoom_value, MIN_ZOOM_VALUE, MAX_ZOOM_VALUE)
