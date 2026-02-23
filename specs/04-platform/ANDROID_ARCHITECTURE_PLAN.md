# ANDROID APP ARCHITECTURE PLAN

## Executive Summary

**Market Impact:** Android represents 71% of global mobile market share. iOS-only limits addressable market to 29%.

**Timeline:** 6 weeks to MVP (20 core screens)

**Approach:** Kotlin Multiplatform (KMP) with shared business logic

---

## Architecture Decision

### Selected: Kotlin Multiplatform (KMP)

**Rationale:**
- Share ViewModels, Services, Models with iOS (via KMP)
- Native UI: Jetpack Compose (Android) / SwiftUI (iOS)
- Gradual migration possible
- Better performance than React Native
- Full native API access

**Alternative Rejected:** React Native
- Would require rewriting 60 SwiftUI screens
- Performance concerns for real-time features
- Native module complexity for Stripe/Firebase

---

## Project Structure

```
HUSTLEXP-ANDROID/
├── androidApp/                 # Android-specific
│   ├── src/main/java/com/hustlexp/
│   │   ├── ui/                # Jetpack Compose screens
│   │   ├── theme/             # Material3 theme
│   │   └── MainActivity.kt
│   └── build.gradle.kts
├── shared/                     # Kotlin Multiplatform
│   ├── src/commonMain/kotlin/
│   │   ├── viewmodels/        # Shared ViewModels
│   │   ├── services/          # Shared Services
│   │   ├── models/            # Shared Models
│   │   └── repositories/      # Shared Repositories
│   └── build.gradle.kts
└── build.gradle.kts
```

---

## Shared Module (KMP)

### ViewModels (Shared)
```kotlin
// shared/src/commonMain/kotlin/viewmodels/CreateTaskViewModel.kt
class CreateTaskViewModel(
    private val taskService: TaskService,
    private val aiService: AIService
) : ViewModel() {
    private val _state = MutableStateFlow(CreateTaskState())
    val state: StateFlow<CreateTaskState> = _state.asStateFlow()
    
    fun createTask(request: CreateTaskRequest) {
        viewModelScope.launch {
            _state.value = _state.value.copy(isLoading = true)
            try {
                val result = taskService.createTask(request)
                _state.value = _state.value.copy(
                    isLoading = false,
                    taskId = result.taskId
                )
            } catch (e: Exception) {
                _state.value = _state.value.copy(
                    isLoading = false,
                    error = e.message
                )
            }
        }
    }
}
```

### Services (Shared)
```kotlin
// shared/src/commonMain/kotlin/services/TaskService.kt
interface TaskService {
    suspend fun createTask(request: CreateTaskRequest): TaskResult
    suspend fun getTask(id: String): Task
    suspend fun acceptTask(taskId: String): Boolean
    suspend fun submitProof(taskId: String, proof: ProofSubmission): Boolean
}

class TaskServiceImpl(
    private val trpcClient: TRPCClient,
    private val escrowService: EscrowService
) : TaskService {
    override suspend fun createTask(request: CreateTaskRequest): TaskResult {
        return trpcClient.mutation("task.create", request)
    }
    // ...
}
```

### Models (Shared)
```kotlin
// shared/src/commonMain/kotlin/models/Task.kt
@Serializable
data class Task(
    val id: String,
    val title: String,
    val description: String,
    val budget: Money,
    val status: TaskStatus,
    val posterId: String,
    val hustlerId: String?,
    val createdAt: Instant,
    val expiresAt: Instant
)

@Serializable
enum class TaskStatus {
    DRAFT, PENDING, ASSIGNED, IN_PROGRESS, COMPLETED, CANCELLED, DISPUTED
}
```

---

## Android UI (Jetpack Compose)

### Screen Mapping (iOS → Android)

| iOS Screen | Android Screen | Status |
|------------|----------------|--------|
| CreateTaskScreen.swift | CreateTaskScreen.kt | Week 1 |
| TaskFeedScreen.swift | TaskFeedScreen.kt | Week 1 |
| TaskDetailScreen.swift | TaskDetailScreen.kt | Week 2 |
| ProofSubmissionScreen.swift | ProofSubmissionScreen.kt | Week 2 |
| ChatScreen.swift | ChatScreen.kt | Week 3 |
| ProfileScreen.swift | ProfileScreen.kt | Week 3 |
| EscrowScreen.swift | EscrowScreen.kt | Week 4 |
| SettingsScreen.swift | SettingsScreen.kt | Week 4 |
| Auth screens | Auth screens | Week 5 |
| Onboarding | Onboarding | Week 5 |
| Polish + QA | Polish + QA | Week 6 |

