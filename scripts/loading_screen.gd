class_name LoadingScreen extends CanvasLayer

## Used by scene manager to display transitions and loading progress. You won't need to
## modify or work with any of the code in this class but I've annotated in case
## you're curious about the logic

signal transition_in_complete
signal transition_out_complete

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var timer: Timer = $Timer

var starting_animation_name:String

## hides progress bar on startup, we'll reveal it later if loading has taken long
## enough that it's worth showing. The alternative is that when something loads
## quickly it flashes on screen briefly, and I don't like that.
func _ready() -> void:
	layer = 100
	progress_bar.visible = false
	anim_player.animation_finished.connect(_on_animation_finished)

## called by SceneManager to start the "in" transition.
func start_transition(animation_name:String) -> void:
	if !anim_player.has_animation(animation_name):
		push_warning("'%s' animation does not exist" % animation_name)
		animation_name = "fade_to_black"
	starting_animation_name = animation_name
	anim_player.play(animation_name)

## called by SceneManger to play the outro to the transition once the content is loaded
func finish_transition() -> void:
	if timer:
		timer.stop()
	progress_bar.visible = false
	var out_animation := _get_outro_animation(starting_animation_name)
	if anim_player.has_animation(out_animation):
		anim_player.play(out_animation)
	else:
		transition_out_complete.emit()

## called at the end of "in" transitions on the method track of the AnimationPlayer let SceneManager
## know that the screen is obscured and loading of the incoming scene can begin
func report_midpoint() -> void:
	transition_in_complete.emit()

## if loading takes long enough that this timer fires, the loading bar will become visible and 
## progress is displayed. If you don't ever want to display the loading bar, you can simple
## choose not to start the timer in [method start_transition]
func _on_timer_timeout() -> void:
	progress_bar.visible = true

func update_bar(val:float) -> void:
	progress_bar.value = val

func _get_outro_animation(intro: String) -> String:
	return intro.replace("_to_", "_from_")

func _on_animation_finished(anim_name: StringName) -> void:
	var name := String(anim_name)
	if name.begins_with("fade_from") or name.begins_with("no_from") or name.begins_with("wipe_from"):
		transition_out_complete.emit()
