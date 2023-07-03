extends Node

@export_file("Step.ogg") var Step1: String 


func play_sound(volume):
	var audio_node = AudioStreamPlayer.new()
	var pick_sound = randi() % footstep_sounds.size()
	audio_node.stream = footstep_sounds[pick_sound]
	audio_node.volume_db = volume
	audio_node.pitch_scale = rand_range(0.95, 1.05)
	add_child(audio_node)
	audio_node.play()
	#await(get_tree().create_timer(2), "timeout")
	audio_node.queue_free()