### Example Screen
```kotlin
// androidApp/src/main/java/com/hustlexp/ui/CreateTaskScreen.kt
@Composable
fun CreateTaskScreen(
    viewModel: CreateTaskViewModel = koinViewModel()
) {
    val state by viewModel.state.collectAsState()
    
    Scaffold(
        topBar = { HustleXPAppBar(title = "Create Task") }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp)
        ) {
            OutlinedTextField(
                value = state.title,
                onValueChange = viewModel::onTitleChange,
                label = { Text("Task Title") },
                modifier = Modifier.fillMaxWidth()
            )
            
            OutlinedTextField(
                value = state.description,
                onValueChange = viewModel::onDescriptionChange,
                label = { Text("Description") },
                modifier = Modifier.fillMaxWidth(),
                minLines = 3
            )
            
            MoneyInput(
                value = state.budget,
                onValueChange = viewModel::onBudgetChange,
                label = "Budget"
            )
            
            Button(
                onClick = { viewModel.createTask() },
                modifier = Modifier.fillMaxWidth(),
                enabled = !state.isLoading
            ) {
                if (state.isLoading) {
                    CircularProgressIndicator()
                } else {
                    Text("Create Task")
                }
            }
        }
    }
}
```

---

## Dependencies

### Shared Module
```kotlin
// shared/build.gradle.kts
plugins {
    kotlin("multiplatform")
    kotlin("plugin.serialization")
}

kotlin {
    android()
    iosX64()
    iosArm64()
    iosSimulatorArm64()
    
    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")
                implementation("io.ktor:ktor-client-core:2.3.4")
                implementation("io.ktor:ktor-client-content-negotiation:2.3.4")
                implementation("io.ktor:ktor-serialization-kotlinx-json:2.3.4")
            }
        }
        
        val androidMain by getting {
            dependencies {
                implementation("io.ktor:ktor-client-okhttp:2.3.4")
            }
        }
        
        val iosMain by getting {
            dependencies {
                implementation("io.ktor:ktor-client-darwin:2.3.4")
            }
        }
    }
}
```

### Android App
```kotlin
// androidApp/build.gradle.kts
plugins {
    id("com.android.application")
    kotlin("android")
}

dependencies {
    implementation(project(":shared"))
    
    // Jetpack Compose
    implementation(platform("androidx.compose:compose-bom:2023.10.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui-tooling-preview")
    
    // Navigation
    implementation("androidx.navigation:navigation-compose:2.7.4")
    
    // DI
    implementation("io.insert-koin:koin-android:3.5.0")
    implementation("io.insert-koin:koin-androidx-compose:3.5.0")
    
    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:32.4.0"))
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-messaging-ktx")
    
    // Stripe
    implementation("com.stripe:stripe-android:20.34.0")
    
    // Image loading
    implementation("io.coil-kt:coil-compose:2.4.0")
}
```

---

## Migration Strategy

### Phase 1: Shared Module (Week 1-2)
1. Extract models from iOS to KMP
2. Extract services (TRPC, Escrow, Auth)
3. Extract ViewModels
4. iOS uses shared module via KMP

### Phase 2: Android MVP (Week 3-6)
1. Create Android project structure
2. Implement 20 core screens
3. Integrate shared module
4. Firebase/Stripe setup
5. QA and polish

### Phase 3: Feature Parity (Ongoing)
- No iOS feature ships without Android equivalent
- Shared module ensures consistency
- Separate UI implementations for native feel

---

## Resource Requirements

| Role | Count | Duration | Cost |
|------|-------|----------|------|
| Android Lead | 1 | 6 weeks | $15K |
| KMP Engineer | 1 | 4 weeks | $10K |
| QA Engineer | 1 | 2 weeks | $4K |
| **Total** | | | **$29K** |

---

## Success Metrics

- [ ] 20 core screens functional
- [ ] Shared module covers 80% business logic
- [ ] Feature parity with iOS v1.0
- [ ] <100ms API response time
- [ ] Crash-free rate >99.5%
- [ ] Play Store approval

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| KMP learning curve | Hire KMP-experienced engineer |
| iOS regression | Comprehensive shared module tests |
| Play Store rejection | Early compliance review |
| Performance issues | Profiling + native optimization |

---

*Plan created: 2026-02-23*
*Target MVP: 2026-04-06 (6 weeks)*
