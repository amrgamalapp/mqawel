package com.masa7pro.app.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.masa7pro.app.R
import com.masa7pro.app.navigation.Screen
import com.masa7pro.app.ui.components.SectionTitle
import com.masa7pro.app.ui.components.ToolCard
import com.masa7pro.app.ui.theme.AccentAmber
import com.masa7pro.app.ui.theme.PrimaryBlue

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    onNavigate: (Screen) -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("مساح برو", style = MaterialTheme.typography.titleLarge, color = MaterialTheme.colorScheme.onPrimary)
                        Text("منصة الحصر الهندسي والمساحة الرقمية", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.8f))
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = PrimaryBlue),
                actions = {
                    IconButton(onClick = { onNavigate(Screen.Saved) }) {
                        Icon(Icons.Default.History, contentDescription = "Saved", tint = MaterialTheme.colorScheme.onPrimary)
                    }
                    IconButton(onClick = { onNavigate(Screen.About) }) {
                        Icon(Icons.Default.Info, contentDescription = "About", tint = MaterialTheme.colorScheme.onPrimary)
                    }
                }
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
            // Logo area
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = PrimaryBlue.copy(alpha = 0.05f)),
                shape = MaterialTheme.shapes.large
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Surface(
                        shape = MaterialTheme.shapes.extraLarge,
                        color = PrimaryBlue,
                        modifier = Modifier.size(80.dp)
                    ) {
                        Box(contentAlignment = Alignment.Center) {
                            Icon(
                                imageVector = Icons.Default.Architecture,
                                contentDescription = "Logo",
                                tint = MaterialTheme.colorScheme.onPrimary,
                                modifier = Modifier.size(40.dp)
                            )
                        }
                    }
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        "مساح برو",
                        style = MaterialTheme.typography.headlineMedium,
                        color = PrimaryBlue,
                        textAlign = TextAlign.Center
                    )
                    Text(
                        "حاسبات دقيقة لكل مهندس مساحة ومكتب فني",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center
                    )
                }
            }

            Spacer(modifier = Modifier.height(8.dp))
            SectionTitle(title = "أدوات سريعة")

            ToolCard(
                title = "حاسبة الخرسانة",
                icon = Icons.Default.ViewInAr,
                onClick = { onNavigate(Screen.Concrete) }
            )
            ToolCard(
                title = "حاسبة الحديد",
                icon = Icons.Default.LinearScale,
                onClick = { onNavigate(Screen.Steel) }
            )
            ToolCard(
                title = "حاسبة الطوب",
                icon = Icons.Default.Wallpaper,
                onClick = { onNavigate(Screen.Brick) }
            )
            ToolCard(
                title = "حاسبة الحفر والردم",
                icon = Icons.Default.Landscape,
                onClick = { onNavigate(Screen.Excavation) }
            )

            Spacer(modifier = Modifier.height(8.dp))
            SectionTitle(title = "مواد التشطيب")

            ToolCard(
                title = "حاسبة المحارة",
                icon = Icons.Default.FormatPaint,
                onClick = { onNavigate(Screen.Plaster) }
            )
            ToolCard(
                title = "حاسبة السيراميك",
                icon = Icons.Default.GridView,
                onClick = { onNavigate(Screen.Ceramic) }
            )

            Spacer(modifier = Modifier.height(8.dp))
            SectionTitle(title = "أدوات مساعدة")

            ToolCard(
                title = "محول الوحدات",
                icon = Icons.Default.SwapHoriz,
                onClick = { onNavigate(Screen.UnitConverter) }
            )
            ToolCard(
                title = "حاسبة المباني الريفية",
                icon = Icons.Default.Home,
                onClick = { onNavigate(Screen.Rural) }
            )

            Spacer(modifier = Modifier.height(16.dp))
            Text(
                "© 2026 مساح برو - إشراف م. عمرو جمال عوض",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}
