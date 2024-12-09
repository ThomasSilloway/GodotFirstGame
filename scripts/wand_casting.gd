extends Node

@onready var wand: Node3D = $".."
@onready var initial_rotation: Vector3 = wand.rotation
@onready var initial_position: Vector3 = wand.position
@onready var initial_quat_rotation: Quaternion = wand.quaternion

enum Element { NONE, FIRE, ICE, ELECTRIC, HEAL }
enum CastingType { NONE, PROJECTILE, RAIN, CONE, SELF }

var selected_element: Element = Element.NONE
var selected_casting_type: CastingType = CastingType.NONE

@export var element_rotation: Quaternion = Quaternion(0, 0, 0, 0)
@export var element_position: Vector3 = Vector3(0, 0, 0)
@export var casting_type_rotation: Quaternion = Quaternion(0, 0, 0, 0)
@export var casting_type_position: Vector3 = Vector3(0, 0, 0)
@export var cast_rotation: Quaternion = Quaternion(0, 0, 0, 0)
@export var cast_position: Vector3 = Vector3(0, 0, 0)
@export var cast_animation_time: float = 0.25

func _on_choose_element_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("wand_up"):
		selected_element = Element.FIRE
		$CastingStateChart.send_event("transition_to_choose_casting_type")
		$CastingStateChart.send_event("transition_to_element")

func _on_choose_casting_type_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("wand_up"):
		selected_casting_type = CastingType.PROJECTILE
		$CastingStateChart.send_event("transition_to_ready_to_cast")
		if $CastingStateChart.get_expression_property("ready_for_casting_type"):
			print("Ready for casting type check passed: " + str($CastingStateChart.get_expression_property("ready_for_casting_type")))
			$CastingStateChart.send_event("transition_to_casting_type")

# Animation functions
func _on_idle_state_entered() -> void:
	print("idle")
	selected_casting_type = CastingType.NONE
	selected_element = Element.NONE

	var tween = get_tree().create_tween().set_parallel(true)

	#tween.tween_property(wand, "rotation", initial_rotation, cast_animation_time)
	tween.tween_property(wand, "quaternion", initial_quat_rotation, cast_animation_time)
	tween.tween_property(wand, "position", initial_position, cast_animation_time)
	$CastingStateChart.set_expression_property("ready_for_casting_type", false)

func _on_element_state_entered() -> void:
	print("element")
	var tween = get_tree().create_tween().set_parallel(true)

	tween.tween_property(wand, "quaternion", element_rotation, cast_animation_time)
	tween.tween_property(wand, "position", initial_position + element_position, cast_animation_time)
	tween.chain().tween_callback(on_finished_element_anims)
		
func on_finished_element_anims() -> void:
	print("Finished element animations")
	if selected_casting_type > CastingType.NONE:
		$CastingStateChart.send_event("transition_to_casting_type")
	else:
		print("Ready for casting type setting to true")
		$CastingStateChart.set_expression_property("ready_for_casting_type", true)

func _on_casting_type_state_entered() -> void:
	print("casting type")
	$CastingStateChart.set_expression_property("ready_for_casting_type", false)
	var tween = get_tree().create_tween().set_parallel(true)

	if selected_casting_type == CastingType.PROJECTILE:
		tween.tween_property(wand, "quaternion", casting_type_rotation, cast_animation_time)
		tween.tween_property(wand, "position", initial_position + casting_type_position, cast_animation_time)
	
	tween.chain().tween_callback(
		$CastingStateChart.send_event.bind("transition_to_cast")
	)

func _on_cast_state_entered() -> void:
	print("cast")
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(wand, "quaternion", cast_rotation, cast_animation_time)
	tween.tween_property(wand, "position", initial_position + cast_position, cast_animation_time)
	tween.chain().tween_callback(
		on_casting_complete
	)

func on_casting_complete() -> void:
	print("Casting complete")
	$CastingStateChart.send_event("transition_to_idle")
	$CastingStateChart.send_event("transition_to_choose_element")
