extends Interactible3D

# i am lazy
@onready var cat = get_tree().get_root().get_node("Node3D/Level/CatPicture")

func _interact():
	cat.show()
	self.CanInteract = false
