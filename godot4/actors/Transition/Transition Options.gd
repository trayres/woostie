extends Window


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.transition_options.connect(_transition_options)

func setup():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _transition_options(idx:int):
	# do the setup
	popup()


func _on_close_requested():
	hide()


func _on_about_to_popup():
	pass
