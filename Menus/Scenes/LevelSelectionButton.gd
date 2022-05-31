extends TextureButton

var completed = false

func init(level):
	$Title.text = level.title
	set_icon_color(level.difficulty)
	if level.done:
		if level.completed:
			completed = true
			$CompletedBadge.show()
		$Score.text = level.score_str()
	if level.set_limit > 0: 
		$LimitedSet/LimitedSetNumberLabel.text = str(level.set_limit)
		$LimitedSet.show()
	match level.type: 
		level.TYPES.PERCENT:
			$TypeBadge.animation = "PERCENT"
		level.TYPES.SURVIVAL:
			$TypeBadge.animation = "SURVIVAL"
		level.TYPES.MINIMUM:
			$TypeBadge.animation = "MINIMUM"

func set_icon_color(difficulty):
	#0.0 Tutorials
	#1.0 Easy
	#2.0 Medium
	#3.0 Hard
	#4.0 Impossible
	var gradient_difficulty = Gradient.new()
	var colors_array = [Color("#4e4e4e"),Color("#ff00e113"),Color("#f5620a"),Color("c70000"),Color("#231f1f")]
	for color_index in range(colors_array.size()):
		gradient_difficulty.add_point(color_index,colors_array[color_index])
	$LevelIcon.self_modulate = gradient_difficulty.interpolate(difficulty)

