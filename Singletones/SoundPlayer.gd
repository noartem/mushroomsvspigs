extends Node

var playing = {}


func _on_player_finished(path: String, player: AudioStreamPlayer):
	playing[path] = max(playing.get(path, 0) - 1, 0)
	player.queue_free()


func play(sound_path: String, volume_db: float = 0.0, delay: float = 0.0, pausable: bool = true, loop: bool = false):
	if not FileAccess.file_exists(sound_path):
		sound_path = "res://Assets/Sounds/" + sound_path + ".wav"

	var stream = load(sound_path)
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	
	if not pausable:
		player.process_mode = Node.PROCESS_MODE_ALWAYS

	if delay > 0:
		await get_tree().create_timer(delay).timeout

	if playing.get(sound_path, 0) > 3:
		player.queue_free()
		return

	playing[sound_path] = max(playing.get(sound_path, 0) + 1, 0)

	player.play()
	player.volume_db = volume_db
	player.connect("finished", _on_player_finished.bind(sound_path, player))
