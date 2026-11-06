# Lab 9 — Multi-Screen Global Cart with Live Badge

A Flutter app with two screens that share one global cart state using `provider` and `ChangeNotifier`.

## Features

- **Catalog screen**
    - 6 products with price
    - "Add to Cart" button that toggles to "In cart" and back
    - Live badge on the cart icon in the AppBar showing the number of items
- **Cart screen**
    - List of selected products
    - Remove button for each item
    - Total price calculation
    - "Clear All" button
    - Empty state message when the cart has no items
- **Instant sync between screens**: any change made on one screen is immediately reflected on the other, because both screens listen to the same `CartProvider`.

## How it works

| Part | Description |
|------|-------------|
| `Product` | Simple model with `id`, `name`, `price` |
| `CartProvider` | `ChangeNotifier` that stores the items and exposes `add`, `remove`, `toggle`, `clear`, `count`, `total`, `contains` |
| `ChangeNotifierProvider` | Wraps `MyApp` at the root so the whole app has access to the cart |
| `context.watch<CartProvider>()` | Used in widgets that must rebuild when the cart changes (badge, lists, total) |
| `context.read<CartProvider>()` | Used in button callbacks to call cart methods |

## Project structure

```
lib/
└── main.dart   # model, provider, app, catalog screen, cart screen
```

## Getting started

### Requirements

- Flutter SDK (Dart 3.7+)
- Android Studio or VS Code with the Flutter plugin

### Run

```bash
git clone https://github.com/YepAndTeam/lab9.git
cd lab9
flutter pub get
flutter run
```

## Demo scenario (sync check)

1. In the catalog, add 3 products. The badge shows `3`.
2. Open the cart. You see 3 items and the total price.
3. Remove one item. The total updates and the title shows `Cart (2)`.
4. Go back. The badge shows `2` and the removed product has the "Add to Cart" button again.
5. Open the cart and press **Clear All**. Go back: the badge is gone and all buttons are "Add to Cart".

## Dependencies

- [`provider`](https://pub.dev/packages/provider) — state management