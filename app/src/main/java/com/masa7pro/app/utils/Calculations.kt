package com.masa7pro.app.utils

import kotlin.math.roundToInt

object Calculations {

    // ===== CONCRETE =====
    fun concreteVolume(length: Double, width: Double, height: Double, deductPercent: Double = 0.0): Double {
        val gross = length * width * height
        return gross * (1 - deductPercent / 100)
    }

    // ===== STEEL / REBAR =====
    // Weight per meter = D² / 162 (kg/m) where D is diameter in mm
    fun rebarUnitWeight(diameterMm: Double): Double {
        return (diameterMm * diameterMm) / 162.0
    }

    fun rebarWeight(diameterMm: Double, lengthM: Double, quantity: Int = 1): Double {
        return rebarUnitWeight(diameterMm) * lengthM * quantity
    }

    fun totalRebarWeight(bars: List<RebarItem>): Double {
        return bars.sumOf { rebarWeight(it.diameter, it.length, it.quantity) }
    }

    data class RebarItem(val diameter: Double, val length: Double, val quantity: Int)

    // ===== BRICKS =====
    // Standard Egyptian brick: 25 x 12 x 6.5 cm
    // With 1.2cm mortar
    // 12cm wall: ~60 bricks/m²
    // 25cm wall: ~120 bricks/m²
    fun brickCount(wallAreaM2: Double, isHalfBrick: Boolean, openingDeductionPercent: Double): Double {
        val bricksPerM2 = if (isHalfBrick) 60.0 else 120.0
        val effectiveArea = wallAreaM2 * (1 - openingDeductionPercent / 100)
        return effectiveArea * bricksPerM2
    }

    fun wallArea(length: Double, height: Double): Double = length * height

    // ===== EXCAVATION & BACKFILL =====
    fun excavationVolume(length: Double, width: Double, depth: Double): Double {
        return length * width * depth
    }

    fun backfillVolume(excavationVol: Double, concreteVol: Double): Double {
        return maxOf(0.0, excavationVol - concreteVol)
    }

    // ===== PLASTERING =====
    fun plasterArea(length: Double, width: Double, height: Double, openingDeductionPercent: Double = 15.0): Double {
        val wallArea = 2 * (length + width) * height
        val ceilingArea = length * width
        val gross = wallArea + ceilingArea
        return gross * (1 - openingDeductionPercent / 100)
    }

    // ===== CERAMIC =====
    fun ceramicArea(length: Double, width: Double, wastePercent: Double = 10.0): Double {
        val gross = length * width
        return gross * (1 + wastePercent / 100)
    }

    fun ceramicBoxes(areaM2: Double, m2PerBox: Double = 1.44): Int {
        return kotlin.math.ceil(areaM2 / m2PerBox).toInt()
    }

    // ===== RURAL BUILDING (Complete House) =====
    data class RuralResult(
        val foundationConcrete: Double,
        val columnsConcrete: Double,
        val beamsConcrete: Double,
        val slabConcrete: Double,
        val totalConcrete: Double,
        val totalSteel: Double,
        val brickCount: Double,
        val plasterArea: Double,
        val ceramicArea: Double,
        val ceramicBoxes: Int
    )

    fun ruralBuildingCalc(
        roomLength: Double,
        roomWidth: Double,
        ceilingHeight: Double,
        isHalfBrick: Boolean,
        openingType: OpeningType
    ): RuralResult {
        val openingDeduction = when (openingType) {
            OpeningType.FEW -> 10.0
            OpeningType.MANY -> 25.0
            OpeningType.SOLID -> 0.0
        }

        // Foundation: 0.8m wide x 0.5m deep, perimeter
        val perimeter = 2 * (roomLength + roomWidth)
        val foundationConcrete = perimeter * 0.8 * 0.5

        // Columns: 4 corners, 0.25 x 0.25 section, full height
        val columnSection = 0.25 * 0.25
        val columnsConcrete = 4 * columnSection * ceilingHeight

        // Beams: perimeter beams, 0.25 x 0.35 section
        val beamSection = 0.25 * 0.35
        val beamsConcrete = perimeter * beamSection

        // Slab: room area x 0.12m thickness
        val slabConcrete = roomLength * roomWidth * 0.12

        val totalConcrete = foundationConcrete + columnsConcrete + beamsConcrete + slabConcrete

        // Steel: 100 kg/m³ average for rural construction
        val totalSteel = totalConcrete * 100.0

        // Bricks
        val wallArea = 2 * (roomLength + roomWidth) * ceilingHeight
        val brickCount = brickCount(wallArea, isHalfBrick, openingDeduction)

        // Plaster
        val plaster = plasterArea(roomLength, roomWidth, ceilingHeight, openingDeduction)

        // Ceramic
        val ceramic = ceramicArea(roomLength, roomWidth, 10.0)
        val ceramicBoxes = ceramicBoxes(ceramic)

        return RuralResult(
            foundationConcrete = round(foundationConcrete),
            columnsConcrete = round(columnsConcrete),
            beamsConcrete = round(beamsConcrete),
            slabConcrete = round(slabConcrete),
            totalConcrete = round(totalConcrete),
            totalSteel = round(totalSteel),
            brickCount = round(brickCount),
            plasterArea = round(plaster),
            ceramicArea = round(ceramic),
            ceramicBoxes = ceramicBoxes
        )
    }

    enum class OpeningType { FEW, MANY, SOLID }

    // ===== UNIT CONVERTER =====
    fun convertLength(value: Double, from: String, to: String): Double {
        val toMeter = when (from) {
            "m" -> 1.0
            "cm" -> 0.01
            "mm" -> 0.001
            "km" -> 1000.0
            "ft" -> 0.3048
            "in" -> 0.0254
            "yd" -> 0.9144
            else -> 1.0
        }
        val fromMeter = when (to) {
            "m" -> 1.0
            "cm" -> 100.0
            "mm" -> 1000.0
            "km" -> 0.001
            "ft" -> 3.28084
            "in" -> 39.3701
            "yd" -> 1.09361
            else -> 1.0
        }
        return value * toMeter * fromMeter
    }

    fun convertArea(value: Double, from: String, to: String): Double {
        val toM2 = when (from) {
            "m2" -> 1.0
            "cm2" -> 0.0001
            "km2" -> 1_000_000.0
            "ft2" -> 0.092903
            "yd2" -> 0.836127
            "feddan" -> 4200.0
            "acre" -> 4046.86
            else -> 1.0
        }
        val fromM2 = when (to) {
            "m2" -> 1.0
            "cm2" -> 10_000.0
            "km2" -> 0.000001
            "ft2" -> 10.7639
            "yd2" -> 1.19599
            "feddan" -> 1.0 / 4200.0
            "acre" -> 1.0 / 4046.86
            else -> 1.0
        }
        return value * toM2 * fromM2
    }

    fun convertVolume(value: Double, from: String, to: String): Double {
        val toM3 = when (from) {
            "m3" -> 1.0
            "cm3" -> 0.000001
            "l" -> 0.001
            "gal" -> 0.00378541
            "ft3" -> 0.0283168
            else -> 1.0
        }
        val fromM3 = when (to) {
            "m3" -> 1.0
            "cm3" -> 1_000_000.0
            "l" -> 1000.0
            "gal" -> 264.172
            "ft3" -> 35.3147
            else -> 1.0
        }
        return value * toM3 * fromM3
    }

    private fun round(value: Double, decimals: Int = 2): Double {
        val factor = kotlin.math.pow(10.0, decimals.toDouble())
        return kotlin.math.round(value * factor) / factor
    }
}
