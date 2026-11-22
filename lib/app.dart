import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NogueiraHomePage extends StatefulWidget {
  const NogueiraHomePage({super.key});
  @override
  State<NogueiraHomePage> createState() => _NogueiraHomePageState();
}

class _NogueiraHomePageState extends State<NogueiraHomePage> {
  static const _productsKey = 'nogueira_products_v1';
  static const _ingredientsKey = 'nogueira_ingredients_v1';
  static const _recipesKey = 'nogueira_recipes_v1';
  static const _ordersKey = 'nogueira_orders_v1';
  int _tab = 0;
  bool _loading = true;
  List<_Product> _products = [];
  List<_Ingredient> _ingredients = [];
  Map<String, List<_RecipeLine>> _recipes = {};
  List<_Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    List<_Product> products = [];
    List<_Ingredient> ingredients = [];
    Map<String, List<_RecipeLine>> recipes = {};
    List<_Order> orders = [];
    try {
      final raw = prefs.getString(_productsKey);
      if (raw != null) products = (jsonDecode(raw) as List).map((e) => _Product.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {}
    try {
      final raw = prefs.getString(_ingredientsKey);
      if (raw != null) ingredients = (jsonDecode(raw) as List).map((e) => _Ingredient.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {}
    try {
      final raw = prefs.getString(_recipesKey);
      if (raw != null) {
        final decoded = Map<String, dynamic>.from(jsonDecode(raw));
        recipes = decoded.map((key, value) => MapEntry(key, (value as List).map((e) => _RecipeLine.fromJson(Map<String, dynamic>.from(e))).toList()));
      }
    } catch (_) {}
    try { final raw = prefs.getString(_ordersKey); if (raw != null) orders = (jsonDecode(raw) as List).map((e) => _Order.fromJson(Map<String, dynamic>.from(e))).toList(); } catch (_) {}
    if (!mounted) return;
    setState(() {
      _products = products.isEmpty ? _initialProducts() : products;
      _ingredients = ingredients;
      _recipes = recipes;
      _orders = orders;
      _loading = false;
    });
    if (products.isEmpty) await _saveProducts();
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
    await prefs.setString(_productsKey, jsonEncode(_products.map((p) => p.toJson()).toList()));
  }

  Future<void> _saveOrders() async { final prefs = await SharedPreferences.getInstance(); await prefs.setString(_ordersKey, jsonEncode(_orders.map((e) => e.toJson()).toList())); }

  Future<void> _saveCostData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ingredientsKey, jsonEncode(_ingredients.map((e) => e.toJson()).toList()));
    await prefs.setString(_recipesKey, jsonEncode(_recipes.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()))));
  }

  Future<void> _openProductDialog({_Product? product, int? index}) async {
    final name = TextEditingController(text: product?.name ?? '');
    final price = TextEditingController(text: product?.price.toStringAsFixed(2) ?? '');
    final category = TextEditingController(text: product?.category ?? 'Geral');
    final result = await showDialog<_Product>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(product == null ? 'Novo produto' : 'Editar produto'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
        TextField(controller: category, decoration: const InputDecoration(labelText: 'Categoria')),
        TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Preço de venda (€)')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
        FilledButton(onPressed: () {
          final value = double.tryParse(price.text.trim().replaceAll(',', '.'));
          if (name.text.trim().isEmpty || category.text.trim().isEmpty || value == null || value < 0) return;
          Navigator.pop(dialogContext, _Product(name.text.trim(), value, category.text.trim()));
        }, child: const Text('Guardar')),
      ],
    ));
    name.dispose(); price.dispose(); category.dispose();
    if (result == null || !mounted) return;
    setState(() {
      if (index == null) {
        _products.add(result);
      } else {
        final oldName = _products[index].name;
        _products[index] = result;
        if (oldName != result.name && _recipes.containsKey(oldName)) {
          _recipes[result.name] = _recipes.remove(oldName)!;
        }
      }
    });
    await _saveProducts();
    await _saveCostData();
  }

  Future<void> _deleteProduct(int index) async {
    final oldName = _products[index].name;
    final confirmed = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Apagar produto?'),
      content: Text('Pretende apagar “$oldName” do catálogo?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Apagar')),
      ],
    ));
    if (confirmed != true || !mounted) return;
    setState(() { _products.removeAt(index); _recipes.remove(oldName); });
    await _saveProducts(); await _saveCostData();
  }

  Future<void> _openIngredientDialog({_Ingredient? ingredient, int? index}) async {
    final name = TextEditingController(text: ingredient?.name ?? '');
    final unit = TextEditingController(text: ingredient?.unit ?? 'kg');
    final price = TextEditingController(text: ingredient?.pricePerUnit.toStringAsFixed(2) ?? '');
    final stock = TextEditingController(text: ingredient?.stockQuantity.toString() ?? '0');
    final minimum = TextEditingController(text: ingredient?.minimumStock.toString() ?? '0');
    final result = await showDialog<_Ingredient>(context: context, builder: (c) => AlertDialog(
      title: Text(ingredient == null ? 'Novo ingrediente' : 'Editar ingrediente'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Ingrediente (ex.: farinha)')),
        TextField(controller: unit, decoration: const InputDecoration(labelText: 'Unidade de compra (kg, L, un.)')),
        TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Preço por unidade (€)')),
        TextField(controller: stock, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Stock atual')),
        TextField(controller: minimum, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Stock mínimo')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
        FilledButton(onPressed: () {
          final v = double.tryParse(price.text.trim().replaceAll(',', '.'));
          final q = double.tryParse(stock.text.trim().replaceAll(',', '.'));
          final m = double.tryParse(minimum.text.trim().replaceAll(',', '.'));
          if (name.text.trim().isEmpty || unit.text.trim().isEmpty || v == null || v < 0 || q == null || q < 0 || m == null || m < 0) return;
          Navigator.pop(c, _Ingredient(name.text.trim(), unit.text.trim(), v, stockQuantity: q, minimumStock: m));
        }, child: const Text('Guardar')),
      ],
    ));
    name.dispose(); unit.dispose(); price.dispose(); stock.dispose(); minimum.dispose();
    if (result == null || !mounted) return;
    setState(() {
      if (index == null) {
        _ingredients.add(result);
      } else {
        final old = _ingredients[index];
        _ingredients[index] = result;
        for (final lines in _recipes.values) {
          for (final line in lines) { if (line.ingredient == old.name) line.ingredient = result.name; }
        }
      }
    });
    await _saveCostData();
  }

  Future<void> _editRecipe(_Product product) async {
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registe primeiro os ingredientes e o respetivo preço de compra.')));
      return;
    }
    final draft = (_recipes[product.name] ?? []).map((e) => _RecipeLine(e.ingredient, e.quantity)).toList();
    final result = await showDialog<List<_RecipeLine>>(context: context, builder: (dialogContext) {
      return StatefulBuilder(builder: (context, refresh) => AlertDialog(
        title: Text('Ficha técnica: ${product.name}'),
        content: SizedBox(width: 420, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (draft.isEmpty) const Text('Adicione os ingredientes usados numa unidade/lote do produto.'),
          ...draft.asMap().entries.map((entry) {
            final i = entry.key; final line = entry.value;
            return Row(children: [
              Expanded(child: DropdownButton<String>(
                isExpanded: true,
                value: _ingredients.any((e) => e.name == line.ingredient) ? line.ingredient : _ingredients.first.name,
                items: _ingredients.map((e) => DropdownMenuItem(value: e.name, child: Text(e.name, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) { if (v != null) refresh(() => line.ingredient = v); },
              )),
              SizedBox(width: 82, child: TextFormField(
                key: ValueKey('qty-$i-${line.quantity}'),
                initialValue: line.quantity.toString(),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Qtd.'),
                onChanged: (v) { line.quantity = double.tryParse(v.replaceAll(',', '.')) ?? 0; },
              )),
              IconButton(onPressed: () => refresh(() => draft.removeAt(i)), icon: const Icon(Icons.delete_outline)),
            ]);
          }),
          Align(alignment: Alignment.centerLeft, child: TextButton.icon(
            onPressed: () => refresh(() => draft.add(_RecipeLine(_ingredients.first.name, 0))),
            icon: const Icon(Icons.add), label: const Text('Adicionar ingrediente'),
          )),
          const Text('Use a mesma unidade do ingrediente registado (kg, g, L, ml ou un.).', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ]))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, draft), child: const Text('Guardar ficha')),
        ],
      ));
    });
    if (result == null || !mounted) return;
    setState(() => _recipes[product.name] = result.where((e) => e.quantity > 0).toList());
    await _saveCostData();
  }

  double _costFor(_Product product) {
    final lines = _recipes[product.name] ?? [];
    return lines.fold(0, (sum, line) {
      final ingredient = _ingredients.where((e) => e.name == line.ingredient).firstOrNull;
      return sum + (ingredient?.pricePerUnit ?? 0) * line.quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_dashboard(), _productList(), _ordersPage(), const _PlaceholderPage(title: 'Clientes', subtitle: 'Ficha e contactos de clientes.'), _costPage(), _stockPage()];
    return Scaffold(
      appBar: AppBar(title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NOGUEIRA GESTÃO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        Text('Nogueira Doces & Salgados', style: TextStyle(fontSize: 12)),
      ])),
      body: _loading ? const Center(child: CircularProgressIndicator()) : pages[_tab],
      floatingActionButton: !_loading && (_tab == 1 || _tab == 4 || _tab == 5) ? FloatingActionButton.extended(
        onPressed: () => _tab == 1 ? _openProductDialog() : _openIngredientDialog(),
        icon: const Icon(Icons.add), label: Text(_tab == 1 ? 'Produto' : 'Ingrediente'),
      ) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab, onDestinationSelected: (v) => setState(() => _tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Produtos'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Encomendas'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Clientes'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), label: 'Custos'),
          NavigationDestination(icon: Icon(Icons.warehouse_outlined), label: 'Stock'),
        ],
      ),
    );
  }

  Widget _dashboard() => ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Bem-vindo!', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6), const Text('Organize o seu negócio num só lugar.'),
      const SizedBox(height: 18), Text('${_products.length}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      const Text('Produtos guardados no dispositivo'),
    ]))),
    const SizedBox(height: 12), const Text('Áreas de gestão', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const _FeatureTile(icon: Icons.inventory_2, title: 'Produtos e preços', subtitle: 'Catálogo editável e guardado no telemóvel'),
    const _FeatureTile(icon: Icons.calculate_outlined, title: 'Custos e margens', subtitle: 'Fichas técnicas e cálculo automático por produto'),
    const _FeatureTile(icon: Icons.receipt_long, title: 'Encomendas e vendas', subtitle: 'Acompanhamento de pedidos'),
    const _FeatureTile(icon: Icons.warehouse_outlined, title: 'Stock', subtitle: 'Ingredientes e existências'),
  ]);

  Widget _productList() => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Catálogo de produtos', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8),
    if (_products.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Ainda não existem produtos.')),
    ..._products.asMap().entries.map((entry) {
      final i = entry.key; final p = entry.value;
      return Card(child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.restaurant_menu)), title: Text(p.name), subtitle: Text(p.category),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('€ ${p.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          PopupMenuButton<String>(onSelected: (a) { if (a == 'edit') _openProductDialog(product: p, index: i); if (a == 'delete') _deleteProduct(i); },
            itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'delete', child: Text('Apagar'))]),
        ]),
      ));
    }),
  ]);

  Widget _costPage() => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Ingredientes e fichas técnicas', style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 4),
    const Text('Registe o preço de compra e depois indique a quantidade usada em cada produto.'),
    const SizedBox(height: 12),
    if (_ingredients.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Ainda não há ingredientes. Toque em “Ingrediente” para começar.'))),
    ..._ingredients.asMap().entries.map((entry) {
      final i = entry.key; final e = entry.value;
      return Card(child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.scale_outlined)),
        title: Text(e.name), subtitle: Text('€ ${e.pricePerUnit.toStringAsFixed(2)} por ${e.unit}'),
        trailing: PopupMenuButton<String>(onSelected: (a) { if (a == 'edit') _openIngredientDialog(ingredient: e, index: i); if (a == 'delete') _deleteIngredient(i); },
          itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'delete', child: Text('Apagar'))]),
      ));
    }),
    const Divider(height: 28),
    Text('Custo de produção por produto', style: Theme.of(context).textTheme.titleMedium),
    const SizedBox(height: 6),
    ..._products.map((p) {
      final cost = _costFor(p); final profit = p.price - cost;
      final hasRecipe = (_recipes[p.name] ?? []).isNotEmpty;
      return Card(child: ListTile(
        title: Text(p.name),
        subtitle: Text(hasRecipe ? 'Custo: € ${cost.toStringAsFixed(2)} · Lucro bruto: € ${profit.toStringAsFixed(2)}' : 'Ficha técnica ainda não criada'),
        trailing: IconButton(tooltip: 'Editar ficha técnica', onPressed: () => _editRecipe(p), icon: const Icon(Icons.edit_note)),
      ));
    }),
    const Padding(padding: EdgeInsets.only(top: 8), child: Text('Atenção: o cálculo considera apenas os ingredientes registados. Embalagens, energia, mão de obra e desperdício devem ser acrescentados como ingredientes/custos para obter uma estimativa mais completa.', style: TextStyle(fontSize: 12, color: Colors.grey))),
  ]);


  Future<void> _newOrder() async {
    if (_products.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicione primeiro um produto ao catálogo.'))); return; }
    final customer = TextEditingController(); final phone = TextEditingController(); final qty = TextEditingController(text: '1'); final notes = TextEditingController();
    String selected = _products.first.name; String payment = 'Por pagar';
    final result = await showDialog<_Order>(context: context, builder: (c) => StatefulBuilder(builder: (c, refresh) => AlertDialog(
      title: const Text('Nova encomenda'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: customer, decoration: const InputDecoration(labelText: 'Nome do cliente')),
        TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefone / WhatsApp')),
        DropdownButtonFormField<String>(value: selected, isExpanded: true, decoration: const InputDecoration(labelText: 'Produto'), items: _products.map((p) => DropdownMenuItem(value: p.name, child: Text(p.name + ' · €' + p.price.toStringAsFixed(2)))).toList(), onChanged: (v) { if (v != null) refresh(() => selected = v); }),
        TextField(controller: qty, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quantidade')),
        DropdownButtonFormField<String>(value: payment, decoration: const InputDecoration(labelText: 'Pagamento'), items: const ['Por pagar','Dinheiro','MBWay','Transferência'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { if (v != null) refresh(() => payment = v); }),
        TextField(controller: notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Observações')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')), FilledButton(onPressed: () {
        final q = double.tryParse(qty.text.trim().replaceAll(',', '.')); final p = _products.firstWhere((e) => e.name == selected);
        if (customer.text.trim().isEmpty || q == null || q <= 0) return;
        Navigator.pop(c, _Order(DateTime.now().millisecondsSinceEpoch.toString(), customer.text.trim(), phone.text.trim(), selected, q, p.price, payment, 'Pendente', notes.text.trim(), DateTime.now()));
      }, child: const Text('Guardar encomenda'))],
    )));
    customer.dispose(); phone.dispose(); qty.dispose(); notes.dispose();
    if (result == null || !mounted) return; setState(() => _orders.insert(0, result)); await _saveOrders();
  }
  Future<void> _changeOrderStatus(_Order order, String status) async { final i = _orders.indexOf(order); if (i < 0) return; setState(() => _orders[i].status = status); await _saveOrders(); }
  Widget _ordersPage() => ListView(padding: const EdgeInsets.all(16), children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text('Encomendas e vendas', style: Theme.of(context).textTheme.titleLarge)), FilledButton.icon(onPressed: _newOrder, icon: const Icon(Icons.add), label: const Text('Nova'))]),
    const SizedBox(height: 10),
    Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Column(children: [Text(_orders.length.toString(), style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)), const Text('Total')]),
      Column(children: [Text(_orders.where((e) => e.status == 'Pendente').length.toString(), style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)), const Text('Pendentes')]),
      Column(children: [Text('€ ' + _orders.where((e) => e.status == 'Concluída').fold<double>(0, (sum, e) => sum + e.total).toStringAsFixed(2), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Text('Concluído')]),
    ]))),
    if (_orders.isEmpty) const Padding(padding: EdgeInsets.all(28), child: Center(child: Text('Ainda não existem encomendas. Toque em Nova para registar a primeira.'))),
    ..._orders.map((o) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(o.customer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), Text('€ ' + o.total.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))]),
      Text(o.product + ' · ' + o.quantity.toString() + ' × €' + o.unitPrice.toStringAsFixed(2)),
      if (o.phone.isNotEmpty) Text('Contacto: ' + o.phone),
      Text(o.created.day.toString().padLeft(2, '0') + '/' + o.created.month.toString().padLeft(2, '0') + '/' + o.created.year.toString() + ' · ' + o.payment),
      if (o.notes.isNotEmpty) Text('Obs.: ' + o.notes),
      Row(children: [const Text('Estado: '), DropdownButton<String>(value: o.status, items: const ['Pendente','Em preparação','Concluída','Cancelada'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { if (v != null) _changeOrderStatus(o, v); }), const Spacer(), IconButton(onPressed: () async { setState(() => _orders.remove(o)); await _saveOrders(); }, icon: const Icon(Icons.delete_outline))]),
    ]))))
  ]);
  Future<void> _stockMovement(_Ingredient ingredient, bool entry) async {
    final controller = TextEditingController();
    final amount = await showDialog<double>(context: context, builder: (c) => AlertDialog(
      title: Text(entry ? 'Entrada de stock' : 'Saída de stock'),
      content: TextField(controller: controller, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Quantidade em ${ingredient.unit}')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
        FilledButton(onPressed: () { final v = double.tryParse(controller.text.trim().replaceAll(',', '.')); if (v == null || v <= 0) return; Navigator.pop(c, v); }, child: Text(entry ? 'Registar entrada' : 'Registar saída')),
      ],
    ));
    controller.dispose();
    if (amount == null || !mounted) return;
    if (!entry && amount > ingredient.stockQuantity) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock insuficiente para esta saída.'))); return; }
    final index = _ingredients.indexOf(ingredient);
    if (index < 0) return;
    setState(() { _ingredients[index] = _Ingredient(ingredient.name, ingredient.unit, ingredient.pricePerUnit, stockQuantity: ingredient.stockQuantity + (entry ? amount : -amount), minimumStock: ingredient.minimumStock); });
    await _saveCostData();
  }

  Widget _stockPage() => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Controlo de stock', style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 4),
    const Text('Registe entradas e saídas para acompanhar as existências dos ingredientes.'),
    const SizedBox(height: 12),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Column(children: [Text('${_ingredients.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const Text('Ingredientes')]),
      Column(children: [Text('${_ingredients.where((e) => e.stockQuantity <= e.minimumStock).length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)), const Text('Stock baixo')]),
    ]))),
    if (_ingredients.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('Adicione ingredientes na área Custos para começar.')),
    ..._ingredients.map((e) {
      final low = e.stockQuantity <= e.minimumStock;
      return Card(child: ListTile(
        leading: CircleAvatar(backgroundColor: low ? Colors.red.shade50 : Colors.green.shade50, child: Icon(low ? Icons.warning_amber_rounded : Icons.check, color: low ? Colors.red : Colors.green)),
        title: Text(e.name),
        subtitle: Text('Disponível: ${e.stockQuantity} ${e.unit} · Mínimo: ${e.minimumStock} ${e.unit}'),
        trailing: PopupMenuButton<String>(onSelected: (v) { if (v == 'in') _stockMovement(e, true); if (v == 'out') _stockMovement(e, false); },
          itemBuilder: (_) => const [PopupMenuItem(value: 'in', child: Text('Registar entrada')), PopupMenuItem(value: 'out', child: Text('Registar saída'))]),
      ));
    }),
  ]);

  Future<void> _deleteIngredient(int index) async {
    final ingredient = _ingredients[index];
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Apagar ingrediente?'), content: Text('Apagar ${ingredient.name}?'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Apagar'))],
    ));
    if (ok != true || !mounted) return;
    setState(() { _ingredients.removeAt(index); for (final lines in _recipes.values) { lines.removeWhere((line) => line.ingredient == ingredient.name); } });
    await _saveCostData();
  }
}

