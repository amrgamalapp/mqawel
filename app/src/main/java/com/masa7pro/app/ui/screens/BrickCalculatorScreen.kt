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
fun BrickCalculatorScreen(
    onBack: () -> Unit,
    viewModel: CalculatorViewModel = viewModel()
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("حاسبة الطوب") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowForward, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = PrimaryBlue, titleContentColor = MaterialTheme.colorScheme.onPrimary, navigationIconContentColor = MaterialTheme.colorScheme.onPrimary)
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
            CalcTextField(
                value = viewModel.brickLength.value,
                onValueChange = { viewModel.brickLength.value = it },
                label = "طول الجدار (م)"
            )
            CalcTextField(
                value = viewModel.brickHeight.value,
                onValueChange = { viewModel.brickHeight.value = it },
                label = "ارتفاع الجدار (م)"
            )

            SectionTitle(title = "سمك الجدار")
            RadioOption(
                text = "نص طوبة (12 سم) - ~60 طوبة/م²",
                selected = viewModel.brickIsHalf.value,
                onSelect = { viewModel.brickIsHalf.value = true }
            )
            RadioOption(
                text = "طوبة كاملة (25 سم) - ~120 طوبة/م²",
                selected = !viewModel.brickIsHalf.value,
                onSelect = { viewModel.brickIsHalf.value = false }
            )

            SectionTitle(title = "الفتحات (أبواب وشبابيك)")
            RadioOption(
                text = "فتحات قليلة (خصم 10%)",
                selected = viewModel.brickOpeningType.value == 0,
                onSelect = { viewModel.brickOpeningType.value = 0 }
            )
            RadioOption(
                text = "فتحات كثيرة 3+ (خصم 25%)",
                selected = viewModel.brickOpeningType.value == 1,
                onSelect = { viewModel.brickOpeningType.value = 1 }
            )
            RadioOption(
                text = "جدران مصمتة (بدون خصم)",
                selected = viewModel.brickOpeningType.value == 2,
                onSelect = { viewModel.brickOpeningType.value = 2 }
            )

            Spacer(modifier = Modifier.height(8.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                CalcButton(
                    text = "احسب",
                    onClick = { viewModel.calculateBrick() },
                    modifier = Modifier.weight(1f),
                    icon = Icons.Default.Calculate
                )
                SecondaryButton(
                    text = "إعادة",
                    onClick = {
                        viewModel.brickLength.value = ""
                        viewModel.brickHeight.value = ""
                        viewModel.brickIsHalf.value = true
                        viewModel.brickOpeningType.value = 0
                        viewModel.brickResult.value = null
                    },
                    modifier = Modifier.weight(1f)
                )
            }

            viewModel.brickResult.value?.let { result ->
                Spacer(modifier = Modifier.height(16.dp))
                ResultCard(
                    title = "عدد الطوب المطلوب",
                    value = String.format("%.0f", result),
                    unit = "طوبة"
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    "مع هالك 5%: ${String.format("%.0f", result * 1.05)} طوبة",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(8.dp))
                CalcButton(
                    text = "حفظ الحساب",
                    onClick = {
                        viewModel.saveCalculation(
                            "طوب: ${viewModel.brickLength.value}×${viewModel.brickHeight.value} م",
                            "العدد = ${String.format("%.0f", result)} طوبة"
                        )
                    },
                    icon = Icons.Default.Save
                )
            }
        }
    }
}
