# 🏥 PHC.Dispensing — Smart Health Clinical Node 

> **Project Resilience** · Clinical Inventory & Dispensing Management System  
> Built for **PHC Rampur**, Mandal Warangal · Sector 4 Supply Node

--- 
 
## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Screens & Navigation](#screens--navigation)
- [Design System](#design-system)
- [Responsive Layout](#responsive-layout)
- [Data Models](#data-models)
- [Getting Started](#getting-started)
- [Running the App](#running-the-app)
- [Demo Credentials](#demo-credentials)
- [Architecture](#architecture)

---

## Overview

**PHC.Dispensing** is a responsive Flutter application designed for real-time clinical inventory management at Primary Health Centres (PHCs). It enables pharmacists and medical officers to:

- Track medicine stock levels with live unit decrement
- Dispense medicines with batch validation
- Monitor cold-chain network transfers across supply nodes
- View district-level analytics and demand forecasts
- Manage multi-facility command operations

The app runs on **Mobile (Android / iOS)**, **Tablet**, **Web**, and **Desktop** from a single codebase using adaptive layouts.

---

## ✨ Features

### 🔐 Authentication
- Branded welcome screen with "Project Resilience" identity
- Secure login with Staff ID + Password validation
- Guest / demo mode for evaluation
- Register flow for new staff onboarding
- Session management with sign-out and terminal lock

### 💊 Dispense Screen
- Live inventory ledger with real-time unit decrement
- Medicine cards showing name, form, category badge, available units, and stock status
- One-tap dispense buttons: **-1**, **-5**, or **Custom** unit count
- Patient Case ID verification for emergency biologics (cold-chain audit trail)
- Expandable "Details" section with batch number, expiry date, and storage conditions
- Priority filter: **Standard** vs **Triage** medicines
- Barcode scanner simulation for medicine lookup
- Medicine search with instant filtering by name, ID, or category
- Status badges: 🟢 Safe, 🟡 Warning, 🔴 Critical with color-coded card borders

### 🎛️ Command Screen
- Operational jurisdiction overview with facility nodes
- Crisis simulation with emergency reroute dispatch
- Node health monitoring with stock level indicators
- 7-alert triage system with actionable directives

### 🔁 Transfers Screen
- Regional cold-chain dispatch tracking
- Transfer directives with origin/destination nodes
- ETA and quantity tracking for active shipments
- 2-directive status board with approval flow

### 📊 Analytics Screen
- District-level stock heatmap
- Demand forecast with autonomous reroute suggestions
- Critical vector identification and dismissal
- AI-powered transfer authorization flow
- Multi-view toggle: Heatmap · Forecast · Transfer Flow

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| UI Paradigm | Material 3 |
| State Management | `StatefulWidget` + `setState` (local state) |
| Routing | Named routes via `MaterialApp.onGenerateRoute` |
| Responsive Layout | `MediaQuery` + `AppBreakpoints` |
| Fonts | Roboto (Material default) |
| Icons | Material Icons |
| Platforms | Android · iOS · Web · macOS · Windows · Linux |
| SDK | Dart `^3.12.0` |
| Dependencies | `cupertino_icons ^1.0.8` |

No unnecessary third-party UI libraries — built entirely with Flutter's native widget system.

---

## 📁 Project Structure

```
smart_health/
├── lib/
│   ├── main.dart                        # App entry point
│   ├── app/
│   │   ├── app.dart                     # MaterialApp root
│   │   ├── app_constants.dart           # App-wide string constants
│   │   ├── app_router.dart              # Named route definitions & navigation
│   │   ├── app_theme.dart               # Color palette, spacing, radius, text styles
│   │   └── theme.dart                   # Legacy theme tokens
│   │
│   ├── core/
│   │   ├── responsive/
│   │   │   ├── breakpoints.dart         # Mobile/Tablet/Desktop breakpoints
│   │   │   └── responsive_builder.dart  # Responsive layout helper
│   │   └── widgets/
│   │       ├── app_button.dart          # Reusable button (compact, primary, secondary)
│   │       ├── app_card.dart            # Card container with optional left accent
│   │       ├── app_text_field.dart      # Styled input field
│   │       └── confidence_gauge.dart    # Analytics confidence indicator widget
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── controllers/
│   │   │   │   └── auth_controller.dart # Auth state & login/logout logic
│   │   │   └── screens/
│   │   │       ├── welcome_screen.dart  # Landing / brand screen
│   │   │       ├── login_screen.dart    # Staff login form
│   │   │       └── register_screen.dart # New staff registration
│   │   │
│   │   ├── screens/                     # Main feature screens
│   │   │   ├── dispense_screen.dart     # 💊 Primary dispensing ledger
│   │   │   ├── command_screen.dart      # 🎛️  Operational command centre
│   │   │   ├── transfers_screen.dart    # 🔁 Cold-chain transfer directives
│   │   │   └── analytics_screen.dart   # 📊 District analytics & forecast
│   │   │
│   │   └── shell/
│   │       ├── screens/
│   │       │   └── main_shell_screen.dart  # Adaptive shell (mobile/desktop)
│   │       └── widgets/
│   │           ├── app_header.dart         # Desktop top navigation bar
│   │           ├── desktop_sidebar.dart    # Desktop left sidebar nav
│   │           └── mobile_bottom_nav.dart  # Mobile bottom tab bar
│   │
│   ├── shared/
│   │   └── models/
│   │       ├── medicine_item.dart       # Medicine inventory data model + mock data
│   │       ├── command_node.dart        # Command node model + mock data
│   │       └── transfer_directive.dart  # Transfer directive model + mock data
│   │
│   ├── models/
│   │   └── medicine_inventory_item.dart # Legacy medicine model
│   │
│   ├── screens/
│   │   ├── dispensing_dashboard_screen.dart  # Legacy dashboard screen
│   │   └── login_screen.dart                 # Legacy login screen
│   │
│   ├── utils/
│   │   └── responsive.dart              # Responsive utility helpers
│   │
│   └── widgets/                         # Legacy reusable widgets
│       ├── action_button.dart
│       ├── app_header.dart
│       ├── clinic_status_card.dart
│       ├── custom_dispense_dialog.dart
│       ├── desktop_sidebar.dart
│       ├── dispensing_ledger_header.dart
│       ├── inventory_search_bar.dart
│       ├── medicine_inventory_card.dart
│       ├── mobile_bottom_navigation.dart
│       └── project_header.dart
│
├── pubspec.yaml                         # Project dependencies
├── analysis_options.yaml                # Dart lint configuration
└── README.md                            # This file
```

---

## 🧭 Screens & Navigation

### Route Map

```
/  (WelcomeScreen)
├── /login  (LoginScreen)
│   └── /dashboard  (MainShellScreen)
│       ├── Tab 0: DispenseScreen       💊 Dispensing Ledger
│       ├── Tab 1: CommandScreen        🎛️  Command Centre
│       ├── Tab 2: TransfersScreen      🔁 Transfer Directives
│       └── Tab 3: AnalyticsScreen      📊 Analytics & Forecast
└── /register  (RegisterScreen)
```

### Navigation Behavior

| Screen Size | Navigation Style |
|-------------|-----------------|
| Mobile < 600px | Bottom tab bar (4 items) |
| Tablet / Desktop ≥ 600px | Left sidebar (240px) + Top AppHeader |

---

## 🎨 Design System

### Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `purpleAccent` | `#5B5CE2` | Brand color, active states, sidebar highlight |
| `primaryBlue` | `#2563EB` | Session labels, active nav on mobile |
| `background` | `#F6F7FB` | App background |
| `surface` | `#FFFFFF` | Cards, panels |
| `textPrimary` | `#0F172A` | Headings, main content |
| `textSecondary` | `#64748B` | Subtitles, labels |
| `textMuted` | `#94A3B8` | Placeholders, timestamps |
| `greenText` | `#059669` | Safe stock status |
| `amberText` | `#D97706` | Warning stock status |
| `redText` | `#DC2626` | Critical / stockout status |
| `borderSubtle` | `#E2E8F0` | Card borders, dividers |

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Icon gaps, micro spacing |
| `sm` | 8px | Element gaps |
| `md` | 12px | Component padding |
| `lg` | 16px | Section padding |
| `xl` | 24px | Page padding |
| `xxl` | 32px | Large section gaps |

### Border Radius Scale

| Token | Value |
|-------|-------|
| `sm` | 6px |
| `md` | 10px |
| `lg` | 14px |
| `xl` | 16px |
| `pill` | 999px |

### Stock Status System

| Status | Color | Meaning |
|--------|-------|---------|
| 🟢 Safe | Green (`#059669`) | ≥ 14 days supply cover |
| 🟡 Warning | Amber (`#D97706`) | 3–13 days supply cover |
| 🔴 Critical | Red (`#DC2626`) | < 3 days / stockout risk |

---

## 📱 Responsive Layout

The app uses a single-codebase adaptive layout driven by `AppBreakpoints`:

```dart
class AppBreakpoints {
  static const double mobile  = 600.0;   // < 600px → mobile layout
  static const double tablet  = 1024.0;  // 600–1024px → tablet layout
  static const double desktop = 1440.0;  // > 1024px → desktop layout
}
```

### Mobile Layout (< 600px)
```
┌─────────────────────────┐
│  [+] Project Resilience │  ← Top bar (52px)
├─────────────────────────┤
│                         │
│     Screen Content      │  ← Scrollable, max-width 480px
│                         │
├─────────────────────────┤
│ Dispense Command Trans. │  ← Bottom tab nav
└─────────────────────────┘
```

### Desktop / Tablet Layout (≥ 600px)
```
┌────────────────────────────────────────────────┐
│  PHC.Dispensing  🟢 Cloud Sync   🔔  ⚙️   RW  │  ← AppHeader (56px)
├──────────┬─────────────────────────────────────┤
│ Sidebar  │                                     │
│          │       Screen Content                │
│ Dispense │       (max-width 1100px,            │
│ Command  │        scrollable)                  │
│ Transfers│                                     │
│ Analytics│                                     │
│          │                                     │
│ Node Card│                                     │
└──────────┴─────────────────────────────────────┘
  240px      flex: 1
```

---

## 📦 Data Models

### `MedicineItem`
```dart
class MedicineItem {
  final String id;           // e.g. "MED-8821"
  final String name;         // e.g. "Amoxicillin 500mg"
  final String category;     // e.g. "ANTIBIOTIC"
  final String formDescription; // e.g. "Oral Capsule • Standard Anti-infective"
  final int availableUnits;  // Current stock count
  final String unitLabel;    // e.g. "units", "vials", "sachets"
  final StockStatusType statusType;  // safe | warning | critical
  final String statusBadgeText;  // e.g. "Safe (14d cover)"
  final String priority;     // "Standard" | "Triage"
  final String footerText;   // e.g. "Ready for dispense"
  final bool hasRedBorder;   // Emergency biologic flag (needs Patient Case ID)
  // ... expiry, batch, storage fields
}
```

### `CommandNode`
```dart
class CommandNode {
  final String id;
  final String facilityName;
  final String location;
  final int stockPercentage;  // 0–100
  final String alertLevel;    // "normal" | "warning" | "critical"
  final int activeAlerts;
}
```

### `TransferDirective`
```dart
class TransferDirective {
  final String id;
  final String medicineId;
  final String medicineName;
  final String fromNode;
  final String toNode;
  final int quantity;
  final String status;  // "in_transit" | "pending" | "delivered"
  final String eta;
}
```

---

## 🚀 Getting Started

### Prerequisites

| Requirement | Version |
|-------------|---------|
| Flutter SDK | ≥ 3.12.0 |
| Dart SDK | ≥ 3.12.0 |
| Android Studio / VS Code | Latest |
| Chrome (for web) | Latest |

### Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd smart_health

# 2. Install dependencies
flutter pub get

# 3. Verify your Flutter environment
flutter doctor
```

---

## ▶️ Running the App

### Web (Chrome)
```bash
flutter run -d chrome
```

### Mobile (Android)
```bash
flutter run -d android
```

### Mobile (iOS)
```bash
flutter run -d ios
```

### Desktop (Windows)
```bash
flutter run -d windows
```

### Desktop (macOS)
```bash
flutter run -d macos
```

### Production Build

```bash
# Web
flutter build web --release

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release
```

---

## 🔑 Demo Credentials

Use these credentials on the Login screen to access the full dashboard:

| Field | Value |
|-------|-------|
| **Staff ID** | `PHC-WAR-882` |
| **Password** | `password123` |
| **Email** | `dr.warangal@phc.gov.in` |
| **Name** | Dr. R. Warangal |
| **Role** | Pharmacist Officer |
| **Facility** | PHC Rampur, Warangal |

> **Guest Mode** is also available — tap "Continue as Guest" on the Welcome screen to skip login.

---

## 🏗️ Architecture

The app follows a **feature-first** directory structure with clear separation of concerns:

```
Presentation Layer
  └── Features (auth / shell / screens)
        └── Screens & Widgets

Shared Layer
  └── Core Widgets (AppCard, AppButton, AppTextField)
  └── Design System (AppColors, AppSpacing, AppRadius, AppTheme)

Data Layer (Mock)
  └── Shared Models (MedicineItem, CommandNode, TransferDirective)
  └── Mock data factories (getInitialMockData())
```

### Key Architectural Decisions

1. **No external state management** — All state is local (`StatefulWidget + setState`). This keeps the codebase simple and dependency-free, appropriate for a hackathon / prototype.

2. **Mock data only** — No backend/API integration. All data is returned from static factory methods inside each model class (e.g., `MedicineItem.getInitialMockData()`). Easy to swap for real API calls.

3. **Single responsive shell** — `MainShellScreen` detects the screen width and switches between mobile (bottom nav) and desktop (sidebar + header) layouts. All 4 feature screens are shared between both.

4. **Design tokens** — All colors, spacing, and radii are defined in `AppTheme` / `AppColors` / `AppSpacing` / `AppRadius` classes. No hardcoded values in UI components.

5. **Named routing** — Navigation is handled via `MaterialApp.onGenerateRoute` with a central `AppRoutes` class for maintainability.

---

## 🔄 Hot Reload / Hot Restart

During development with `flutter run`:

| Action | Shortcut |
|--------|----------|
| Hot Reload | Press `r` in terminal |
| Hot Restart | Press `R` in terminal |
| Open DevTools | Press `v` in terminal |
| Quit | Press `q` in terminal |

---

## 📄 License

This project was built for a Hackathon. All rights reserved.

---

<div align="center">

**Built with ❤️ using Flutter · Project Resilience · PHC.Dispensing v1.0.0**

*Empowering frontline health workers with real-time clinical intelligence*

</div>
