@icon("../icons/StateDialogue.svg")
extends State
##Starts a dialogue from DialogueManager.
class_name StateDialogue

@export var dialogue: DialogueResource ## The dialogue of reference.
@export var title = "" ## The title of the dialogue in the dialogue resource.
@export var pause := true ## Pause the game when dialogue is on screen.

func enter():
	if dialogue:
		var player = state_machine.params.get("entity")
		if player is CharacterEntity:
			player.stop()
			player.input_enabled = false

		get_tree().paused = pause
		DialogueManager.show_dialogue_balloon(dialogue, title)
		await DialogueManager.dialogue_ended

		if player is CharacterEntity:
			player.input_enabled = true
		get_tree().paused = false
		complete()
