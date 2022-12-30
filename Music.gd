extends Node

const fadeTime: float = 1.0
const layers: Dictionary = {}

class Layer:
	enum LayerState {UNMUTED, FADING, MUTED}
	var layerState
	var audioStreamPlayer: AudioStreamPlayer
	var sceneTree: SceneTree
	
	#class constructor
	func _init(audioStreamPlayer: AudioStreamPlayer, sceneTree: SceneTree):
		self.audioStreamPlayer = audioStreamPlayer
		self.sceneTree = sceneTree
		layerState = LayerState.MUTED
		audioStreamPlayer.volume_db = -80
	
	#fade-in coroutine
	func fadeIn() -> void:
		if layerState == LayerState.FADING:
			return	
		layerState = LayerState.FADING
		while audioStreamPlayer.volume_db < 0:
			print("fading in ", audioStreamPlayer.volume_db)	
			audioStreamPlayer.volume_db += 1
			yield(sceneTree.create_timer(fadeTime/80), "timeout")		
		layerState = LayerState.UNMUTED
		print("unmuted")

	#fade-out coroutine
	func fadeOut() -> void:
		if layerState == LayerState.FADING:
			return		
		layerState = LayerState.FADING
		while audioStreamPlayer.volume_db > -80:
			print("fading out ", audioStreamPlayer.volume_db)	
			audioStreamPlayer.volume_db -= 1
			yield(sceneTree.create_timer(fadeTime/80), "timeout")
		layerState = LayerState.MUTED
		print("muted")
	
	#fade and stop coroutine	
	func fadeAndStop() -> void:
		fadeOut()
		while layerState == LayerState.FADING:
			yield(sceneTree, "idle_frame");
		if layerState == LayerState.MUTED:
			audioStreamPlayer.stop();
			
	func play(startUnmuted: bool) -> void:
		if layerState == LayerState.FADING:
			return;
		audioStreamPlayer.play()
		if startUnmuted:	
			fadeIn()	
			
	func toggleState() -> void:
		if layerState == LayerState.MUTED:
			fadeIn();
		if layerState == LayerState.UNMUTED:
			fadeOut();

func play() -> void:
	layers[1].play(true)
	layers[2].play(false)
	layers[3].play(false)
	layers[4].play(false)
	
func stop() -> void:
	for layer in layers.values():
		layer.fadeAndStop()


func _ready():
	var audioStreamPlayers = get_children()
	var i: int = 0
	for player in audioStreamPlayers:
		if player.get_class() == "AudioStreamPlayer":
			i += 1
			layers[i] = Layer.new(player, get_tree())


#******** Signals *******

func _on_Play_button_down():
	play()


func _on_Stop_button_down():
	stop()


func _on_Layer1_button_down():
	layers[1].toggleState()


func _on_Layer2_button_down():
	layers[2].toggleState()


func _on_Layer3_button_down():
	layers[3].toggleState()


func _on_Layer4_button_down():
	layers[4].toggleState()
