package com.masa7pro.app.navigation

sealed class Screen(val route: String, val title: String) {
    object Home : Screen("home", "الرئيسية")
    object Concrete : Screen("concrete", "حاسبة الخرسانة")
    object Steel : Screen("steel", "حاسبة الحديد")
    object Brick : Screen("brick", "حاسبة الطوب")
    object Excavation : Screen("excavation", "حاسبة الحفر والردم")
    object Plaster : Screen("plaster", "حاسبة المحارة")
    object Ceramic : Screen("ceramic", "حاسبة السيراميك")
    object UnitConverter : Screen("converter", "محول الوحدات")
    object Rural : Screen("rural", "حاسبة المباني الريفية")
    object About : Screen("about", "عن التطبيق")
    object Saved : Screen("saved", "الحسابات المحفوظة")
}
