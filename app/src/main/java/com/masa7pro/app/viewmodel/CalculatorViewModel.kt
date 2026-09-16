package com.masa7pro.app.viewmodel

import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import com.masa7pro.app.utils.Calculations
import com.masa7pro.app.utils.Calculations.RebarItem
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class CalculatorViewModel : ViewModel() {

    // Saved calculations
    val savedCalculations = mutableStateListOf<SavedCalculation>()

    // Concrete
    val concreteLength = mutableStateOf("")
    val concreteWidth = mutableStateOf("")
    val concreteHeight = mutableStateOf("")
    val concreteDeduct = mutableStateOf("0")
    val concreteResult = mutableStateOf<Double?>(null)

    // Steel
    val steelBars = mutableStateListOf<RebarItemInput>()
    val steelResult = mutableStateOf<Double?>(null)

    // Brick
    val brickLength = mutableStateOf("")
    val brickHeight = mutableStateOf("")
    val brickIsHalf = mutableStateOf(true)
    val brickOpeningType = mutableStateOf(0) // 0=few, 1=many, 2=solid
    val brickResult = mutableStateOf<Double?>(null)

    // Excavation
    val excLength = mutableStateOf("")
    val excWidth = mutableStateOf("")
    val excDepth = mutableStateOf("")
    val excConcreteVol = mutableStateOf("")
    val excResult = mutableStateOf<Double?>(null)
    val backfillResult = mutableStateOf<Double?>(null)

    // Plaster
    val plasterLength = mutableStateOf("")
    val plasterWidth = mutableStateOf("")
    val plasterHeight = mutableStateOf("")
    val plasterOpening = mutableStateOf("15")
    val plasterResult = mutableStateOf<Double?>(null)

    // Ceramic
    val ceramicLength = mutableStateOf("")
    val ceramicWidth = mutableStateOf("")
    val ceramicWaste = mutableStateOf("10")
    val ceramicM2PerBox = mutableStateOf("1.44")
    val ceramicAreaResult = mutableStateOf<Double?>(null)
    val ceramicBoxesResult = mutableStateOf<Int?>(null)

    // Rural
    val ruralLength = mutableStateOf("")
    val ruralWidth = mutableStateOf("")
    val ruralHeight = mutableStateOf("")
    val ruralIsHalfBrick = mutableStateOf(true)
    val ruralOpeningType = mutableStateOf(0)
    val ruralResult = mutableStateOf<Calculations.RuralResult?>(null)

    // Unit Converter
    val ucValue = mutableStateOf("")
    val ucCategory = mutableStateOf(0) // 0=length, 1=area, 2=volume
    val ucFrom = mutableStateOf(0)
    val ucTo = mutableStateOf(1)
    val ucResult = mutableStateOf<Double?>(null)

    init {
        addSteelBar()
    }

    data class RebarItemInput(var diameter: String = "12", var length: String = "6", var quantity: String = "1")
    data class SavedCalculation(val id: String, val title: String, val details: String, val timestamp: String)

    fun addSteelBar() {
        steelBars.add(RebarItemInput())
    }

    fun removeSteelBar(index: Int) {
        if (steelBars.size > 1) {
            steelBars.removeAt(index)
        }
    }

    fun calculateConcrete() {
        val l = concreteLength.value.toDoubleOrNull() ?: return
        val w = concreteWidth.value.toDoubleOrNull() ?: return
        val h = concreteHeight.value.toDoubleOrNull() ?: return
        val d = concreteDeduct.value.toDoubleOrNull() ?: 0.0
        concreteResult.value = Calculations.concreteVolume(l, w, h, d)
    }

    fun calculateSteel() {
        val items = steelBars.mapNotNull { bar ->
            val d = bar.diameter.toDoubleOrNull()
            val len = bar.length.toDoubleOrNull()
            val q = bar.quantity.toIntOrNull()
            if (d != null && len != null && q != null) RebarItem(d, len, q) else null
        }
        steelResult.value = Calculations.totalRebarWeight(items)
    }

    fun calculateBrick() {
        val l = brickLength.value.toDoubleOrNull() ?: return
        val h = brickHeight.value.toDoubleOrNull() ?: return
        val area = Calculations.wallArea(l, h)
        val openingDeduction = when (brickOpeningType.value) {
            0 -> 10.0
            1 -> 25.0
            else -> 0.0
        }
        brickResult.value = Calculations.brickCount(area, brickIsHalf.value, openingDeduction)
    }

    fun calculateExcavation() {
        val l = excLength.value.toDoubleOrNull() ?: return
        val w = excWidth.value.toDoubleOrNull() ?: return
        val d = excDepth.value.toDoubleOrNull() ?: return
        val conc = excConcreteVol.value.toDoubleOrNull() ?: 0.0
        val exc = Calculations.excavationVolume(l, w, d)
        excResult.value = exc
        backfillResult.value = Calculations.backfillVolume(exc, conc)
    }

    fun calculatePlaster() {
        val l = plasterLength.value.toDoubleOrNull() ?: return
        val w = plasterWidth.value.toDoubleOrNull() ?: return
        val h = plasterHeight.value.toDoubleOrNull() ?: return
        val o = plasterOpening.value.toDoubleOrNull() ?: 15.0
        plasterResult.value = Calculations.plasterArea(l, w, h, o)
    }

    fun calculateCeramic() {
        val l = ceramicLength.value.toDoubleOrNull() ?: return
        val w = ceramicWidth.value.toDoubleOrNull() ?: return
        val waste = ceramicWaste.value.toDoubleOrNull() ?: 10.0
        val m2Box = ceramicM2PerBox.value.toDoubleOrNull() ?: 1.44
        val area = Calculations.ceramicArea(l, w, waste)
        ceramicAreaResult.value = area
        ceramicBoxesResult.value = Calculations.ceramicBoxes(area, m2Box)
    }

    fun calculateRural() {
        val l = ruralLength.value.toDoubleOrNull() ?: return
        val w = ruralWidth.value.toDoubleOrNull() ?: return
        val h = ruralHeight.value.toDoubleOrNull() ?: return
        val opening = when (ruralOpeningType.value) {
            0 -> Calculations.OpeningType.FEW
            1 -> Calculations.OpeningType.MANY
            else -> Calculations.OpeningType.SOLID
        }
        ruralResult.value = Calculations.ruralBuildingCalc(l, w, h, ruralIsHalfBrick.value, opening)
    }

    fun calculateUnitConvert() {
        val v = ucValue.value.toDoubleOrNull() ?: return
        val result = when (ucCategory.value) {
            0 -> Calculations.convertLength(v, lengthUnits[ucFrom.value], lengthUnits[ucTo.value])
            1 -> Calculations.convertArea(v, areaUnits[ucFrom.value], areaUnits[ucTo.value])
            else -> Calculations.convertVolume(v, volumeUnits[ucFrom.value], volumeUnits[ucTo.value])
        }
        ucResult.value = result
    }

    fun saveCalculation(title: String, details: String) {
        val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault())
        val calc = SavedCalculation(
            id = System.currentTimeMillis().toString(),
            title = title,
            details = details,
            timestamp = sdf.format(Date())
        )
        savedCalculations.add(0, calc)
    }

    fun deleteCalculation(id: String) {
        savedCalculations.removeAll { it.id == id }
    }

    companion object {
        val lengthUnits = listOf("m", "cm", "mm", "km", "ft", "in", "yd")
        val lengthLabels = listOf("متر", "سنتيمتر", "مليمتر", "كيلومتر", "قدم", "بوصة", "ياردة")
        val areaUnits = listOf("m2", "cm2", "km2", "ft2", "yd2", "feddan", "acre")
        val areaLabels = listOf("م²", "سم²", "كم²", "قدم²", "ياردة²", "فدان", "أكر")
        val volumeUnits = listOf("m3", "cm3", "l", "gal", "ft3")
        val volumeLabels = listOf("م³", "سم³", "لتر", "جالون", "قدم³")
    }
}
