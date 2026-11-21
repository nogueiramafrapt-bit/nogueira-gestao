import 'package:flutter/material.dart';

class NogueiraHomePage extends StatefulWidget {
  const NogueiraHomePage({super.key});

  @override
  State<NogueiraHomePage> createState() => _NogueiraHomePageState();
}

class _NogueiraHomePageState extends State<NogueiraHomePage> {
  int _tab = 0;
  final List<_Product> _products = [
    _Product('Coxinha', 0.30, 'Salgados'),
    _Product('Bolinha de queijo', 0.30, 'Salgados'),
    _Product('Rissol de camarão', 0.35, 'Salgados'),
    _Product('Pão recheado', 8.00, 'Padaria'),
    _Product('Bolo caseiro', 10.00, 'Bolos'),
    _Product('Pizza brasileira', 17.00, 'Pizzas'),
  ];

  void _addProduct() {
    final name = TextEditingController();
    final price = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo produto'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
          TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Preço (€)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () {
            final value = double.tryParse(price.text.replaceAll(',', '.'));
            if (name.text.trim().isNotEmpty && value != null && value >= 0) {
              setState(() => _products.add(_Product(name.text.trim(), value, 'Geral')));
              Navigator.pop(context);
            }
          }, child: const Text('Guardar')),
        ],
      ),
    );
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
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NOGUEIRA GESTÃO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          Text('Nogueira Doces & Salgados', style: TextStyle(fontSize: 12)),
        ]),
      ),
      body: pages[_tab],
      floatingActionButton: _tab == 1 ? FloatingActionButton.extended(onPressed: _addProduct, icon: const Icon(Icons.add), label: const Text('Produto')) : null,
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
      const Text('Produtos registados nesta sessão'),
    ]))),
    const SizedBox(height: 12),
    const Text('Áreas de gestão', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const _FeatureTile(icon: Icons.inventory_2, title: 'Produtos e preços', subtitle: 'Catálogo e preços de venda'),
    const _FeatureTile(icon: Icons.calculate_outlined, title: 'Custos e margens', subtitle: 'Cálculo de custo e rentabilidade'),
    const _FeatureTile(icon: Icons.receipt_long, title: 'Encomendas e vendas', subtitle: 'Acompanhamento de pedidos'),
    const _FeatureTile(icon: Icons.warehouse_outlined, title: 'Stock', subtitle: 'Ingredientes e existências'),
  ]);

  Widget _productList() => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Catálogo de produtos', style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 8),
    ..._products.map((p) => Card(child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.restaurant_menu)),
      title: Text(p.name),
      subtitle: Text(p.category),
      trailing: Text('€ ${p.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
    ))),
  ]);
}

class _Product {
  _Product(this.name, this.price, this.category);
  final String name;
  final double price;
  final String category;
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
