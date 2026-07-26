extends Node2D

var player_pos := Vector2(320, 550)
var player_speed := 400.0
var player_radius := 30.0
var screen_width := 640.0
var screen_height := 600.0

var orbs: Array = [] # each entry: {"pos": Vector2, "speed": float, "color": Color}
var spawn_timer := 0.0
var spawn_interval := 0.9
var score := 0

@onready var score_label := $CanvasLayer/ScoreLabel

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	# --- move the blob ---
	var dir := 0.0
	if Input.is_action_pressed("ui_left"):
		dir -= 1.0
	if Input.is_action_pressed("ui_right"):
		dir += 1.0
	player_pos.x += dir * player_speed * delta
	player_pos.x = clamp(player_pos.x, player_radius, screen_width - player_radius)

	# --- spawn falling orbs ---
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		orbs.append({
			"pos": Vector2(randf_range(20.0, screen_width - 20.0), -20.0),
			"speed": randf_range(120.0, 240.0),
			"color": Color(randf(), randf(), randf())
		})

	# --- move orbs, check catches, remove off-screen ---
	for i in range(orbs.size() - 1, -1, -1):
		var orb = orbs[i]
		orb["pos"].y += orb["speed"] * delta
		if orb["pos"].distance_to(player_pos) < player_radius + 10.0:
			score += 1
			score_label.text = "Score: %d" % score
			orbs.remove_at(i)
		elif orb["pos"].y > screen_height + 20.0:
			orbs.remove_at(i)

	queue_redraw()

func _draw() -> void:
	# body of an imaginary one-eyed blob alien
	draw_circle(player_pos, player_radius, Color(0.3, 0.9, 0.5))
	# big eye
	draw_circle(player_pos + Vector2(0, -8), 12.0, Color(1, 1, 1))
	draw_circle(player_pos + Vector2(0, -8), 6.0, Color(0, 0, 0))
	# little antenna
	draw_line(player_pos + Vector2(-6, -player_radius), player_pos + Vector2(-14, -player_radius - 18), Color(0.3, 0.9, 0.5), 3.0)
	draw_circle(player_pos + Vector2(-14, -player_radius - 18), 4.0, Color(1.0, 0.8, 0.2))

	# falling orbs
	for orb in orbs:
		draw_circle(orb["pos"], 10.0, orb["color"])
