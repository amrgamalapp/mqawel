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
fun SteelCalculatorScreen(
    onBack: () -> Unit,
    viewModel: CalculatorViewModel = viewModel()
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("حاسبة الحديد") },
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
            SectionTitle(title = "أسياخ التسليح")

            viewModel.steelBars.forEachIndexed { index, bar ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
                ) {
                    Column(modifier = Modifier.padding(12.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = androidx.compose.ui.Alignment.CenterVertically
                        ) {
                            Text("سيخ ${index + 1}", style = MaterialTheme.typography.labelLarge, color = PrimaryBlue)
                            if (viewModel.steelBars.size > 1) {
                                IconButton(onClick = { viewModel.removeSteelBar(index) }) {
                                    Icon(Icons.Default.Delete, contentDescription = "Delete", tint = MaterialTheme.colorScheme.error)
                                }
                            }
                        }
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            CalcTextField(
                                value = bar.diameter,
                                onValueChange = { viewModel.steelBars[index] = bar.copy(diameter = it) },
                                label = "قطر (مم)",
                                modifier = Modifier.weight(1f)
                            )
                            CalcTextField(
                                value = bar.length,
                                onValueChange = { viewModel.steelBars[index] = bar.copy(length = it) },
                                label = "طول (م)",
                                modifier = Modifier.weight(1f)
                            )
                            CalcTextField(
                                value = bar.quantity,
                                onValueChange = { viewModel.steelBars[index] = bar.copy(quantity = it) },
                                label = "عدد",
                                modifier = Modifier.weight(1f)
                            )
                        }
                    }
                }
            }

            OutlinedButton(
                onClick = { viewModel.addSteelBar() },
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(Icons.Default.Add, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text("أضف سيخ")
            }

            Spacer(modifier = Modifier.height(8.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                CalcButton(
                    text = "احسب",
                    onClick = { viewModel.calculateSteel() },
                    modifier = Modifier.weight(1f),
                    icon = Icons.Default.Calculate
                )
                SecondaryButton(
                    text = "إعادة",
                    onClick = {
                        viewModel.steelBars.clear()
                        viewModel.addSteelBar()
                        viewModel.steelResult.value = null
                    },
                    modifier = Modifier.weight(1f)
                )
            }

            viewModel.steelResult.value?.let { result ->
                Spacer(modifier = Modifier.height(16.dp))
                ResultCard(
                    title = "وزن حديد التسليح",
                    value = String.format("%.2f", result),
                    unit = "كيلوجرام (كجم)"
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    "ملاحظة: الوزن = Σ (عدد × طول × قطر² ÷ 162)",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(8.dp))
                CalcButton(
                    text = "حفظ الحساب",
                    onClick = {
                        viewModel.saveCalculation(
                            "حديد تسليح - ${viewModel.steelBars.size} سيخ",
                            "الوزن = ${String.format("%.2f", result)} كجم"
                        )
                    },
                    icon = Icons.Default.Save
                )
            }
        }
    }
}
