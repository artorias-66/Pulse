# Ledger — Ethereal Invest 📈

A production-quality Flutter stock investing app built from the **"Ethereal Ledger"** design system.

## Why This Is Showcase-Ready

- Deep-linkable navigation via `go_router` (`/home`, `/explore`, `/portfolio`, `/profile`, `/stock/:id`)
- Riverpod state architecture with reusable providers and computed selectors
- Persistent watchlist using Hive local storage
- Pull-to-refresh + retryable error states across key surfaces
- Widget + unit test coverage for core formatting and chart utilities
- CI workflow for static analysis and test execution

## ✨ Features

| Screen | Highlights |
|---|---|
| **Home** | Portfolio summary card, interactive fl_chart, horizontal watchlist with sparklines |
| **Explore** | Live search + category filter chips, market movers with sparkline |
| **Stock Detail** | Interactive chart (1D/1W/1M/1Y), Buy/Sell bottom sheet, Key Stats grid |
| **Portfolio** | Gradient balance card, interactive pie chart, holdings list with P&L |
| **Profile** | Avatar, KYC badge, grouped settings, logout confirmation |
| **Auth** | Email/password login + signup, persisted session, route protection |

### Authentication Demo

- Default demo account:
  - Email: `demo@pulse.app`
  - Password: `Demo@123`
- Session persists across app restarts (local storage).
- Protected routes automatically show login screen when signed out.

## 🏗️ Architecture

```
lib/
  core/
    theme/         ← AppColors, AppTheme (Material 3)
    utils/         ← Formatters, ChartHelpers
  data/
    models/        ← Stock, Holding, PortfolioSummary
    mock/          ← 12 stocks, portfolio holdings
  features/
    home/          ← HomeScreen + widgets
    explore/       ← ExploreScreen
    stock/         ← StockDetailScreen
    portfolio/     ← PortfolioScreen
    profile/       ← ProfileScreen
  providers/       ← Riverpod providers (stocks, portfolio, watchlist)
  widgets/         ← BottomNavBar, SkeletonLoader, SparklineChart, PriceChip
  core/storage/    ← LocalStorage (Hive-backed app persistence)
  app.dart         ← App shell with tab fade transitions
  main.dart        ← Entry point
```

### Navigation

- `MaterialApp.router` with `go_router`
- Tab shell routing for bottom navigation
- Shareable stock details route: `/stock/:id`

### Data & State

- `StateNotifierProvider` for async stock and portfolio states
- `AuthNotifier` for sign-in/sign-up/sign-out session handling
- Persistent watchlist store (`Hive`) with fallback defaults
- Derived providers for filtering, categories, watchlist data, and stock lookup by id

## 🛠️ Tech Stack

- **Flutter** (stable)
- **State Management**: Riverpod 2.x (`StateNotifierProvider`, `Provider`)
- **HTTP Client**: Dio 5.x (wired up, data is mocked)
- **Charts**: fl_chart 0.68
- **Fonts**: Google Fonts (Plus Jakarta Sans + Inter)
- **Shimmer**: shimmer 3.x for skeleton loaders
- **Persistence**: Hive/Hive Flutter
- **Routing**: go_router (deep links + shell navigation)

## 🚀 Getting Started

```bash
git clone https://github.com/yourname/pulse.git
cd pulse
flutter pub get
flutter run
```

## ✅ Quality Gates

Run locally:

```bash
flutter analyze
flutter test
```

GitHub Actions CI runs both checks on every push/PR.

## 🧪 Testing

- `test/widget_test.dart` → app smoke test
- `test/formatters_test.dart` → formatting logic correctness
- `test/chart_helpers_test.dart` → chart helper edge cases

## 👨‍💻 Interview Talking Points (Groww App Team)

- Scaled UX: deep links + resilient screen states (loading/error/retry/refresh)
- App architecture: clear feature separation and composable state derivations
- Reliability: local persistence and deterministic utility tests
- Developer velocity: CI checks and maintainable reusable widgets

## 🎨 Design System

Based on Stitch "Zenith Invest Mobile UI" — **The Ethereal Ledger**:
- Primary: `#006C4F` (Forest Green)
- Accent: `#00D09C`
- Loss/Sell: `#B02C31` (Editorial Red)
- Background: `#F8F9FA` (Studio White)
- No hard borders — surface tonal hierarchy
- Gradient buttons, frosted glass nav bar

## 📸 Screens

> Home → Explore → Stock Detail → Portfolio → Profile

## 📄 License

MIT
