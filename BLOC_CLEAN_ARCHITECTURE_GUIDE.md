# BLoC & Clean Architecture Learning Guide

This document explains the BLoC pattern and Clean Architecture concepts implemented in this project.

## 📚 What You're Learning

### 1. Clean Architecture Layers

Clean Architecture separates your app into **4 distinct layers**, each with a specific responsibility:

```
┌─────────────────────────────────────────────────┐
│ PRESENTATION LAYER (UI)                         │
│ - StudyHomePage (the screen users see)          │
│ - StudyBloc (state management)                  │
│ - StudyItemView (UI model)                      │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ DOMAIN LAYER (Business Logic)                   │
│ - Study (entity/model)                          │
│ - StudyRepository (interface)                   │
│ - GetStudies (usecase/business logic)           │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ DATA LAYER (Data Sources)                       │
│ - StudyLocalDataSource (where data comes from)  │
│ - StudyRepositoryImpl (repository implementation)│
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ EXTERNAL (Databases, APIs, Files)              │
│ - Local database, REST API, JSON files, etc.    │
└─────────────────────────────────────────────────┘
```

### 2. Data Flow Through Layers

When you open the app and the page loads studies:

```
1. StudyHomePage.initState()
   └─→ Sends StudyLoadRequested event to StudyBloc

2. StudyBloc receives the event
   └─→ Emits StudyLoading state (UI shows spinner)
   └─→ Calls GetStudies.call() from DOMAIN layer

3. GetStudies.call() (Domain Logic)
   └─→ Calls StudyRepository.getStudies() from DATA layer

4. StudyRepositoryImpl (Data Layer)
   └─→ Calls StudyLocalDataSource.fetch()
   └─→ Converts raw Map data → Study entities
   └─→ Returns List<Study>

5. GetStudies receives List<Study>
   └─→ Returns it to BLoC

6. StudyBloc transforms Study → StudyItemView
   └─→ Emits StudyLoaded state with transformed data

7. BlocBuilder in StudyHomePage
   └─→ Detects state change
   └─→ Rebuilds UI with the new data
   └─→ Displays GridView of study cards
```

### 3. Why Separate Layers?

| Benefit | Explanation |
|---------|-------------|
| **Testability** | Each layer can be tested independently without UI |
| **Reusability** | Domain logic can be used in web, mobile, desktop |
| **Maintainability** | Changes to one layer don't break others |
| **Flexibility** | Swap datasource (API → database) without changing UI |
| **Scalability** | Easy to add features without everything breaking |

---

## 🎯 BLoC Pattern Explained

BLoC = **Business Logic Component**

### The 3 Parts of BLoC

#### 1. **Events** (Input)
- Represent user actions: "Load studies", "Favorite this item", etc.
- Sent TO the BLoC
- Located in `study_event.dart`

```dart
class StudyLoadRequested extends StudyEvent {
  const StudyLoadRequested();
}
```

#### 2. **States** (Output)
- Represent the UI state: Loading, Loaded, Error, etc.
- Emitted BY the BLoC
- Located in `study_state.dart`

```dart
class StudyLoaded extends StudyState {
  final List<StudyItemView> items;
  const StudyLoaded(this.items);
}
```

#### 3. **BLoC** (Logic)
- Listens to events
- Uses business logic (domain layer)
- Emits states
- Located in `study_bloc.dart`

```dart
class StudyBloc extends Bloc<StudyEvent, StudyState> {
  Future<void> _onStudyLoadRequested(...) async {
    emit(const StudyLoading()); // Show spinner
    final studies = await _getStudies(); // Get data
    emit(StudyLoaded(items)); // Show data
  }
}
```

### BLoC Lifecycle

```
Create BLoC instance (in main.dart via BlocProvider)
         ↓
User interacts with UI
         ↓
Event is added to BLoC (context.read<StudyBloc>().add(...))
         ↓
BLoC listens for that event type
         ↓
BLoC's handler is called (e.g., _onStudyLoadRequested)
         ↓
BLoC emits states as it processes
         ↓
BlocBuilder listens to states
         ↓
UI rebuilds when state changes
```

