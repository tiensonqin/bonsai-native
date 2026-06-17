package com.logseq.bonsaiandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    var treeJson by remember { mutableStateOf(BonsaiAndroidNative.render(this)) }
                    BonsaiNode(
                        node = JSONObject(treeJson),
                        refresh = { treeJson = BonsaiAndroidNative.render(this) },
                    )
                }
            }
        }
    }
}

@Composable
private fun BonsaiNode(node: JSONObject, refresh: () -> Unit) {
    val modifier = node.optJSONArray("modifiers").toModifier()
    when (node.getString("type")) {
        "text" -> Text(text = node.getString("text"), modifier = modifier)
        "button" -> {
            val eventId = node.getInt("eventId")
            Button(
                modifier = modifier,
                onClick = {
                    BonsaiAndroidNative.dispatchClick(eventId)
                    refresh()
                },
            ) {
                Text(node.getString("text"))
            }
        }
        "textField" -> {
            val eventId = node.getInt("eventId")
            var value by remember(node.optString("text")) { mutableStateOf(node.optString("text")) }
            OutlinedTextField(
                modifier = modifier,
                value = value,
                placeholder = node.optString("placeholder").takeIf { it.isNotBlank() }?.let { { Text(it) } },
                onValueChange = {
                    value = it
                    BonsaiAndroidNative.dispatchChange(eventId, it)
                    refresh()
                },
            )
        }
        "vstack" -> {
            Column(
                modifier = modifier,
                verticalArrangement = Arrangement.spacedBy(node.optDouble("spacing", 0.0).dp),
            ) {
                val children = node.getJSONArray("children")
                for (index in 0 until children.length()) {
                    BonsaiNode(children.getJSONObject(index), refresh)
                }
            }
        }
        "hstack" -> {
            Row(
                modifier = modifier,
                horizontalArrangement = Arrangement.spacedBy(node.optDouble("spacing", 0.0).dp),
            ) {
                val children = node.getJSONArray("children")
                for (index in 0 until children.length()) {
                    BonsaiNode(children.getJSONObject(index), refresh)
                }
            }
        }
        "scrollView" -> {
            Column(modifier = modifier.verticalScroll(rememberScrollState())) {
                BonsaiNode(node.getJSONObject("child"), refresh)
            }
        }
        "list" -> {
            LazyColumn(modifier = modifier) {
                items(node.getJSONArray("rows").objects(), key = { it.getString("key") }) {
                    BonsaiNode(it.getJSONObject("node"), refresh)
                }
            }
        }
    }
}

private fun JSONArray?.toModifier(): Modifier {
    var modifier: Modifier = Modifier
    if (this == null) return modifier
    forEachObject { item ->
        when (item.getString("type")) {
            "padding" -> {
                modifier = modifier.padding(
                    start = item.optDouble("start", 0.0).dp,
                    top = item.optDouble("top", 0.0).dp,
                    end = item.optDouble("end", 0.0).dp,
                    bottom = item.optDouble("bottom", 0.0).dp,
                )
            }
            "frame" -> {
                if (!item.isNull("width")) modifier = modifier.width(item.getDouble("width").dp)
                if (!item.isNull("height")) modifier = modifier.height(item.getDouble("height").dp)
            }
        }
    }
    return modifier
}

private fun JSONArray.forEachObject(f: (JSONObject) -> Unit) {
    for (index in 0 until length()) f(getJSONObject(index))
}

private fun JSONArray.objects(): List<JSONObject> =
    buildList {
        forEachObject { add(it) }
    }
