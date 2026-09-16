package com.masa7pro.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.masa7pro.app.ui.components.*
import com.masa7pro.app.ui.theme.PrimaryBlue
import com.masa7pro.app.viewmodel.CalculatorViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RuralCalculatorScreen(
    onBack: () -> Unit,
    viewModel: CalculatorViewModel = viewModel()
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("حاسبة المباني الريفية") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowForward, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = PrimaryBlue,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary,
                    navigationIconContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                "احسب خامات بيتك بالبلدي وبدون مصطلحات معقدة",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            CalcTextField(
                value = viewModel.ruralLength.value,
                onValueChange = { viewModel.ruralLength.value = it },
                label = "طول الاوضة/الصالة (م)"
            )
            CalcTextField(
                value = viewModel.ruralWidth.value,
                onValueChange = { viewModel.ruralWidth.value = it },
                label = "عرض الاوضة/الصالة (م)"
            )
            CalcTextField(
                value = viewModel.ruralHeight.value,
                onValueChange = { viewModel.ruralHeight.value = it },
                label = "ارتفاع السقف (م)"
            )

            SectionTitle(title = "سمك جدار المباني")
            RadioOption(
                text = "نص طوبة (12 سم)",
                selected = viewModel.ruralIsHalfBrick.value,
                onSelect = { viewModel.ruralIsHalfBrick.value = true }
            )
            RadioOption(
                text = "طوبة كاملة (25 سم)",
                selected = !viewModel.ruralIsHalfBrick.value,
                onSelect = { viewModel.ruralIsHalfBrick.value = false }
            )

            SectionTitle(title = "الفتحات (الابواب والشبابيك)")
            RadioOption(
                text = "باب وباب/شباك (خصم 10%)",
                selected = viewModel.ruralOpeningType.value == 0,
                onSelect = { viewModel.ruralOpeningType.value = 0 }
            )
            RadioOption(
                text = "فتحات كتير (3+) - خصم 25%",
                selected = viewModel.ruralOpeningType.value == 1,
                onSelect = { viewModel.ruralOpeningType.value = 1 }
            )
            RadioOption(
                text = "جدران مصمتة (بدون خصم)",
                selected = viewModel.ruralOpeningType.value == 2,
                onSelect = { viewModel.ruralOpeningType.value = 2 }
            )

            Spacer(modifier = Modifier.height(8.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                CalcButton(
                    text = "احسب",
                    onClick = { viewModel.calculateRural() },
                    modifier = Modifier.weight(1f),
                    icon = Icons.Default.Calculate
                )
                SecondaryButton(
                    text = "اعادة",
                    onClick = {
                        viewModel.ruralLength.value = ""
                        viewModel.ruralWidth.value = ""
                        viewModel.ruralHeight.value = ""
                        viewModel.ruralIsHalfBrick.value = true
                        viewModel.ruralOpeningType.value = 0
                        viewModel.ruralResult.value = null
                    },
                    modifier = Modifier.weight(1f)
                )
            }

            viewModel.ruralResult.value?.let { result ->
                Spacer(modifier = Modifier.height(16.dp))
                SectionTitle(title = "نتائج الحصر")

                ResultCard(title = "الخرسانة الاجمالية", value = String.format("%.2f", result.totalConcrete), unit = "م³")
                Spacer(modifier = Modifier.height(8.dp))
                ResultCard(title = "حديد التسليح", value = String.format("%.0f", result.totalSteel), unit = "كجم")
                Spacer(modifier = Modifier.height(8.dp))
                ResultCard(title = "عدد الطوب", value = String.format("%.0f", result.brickCount), unit = "طوبة")
                Spacer(modifier = Modifier.height(8.dp))
                ResultCard(title = "مساحة المحارة", value = String.format("%.2f", result.plasterArea), unit = "م²")
                Spacer(modifier = Modifier.height(8.dp))
                ResultCard(title = "مساحة السيراميك", value = String.format("%.2f", result.ceramicArea), unit = "م²")
                Spacer(modifier = Modifier.height(8.dp))
                ResultCard(title = "علب السيراميك", value = result.ceramicBoxes.toString(), unit = "علبة")

                Spacer(modifier = Modifier.height(8.dp))
                CalcButton(
                    text = "حفظ الحساب",
                    onClick = {
                        viewModel.saveCalculation(
                            "مبني ريفي: ${viewModel.ruralLength.value}x${viewModel.ruralWidth.value} م",
                            "خرسانة=${String.format("%.2f", result.totalConcrete)}م³ | حديد=${String.format("%.0f", result.totalSteel)}كجم | طوب=${String.format("%.0f", result.brickCount)}"
                        )
                    },
                    icon = Icons.Default.Save
                )
            }
        }
    }
}
