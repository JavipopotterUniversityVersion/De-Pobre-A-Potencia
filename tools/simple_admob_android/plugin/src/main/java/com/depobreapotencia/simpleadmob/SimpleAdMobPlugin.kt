package com.depobreapotencia.simpleadmob

import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class SimpleAdMobPlugin(godot: Godot) : GodotPlugin(godot) {

    private var initialized = false
    private var rewardedAd: RewardedAd? = null
    private var interstitialAd: InterstitialAd? = null

    override fun getPluginName(): String = BuildConfig.GODOT_PLUGIN_NAME

    override fun getPluginSignals(): Set<SignalInfo> {
        return setOf(
            SignalInfo("initialization_complete", Int::class.java, String::class.java),
            SignalInfo("rewarded_ad_loaded"),
            SignalInfo("rewarded_ad_failed_to_load", Int::class.java),
            SignalInfo("rewarded_ad_failed_to_show", Int::class.java),
            SignalInfo("rewarded_ad_closed"),
            SignalInfo("user_earned_rewarded", String::class.java, Int::class.java),
            SignalInfo("interstitial_loaded"),
            SignalInfo("interstitial_closed"),
        )
    }

    @UsedByGodot
    fun initialize(_appId: String) {
        val activity = getActivity() ?: return
        runOnUiThread {
            MobileAds.initialize(activity) { _
                initialized = true
                emitSignal("initialization_complete", 1, "admob")
            }
        }
    }

    @UsedByGodot
    fun get_is_initialized(): Boolean = initialized

    @UsedByGodot
    fun load_rewarded(adUnitId: String) {
        val activity = getActivity() ?: return
        runOnUiThread {
            RewardedAd.load(
                activity,
                adUnitId,
                AdRequest.Builder().build(),
                object : RewardedAdLoadCallback() {
                    override fun onAdLoaded(ad: RewardedAd) {
                        rewardedAd = ad
                        emitSignal("rewarded_ad_loaded")
                    }

                    override fun onAdFailedToLoad(adError: LoadAdError) {
                        rewardedAd = null
                        emitSignal("rewarded_ad_failed_to_load", adError.code)
                    }
                },
            )
        }
    }

    @UsedByGodot
    fun get_is_rewarded_loaded(): Boolean = rewardedAd != null

    @UsedByGodot
    fun show_rewarded() {
        val activity = getActivity() ?: return
        runOnUiThread {
            val ad = rewardedAd
            if (ad == null) {
                emitSignal("rewarded_ad_failed_to_show", -1)
                return@runOnUiThread
            }

            ad.fullScreenContentCallback = object : FullScreenContentCallback() {
                override fun onAdDismissedFullScreenContent() {
                    rewardedAd = null
                    emitSignal("rewarded_ad_closed")
                }

                override fun onAdFailedToShowFullScreenContent(adError: com.google.android.gms.ads.AdError) {
                    rewardedAd = null
                    emitSignal("rewarded_ad_failed_to_show", adError.code)
                }
            }

            ad.show(activity) { rewardItem ->
                emitSignal("user_earned_rewarded", rewardItem.type, rewardItem.amount)
            }
        }
    }

    @UsedByGodot
    fun load_interstitial(adUnitId: String) {
        val activity = getActivity() ?: return
        runOnUiThread {
            InterstitialAd.load(
                activity,
                adUnitId,
                AdRequest.Builder().build(),
                object : InterstitialAdLoadCallback() {
                    override fun onAdLoaded(ad: InterstitialAd) {
                        interstitialAd = ad
                        emitSignal("interstitial_loaded")
                    }

                    override fun onAdFailedToLoad(adError: LoadAdError) {
                        interstitialAd = null
                    }
                },
            )
        }
    }

    @UsedByGodot
    fun get_is_interstitial_loaded(): Boolean = interstitialAd != null

    @UsedByGodot
    fun show_interstitial() {
        val activity = getActivity() ?: return
        runOnUiThread {
            val ad = interstitialAd
            if (ad == null) {
                return@runOnUiThread
            }

            ad.fullScreenContentCallback = object : FullScreenContentCallback() {
                override fun onAdDismissedFullScreenContent() {
                    interstitialAd = null
                    emitSignal("interstitial_closed")
                }

                override fun onAdFailedToShowFullScreenContent(adError: com.google.android.gms.ads.AdError) {
                    interstitialAd = null
                    emitSignal("interstitial_closed")
                }
            }

            ad.show(activity)
        }
    }
}