---

## 📁 File Structure & Responsibilities

### `/presentation/bloc/`
**Purpose**: State management using BLoC pattern
- `study_event.dart` - Events (user actions)
- `study_state.dart` - States (UI states)
- `study_bloc.dart` - BLoC (business logic orchestration)

**Key Concept**: BLoC is the middleman between UI and Domain layer

### `/presentation/pages/`
**Purpose**: UI screens users interact with
- `study_home_page.dart` - Main screen, uses BlocBuilder
- `layout_study_page.dart` - Detail screen

**Key Concept**: Pages listen to BLoC states and rebuild UI accordingly

### `/domain/`
**Purpose**: Business logic (framework-independent)
- `entities/study.dart` - Data model
- `usecases/get_studies.dart` - Business logic ("get all studies")
- `repositories/study_repository.dart` - Interface

**Key Concept**: Domain doesn't know about Flutter, databases, or APIs

### `/data/`
**Purpose**: Fetching and transforming data
- `datasources/study_local_datasource.dart` - Data source (hardcoded, API, database, etc.)
- `repositories/study_repository_impl.dart` - Implements domain interface

**Key Concept**: Converts raw data into domain entities

### `/app/`
**Purpose**: Dependency Injection setup
- `study_hub_injection.dart` - Creates and wires up all dependencies

**Key Concept**: Central place where all layers connect

---

## 🔄 Dependency Injection Deep Dive

### What is DI?

Instead of classes creating their own dependencies:

```dart
// ❌ Bad (no DI)
class StudyBloc extends Bloc<StudyEvent, StudyState> {
  final GetStudies getStudies = GetStudies(...); // Creates its own
}
```

We provide them from outside:

```dart
// ✅ Good (with DI)
class StudyBloc extends Bloc<StudyEvent, StudyState> {
  final GetStudies getStudies;
  StudyBloc(this.getStudies); // Receives it
}
```

### The Chain in `study_hub_injection.dart`

```dart
StudyBloc createStudyBloc() {
  // Layer 1: DATA - Raw data source
  final dataSource = StudyLocalDataSource();

  // Layer 2: DATA - Repository implementation
  final repository = StudyRepositoryImpl(dataSource);

  // Layer 3: DOMAIN - Business logic
  final getStudies = GetStudies(repository);

  // Layer 4: PRESENTATION - State management
  final bloc = StudyBloc(getStudies);

  return bloc;
}
```

### Why This Matters for Testing

```dart
// In your test file
class FakeDataSource extends StudyLocalDataSource {
  @override
  Future<List<Map>> fetch() async {
    return [/* test data */]; // No real database!
  }
}

// Test the BLoC with fake data
final testBloc = StudyBloc(
  GetStudies(StudyRepositoryImpl(FakeDataSource()))
);
```

---

## 💡 Key Concepts to Remember

### 1. **Unidirectional Data Flow**
- Data flows DOWN through layers (Presentation → Domain → Data)
- Events flow UP from UI to BLoC
- States flow DOWN from BLoC to UI

### 2. **Separation of Concerns**
- Domain layer: Pure logic, no Flutter/database code
- Data layer: Fetching/storing, no business logic
- Presentation layer: UI only, delegates logic to BLoC

### 3. **Entity vs Model vs View**
- **Entity** (Domain): `Study` - business model
- **Model** (Data): Raw `Map` from datasource
- **View** (Presentation): `StudyItemView` - what UI needs

### 4. **Reactive UI**
- Don't manually call setState()
- Don't manually update widgets
- Just emit state changes, UI reacts automatically via BlocBuilder

### 5. **Framework Independence**
- Domain layer has ZERO imports from `package:flutter`
- Domain logic could run in backend, CLI, web, anywhere
- Only Presentation layer imports Flutter

