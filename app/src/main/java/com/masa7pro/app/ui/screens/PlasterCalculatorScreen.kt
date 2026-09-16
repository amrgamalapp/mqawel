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
fun PlasterCalculatorScreen(
    onBack: () -> Unit,
    viewModel: CalculatorViewModel = viewModel()
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("حاسبة المحارة") },
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
                value = viewModel.plasterLength.value,
                onValueChange = { viewModel.plasterLength.value = it },
                label = "طول الغرفة (م)"
            )
            CalcTextField(
                value = viewModel.plasterWidth.value,
                onValueChange = { viewModel.plasterWidth.value = it },
                label = "عرض الغرفة (م)"
            )
            CalcTextField(
                value = viewModel.plasterHeight.value,
                onValueChange = { viewModel.plasterHeight.value = it },
                label = "ارتفاع الحوائط (م)"
            )
            CalcTextField(
                value = viewModel.plasterOpening.value,
                onValueChange = { viewModel.plasterOpening.value = it },
                label = "نسبة خصم الفتحات (%)"
            )

            Spacer(modifier = Modifier.height(8.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                CalcButton(
                    text = "احسب",
                    onClick = { viewModel.calculatePlaster() },
                    modifier = Modifier.weight(1f),
                    icon = Icons.Default.Calculate
                )
                SecondaryButton(
                    text = "إعادة",
                    onClick = {
                        viewModel.plasterLength.value = ""
                        viewModel.plasterWidth.value = ""
                        viewModel.plasterHeight.value = ""
                        viewModel.plasterOpening.value = "15"
                        viewModel.plasterResult.value = null
                    },
                    modifier = Modifier.weight(1f)
                )
            }

            viewModel.plasterResult.value?.let { result ->
                Spacer(modifier = Modifier.height(16.dp))
                ResultCard(
                    title = "مساحة المحارة",
                    value = String.format("%.2f", result),
                    unit = "متر مربع (م²)"
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    "تشمل الجدران + السقف مع خصم الفتحات",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(8.dp))
                CalcButton(
                    text = "حفظ الحساب",
                    onClick = {
                        viewModel.saveCalculation(
                            "محارة: ${viewModel.plasterLength.value}×${viewModel.plasterWidth.value}×${viewModel.plasterHeight.value} م",
                            "المساحة = ${String.format("%.2f", result)} م²"
                        )
                    },
                    icon = Icons.Default.Save
                )
            }
        }
    }
}
