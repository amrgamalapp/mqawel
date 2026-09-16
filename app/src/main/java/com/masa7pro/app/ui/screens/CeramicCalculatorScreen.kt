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
fun CeramicCalculatorScreen(
    onBack: () -> Unit,
    viewModel: CalculatorViewModel = viewModel()
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("حاسبة السيراميك") },
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
                value = viewModel.ceramicLength.value,
                onValueChange = { viewModel.ceramicLength.value = it },
                label = "طول المساحة (م)"
            )
            CalcTextField(
                value = viewModel.ceramicWidth.value,
                onValueChange = { viewModel.ceramicWidth.value = it },
                label = "عرض المساحة (م)"
            )
            CalcTextField(
                value = viewModel.ceramicWaste.value,
                onValueChange = { viewModel.ceramicWaste.value = it },
                label = "معامل الهالك (%)"
            )
            CalcTextField(
                value = viewModel.ceramicM2PerBox.value,
                onValueChange = { viewModel.ceramicM2PerBox.value = it },
                label = "مساحة العلبة (م²/علبة)"
            )

            Spacer(modifier = Modifier.height(8.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                CalcButton(
                    text = "احسب",
                    onClick = { viewModel.calculateCeramic() },
                    modifier = Modifier.weight(1f),
                    icon = Icons.Default.Calculate
                )
                SecondaryButton(
                    text = "إعادة",
                    onClick = {
                        viewModel.ceramicLength.value = ""
                        viewModel.ceramicWidth.value = ""
                        viewModel.ceramicWaste.value = "10"
                        viewModel.ceramicM2PerBox.value = "1.44"
                        viewModel.ceramicAreaResult.value = null
                        viewModel.ceramicBoxesResult.value = null
                    },
                    modifier = Modifier.weight(1f)
                )
            }

            viewModel.ceramicAreaResult.value?.let { area ->
                Spacer(modifier = Modifier.height(16.dp))
                ResultCard(
                    title = "مساحة السيراميك مع الهالك",
                    value = String.format("%.2f", area),
                    unit = "متر مربع (م²)"
                )
            }

            viewModel.ceramicBoxesResult.value?.let { boxes ->
                Spacer(modifier = Modifier.height(12.dp))
                ResultCard(
                    title = "عدد علب السيراميك",
                    value = boxes.toString(),
                    unit = "علبة"
                )
                Spacer(modifier = Modifier.height(8.dp))
                CalcButton(
                    text = "حفظ الحساب",
                    onClick = {
                        viewModel.saveCalculation(
                            "سيراميك: ${viewModel.ceramicLength.value}×${viewModel.ceramicWidth.value} م",
                            "المساحة = ${String.format("%.2f", area)} م² | العلب = $boxes"
                        )
                    },
                    icon = Icons.Default.Save
                )
            }
        }
    }
}