---

## 🚀 Common Use Cases

### Adding a New Feature

1. **Add Domain Entity** (if new data type)
   - Create `Feature.dart` in domain/entities

2. **Add Domain Usecase**
   - Create `GetFeatures.dart` in domain/usecases
   - Define the business logic

3. **Add Data Layer**
   - Create datasource in data/datasources
   - Create repository implementation in data/repositories

4. **Add BLoC**
   - Create feature_event.dart
   - Create feature_state.dart
   - Create feature_bloc.dart

5. **Add Presentation**
   - Create pages/widgets using BlocBuilder
   - Wire up in main.dart with BlocProvider

6. **Update Injection**
   - Add createFeatureBloc() function

---

## 📖 Reading the Code

When you open a file, look for these patterns:

### In BLoC
```dart
// Event handler - listens for events and processes them
Future<void> _onStudyLoadRequested(...) async {
  emit(const StudyLoading()); // Emit state
  try {
    final data = await _usecase(); // Call domain
    emit(StudyLoaded(data)); // Emit success
  } catch (e) {
    emit(StudyError(e.toString())); // Emit error
  }
}
```

### In Pages
```dart
// Trigger events in initState or callbacks
@override
void initState() {
  super.initState();
  context.read<StudyBloc>().add(const StudyLoadRequested());
}

// Listen to states and rebuild UI
BlocBuilder<StudyBloc, StudyState>(
  builder: (context, state) {
    if (state is StudyLoading) return Spinner();
    if (state is StudyLoaded) return GridView(...);
    if (state is StudyError) return ErrorWidget();
  }
)
```

---

## 🎓 Learning Path

1. **Understand the layers** - Read the comments in each file explaining its layer
2. **Follow the data flow** - Trace a study from datasource to UI
3. **Study the BLoC pattern** - Understand Events → BLoC → States
4. **Learn Dependency Injection** - Why we inject instead of create
5. **Practice** - Add a new feature following the same pattern

---

## 📌 Files with Comments

All key files have detailed comments explaining:
- What each class/method does
- Why it's structured that way
- How it fits into the architecture
- Code examples and explanations

**Start reading here:**
1. `lib/src/app/study_hub_injection.dart` - See all layers connected
2. `lib/src/features/study_hub/presentation/bloc/study_bloc.dart` - Core logic
3. `lib/src/features/study_hub/presentation/pages/study_home_page.dart` - UI integration
4. `lib/src/app/main.dart` - App setup

---

## 🔗 Architecture Diagram

```
┌──────────────────────────────┐
│   StudyHomePage (StatefulWidget)
│   - Uses BlocBuilder
│   - Listens to StudyBloc states
│   - Sends StudyLoadRequested event
└──────────────┬───────────────┘
               │ event
               ▼
┌──────────────────────────────┐
│   StudyBloc (Business Logic)
│   - _onStudyLoadRequested()
│   - _toViewModel()
│   - Emits states
└──────────────┬───────────────┘
               │ calls
               ▼
┌──────────────────────────────┐
│   GetStudies (Domain Usecase)
│   - call() method
│   - Pure business logic
└──────────────┬───────────────┘
               │ calls
               ▼
┌──────────────────────────────┐
│   StudyRepository (Interface)
│   - getStudies()
└──────────────┬───────────────┘
               │ implemented by
               ▼
┌──────────────────────────────┐
│   StudyRepositoryImpl (Data)
│   - Transforms Map → Study
└──────────────┬───────────────┘
               │ uses
               ▼
┌──────────────────────────────┐
│   StudyLocalDataSource (Data)
│   - fetch() returns raw data
└──────────────┬───────────────┘
               │ represents
               ▼
        [Hardcoded Data]
      (Database/API in real app)
```

---

Happy Learning! 🚀

Feel free to:
- Read the comments in the code
- Trace data flow from datasource to UI
- Add print statements to see when things happen
- Try modifying the data and seeing how it flows through layers
