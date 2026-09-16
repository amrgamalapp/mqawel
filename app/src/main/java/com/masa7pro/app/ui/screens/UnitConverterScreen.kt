package com.masa7pro.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.masa7pro.app.ui.components.*
import com.masa7pro.app.ui.theme.PrimaryBlue
import com.masa7pro.app.viewmodel.CalculatorViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UnitConverterScreen(
    onBack: () -> Unit,
    viewModel: CalculatorViewModel = viewModel()
) {
    val categories = listOf("الطول", "المساحة", "الحجم")
    val labels = when (viewModel.ucCategory.value) {
        0 -> CalculatorViewModel.lengthLabels
        1 -> CalculatorViewModel.areaLabels
        else -> CalculatorViewModel.volumeLabels
    }

    LaunchedEffect(viewModel.ucCategory.value) {
        viewModel.ucFrom.value = 0
        viewModel.ucTo.value = 1
        viewModel.ucResult.value = null
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("محول الوحدات") },
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
            SingleChoiceSegmentedButtonRow(modifier = Modifier.fillMaxWidth()) {
                categories.forEachIndexed { index, label ->
                    SegmentedButton(
                        selected = viewModel.ucCategory.value == index,
                        onClick = { viewModel.ucCategory.value = index },
                        shape = SegmentedButtonDefaults.itemShape(
                            index = index,
                            count = categories.size
                        )
                    ) {
                        Text(label)
                    }
                }
            }

            CalcTextField(
                value = viewModel.ucValue.value,
                onValueChange = { viewModel.ucValue.value = it },
                label = "القيمة"
            )

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                var expandedFrom by remember { mutableStateOf(false) }
                ExposedDropdownMenuBox(
                    expanded = expandedFrom,
                    onExpandedChange = { expandedFrom = it },
                    modifier = Modifier.weight(1f)
                ) {
                    OutlinedTextField(
                        value = labels.getOrElse(viewModel.ucFrom.value) { "" },
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("من") },
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expandedFrom) },
                        modifier = Modifier.menuAnchor().fillMaxWidth()
                    )
                    ExposedDropdownMenu(
                        expanded = expandedFrom,
                        onDismissRequest = { expandedFrom = false }
                    ) {
                        labels.forEachIndexed { index, label ->
                            DropdownMenuItem(
                                text = { Text(label) },
                                onClick = {
                                    viewModel.ucFrom.value = index
                                    expandedFrom = false
                                }
                            )
                        }
                    }
                }

                var expandedTo by remember { mutableStateOf(false) }
                ExposedDropdownMenuBox(
                    expanded = expandedTo,
                    onExpandedChange = { expandedTo = it },
                    modifier = Modifier.weight(1f)
                ) {
                    OutlinedTextField(
                        value = labels.getOrElse(viewModel.ucTo.value) { "" },
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("إلى") },
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expandedTo) },
                        modifier = Modifier.menuAnchor().fillMaxWidth()
                    )
                    ExposedDropdownMenu(
                        expanded = expandedTo,
                        onDismissRequest = { expandedTo = false }
                    ) {
                        labels.forEachIndexed { index, label ->
                            DropdownMenuItem(
                                text = { Text(label) },
                                onClick = {
                                    viewModel.ucTo.value = index
                                    expandedTo = false
                                }
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            CalcButton(
                text = "حول",
                onClick = { viewModel.calculateUnitConvert() },
                icon = Icons.Default.SwapHoriz
            )

            viewModel.ucResult.value?.let { result ->
                Spacer(modifier = Modifier.height(16.dp))
                ResultCard(
                    title = "النتيجة",
                    value = String.format("%.4f", result),
                    unit = labels[viewModel.ucTo.value]
                )
            }
        }
    }
}
