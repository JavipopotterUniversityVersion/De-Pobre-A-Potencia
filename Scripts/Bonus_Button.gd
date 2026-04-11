extends Button

func _ready():
	button_up.connect(_execute_bonus)

func _execute_bonus():
	print("[Bonus_Button] Rewarded requested. Provider=", AdsManager.get_provider_name())
	AdsManager.show_rewarded_ad(_on_bonus_active)

func _on_bonus_active():
	GameManager.start_bonus()
	$Timer.wait_time = 120
	AdsManager.happy_time()
	$Timer.start()
	while($Timer.time_left > 0):
		$Label.text = "%d:%02d" % [floor($Timer.time_left / 60), int($Timer.time_left) % 60]
		await get_tree().create_timer(1).timeout
	$Label.text = ""
