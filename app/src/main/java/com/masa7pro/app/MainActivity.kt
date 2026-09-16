package com.masa7pro.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.masa7pro.app.navigation.NavGraph
import com.masa7pro.app.ui.theme.Masa7ProTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            Masa7ProTheme {
                NavGraph()
            }
        }
    }
}
