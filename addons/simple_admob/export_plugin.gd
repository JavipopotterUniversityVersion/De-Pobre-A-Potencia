@tool
extends EditorPlugin

var _export_plugin: AndroidExportPlugin


func _enter_tree() -> void:
	_export_plugin = AndroidExportPlugin.new()
	add_export_plugin(_export_plugin)


func _exit_tree() -> void:
	if _export_plugin != null:
		remove_export_plugin(_export_plugin)
		_export_plugin = null


class AndroidExportPlugin extends EditorExportPlugin:
	const _PLUGIN_NAME := "simple_admob"
	const _AAR_DEBUG := "simple_admob/bin/debug/simple-admob-debug.aar"
	const _AAR_RELEASE := "simple_admob/bin/release/simple-admob-release.aar"

	func _get_name() -> String:
		return _PLUGIN_NAME

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_libraries(_platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		if debug and not FileAccess.file_exists("res://addons/" + _AAR_DEBUG):
			push_warning("[simple_admob] Missing debug AAR. Build and copy simple-admob-debug.aar first.")
		if not debug and not FileAccess.file_exists("res://addons/" + _AAR_RELEASE):
			push_warning("[simple_admob] Missing release AAR. Build and copy simple-admob-release.aar first.")

		if debug:
			return PackedStringArray([_AAR_DEBUG])
		return PackedStringArray([_AAR_RELEASE])

	func _get_android_dependencies(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		return PackedStringArray([
			"com.google.android.gms:play-services-ads:25.1.0",
		])

	func _get_android_dependencies_maven_repos(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		return PackedStringArray([
			"https://dl.google.com/dl/android/maven2",
			"https://repo.maven.apache.org/maven2",
		])

	func _get_android_manifest_element_contents(_platform: EditorExportPlatform, _debug: bool) -> String:
		return "<uses-permission android:name=\"android.permission.INTERNET\"/>\n<uses-permission android:name=\"android.permission.ACCESS_NETWORK_STATE\"/>"

	func _get_android_manifest_application_element_contents(_platform: EditorExportPlatform, _debug: bool) -> String:
		var app_id := str(ProjectSettings.get_setting("admob/app_id/android", "ca-app-pub-3940256099942544~3347511713"))
		return "<meta-data android:name=\"com.google.android.gms.ads.APPLICATION_ID\" android:value=\"%s\"/>" % app_id
