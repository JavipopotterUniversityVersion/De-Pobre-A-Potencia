extends Node
var sdk = null
var window:JavaScriptObject = JavaScriptBridge.get_interface("window")

signal ad_started
signal ad_finished
signal ad_error

var ADS = false

var adStartedCallback = JavaScriptBridge.create_callback(adStarted)
var adErrorCallback = JavaScriptBridge.create_callback(adError)
var adFinishedCallback = JavaScriptBridge.create_callback(adFinished)
var rewardedAdFinishedCallback = JavaScriptBridge.create_callback(rewardedAdFinished)

var adCallbacks:JavaScriptObject = JavaScriptBridge.create_object("adCallbacks")
var rewardAdCallbacks:JavaScriptObject= JavaScriptBridge.create_object("rewardedAdCallbacks")

func _ready() -> void:
	if window == null: return
	sdk = window.CrazyGames.SDK
	
	adCallbacks["adFinished"] = adFinishedCallback
	adCallbacks["adError"] = adErrorCallback
	adCallbacks["adStarted"] = adStartedCallback
	
	rewardAdCallbacks["adFinished"] = rewardedAdFinishedCallback
	rewardAdCallbacks["adError"] = adErrorCallback
	rewardAdCallbacks["adStarted"] = adStartedCallback
	#sdk.game.init()
	show_banner()
	JavaScriptBridge.eval("console.log('SDK Initialized')")
	
	window.printData.call()

func happy_time():
	if sdk == null:
		return
	
	sdk.game.happytime()

func clear_data():
	if sdk != null:
		window.clear_data()

func save_data(key: String, data: Dictionary) -> void:
	if sdk == null:
		return
		
	var json_str = JSON.stringify(data)
	JavaScriptBridge.eval("console.log('data saved')")
	window.setData(key, json_str)
	#sdk.data.setItem(key, json_str);

func get_data(key: String) -> Dictionary:
	if sdk == null:
		return {}
		
	#var result = sdk.data.getItem(key)
	var result = window.getData("" + key)
		
	if result != null:
		var parsed = JSON.parse_string(result)
		return parsed
	return {}

func adStarted():
	JavaScriptBridge.eval("console.log('Ad Started')")
	sdk.game.gameplayStop()
	emit_signal("ad_started")

func adError(error):
	JavaScriptBridge.eval("console.log('Ad Error')")
	emit_signal("ad_error", error)

func adFinished():
	JavaScriptBridge.eval("console.log('Ad Finished')")
	sdk.game.gameplayStart()
	emit_signal("ad_done")

func rewardedAdFinished(reward):
	reward.call()

func show_rewarded_ad(reward):
	if (sdk != null && ADS):
		window.request_rewarded_ad.call()
		window.get_reward = "Undefined"
		
		while(window.get_reward == "Undefined"):
			await get_tree().create_timer(0.5).timeout
		JavaScriptBridge.eval("console.log(" + window.get_reward + ")")
		
		if window.get_reward == "True":
			reward.call()
			JavaScriptBridge.eval("console.log('Reward')")
		else:
			JavaScriptBridge.eval("console.log('No reward')")
	else:
		reward.call()

func show_midgame_ad() -> void:
	if (sdk == null || !ADS):
		return
		
	window.request_ad.call()

func show_banner():
	if ADS:
		sdk.banner.requestResponsiveBanner("responsive-banner-container")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GameManager.save_data()

#	var adStartedCallback = JavaScript.create_callback(adStarted)
#	var adErrorCallback = JavaScript.create_callback(adError)
#	var adFinishedCallback = JavaScript.create_callback(adFinished)
