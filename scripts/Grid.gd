extends Node2D

# Grid setup variables
export (int) var width_in_blocks = 8
export (int) var height_in_blocks = 10
export (int) var x_start_position = 64
export (int) var y_start_position = 128
export (int) var offset = 78
export (int) var new_block_start_offset = 1
export (Array, Resource) var block_lists


var filler_blocks = []
var special_blocks = []
var special_blocks_spawn_chance = []

# The blocks currently in the grid, a 2D array filled at runtime
var blocks

# Locations currently marked for destruction because they are matched
var matched_locations

# How many times repeated matches have been formed without a swap
var chain_count = 1

signal entered_ready_state()
signal entered_wait_state()
signal match_found(match_size, chain_count, custom_weighting)

const MAX_MOVEMENT_DISTANCE = 1

enum InteractionState {WAITING_ON_ANIMATION, WAITING_FOR_FIRST_SELECTION, WAITING_FOR_SECOND_SELECTION}
var interaction_state = InteractionState.WAITING_FOR_FIRST_SELECTION

func _ready():
	randomize()
	load_blocks()
	blocks = make_2D_array()
	populate_grid()
	matched_locations = make_2D_array()
	clear_2D_array(matched_locations)

func _process(delta):
	get_user_mouse_input()

func load_blocks():
	print("Loading blocks:")
	for list in block_lists:
		for filler_block in list.filler:
			print(filler_block.get_state().get_node_name(0))
			filler_blocks.push_back(filler_block)
		for special_block in list.special:
			print(special_block.get_state().get_node_name(0))
			special_blocks.push_back(special_block)
		for spawn_chance in list.special_spawn_chance:
			print(spawn_chance)
			special_blocks_spawn_chance.push_back(spawn_chance)

# Creates and returns a two-dimensional array
func make_2D_array():
	var array = []
	for i in height_in_blocks:
		array.append([])
		for j in width_in_blocks:
			array[i].append(null)
	return array

func clear_2D_array(array):
	for i in height_in_blocks:
		for j in width_in_blocks:
			array[i][j] = false

func reset_game_state():
	chain_count = 1
	is_first_time_finding_matches = true
	interaction_state = InteractionState.WAITING_FOR_FIRST_SELECTION
	emit_signal("entered_ready_state")

func get_new_block():
	var total_chance_for_special = 0.0
	for i in special_blocks.size():
		total_chance_for_special += special_blocks_spawn_chance[i] * 0.01
	var spawn_filler_or_special = rand_range(0.0, 1.0)
	if spawn_filler_or_special <= total_chance_for_special:
		var random_special_block_index = floor(rand_range(0, special_blocks.size()))
		return special_blocks[random_special_block_index].instance()
	else:
		var random_filler_block_index = floor(rand_range(0, filler_blocks.size()))
		return filler_blocks[random_filler_block_index].instance()

func populate_grid():
	interaction_state = InteractionState.WAITING_ON_ANIMATION
	for i in height_in_blocks:
		for j in width_in_blocks:
			var new_block = get_new_block()

			while would_match_be_formed_at(i, j, new_block.block_color): # Make sure that index will not form a match
				new_block = get_new_block()

			add_child(new_block)
			new_block.position = grid_to_pixel(i - new_block_start_offset, j)
			new_block.move_smooth(grid_to_pixel(i, j))

			blocks[i][j] = new_block

	get_node("after_populate_delay").start()

func _on_after_populate_delay_timeout():
	reset_game_state()

# Determines if a match of block_color would be formed by placing a block_color block at row, column
func would_match_be_formed_at(row, column, block_color):
	if row >= 2:
		if blocks[row - 1][column] != null && blocks[row - 2][column] != null: 
			if blocks[row - 1][column].block_color == block_color && blocks[row - 2][column].block_color == block_color:
				return true
	if column >= 2:
		if blocks[row][column - 1] != null && blocks[row][column - 2] != null: 
			if blocks[row][column - 1].block_color == block_color && blocks[row][column - 2].block_color == block_color:
				return true
	return false

func play_sound(sound_name):
	Audio.set_bus_pitch_by_note("Destroy", clamp(chain_count - 1, 0, Audio.major_scale.size() - 1))
	Audio.play(sound_name, sound_name.capitalize())

# Converts a grid coordinate to a screen pixel coordinate
func grid_to_pixel(row, column):
	var new_x = x_start_position + offset * column
	var new_y = y_start_position + offset * row
	return Vector2(new_x, new_y)

# Converts a screen pixel coordinate to a grid coordinate
func pixel_to_grid(x, y):
	var row = round((y - y_start_position) / offset)
	var column = round((x - x_start_position) / offset)
	return Vector2(row, column)
	
