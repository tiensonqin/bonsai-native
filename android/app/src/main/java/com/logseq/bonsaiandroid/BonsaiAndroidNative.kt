package com.logseq.bonsaiandroid

import android.content.Context

object BonsaiAndroidNative {
    private val loaded: Boolean = runCatching {
        System.loadLibrary("bonsai_android_counter")
    }.isSuccess

    private external fun renderNative(): String
    private external fun dispatchClickNative(eventId: Int)
    private external fun dispatchChangeNative(eventId: Int, text: String)

    fun render(context: Context): String =
        if (loaded) {
            renderNative()
        } else {
            context.assets.open("bonsai_counter.json")
                .bufferedReader()
                .use { it.readText() }
        }

    fun dispatchClick(eventId: Int) {
        if (loaded) dispatchClickNative(eventId)
    }

    fun dispatchChange(eventId: Int, text: String) {
        if (loaded) dispatchChangeNative(eventId, text)
    }

    val isNativeLoaded: Boolean = loaded
}
