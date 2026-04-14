extends Node

enum Provider {
	NONE,
	CRAZYGAMES,
	ADMOB,
}

const SETTING_PROVIDER := "ads/provider"

var _provider: Provider = Provider.NONE
var _admob_initialized := false

var _reward_pending := false
var _reward_earned := false
var _reward_request_id := 0
var _reward_callback: Callable


func _ready() -> void:
	_register_project_settings()
	_provider = _resolve_provider()
	print("[AdsManager] Provider:", get_provider_name())

	if _provider == Provider.ADMOB:
		_setup_admob_signals()
		_prepare_admob()


func get_provider_name() -> String:
	match _provider:
		Provider.CRAZYGAMES:
			return "crazygames"
		Provider.ADMOB:
			return "admob"
		_:
			return "none"


func show_rewarded_ad(on_reward: Callable) -> void:
	match _provider:
		Provider.CRAZYGAMES:
			CrazySDK.show_rewarded_ad(on_reward)
		Provider.ADMOB:
			_show_rewarded_admob(on_reward)
		_:
			return


func show_midgame_ad() -> void:
	match _provider:
		Provider.CRAZYGAMES:
			CrazySDK.show_midgame_ad()
		Provider.ADMOB:
			if not _admob_available():
				return
			if MobileAds.get_is_interstitial_loaded():
				MobileAds.show_interstitial()
			else:
				MobileAds.load_interstitial()
		_:
			return


func happy_time() -> void:
	if _provider == Provider.CRAZYGAMES:
		CrazySDK.happy_time()


func _register_project_settings() -> void:
	if ProjectSettings.has_setting(SETTING_PROVIDER):
		return

	ProjectSettings.set_setting(SETTING_PROVIDER, "auto")
	ProjectSettings.set_initial_value(SETTING_PROVIDER, "auto")
	ProjectSettings.add_property_info({
		"name": SETTING_PROVIDER,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "auto,crazygames,admob,none",
	})


func _resolve_provider() -> Provider:
	var configured := str(ProjectSettings.get_setting(SETTING_PROVIDER, "auto")).to_lower()

	if configured == "auto":
		if OS.has_feature("web") or OS.get_name() == "Web":
			return Provider.CRAZYGAMES
		if OS.has_feature("android") or OS.get_name() == "Android":
			return Provider.ADMOB
		return Provider.CRAZYGAMES

	if configured == "crazygames":
		return Provider.CRAZYGAMES
	if configured == "admob":
		return Provider.ADMOB

	return Provider.NONE


func _admob_available() -> bool:
	if not (OS.has_feature("android") or OS.get_name() == "Android"):
		return false
	if MobileAds == null:
		return false
	if MobileAds.has_method("has_native_plugin"):
		return MobileAds.has_native_plugin()
	return Engine.has_singleton("SimpleAdMob")


func _prepare_admob() -> void:
	if not _admob_available():
		push_warning("[AdsManager] AdMob native singleton not found. Verify plugin binaries and Android export setup.")
		return

	if MobileAds.get_is_initialized():
		_admob_initialized = true
		_preload_admob_ads()
	else:
		print("[AdsManager] Waiting for AdMob initialization...")


func _on_admob_initialization_complete(status: int, _adapter_name: String) -> void:
	if status == MobileAds.AdMobSettings.INITIALIZATION_STATUS.READY:
		_admob_initialized = true
		_preload_admob_ads()
		print("[AdsManager] AdMob initialized")
		if _reward_pending:
			if MobileAds.get_is_rewarded_loaded():
				MobileAds.show_rewarded()
			else:
				MobileAds.load_rewarded()
	else:
		_admob_initialized = false
		push_warning("[AdsManager] AdMob initialization failed")


