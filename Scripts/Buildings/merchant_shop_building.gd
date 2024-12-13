extends Node2D


## References to tooltip elements
#@onready var doorTooltip = $Etc/DoorTooltip # The parent control node for the door's tooltip label
#@onready var jobBoardTooltip = $Etc/JobBoardTooltip # The parent control node for the job board's tooltip label 
#
## Boolean variables that tell if the player is in the area for the areas
#var is_in_door_area
#var is_in_job_board_area
#
#
#func _ready() -> void:
	#is_in_door_area = false
	#is_in_job_board_area = false
#
#
#func _process(delta: float) -> void:
	#if is_in_door_area and Input.is_action_pressed("interact"): # Player interacts with the door
		#print("Player entered the door")
		#get_tree().change_scene_to_file("res://Scenes/Buildings/Merchant/Inside/merchant_shop_inside.tscn") # Change to the inside of the merchant shop
#
#
## Area entered for the door of the building
#func _on_door_area_2d_area_entered(area: Area2D) -> void:
	#if area.is_in_group("Player"):
		#doorTooltip.visible = true # Makes the tooltip visible if the player is close to the door
		#is_in_door_area = true
#
#
## Area exited for the door of the building
#func _on_door_area_2d_area_exited(area: Area2D) -> void:
	#if area.is_in_group("Player"):
		#doorTooltip.visible = false # Makes the tooltip invisible if the player is not close to the door
		#is_in_door_area = false


# Area entered for the auto-enter door area (this will automatically bring the player inside)
func _on_auto_door_area_2d_area_entered(area: Area2D) -> void:
	# Ensure the triggering area belongs to the player group
	if area.is_in_group("Player"):
		# Find the player node
		var player = get_tree().current_scene.get_node("Entities/HanTyumi")
		if player:
			# Load the interior scene
			var interior_scene = preload("res://Scenes/Buildings/Merchant/Inside/merchant_shop_inside.tscn").instantiate()
			interior_scene.name = "MerchantShopInterior"
			
			# Add the interior scene to the root node (a sibling of the overworld)
			get_tree().root.add_child(interior_scene)
			
			# Hide the overworld (make it invisible and non-interactive)
			var overworld = get_tree().root.get_node("Overworld")
			if overworld:
				# Move the player into the interior scene
				player.get_parent().remove_child(player)
				# Access the entity node group to add the player to it
				var entity_nodes = interior_scene.get_node("Entities") # Get the reference to the interior scene's entity node group
				if entity_nodes:
					entity_nodes.add_child(player)
					player.position.x = 0
					player.position.y = 0
				overworld.visible = false # make the overworld scene invisible


## Area entered for the job board
#func _on_job_board_area_2d_area_entered(area: Area2D) -> void:
	#if area.is_in_group("Player"):
		#jobBoardTooltip.visible = true # Makes the job board tooltip visible if the player is close to it
		#is_in_job_board_area = true
#
#
## Area exited for the job board
#func _on_job_board_area_2d_area_exited(area: Area2D) -> void:
	#if area.is_in_group("Player"):
		#jobBoardTooltip.visible = false # Makes the job board tooltip invisible if the player is not close to it
		#is_in_job_board_area = false
