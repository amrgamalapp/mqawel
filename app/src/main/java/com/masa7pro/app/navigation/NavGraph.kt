package com.masa7pro.app.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.masa7pro.app.ui.screens.*

@Composable
fun NavGraph() {
    val navController = rememberNavController()

    NavHost(navController = navController, startDestination = Screen.Home.route) {
        composable(Screen.Home.route) {
            HomeScreen(
                onNavigate = { screen ->
                    navController.navigate(screen.route)
                }
            )
        }
        composable(Screen.Concrete.route) {
            ConcreteCalculatorScreen(onBack = { navController.popBackStack() })
        }
        composable(Screen.Steel.route) {
            SteelCalculatorScreen(onBack = { navController.popBackStack() })
        }
        composable(Screen.Brick.route) {
            BrickCalculatorScreen(onBack = { navController.popBackStack() })
        }
        composable(Screen.Excavation.route) {
            ExcavationCalculatorScreen(onBack = { navController.popBackStack() })
        }
        composable(Screen.Plaster.route) {
            PlasterCalculatorScreen(onBack = { navController.popBackStack() })
        }
        composable(Screen.Ceramic.route) {
            CeramicCalculatorScreen(onBack = { navController.popBackStack() })
        }
        composable(Screen.UnitConverter.route) {
            UnitConverterScreen(onBack = { navController.popBackStack() })
        }
        composable(Screen.Rural.route) {
            RuralCalculatorScreen(onBack = { navController.popBackStack() })
        }
        composable(Screen.Saved.route) {
            SavedCalculationsScreen(onBack = { navController.popBackStack() })
        }
        composable(Screen.About.route) {
            AboutScreen(onBack = { navController.popBackStack() })
        }
    }
}