func _setup_admob_signals() -> void:
	if not _admob_available():
		return

	if not MobileAds.rewarded_ad_loaded.is_connected(_on_admob_rewarded_loaded):
		MobileAds.rewarded_ad_loaded.connect(_on_admob_rewarded_loaded)
	if not MobileAds.rewarded_ad_failed_to_load.is_connected(_on_admob_rewarded_failed_to_load):
		MobileAds.rewarded_ad_failed_to_load.connect(_on_admob_rewarded_failed_to_load)
	if not MobileAds.rewarded_ad_failed_to_show.is_connected(_on_admob_rewarded_failed_to_show):
		MobileAds.rewarded_ad_failed_to_show.connect(_on_admob_rewarded_failed_to_show)
	if not MobileAds.rewarded_ad_closed.is_connected(_on_admob_rewarded_closed):
		MobileAds.rewarded_ad_closed.connect(_on_admob_rewarded_closed)
	if not MobileAds.user_earned_rewarded.is_connected(_on_admob_user_earned_rewarded):
		MobileAds.user_earned_rewarded.connect(_on_admob_user_earned_rewarded)
	if not MobileAds.initialization_complete.is_connected(_on_admob_initialization_complete):
		MobileAds.initialization_complete.connect(_on_admob_initialization_complete)
	if not MobileAds.interstitial_loaded.is_connected(_on_admob_interstitial_loaded):
		MobileAds.interstitial_loaded.connect(_on_admob_interstitial_loaded)
	if not MobileAds.rewarded_ad_loaded.is_connected(_on_admob_rewarded_loaded_log):
		MobileAds.rewarded_ad_loaded.connect(_on_admob_rewarded_loaded_log)
	if not MobileAds.rewarded_ad_failed_to_load.is_connected(_on_admob_rewarded_failed_to_load_log):
		MobileAds.rewarded_ad_failed_to_load.connect(_on_admob_rewarded_failed_to_load_log)

	if not MobileAds.interstitial_closed.is_connected(_on_admob_interstitial_closed):
		MobileAds.interstitial_closed.connect(_on_admob_interstitial_closed)


func _preload_admob_ads() -> void:
	if not _admob_available() or not _admob_initialized:
		return

	MobileAds.load_rewarded()
	MobileAds.load_interstitial()


func _show_rewarded_admob(on_reward: Callable) -> void:
	if not _admob_available():
		return
	if _reward_pending:
		return

	_reward_pending = true
	_reward_earned = false
	_reward_callback = on_reward
	_reward_request_id += 1
	var request_id := _reward_request_id

	if not _admob_initialized:
		print("[AdsManager] Rewarded requested before AdMob init. Waiting...")
		_call_reward_timeout_watch(request_id)
		return

	if MobileAds.get_is_rewarded_loaded():
		MobileAds.show_rewarded()
	else:
		MobileAds.load_rewarded()

	_call_reward_timeout_watch(request_id)


func _call_reward_timeout_watch(request_id: int) -> void:
	_reward_timeout_watch.call_deferred(request_id)


func _reward_timeout_watch(request_id: int) -> void:
	await get_tree().create_timer(10.0).timeout
	if not _reward_pending:
		return
	if request_id != _reward_request_id:
		return
	_clear_reward_state(false)


func _on_admob_rewarded_loaded() -> void:
	if _reward_pending:
		MobileAds.show_rewarded()


func _on_admob_rewarded_failed_to_load(_error_code: int) -> void:
	_clear_reward_state(false)


func _on_admob_rewarded_failed_to_show(_error_code: int) -> void:
	_clear_reward_state(false)


func _on_admob_user_earned_rewarded(_currency: String, _amount: int) -> void:
	if _reward_pending:
		_reward_earned = true


func _on_admob_rewarded_closed() -> void:
	if not _reward_pending:
		MobileAds.load_rewarded()
		return

	if _reward_earned:
		_clear_reward_state(true)
	else:
		_clear_reward_state(false)

	MobileAds.load_rewarded()


func _on_admob_interstitial_closed() -> void:
	if _admob_available():
		MobileAds.load_interstitial()


func _on_admob_interstitial_loaded() -> void:
	print("[AdsManager] Interstitial loaded")


func _on_admob_rewarded_loaded_log() -> void:
	print("[AdsManager] Rewarded loaded")


func _on_admob_rewarded_failed_to_load_log(error_code: int) -> void:
	push_warning("[AdsManager] Rewarded failed to load. error=" + str(error_code))


func _clear_reward_state(grant_reward: bool) -> void:
	var callback := _reward_callback
	_reward_pending = false
	_reward_earned = false
	_reward_callback = Callable()

	if grant_reward and callback.is_valid():
		callback.call()