# Checks if a grid coordinate is in the grid and usable
func is_in_grid(grid_coordinate):
	return (grid_coordinate.x >= 0 && grid_coordinate.x < height_in_blocks && grid_coordinate.y >= 0 && grid_coordinate.y < width_in_blocks)

var first_click = Vector2(0, 0)
var second_click = Vector2(0, 0)
# Gets click locations and selects blocks based on user input
func get_user_mouse_input():
	var current_mouse_location = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
	if interaction_state == InteractionState.WAITING_FOR_FIRST_SELECTION:
		if Input.is_action_just_pressed("ui_click"):
			first_click = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
		if Input.is_action_just_released("ui_click"):
			if current_mouse_location == first_click:
				interaction_state = InteractionState.WAITING_FOR_SECOND_SELECTION # Cursor stayed on the same block
				blocks[first_click.x][first_click.y].select()
			elif is_in_grid(current_mouse_location):
				swap_blocks(first_click, current_mouse_location) # User dragged the cursor to another block
	elif interaction_state == InteractionState.WAITING_FOR_SECOND_SELECTION:
		if Input.is_action_just_pressed("ui_click"):
			second_click = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
		if Input.is_action_just_released("ui_click"):
			if is_in_grid(current_mouse_location) && current_mouse_location != second_click: # User dragged after already having a first selection
				blocks[first_click.x][first_click.y].deselect()
				swap_blocks(second_click, current_mouse_location)
			elif second_click != first_click && second_click.distance_squared_to(first_click) <= MAX_MOVEMENT_DISTANCE: # User made a valid second click
				blocks[first_click.x][first_click.y].deselect()
				swap_blocks(first_click, second_click)
			else: # User made an out-of-range second click, so treat it as a first click
				blocks[first_click.x][first_click.y].deselect()
				if is_in_grid(second_click):
					blocks[second_click.x][second_click.y].select()
					first_click = second_click
					interaction_state = InteractionState.WAITING_FOR_SECOND_SELECTION
				else:
					interaction_state = InteractionState.WAITING_FOR_FIRST_SELECTION

var last_swap = {
	first_block =  null,
	second_block =  null,
	first_block_grid = Vector2(0, 0),
	second_block_grid = Vector2(0, 0)
}

func store_last_swap(first_block, second_block, first_block_grid, second_block_grid):
	last_swap["first_block"] = first_block
	last_swap["second_block"] = second_block
	last_swap["first_block_grid"] = first_block_grid
	last_swap["second_block_grid"] = second_block_grid

var is_first_time_finding_matches = true

# Swaps on-screen positions and grid positions of two blocks as long as they are an allowed movement
func swap_blocks(first_block_grid, second_block_grid):
	if first_block_grid.distance_squared_to(second_block_grid) <= MAX_MOVEMENT_DISTANCE:
		var first_block = blocks[first_block_grid.x][first_block_grid.y]
		var second_block = blocks[second_block_grid.x][second_block_grid.y]
		if first_block != null && second_block != null && first_block.is_swappable && second_block.is_swappable:
			store_last_swap(first_block, second_block, first_block_grid, second_block_grid)

			interaction_state = InteractionState.WAITING_ON_ANIMATION
			emit_signal("entered_wait_state")

			blocks[first_block_grid.x][first_block_grid.y] = second_block
			blocks[second_block_grid.x][second_block_grid.y] = first_block

			# The user is likely more focused on the movement of the first block than the second block, so render the first block above the second
			first_block.z_index = 1 
			second_block.z_index = 0

			first_block.move_smooth(grid_to_pixel(second_block_grid.x, second_block_grid.y))
			second_block.move_smooth(grid_to_pixel(first_block_grid.x, first_block_grid.y))

			get_node("after_swap_delay").start() 
		else:
			reset_game_state()
	else:
		# The swap must not have been possible, so let the user select again
		reset_game_state()

func _on_after_swap_delay_timeout():
	find_matches()

func unswap_blocks():
	is_first_time_finding_matches = false # This prevents the unswapped blocks from entering an infinite loop of swapping back and forth 
	if last_swap["first_block"] != null && last_swap["second_block"] != null:
		if last_swap["first_block_grid"] != last_swap["second_block_grid"]:
			play_sound("error")
		swap_blocks(last_swap["second_block_grid"], last_swap["first_block_grid"])


