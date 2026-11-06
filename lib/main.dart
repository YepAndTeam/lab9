import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ---------------- MODEL ----------------

class Product {
  final int id;
  final String name;
  final double price;

  const Product(this.id, this.name, this.price);
}

// ---------------- STATE ----------------

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);

  int get count => _items.length;

  double get total => _items.fold(0.0, (sum, p) => sum + p.price);

  bool contains(Product p) => _items.any((e) => e.id == p.id);

  void add(Product p) {
    if (!contains(p)) {
      _items.add(p);
      notifyListeners();
    }
  }

  void remove(Product p) {
    _items.removeWhere((e) => e.id == p.id);
    notifyListeners();
  }

  void toggle(Product p) {
    if (contains(p)) {
      remove(p);
    } else {
      add(p);
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

// ---------------- APP ----------------

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Cart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CatalogScreen(),
    );
  }
}

// ---------------- SCREEN 1: CATALOG ----------------

const List<Product> kProducts = [
  Product(1, 'Headphones', 59.99),
  Product(2, 'Keyboard', 89.50),
  Product(3, 'Mouse', 24.90),
  Product(4, 'Monitor', 219.00),
  Product(5, 'Webcam', 45.00),
  Product(6, 'USB-C Hub', 32.75),
];

class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartProvider>().count;

    return IconButton(
      tooltip: 'Open cart',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
      },
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Catalog'),
        actions: const [CartBadgeButton(), SizedBox(width: 8)],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: kProducts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final product = kProducts[index];
          final inCart = cart.contains(product);

          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
              title: Text(product.name),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              trailing: inCart
                  ? FilledButton.tonalIcon(
                onPressed: () =>
                    context.read<CartProvider>().toggle(product),
                icon: const Icon(Icons.check),
                label: const Text('In cart'),
              )
                  : FilledButton.icon(
                onPressed: () =>
                    context.read<CartProvider>().toggle(product),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------- SCREEN 2: CART ----------------

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Cart (${cart.count})'),
        actions: [
          TextButton.icon(
            onPressed: cart.count == 0
                ? null
                : () => context.read<CartProvider>().clear(),
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Clear All'),
          ),
        ],
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final product = cart.items[index];
                return Card(
                  child: ListTile(
                    title: Text(product.name),
                    subtitle:
                    Text('\$${product.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          context.read<CartProvider>().remove(product),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '\$${cart.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}