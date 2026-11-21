import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NogueiraHomePage extends StatefulWidget {
  const NogueiraHomePage({super.key});

  @override
  State<NogueiraHomePage> createState() => _NogueiraHomePageState();
}

class _NogueiraHomePageState extends State<NogueiraHomePage> {
  static const _storageKey = 'nogueira_products_v1';
  int _tab = 0;
  bool _loading = true;
  List<_Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    final loaded = <_Product>[];
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          loaded.add(_Product.fromJson(item as Map<String, dynamic>));
        }
      } catch (_) {
        // A lista inicial será apresentada se os dados guardados estiverem inválidos.
      }
    }
    if (!mounted) return;
    setState(() {
      _products = loaded.isEmpty ? _initialProducts() : loaded;
      _loading = false;
    });
    if (loaded.isEmpty) await _saveProducts();
  }

  List<_Product> _initialProducts() => [
    _Product('Coxinha', 0.30, 'Salgados'),
    _Product('Bolinha de queijo', 0.30, 'Salgados'),
    _Product('Rissol de camarão', 0.35, 'Salgados'),
    _Product('Pão recheado', 8.00, 'Padaria'),
    _Product('Bolo caseiro', 10.00, 'Bolos'),
    _Product('Pizza brasileira', 17.00, 'Pizzas'),
  ];

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_products.map((p) => p.toJson()).toList()));
  }

  Future<void> _openProductDialog({_Product? product, int? index}) async {
    final name = TextEditingController(text: product?.name ?? '');
    final price = TextEditingController(text: product?.price.toStringAsFixed(2) ?? '');
    final category = TextEditingController(text: product?.category ?? 'Geral');
    final result = await showDialog<_Product>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(product == null ? 'Novo produto' : 'Editar produto'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Nome')),
          TextField(controller: category, decoration: const InputDecoration(labelText: 'Categoria')),
          TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Preço de venda (€)')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          FilledButton(onPressed: () {
            final value = double.tryParse(price.text.trim().replaceAll(',', '.'));
            if (name.text.trim().isEmpty || value == null || value < 0 || category.text.trim().isEmpty) return;
            Navigator.pop(dialogContext, _Product(name.text.trim(), value, category.text.trim()));
          }, child: const Text('Guardar')),
        ],
      ),
    );
    name.dispose();
    price.dispose();
    category.dispose();
    if (result == null || !mounted) return;
    setState(() {
      if (index == null) {
        _products.add(result);
      } else {
        _products[index] = result;
      }
    });
    await _saveProducts();
  }

  Future<void> _deleteProduct(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Apagar produto?'),
        content: Text('Pretende apagar “${_products[index].name}” do catálogo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Apagar')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _products.removeAt(index));
    await _saveProducts();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _dashboard(),
      _productList(),
      const _PlaceholderPage(title: 'Encomendas', subtitle: 'Registo e acompanhamento de encomendas.'),
      const _PlaceholderPage(title: 'Clientes', subtitle: 'Ficha e contactos de clientes.'),
      const _PlaceholderPage(title: 'Stock e custos', subtitle: 'Ingredientes, existências e fichas técnicas.'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NOGUEIRA GESTÃO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        Text('Nogueira Doces & Salgados', style: TextStyle(fontSize: 12)),
      ])),
      body: _loading ? const Center(child: CircularProgressIndicator()) : pages[_tab],
      floatingActionButton: !_loading && _tab == 1
          ? FloatingActionButton.extended(onPressed: () => _openProductDialog(), icon: const Icon(Icons.add), label: const Text('Produto'))
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Produtos'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Encomendas'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Clientes'),
          NavigationDestination(icon: Icon(Icons.warehouse_outlined), label: 'Stock'),
        ],
      ),
    );
  }

  Widget _dashboard() => ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Bem-vindo!', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('Organize o seu negócio num só lugar.'),
      const SizedBox(height: 18),
      Text('${_products.length}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      const Text('Produtos guardados no dispositivo'),
    ]))),
    const SizedBox(height: 12),
    const Text('Áreas de gestão', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const _FeatureTile(icon: Icons.inventory_2, title: 'Produtos e preços', subtitle: 'Catálogo editável e guardado no telemóvel'),
    const _FeatureTile(icon: Icons.calculate_outlined, title: 'Custos e margens', subtitle: 'Cálculo de custo e rentabilidade'),
    const _FeatureTile(icon: Icons.receipt_long, title: 'Encomendas e vendas', subtitle: 'Acompanhamento de pedidos'),
    const _FeatureTile(icon: Icons.warehouse_outlined, title: 'Stock', subtitle: 'Ingredientes e existências'),
  ]);

  Widget _productList() => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Catálogo de produtos', style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 8),
    if (_products.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Ainda não existem produtos. Toque em “Produto” para adicionar.')),
    ..._products.asMap().entries.map((entry) {
      final i = entry.key;
      final p = entry.value;
      return Card(child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.restaurant_menu)),
        title: Text(p.name),
        subtitle: Text(p.category),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('€ ${p.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'edit') _openProductDialog(product: p, index: i);
              if (action == 'delete') _deleteProduct(i);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Apagar')),
            ],
          ),
        ]),
      ));
    }),
  ]);
}

class _Product {
  const _Product(this.name, this.price, this.category);
  final String name;
  final double price;
  final String category;

  Map<String, dynamic> toJson() => {'name': name, 'price': price, 'category': category};
  factory _Product.fromJson(Map<String, dynamic> json) => _Product(
    json['name'] as String,
    (json['price'] as num).toDouble(),
    json['category'] as String,
  );
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon, color: Theme.of(context).colorScheme.primary), title: Text(title), subtitle: Text(subtitle)));
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.construction_outlined, size: 48),
    const SizedBox(height: 12),
    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text(subtitle, textAlign: TextAlign.center),
    const SizedBox(height: 8),
    const Text('Módulo previsto para a próxima fase.', style: TextStyle(color: Colors.grey)),
  ])));
}