# Marks every match found for later removal
func find_matches():
	var any_matches_found = false
	var checked = make_2D_array()
	clear_2D_array(checked)
	# Check right
	for i in height_in_blocks:
		for j in width_in_blocks:
			if !checked[i][j]:
				var match_size = 0
				var probe = j
				for counter in range(1, 5 + 1):
					probe += 1
					if probe >= width_in_blocks || blocks[i][probe].block_color != blocks[i][j].block_color:
						break
					checked[i][probe] = true
				match_size = probe - j
				probe -= 1
				if match_size >= 3:
					#print("Found a match of size ", match_size, " starting at ", i, ", ", j, " and ending at ", i, ", ", probe)
					for y_index in range(j, probe + 1):
						set_matched(i, y_index)
					found_match(match_size, chain_count)
					any_matches_found = true
					match_size = 0

	clear_2D_array(checked)
	# Check down
	for i in height_in_blocks:
		for j in width_in_blocks:
			if !checked[i][j]:
				var match_size = 0
				var probe = i
				for counter in range(1, 5 + 1):
					probe += 1
					if probe >= height_in_blocks || blocks[probe][j].block_color != blocks[i][j].block_color:
						break
					checked[probe][j] = true
				match_size = probe - i
				probe -= 1
				if match_size >= 3:
					#print("Found a match of size ", match_size, " starting at ", i, ", ", j, " and ending at ", probe, ", ", j)
					for x_index in range(i, probe + 1):
						set_matched(x_index, j)
					found_match(match_size, chain_count)
					any_matches_found = true
					match_size = 0

	if any_matches_found:
		do_special_destroy_behavior()
	else: 
		# No matches were found, so either swap back (the match was invalid) or select again (the chain is finished)
		if is_first_time_finding_matches:
			unswap_blocks()
		else:
			reset_game_state()

# Called whenever a location becomes part of a match
func set_matched(row, column):
	if (is_in_grid(Vector2(row, column))):
		if !matched_locations[row][column]:
			matched_locations[row][column] = true
			blocks[row][column].play_destroy_animation()

# Adds a match to the game mode for processing
func found_match(match_size, chain_count, custom_weighting = 1.0):
	emit_signal("match_found", match_size, chain_count, custom_weighting)

func do_special_destroy_behavior():
	for row in height_in_blocks:
		for column in width_in_blocks:
			if matched_locations[row][column]:
				var block = blocks[row][column]
				var behavior = block.special_destroy_behavior
				match behavior:
					block.SpecialDestroyBehavior.SQUARE:
						for i in range(row - 1, row + 1 + 1): # range() uses final - 1, so add 1 
							for j in range(column - 1, column + 1 + 1): # range() uses final - 1, so add 1 
								set_matched(i, j)
					block.SpecialDestroyBehavior.ROW:
						for j in width_in_blocks:
							set_matched(row, j)
					block.SpecialDestroyBehavior.COLUMN:
						for i in height_in_blocks:
							set_matched(i, column)
					block.SpecialDestroyBehavior.CROSS:
						for i in height_in_blocks:
							set_matched(i, column)
						for j in width_in_blocks:
							set_matched(row, j)
					block.SpecialDestroyBehavior.ALL_OF_SAME_COLOR:
						for i in height_in_blocks:
							for j in width_in_blocks:
								if blocks[i][j] != null:
									if blocks[i][j].block_color == block.block_color:
										set_matched(i, j)
	play_sound("destroy")
	get_node("destroy_animation_delay").start()

func _on_destroy_animation_delay_timeout():
	destroy_matched()

# Destroys all blocks that are matched
func destroy_matched():
	for i in height_in_blocks:
		for j in width_in_blocks:
			if blocks[i][j] != null:
				if matched_locations[i][j]:
					blocks[i][j].queue_free()
					blocks[i][j] = null

	clear_2D_array(matched_locations)
	collapse_null()

# Collapses grid columns, moving any null spaces to the top of the column
func collapse_null():
	is_first_time_finding_matches = false
	for i in range(height_in_blocks - 1, 0 - 1, -1): # Iterates from the bottom of the grid up
		for j in width_in_blocks:
			if blocks[i][j] == null:
				for k in range(i, 0 - 1, -1): # Iterates from the bottom of the column up
					if blocks[k][j] != null: 
						blocks[k][j].move_smooth(grid_to_pixel(i, j))
						blocks[i][j] = blocks[k][j]
						blocks[k][j] = null 
						break
	get_node("after_collapse_delay").start()

func _on_after_collapse_delay_timeout():
	repopulate_grid()

# Adds new blocks to empty spaces after matches were destroyed
func repopulate_grid():
	for i in height_in_blocks:
		for j in width_in_blocks:
			if blocks[i][j] == null:
				var new_block = get_new_block()

				while would_match_be_formed_at(i, j, new_block.block_color): # Make sure that index will not form a match
					new_block = get_new_block()

				add_child(new_block)
				new_block.position = grid_to_pixel(i - new_block_start_offset, j)
				new_block.move_smooth(grid_to_pixel(i, j))
				blocks[i][j] = new_block
	chain_count += 1
	get_node("after_repopulate_delay").start()

func _on_after_repopulate_delay_timeout():
	find_matches()
