package com.masa7pro.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.Calculate
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Save
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
fun ConcreteCalculatorScreen(
    onBack: () -> Unit,
    viewModel: CalculatorViewModel = viewModel()
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("حاسبة الخرسانة") },
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
                value = viewModel.concreteLength.value,
                onValueChange = { viewModel.concreteLength.value = it },
                label = "الطول (م)"
            )
            CalcTextField(
                value = viewModel.concreteWidth.value,
                onValueChange = { viewModel.concreteWidth.value = it },
                label = "العرض (م)"
            )
            CalcTextField(
                value = viewModel.concreteHeight.value,
                onValueChange = { viewModel.concreteHeight.value = it },
                label = "الارتفاع / السمك (م)"
            )
            CalcTextField(
                value = viewModel.concreteDeduct.value,
                onValueChange = { viewModel.concreteDeduct.value = it },
                label = "نسبة الخصم للتقاطعات (%)"
            )

            Spacer(modifier = Modifier.height(8.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                CalcButton(
                    text = "احسب",
                    onClick = { viewModel.calculateConcrete() },
                    modifier = Modifier.weight(1f),
                    icon = Icons.Default.Calculate
                )
                SecondaryButton(
                    text = "إعادة",
                    onClick = {
                        viewModel.concreteLength.value = ""
                        viewModel.concreteWidth.value = ""
                        viewModel.concreteHeight.value = ""
                        viewModel.concreteDeduct.value = "0"
                        viewModel.concreteResult.value = null
                    },
                    modifier = Modifier.weight(1f)
                )
            }

            viewModel.concreteResult.value?.let { result ->
                Spacer(modifier = Modifier.height(16.dp))
                ResultCard(
                    title = "حجم الخرسانة",
                    value = String.format("%.2f", result),
                    unit = "متر مكعب (م³)"
                )
                Spacer(modifier = Modifier.height(8.dp))
                CalcButton(
                    text = "حفظ الحساب",
                    onClick = {
                        viewModel.saveCalculation(
                            "خرسانة: ${viewModel.concreteLength.value}×${viewModel.concreteWidth.value}×${viewModel.concreteHeight.value} م",
                            "الحجم = ${String.format("%.2f", result)} م³"
                        )
                    },
                    icon = Icons.Default.Save
                )
            }
        }
    }
}
