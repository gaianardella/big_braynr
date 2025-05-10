extends PopupPanel

@onready var courses = $CenterContainer/VBoxContainer/HBoxContainer/Courses as OptionButton
@onready var chapter_button = $CenterContainer/VBoxContainer/HBoxContainer2/Chapters as OptionButton
@onready var HboxContainerOfChapter = $CenterContainer/VBoxContainer/HBoxContainer2 as HBoxContainer

const WINDOWS_MODE_ARRAY : Array[String] = [
	"choose an option",
	"Mobile security",
	"COMPUTABILITY",
	"ADVANCED ALGORITHMS",
	"MOBILE PROGRAMMING E MULTIMEDIA",
	"SOFTWARE VERIFICATION",
]

const COURSE_CHAPTERS := {
	"COMPUTABILITY": [
		"Turing Machines",
		"Decidability",
		"Reductions"
	],
	"Mobile security": [
		"Encryption",
		"Authentication",
		"Threats"
	],
	"ADVANCED ALGORITHMS": [
		"Greedy",
		"Dynamic Programming",
		"Graph Algorithms"
	]
}

func _ready():
	# Populate the main course dropdown
	for item in WINDOWS_MODE_ARRAY:
		courses.add_item(item)

	# Connect signal to handle selection
	courses.item_selected.connect(on_window_mode_selected)

	# Hide the chapter dropdown initially
	HboxContainerOfChapter.visible = false

func on_window_mode_selected(index: int) -> void:
	var selected = courses.get_item_text(index)
	chapter_button.clear()

	if COURSE_CHAPTERS.has(selected):
		HboxContainerOfChapter.visible = true
		for chapter in COURSE_CHAPTERS[selected]:
			chapter_button.add_item(chapter)
	else:
		HboxContainerOfChapter.visible = false
