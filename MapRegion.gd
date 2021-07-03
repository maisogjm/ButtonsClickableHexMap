extends Area2D
class_name MapRegion

# NICE reference for dynamically creating clickable polygons:
# https://godotengine.org/qa/88503/whats-the-best-way-to-instantiate-dozens-clickable-polygons?show=88629#a88629
# See also: https://github.com/t-karcher/ClickableMap

signal region_selected

var shape : PoolVector2Array setget set_shape

onready var _poly := $Polygon2D
onready var _coll := $CollisionPolygon2D

func set_shape(new_shape: PoolVector2Array):
	_poly.set_polygon(new_shape)
	# Transparent by default
	# 0.002121,0.956511,0.632383,1
	_poly.color = Color(0.002121, 0.956511, 0.632383, 0.1)
	#_poly.color = Color(randf(), randf(), randf(), 0)
	#_poly.color = Color(randf(), randf(), randf(), 0.6)
	_coll.set_polygon(new_shape)
	shape = new_shape

func _on_MapRegion_mouse_entered():
	_poly.color.a = 0.5

func _on_MapRegion_mouse_exited():
	#_poly.color.a = 0.6
	_poly.color.a = 0.1

func _on_MapRegion_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		emit_signal("region_selected")
