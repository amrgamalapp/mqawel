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
fun ExcavationCalculatorScreen(
    onBack: () -> Unit,
    viewModel: CalculatorViewModel = viewModel()
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("حاسبة الحفر والردم") },
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
                value = viewModel.excLength.value,
                onValueChange = { viewModel.excLength.value = it },
                label = "طول الحفرة (م)"
            )
            CalcTextField(
                value = viewModel.excWidth.value,
                onValueChange = { viewModel.excWidth.value = it },
                label = "عرض الحفرة (م)"
            )
            CalcTextField(
                value = viewModel.excDepth.value,
                onValueChange = { viewModel.excDepth.value = it },
                label = "عمق الحفر (م)"
            )
            CalcTextField(
                value = viewModel.excConcreteVol.value,
                onValueChange = { viewModel.excConcreteVol.value = it },
                label = "حجم الخرسانة داخل الحفرة (م³) - اختياري"
            )

            Spacer(modifier = Modifier.height(8.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                CalcButton(
                    text = "احسب",
                    onClick = { viewModel.calculateExcavation() },
                    modifier = Modifier.weight(1f),
                    icon = Icons.Default.Calculate
                )
                SecondaryButton(
                    text = "إعادة",
                    onClick = {
                        viewModel.excLength.value = ""
                        viewModel.excWidth.value = ""
                        viewModel.excDepth.value = ""
                        viewModel.excConcreteVol.value = ""
                        viewModel.excResult.value = null
                        viewModel.backfillResult.value = null
                    },
                    modifier = Modifier.weight(1f)
                )
            }

            viewModel.excResult.value?.let { exc ->
                Spacer(modifier = Modifier.height(16.dp))
                ResultCard(
                    title = "حجم الحفر",
                    value = String.format("%.2f", exc),
                    unit = "متر مكعب (م³)"
                )
            }

            viewModel.backfillResult.value?.let { backfill ->
                Spacer(modifier = Modifier.height(12.dp))
                ResultCard(
                    title = "حجم الردم",
                    value = String.format("%.2f", backfill),
                    unit = "متر مكعب (م³)"
                )
                Spacer(modifier = Modifier.height(8.dp))
                CalcButton(
                    text = "حفظ الحساب",
                    onClick = {
                        viewModel.saveCalculation(
                            "حفر وردم: ${viewModel.excLength.value}×${viewModel.excWidth.value}×${viewModel.excDepth.value} م",
                            "حفر = ${String.format("%.2f", exc)} م³ | ردم = ${String.format("%.2f", backfill)} م³"
                        )
                    },
                    icon = Icons.Default.Save
                )
            }
        }
    }
}
