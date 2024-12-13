extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("Merchant Shop | Pause state is: ", GameManager.isPaused, " upon instantiation.")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# For when the player enters the door area (this will automatically make the player exit)
func _on_auto_door_area_2d_area_entered(area: Area2D) -> void:
	# Ensure the triggering area belongs to the player group
	if area.is_in_group("Player"):
		# Find the player node
		var interior_scene = get_tree().root.get_node("MerchantShopInterior")
		var player = interior_scene.get_node("Entities/HanTyumi")
		if player:
			# Unhide the overworld to make it visible and interactive
			var overworld = get_tree().root.get_node("Overworld")
			if overworld:
				#print("Overworld detected")
				# Remove the player node from the interior scene
				player.get_parent().remove_child(player)
				# Add the player to the overworld and set them to position 0,0
				var entity_nodes = overworld.get_node("Entities") # Get the reference to the interior scene's entity node group
				if entity_nodes:
					entity_nodes.add_child(player)
					player.position.x = -195
					player.position.y = -120
					overworld.visible = true
			# Delete the entire interior scene
			interior_scene.queue_free()