class _Product {
  const _Product(this.name, this.price, this.category);
  final String name; final double price; final String category;
  Map<String, dynamic> toJson() => {'name': name, 'price': price, 'category': category};
  factory _Product.fromJson(Map<String, dynamic> j) => _Product(j['name'] as String, (j['price'] as num).toDouble(), j['category'] as String);
}
class _Ingredient {
  const _Ingredient(this.name, this.unit, this.pricePerUnit, {this.stockQuantity = 0, this.minimumStock = 0});
  final String name; final String unit; final double pricePerUnit; final double stockQuantity; final double minimumStock;
  Map<String, dynamic> toJson() => {'name': name, 'unit': unit, 'pricePerUnit': pricePerUnit, 'stockQuantity': stockQuantity, 'minimumStock': minimumStock};
  factory _Ingredient.fromJson(Map<String, dynamic> j) => _Ingredient(j['name'] as String, j['unit'] as String, (j['pricePerUnit'] as num).toDouble(), stockQuantity: (j['stockQuantity'] as num? ?? 0).toDouble(), minimumStock: (j['minimumStock'] as num? ?? 0).toDouble());
}
class _RecipeLine {
  _RecipeLine(this.ingredient, this.quantity);
  String ingredient; double quantity;
  Map<String, dynamic> toJson() => {'ingredient': ingredient, 'quantity': quantity};
  factory _RecipeLine.fromJson(Map<String, dynamic> j) => _RecipeLine(j['ingredient'] as String, (j['quantity'] as num).toDouble());
}
class _Order {
  _Order(this.id, this.customer, this.phone, this.product, this.quantity, this.unitPrice, this.payment, this.status, this.notes, this.created);
  final String id, customer, phone, product; final double quantity, unitPrice; final String payment; String status; final String notes; final DateTime created;
  double get total => quantity * unitPrice;
  Map<String, dynamic> toJson() => {'id': id, 'customer': customer, 'phone': phone, 'product': product, 'quantity': quantity, 'unitPrice': unitPrice, 'payment': payment, 'status': status, 'notes': notes, 'created': created.toIso8601String()};
  factory _Order.fromJson(Map<String, dynamic> j) => _Order(j['id'] as String, j['customer'] as String, (j['phone'] ?? '') as String, j['product'] as String, (j['quantity'] as num).toDouble(), (j['unitPrice'] as num).toDouble(), j['payment'] as String, j['status'] as String, (j['notes'] ?? '') as String, DateTime.parse(j['created'] as String));
}
class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon; final String title; final String subtitle;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon, color: Theme.of(context).colorScheme.primary), title: Text(title), subtitle: Text(subtitle)));
}
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, required this.subtitle});
  final String title; final String subtitle;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.construction_outlined, size: 48), const SizedBox(height: 12),
    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
    Text(subtitle, textAlign: TextAlign.center), const SizedBox(height: 8),
    const Text('Módulo previsto para a próxima fase.', style: TextStyle(color: Colors.grey)),
  ])));
}
