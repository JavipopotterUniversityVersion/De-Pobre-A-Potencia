extends Node
var sdk = null

signal ad_started
signal ad_finished
signal ad_error

func _ready() -> void:
	if not OS.has_feature("crazygames"): return
	
	if Engine.has_singleton("JavaScriptBridge"):
		var js = JavaScriptBridge.get_interface("window")
		if js.has("CrazyGames") and js.CrazyGames.has("SDK"):
			sdk = js.CrazyGames.SDK
			sdk.game.init()
			show_banner()
			print("CrazyGames SDK initialized")
		else:
			print("SDK aún no cargado")

func save_data(key: String, data: Dictionary) -> void:
	var json_str = JSON.stringify(data)
	print(json_str)
	JavaScriptBridge.eval("window.CrazyGames.SDK.data.setItem(" + key + ", " + json_str + ");")

func get_data(key: String) -> Dictionary:
	var result = JavaScriptBridge.eval("window.CrazyGames.SDK.data.getItem(" + key + ");", true)
	if result != null:
		var parsed = JSON.parse_string(result)
		if typeof(parsed) == TYPE_DICTIONARY:
			return parsed
		else:
			print("Error al parsear datos.")
	else:
		print("No hay datos guardados.")
	return {}

func adStarted(args):
	emit_signal("ad_started")

func adError(error):
	emit_signal("ad_error", error)

func adFinished(args):
	emit_signal("ad_done")

func show_rewarded_ad(reward):
	if sdk != null:
		sdk.game.gameplayStop()
		sdk.ad.requestAd("rewarded", {
			"onComplete": func ():
				print("Recompensa otorgada")
				reward.call()
				sdk.game.gameplayStart(),
			"onClose": func ():
				print("Anuncio cerrado")
				sdk.game.gameplayStart(),
			"onError": func ():
				print("Error al mostrar anuncio")
				sdk.game.gameplayStart()
		})
	else:
		reward.call()

func show_midgame_ad() -> void:
	if sdk != null:
		sdk.game.gameplayStop()
		sdk.ad.requestAd("midgame", {
			"onComplete": JavaScriptBridge.create_callback(func():
				print("📺 Midgame ad terminado")
				sdk.game.gameplayStart()
				),
			"onClose": JavaScriptBridge.create_callback(func():
				print("❌ Midgame ad cerrado")
				sdk.game.gameplayStart()
				),
			"onError": JavaScriptBridge.create_callback(func():
				print("⚠️ Error en midgame ad")
				sdk.game.gameplayStart()
				)
		})

func show_banner():
	sdk.banner.requestResponsiveBanner("responsive-banner-container")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GameManager.save_data()

#	var adStartedCallback = JavaScript.create_callback(adStarted)
#	var adErrorCallback = JavaScript.create_callback(adError)
#	var adFinishedCallback = JavaScript.create_callback(adFinished)
