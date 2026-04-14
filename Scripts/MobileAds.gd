extends Node

class_name SimpleMobileAds

class _AdMobSettingsClass:
	enum INITIALIZATION_STATUS {
		NOT_READY,
		READY,
	}


signal initialization_complete(status, adapter_name)

signal rewarded_ad_loaded()
signal rewarded_ad_failed_to_load(error_code)
signal rewarded_ad_failed_to_show(error_code)
signal rewarded_ad_closed()
signal user_earned_rewarded(currency, amount)

signal interstitial_loaded()
signal interstitial_closed()


var AdMobSettings = _AdMobSettingsClass.new()

const DEFAULT_REWARDED_UNIT_ID := "ca-app-pub-3940256099942544/5224354917"
const DEFAULT_INTERSTITIAL_UNIT_ID := "ca-app-pub-3940256099942544/1033173712"

var _plugin
var _rewarded_unit_id := DEFAULT_REWARDED_UNIT_ID
var _interstitial_unit_id := DEFAULT_INTERSTITIAL_UNIT_ID
var _is_initialized := false


func _ready() -> void:
	_read_project_config()

	if not Engine.has_singleton("SimpleAdMob"):
		push_warning("[MobileAds] Native SimpleAdMob plugin not found")
		return

	_plugin = Engine.get_singleton("SimpleAdMob")
	_connect_plugin_signals()
	_plugin.initialize(ProjectSettings.get_setting("admob/app_id/android", "ca-app-pub-3940256099942544~3347511713"))


func _read_project_config() -> void:
	var cfg = ProjectSettings.get_setting("admob/config", {})
	if cfg is Dictionary:
		var rewarded = cfg.get("rewarded", {})
		if rewarded is Dictionary:
			var rewarded_unit_ids = rewarded.get("unit_ids", {})
			if rewarded_unit_ids is Dictionary:
				var android_rewarded = rewarded_unit_ids.get("Android", {})
				if android_rewarded is Dictionary:
					var rewarded_standard = android_rewarded.get("standard", "")
					if str(rewarded_standard) != "":
						_rewarded_unit_id = str(rewarded_standard)

		var interstitial = cfg.get("interstitial", {})
		if interstitial is Dictionary:
			var interstitial_unit_ids = interstitial.get("unit_ids", {})
			if interstitial_unit_ids is Dictionary:
				var android_interstitial = interstitial_unit_ids.get("Android", {})
				if android_interstitial is Dictionary:
					var interstitial_standard = android_interstitial.get("standard", "")
					if str(interstitial_standard) != "":
						_interstitial_unit_id = str(interstitial_standard)


func _connect_plugin_signals() -> void:
	if _plugin == null:
		return

	_connect_plugin_signal("initialization_complete", _on_initialization_complete)
	_connect_plugin_signal("rewarded_ad_loaded", _on_rewarded_ad_loaded)
	_connect_plugin_signal("rewarded_ad_failed_to_load", _on_rewarded_ad_failed_to_load)
	_connect_plugin_signal("rewarded_ad_failed_to_show", _on_rewarded_ad_failed_to_show)
	_connect_plugin_signal("rewarded_ad_closed", _on_rewarded_ad_closed)
	_connect_plugin_signal("user_earned_rewarded", _on_user_earned_rewarded)
	_connect_plugin_signal("interstitial_loaded", _on_interstitial_loaded)
	_connect_plugin_signal("interstitial_closed", _on_interstitial_closed)


func _connect_plugin_signal(signal_name: String, callable: Callable) -> void:
	if not _plugin.has_signal(signal_name):
		return
	if not _plugin.is_connected(signal_name, callable):
		_plugin.connect(signal_name, callable)


func get_is_initialized() -> bool:
	if _plugin == null:
		return false
	return bool(_plugin.get_is_initialized())


func has_native_plugin() -> bool:
	return _plugin != null


func load_rewarded(_ad_unit_name: String = "standard") -> void:
	if _plugin == null:
		return
	_plugin.load_rewarded(_rewarded_unit_id)


func get_is_rewarded_loaded() -> bool:
	if _plugin == null:
		return false
	return bool(_plugin.get_is_rewarded_loaded())


func show_rewarded() -> void:
	if _plugin == null:
		return
	_plugin.show_rewarded()


func load_interstitial(_ad_unit_name: String = "standard") -> void:
	if _plugin == null:
		return
	_plugin.load_interstitial(_interstitial_unit_id)


func get_is_interstitial_loaded() -> bool:
	if _plugin == null:
		return false
	return bool(_plugin.get_is_interstitial_loaded())


func show_interstitial() -> void:
	if _plugin == null:
		return
	_plugin.show_interstitial()


func _on_initialization_complete(status: int, adapter_name: String) -> void:
	_is_initialized = status == AdMobSettings.INITIALIZATION_STATUS.READY
	emit_signal("initialization_complete", status, adapter_name)


func _on_rewarded_ad_loaded() -> void:
	emit_signal("rewarded_ad_loaded")


func _on_rewarded_ad_failed_to_load(error_code: int) -> void:
	emit_signal("rewarded_ad_failed_to_load", error_code)


func _on_rewarded_ad_failed_to_show(error_code: int) -> void:
	emit_signal("rewarded_ad_failed_to_show", error_code)


func _on_rewarded_ad_closed() -> void:
	emit_signal("rewarded_ad_closed")


func _on_user_earned_rewarded(currency: String, amount: int) -> void:
	emit_signal("user_earned_rewarded", currency, amount)


func _on_interstitial_loaded() -> void:
	emit_signal("interstitial_loaded")


func _on_interstitial_closed() -> void:
	emit_signal("interstitial_closed")
