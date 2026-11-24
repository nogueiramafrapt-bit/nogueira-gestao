import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const _customersKey = 'nogueira_customers_v1';
  static const _expensesKey = 'nogueira_expenses_v1';
  int _tab = 0;
  bool _loading = true;
  List<_Product> _products = [];
  List<_Ingredient> _ingredients = [];
  Map<String, List<_RecipeLine>> _recipes = {};
  List<_Order> _orders = [];
  List<_Customer> _customers = [];
  List<_Expense> _expenses = [];
  String _customerSearch = '';
  String _orderSearch = '';
  DateTime? _orderFrom;
  DateTime? _orderTo;
  String _expenseCategoryFilter = 'Todas';
  String _expenseMonthFilter = 'Todos';
  String _cashflowMonthFilter = 'Todos';

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
    List<_Customer> customers = [];
    List<_Expense> expenses = [];
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
    try { final raw = prefs.getString(_customersKey); if (raw != null) customers = (jsonDecode(raw) as List).map((e) => _Customer.fromJson(Map<String, dynamic>.from(e))).toList(); } catch (_) {}
    try { final raw = prefs.getString(_expensesKey); if (raw != null) expenses = (jsonDecode(raw) as List).map((e) => _Expense.fromJson(Map<String, dynamic>.from(e))).toList(); } catch (_) {}
    if (!mounted) return;
    setState(() {
      _products = products.isEmpty ? _initialProducts() : products;
      _ingredients = ingredients;
      _recipes = recipes;
      _orders = orders;
      _customers = customers;
      _expenses = expenses;
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

  Future<void> _saveCustomers() async { final prefs = await SharedPreferences.getInstance(); await prefs.setString(_customersKey, jsonEncode(_customers.map((e) => e.toJson()).toList())); }

  Future<void> _saveOrders() async { final prefs = await SharedPreferences.getInstance(); await prefs.setString(_ordersKey, jsonEncode(_orders.map((e) => e.toJson()).toList())); }

  Future<void> _saveExpenses() async { final prefs = await SharedPreferences.getInstance(); await prefs.setString(_expensesKey, jsonEncode(_expenses.map((e) => e.toJson()).toList())); }

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
    final pages = [_dashboard(), _productList(), _ordersPage(), _customersPage(), _costPage(), _stockPage(), _reportsPage(), _backupPage(), _expensesPage(), _cashflowPage()];
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
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Relatórios'),
          NavigationDestination(icon: Icon(Icons.backup_outlined), label: 'Backup'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Despesas'),
          NavigationDestination(icon: Icon(Icons.swap_vert_circle_outlined), label: 'Fluxo caixa'),
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



  Map<String, dynamic> _backupData() => {
    'app': 'Nogueira Gestão',
    'backup_created_at': DateTime.now().toIso8601String(),
    'products': _products.map((e) => e.toJson()).toList(),
    'ingredients': _ingredients.map((e) => e.toJson()).toList(),
    'recipes': _recipes.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
    'orders': _orders.map((e) => e.toJson()).toList(),
    'customers': _customers.map((e) => e.toJson()).toList(),
    'expenses': _expenses.map((e) => e.toJson()).toList(),
  };

  String _ordersCsv() {
    String cell(Object? value) => '"${(value ?? '').toString().replaceAll('"', '""')}"';
    final rows = <List<String>>[
      ['Data', 'Cliente', 'Telefone', 'Produto', 'Quantidade', 'Preço unitário (€)', 'Total (€)', 'Recebido (€)', 'Em falta (€)', 'Pagamento', 'Estado', 'Observações'],
      ..._orders.map((o) => [
        o.created.toIso8601String(), o.customer, o.phone, o.product,
        o.quantity.toString(), o.unitPrice.toStringAsFixed(2), o.total.toStringAsFixed(2),
        o.paidTotal.toStringAsFixed(2), (o.total - o.paidTotal).clamp(0, double.infinity).toStringAsFixed(2),
        o.payment, o.status, o.notes,
      ]),
    ];
    return '\uFEFF' + rows.map((r) => r.map(cell).join(';')).join('\n');
  }

  String _expensesCsv() {
    String cell(Object? value) => '"${(value ?? '').toString().replaceAll('"', '""')}"';
    final rows = <List<String>>[
      ['Data', 'Descrição', 'Categoria', 'Valor (€)'],
      ..._expenses.map((e) => [
        e.date.toIso8601String(), e.description, e.category, e.amount.toStringAsFixed(2),
      ]),
    ];
    return '\uFEFF' + rows.map((r) => r.map(cell).join(';')).join('\n');
  }

  Future<void> _showCopyData(String title, String content) async {
    await showDialog<void>(context: context, builder: (c) => AlertDialog(
      title: Text(title),
      content: SizedBox(width: 520, child: SingleChildScrollView(child: SelectableText(content, style: const TextStyle(fontSize: 11)))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Fechar')),
        FilledButton.icon(onPressed: () async {
          await Clipboard.setData(ClipboardData(text: content));
          if (c.mounted) Navigator.pop(c);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conteúdo copiado. Cole num ficheiro e guarde-o em segurança.')));
        }, icon: const Icon(Icons.copy), label: const Text('Copiar')),
      ],
    ));
  }


  Future<void> _restoreBackup() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Restaurar cópia de segurança'),
      content: SizedBox(width: 520, child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Cole abaixo o conteúdo JSON de uma cópia criada pela aplicação. Os dados atuais serão substituídos.'),
        const SizedBox(height: 10),
        TextField(controller: controller, minLines: 5, maxLines: 10, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Cole aqui o JSON do backup')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Validar e restaurar')),
      ],
    ));
    if (confirmed != true || !mounted) { controller.dispose(); return; }
    try {
      final decoded = Map<String, dynamic>.from(jsonDecode(controller.text));
      if (decoded['app'] != 'Nogueira Gestão') throw const FormatException('Este ficheiro não é uma cópia da Nogueira Gestão.');
      final products = (decoded['products'] as List).map((e) => _Product.fromJson(Map<String, dynamic>.from(e))).toList();
      final ingredients = (decoded['ingredients'] as List).map((e) => _Ingredient.fromJson(Map<String, dynamic>.from(e))).toList();
      final recipeJson = Map<String, dynamic>.from(decoded['recipes']);
      final recipes = recipeJson.map((k, v) => MapEntry(k, (v as List).map((e) => _RecipeLine.fromJson(Map<String, dynamic>.from(e))).toList()));
      final orders = (decoded['orders'] as List).map((e) => _Order.fromJson(Map<String, dynamic>.from(e))).toList();
      final customers = (decoded['customers'] as List).map((e) => _Customer.fromJson(Map<String, dynamic>.from(e))).toList();
      final expenses = ((decoded['expenses'] as List?) ?? []).map((e) => _Expense.fromJson(Map<String, dynamic>.from(e))).toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_productsKey, jsonEncode(products.map((e) => e.toJson()).toList()));
      await prefs.setString(_ingredientsKey, jsonEncode(ingredients.map((e) => e.toJson()).toList()));
      await prefs.setString(_recipesKey, jsonEncode(recipes.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()))));
      await prefs.setString(_ordersKey, jsonEncode(orders.map((e) => e.toJson()).toList()));
      await prefs.setString(_customersKey, jsonEncode(customers.map((e) => e.toJson()).toList()));
      await prefs.setString(_expensesKey, jsonEncode(expenses.map((e) => e.toJson()).toList()));
      if (!mounted) return;
      setState(() { _products = products; _ingredients = ingredients; _recipes = recipes; _orders = orders; _customers = customers; _expenses = expenses; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cópia restaurada com sucesso.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível restaurar: ${e is FormatException ? e.message : 'ficheiro inválido ou incompleto'}.')));
    } finally {
      controller.dispose();
    }
  }

  Widget _backupPage() => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Cópia de segurança e exportação', style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 6),
    const Text('Guarde uma cópia dos seus dados fora do telemóvel. Faça uma cópia regularmente.'),
    const SizedBox(height: 14),
    Card(child: ListTile(
      leading: const Icon(Icons.backup_outlined, size: 30),
      title: const Text('Cópia completa (JSON)'),
      subtitle: const Text('Inclui produtos, ingredientes, fichas técnicas, encomendas, clientes e despesas.'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCopyData('Cópia de segurança completa', const JsonEncoder.withIndent('  ').convert(_backupData())),
    )),
    Card(child: ListTile(
      leading: const Icon(Icons.settings_backup_restore, size: 30),
      title: const Text('Restaurar cópia JSON'),
      subtitle: const Text('Cole uma cópia anterior para recuperar todos os registos. Substitui os dados atuais.'),
      trailing: const Icon(Icons.chevron_right),
      onTap: _restoreBackup,
    )),
    Card(child: ListTile(
      leading: const Icon(Icons.table_chart_outlined, size: 30),
      title: const Text('Exportar encomendas (CSV)'),
      subtitle: const Text('Formato compatível com Excel. Inclui datas, clientes, valores e estados.'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCopyData('Exportação de encomendas (CSV)', _ordersCsv()),
    )),
    Card(child: ListTile(
      leading: const Icon(Icons.payments_outlined, size: 30),
      title: const Text('Exportar despesas (CSV)'),
      subtitle: const Text('Datas, descrição, categoria e valor para Excel.'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCopyData('Exportação de despesas (CSV)', _expensesCsv()),
    )),
    const SizedBox(height: 12),
    const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Importante: copie o conteúdo e cole num ficheiro para guardar no telemóvel ou computador. A restauração da cópia JSON substitui os dados atuais. Faça backups regularmente e guarde-os num local seguro.', style: TextStyle(fontSize: 12)))),
  ]);

  Future<void> _openExpenseDialog({_Expense? expense, int? index}) async {
    final description = TextEditingController(text: expense?.description ?? '');
    final amount = TextEditingController(text: expense?.amount.toStringAsFixed(2) ?? '');
    const categories = ['Ingredientes', 'Embalagens', 'Energia/água', 'Transporte/entregas', 'Renda', 'Equipamentos', 'Marketing', 'Impostos/taxas', 'Outros'];
    String category = expense?.category ?? categories.first;
    DateTime date = expense?.date ?? DateTime.now();
    final result = await showDialog<_Expense>(context: context, builder: (c) => StatefulBuilder(builder: (c, refresh) => AlertDialog(
      title: Text(expense == null ? 'Registar despesa' : 'Editar despesa'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: description, decoration: const InputDecoration(labelText: 'Descrição')),
        TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Valor (€)')),
        DropdownButtonFormField<String>(value: category, decoration: const InputDecoration(labelText: 'Categoria'), items: categories.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { if (v != null) refresh(() => category = v); }),
        ListTile(contentPadding: EdgeInsets.zero, title: const Text('Data da despesa'), subtitle: Text('${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'), trailing: const Icon(Icons.calendar_month), onTap: () async { final picked = await showDatePicker(context: c, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100)); if (picked != null) refresh(() => date = picked); }),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
        FilledButton(onPressed: () { final value = double.tryParse(amount.text.trim().replaceAll(',', '.')); if (description.text.trim().isEmpty || value == null || value <= 0) return; Navigator.pop(c, _Expense(description.text.trim(), category, value, date)); }, child: const Text('Guardar')),
      ],
    )));
    description.dispose(); amount.dispose();
    if (result == null || !mounted) return;
    setState(() { if (index == null) { _expenses.add(result); } else { _expenses[index] = result; } });
    await _saveExpenses();
  }

  Future<void> _deleteExpense(int index) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Apagar despesa?'),
      content: Text('Apagar "${_expenses[index].description}"?'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Apagar'))],
    ));
    if (ok != true || !mounted) return;
    setState(() => _expenses.removeAt(index));
    await _saveExpenses();
  }

  Widget _cashflowPage() {
    final months = <String>{};
    for (final o in _orders.where((e) => e.status == 'Concluída')) { months.add('${o.created.year}-${o.created.month.toString().padLeft(2, '0')}'); for (final p in o.payments) { months.add('${p.date.year}-${p.date.month.toString().padLeft(2, '0')}'); } }
    for (final e in _expenses) { months.add('${e.date.year}-${e.date.month.toString().padLeft(2, '0')}'); }
    final ordered = months.toList()..sort((a, b) => b.compareTo(a));
    final selected = _cashflowMonthFilter == 'Todos' ? (ordered.isEmpty ? '' : ordered.first) : _cashflowMonthFilter;
    String key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';
    double sales(String m) => _orders.where((o) => o.status == 'Concluída' && key(o.created) == m).fold<double>(0, (v, o) => v + o.total);
    double received(String m) => _orders.where((o) => o.status == 'Concluída').fold<double>(0, (v, o) => v + (o.payments.isEmpty ? (o.payment != 'Por pagar' && key(o.created) == m ? o.total : 0) : o.payments.where((p) => key(p.date) == m).fold<double>(0, (a, p) => a + p.amount)));
    double pending(String m) => _orders.where((o) => o.status == 'Concluída' && key(o.created) == m).fold<double>(0, (v, o) => v + (o.total - o.paidTotal).clamp(0, double.infinity));
    double spent(String m) => _expenses.where((e) => key(e.date) == m).fold<double>(0, (v, e) => v + e.amount);
    String eur(double v) => '€ ${v.toStringAsFixed(2)}';
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Fluxo financeiro mensal', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      const Text('Entradas recebidas, despesas registadas e valores por receber.'),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: ordered.contains(_cashflowMonthFilter) ? _cashflowMonthFilter : 'Todos',
        decoration: const InputDecoration(labelText: 'Período', border: OutlineInputBorder()),
        items: ['Todos', ...ordered].map((m) => DropdownMenuItem<String>(value: m, child: Text(m == 'Todos' ? 'Último mês com registos' : m.split('-').reversed.join('/')))).toList(),
        onChanged: (v) { if (v != null) setState(() => _cashflowMonthFilter = v); },
      ),
      if (selected.isNotEmpty) ...[
        const SizedBox(height: 12),
        GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.65, crossAxisSpacing: 8, mainAxisSpacing: 8, children: [
          _reportCard('Entradas recebidas', eur(received(selected)), Icons.south_west),
          _reportCard('Despesas registadas', eur(spent(selected)), Icons.north_east),
          _reportCard('Saldo do período', eur(received(selected) - spent(selected)), Icons.account_balance_wallet_outlined),
          _reportCard('Vendas por receber', eur(pending(selected)), Icons.pending_actions),
        ]),
        const SizedBox(height: 8),
        Text('Vendas concluídas: ${eur(sales(selected))}', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 18),
        Text('Evolução mensal', style: Theme.of(context).textTheme.titleMedium),
        ...ordered.map((m) {
          final income = received(m), expense = spent(m), balance = income - expense;
          return Card(child: ListTile(
            title: Text(m.split('-').reversed.join('/')),
            subtitle: Text('Entradas: ${eur(income)} · Despesas: ${eur(expense)} · Por receber: ${eur(pending(m))}'),
            trailing: Text(eur(balance), style: TextStyle(fontWeight: FontWeight.bold, color: balance >= 0 ? Colors.green : Colors.red)),
          ));
        }),
      ] else
        const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Ainda não existem vendas concluídas nem despesas registadas.'))),
      const Padding(padding: EdgeInsets.only(top: 12), child: Text('Estimativa: encomendas concluídas com pagamento diferente de “Por pagar” são consideradas entradas, pela data da encomenda. Despesas são consideradas pela data registada. Não substitui a conciliação bancária nem a contabilidade.', style: TextStyle(fontSize: 12, color: Colors.grey))),
    ]);
  }

  Widget _expensesPage() {
    final sorted = [..._expenses]..sort((a, b) => b.date.compareTo(a.date));
    final total = _expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final now = DateTime.now();
    final month = _expenses.where((e) => e.date.year == now.year && e.date.month == now.month).fold<double>(0, (sum, e) => sum + e.amount);
    final categories = ['Todas', 'Ingredientes', 'Embalagens', 'Energia/água', 'Transporte/entregas', 'Renda', 'Equipamentos', 'Marketing', 'Impostos/taxas', 'Outros'];
    final months = _expenses.map((e) => '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}').toSet().toList()..sort((a, b) => b.compareTo(a));
    final visible = sorted.where((e) {
      final categoryOk = _expenseCategoryFilter == 'Todas' || e.category == _expenseCategoryFilter;
      final monthKey = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}';
      return categoryOk && (_expenseMonthFilter == 'Todos' || monthKey == _expenseMonthFilter);
    }).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Despesas e fluxo de caixa', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      const Text('Registe os gastos do negócio. Os dados ficam guardados neste dispositivo e entram na cópia de segurança.'),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _reportCard('Despesas este mês', '€ ${month.toStringAsFixed(2)}', Icons.calendar_month)),
        Expanded(child: _reportCard('Total registado', '€ ${total.toStringAsFixed(2)}', Icons.receipt_long)),
      ]),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: _openExpenseDialog, icon: const Icon(Icons.add), label: const Text('Registar despesa')),
      const SizedBox(height: 16),
      Text('Filtrar histórico', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(
          value: _expenseCategoryFilter,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
          items: categories.map((v) => DropdownMenuItem(value: v, child: Text(v, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (v) { if (v != null) setState(() => _expenseCategoryFilter = v); },
        )),
        const SizedBox(width: 8),
        Expanded(child: DropdownButtonFormField<String>(
          value: _expenseMonthFilter,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Mês', border: OutlineInputBorder()),
          items: ['Todos', ...months].map((v) => DropdownMenuItem(value: v, child: Text(v == 'Todos' ? v : v.split('-').reversed.join('/')))).toList(),
          onChanged: (v) { if (v != null) setState(() => _expenseMonthFilter = v); },
        )),
      ]),
      const SizedBox(height: 12),
      Text('Histórico de despesas · ${visible.length}', style: Theme.of(context).textTheme.titleMedium),
      if (visible.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Não existem despesas para estes filtros.'))),
      ...visible.map((e) {
        final originalIndex = _expenses.indexOf(e);
        return Card(child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
          title: Text(e.description),
          subtitle: Text('${e.category} · ${e.date.day.toString().padLeft(2, '0')}/${e.date.month.toString().padLeft(2, '0')}/${e.date.year}'),
          trailing: Wrap(spacing: 0, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text('€ ${e.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(tooltip: 'Editar', onPressed: () => _openExpenseDialog(expense: e, index: originalIndex), icon: const Icon(Icons.edit_outlined)),
            IconButton(tooltip: 'Apagar', onPressed: () => _deleteExpense(originalIndex), icon: const Icon(Icons.delete_outline)),
          ]),
        ));
      }),
    ]);
  }

  Widget _reportsPage() {
    final completed = _orders.where((o) => o.status == 'Concluída').toList();
    final pending = _orders.where((o) => o.status == 'Pendente' || o.status == 'Em preparação').toList();
    final cancelled = _orders.where((o) => o.status == 'Cancelada').toList();
    final now = DateTime.now();
    final monthOrders = completed.where((o) => o.created.year == now.year && o.created.month == now.month).toList();
    final revenue = completed.fold<double>(0, (sum, o) => sum + o.total);
    final monthRevenue = monthOrders.fold<double>(0, (sum, o) => sum + o.total);
    final pendingValue = pending.fold<double>(0, (sum, o) => sum + o.total);
    final quantities = <String, double>{};
    final sales = <String, double>{};
    final costs = <String, double>{};
    final missingRecipes = <String>{};
    for (final order in completed) {
      for (final line in order.lines) {
        quantities[line.product] = (quantities[line.product] ?? 0) + line.quantity;
        sales[line.product] = (sales[line.product] ?? 0) + line.total;
        final product = _products.where((p) => p.name == line.product).firstOrNull;
        final recipe = _recipes[line.product] ?? [];
        if (product == null || recipe.isEmpty) {
          missingRecipes.add(line.product);
        } else {
          costs[line.product] = (costs[line.product] ?? 0) + _costFor(product) * line.quantity;
        }
      }
    }
    final productNames = quantities.keys.toList()..sort();
    final estimatedCost = costs.values.fold<double>(0, (sum, value) => sum + value);
    final estimatedProfit = revenue - estimatedCost;
    final operatingExpenses = _expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final monthExpenses = _expenses.where((e) => e.date.year == now.year && e.date.month == now.month).fold<double>(0, (sum, e) => sum + e.amount);
    final estimatedNet = estimatedProfit - operatingExpenses;
    final estimatedMonthCost = monthOrders.fold<double>(0, (sum, order) {
      for (final line in order.lines) {
        final product = _products.where((p) => p.name == line.product).firstOrNull;
        if (product != null && (_recipes[line.product] ?? []).isNotEmpty) sum += _costFor(product) * line.quantity;
      }
      return sum;
    });
    final estimatedMonthGross = monthRevenue - estimatedMonthCost;
    final estimatedMonthNet = estimatedMonthGross - monthExpenses;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Relatórios', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 4),
      const Text('Resumo calculado a partir das encomendas registadas.'),
      const SizedBox(height: 12),
      GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.65, crossAxisSpacing: 8, mainAxisSpacing: 8, children: [
        _reportCard('Vendas concluídas', '€ ${revenue.toStringAsFixed(2)}', Icons.euro),
        _reportCard('Este mês', '€ ${monthRevenue.toStringAsFixed(2)}', Icons.calendar_month),
        _reportCard('Lucro bruto estimado', '€ ${estimatedProfit.toStringAsFixed(2)}', Icons.trending_up),
        _reportCard('Despesas registadas', '€ ${operatingExpenses.toStringAsFixed(2)}', Icons.receipt_long),
        _reportCard('Lucro líquido estimado', '€ ${estimatedNet.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined),
        _reportCard('Despesas este mês', '€ ${monthExpenses.toStringAsFixed(2)}', Icons.calendar_month),
        _reportCard('Lucro líquido este mês*', '€ ${estimatedMonthNet.toStringAsFixed(2)}', Icons.date_range),
        _reportCard('Custo estimado', '€ ${estimatedCost.toStringAsFixed(2)}', Icons.calculate_outlined),
        _reportCard('Por concluir', '€ ${pendingValue.toStringAsFixed(2)}', Icons.pending_actions),
        _reportCard('Encomendas concluídas', completed.length.toString(), Icons.check_circle_outline),
      ]),
      const SizedBox(height: 18),
      Text('Vendas e lucro por produto', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      if (completed.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Ainda não há vendas concluídas para apresentar.'))),
      ...productNames.map((name) {
        final qty = quantities[name] ?? 0;
        final total = sales[name] ?? 0;
        final cost = costs[name];
        final profit = cost == null ? null : total - cost;
        final margin = profit == null || total <= 0 ? null : profit / total * 100;
        return Card(child: ListTile(
          title: Text(name),
          subtitle: Text('${qty.toStringAsFixed(2)} unidade(s) · Custo: ${cost == null ? 'sem ficha técnica' : '€ ${cost.toStringAsFixed(2)}'}${margin == null ? '' : ' · Margem bruta: ${margin.toStringAsFixed(1)}%'}'),
          trailing: Text('€ ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ));
      }),
      const SizedBox(height: 18),
      Text('Estado das encomendas', style: Theme.of(context).textTheme.titleMedium),
      Card(child: Column(children: [
        ListTile(title: const Text('Pendentes / em preparação'), trailing: Text('${pending.length} · € ${pendingValue.toStringAsFixed(2)}')),
        ListTile(title: const Text('Canceladas'), trailing: Text(cancelled.length.toString())),
      ])),
      Padding(padding: const EdgeInsets.only(top: 8), child: Text('Lucro líquido estimado = lucro bruto estimado menos todas as despesas registadas. Resultado mensal* = vendas concluídas do mês menos custo estimado dos ingredientes com ficha técnica e despesas registadas nesse mês. Não inclui custos não registados. Produtos sem ficha técnica não entram no custo estimado; valores não substituem a contabilidade oficial.', style: TextStyle(fontSize: 12, color: Colors.grey))),
      if (missingRecipes.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Fichas técnicas em falta: ${missingRecipes.join(', ')}', style: const TextStyle(fontSize: 12, color: Colors.deepOrange))),
    ]);
  }

  Widget _reportCard(String label, String value, IconData icon) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
    const SizedBox(height: 6),
    Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
    Text(label, style: const TextStyle(fontSize: 12), maxLines: 2),
  ])));

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
    final customer = TextEditingController(); final phone = TextEditingController(); final notes = TextEditingController();
    final drafts = <_DraftOrderLine>[_DraftOrderLine(_products.first.name)];
    DateTime? dueDate;
    String payment = 'Por pagar';
    final result = await showDialog<_Order>(context: context, builder: (c) => StatefulBuilder(builder: (c, refresh) => AlertDialog(
      title: const Text('Nova encomenda'),
      content: SizedBox(width: 480, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: customer, decoration: const InputDecoration(labelText: 'Nome do cliente')),
        TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefone / WhatsApp')),
        const SizedBox(height: 12),
        ...drafts.asMap().entries.map((entry) {
          final index = entry.key; final draft = entry.value;
          return Row(children: [
            Expanded(child: DropdownButton<String>(isExpanded: true, value: draft.product, items: _products.map((p) => DropdownMenuItem(value: p.name, child: Text(p.name, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) { if (v != null) refresh(() => draft.product = v); })),
            SizedBox(width: 76, child: TextField(controller: draft.quantity, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Qtd.'))),
            IconButton(onPressed: drafts.length == 1 ? null : () => refresh(() => drafts.removeAt(index)), icon: const Icon(Icons.remove_circle_outline)),
          ]);
        }),
        Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () => refresh(() => drafts.add(_DraftOrderLine(_products.first.name))), icon: const Icon(Icons.add), label: const Text('Adicionar produto'))),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event), title: Text(dueDate == null ? 'Prazo de entrega: não definido' : 'Entrega: '+dueDate!.day.toString().padLeft(2, '0')+'/'+dueDate!.month.toString().padLeft(2, '0')+'/'+dueDate!.year.toString()), trailing: IconButton(icon: const Icon(Icons.calendar_month), onPressed: () async { final picked = await showDatePicker(context: c, initialDate: dueDate ?? DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 730))); if (picked != null) refresh(() => dueDate = picked); })),
        DropdownButtonFormField<String>(value: payment, decoration: const InputDecoration(labelText: 'Pagamento'), items: const ['Por pagar','Dinheiro','MBWay','Transferência'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { if (v != null) refresh(() => payment = v); }),
        TextField(controller: notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Observações')),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')), FilledButton(onPressed: () {
        final lines = <_OrderLine>[];
        for (final draft in drafts) {
          final q = double.tryParse(draft.quantity.text.trim().replaceAll(',', '.'));
          if (q == null || q <= 0) return;
          final product = _products.firstWhere((p) => p.name == draft.product);
          lines.add(_OrderLine(product.name, q, product.price));
        }
        if (customer.text.trim().isEmpty) return;
        Navigator.pop(c, _Order(DateTime.now().millisecondsSinceEpoch.toString(), customer.text.trim(), phone.text.trim(), lines, payment, 'Pendente', notes.text.trim(), DateTime.now(), dueDate: dueDate));
      }, child: const Text('Guardar encomenda'))],
    )));
    customer.dispose(); phone.dispose(); notes.dispose(); for (final draft in drafts) { draft.dispose(); }
    if (result == null || !mounted) return;
    setState(() { _orders.insert(0, result); final existing = _customers.indexWhere((e) => e.name.toLowerCase() == result.customer.toLowerCase()); if (existing < 0) _customers.add(_Customer(result.customer, result.phone, '', DateTime.now())); else if (result.phone.isNotEmpty) _customers[existing].phone = result.phone; });
    await _saveOrders(); await _saveCustomers();
  }
  Future<void> _editCustomer({_Customer? customer, int? index}) async {
    final name = TextEditingController(text: customer?.name ?? ''); final phone = TextEditingController(text: customer?.phone ?? ''); final notes = TextEditingController(text: customer?.notes ?? '');
    final result = await showDialog<_Customer>(context: context, builder: (c) => AlertDialog(title: Text(customer == null ? 'Novo cliente' : 'Editar cliente'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')), TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefone / WhatsApp')), TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notas'))])), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')), FilledButton(onPressed: () { if (name.text.trim().isEmpty) return; Navigator.pop(c, _Customer(name.text.trim(), phone.text.trim(), notes.text.trim(), customer?.created ?? DateTime.now())); }, child: const Text('Guardar'))]));
    name.dispose(); phone.dispose(); notes.dispose(); if (result == null || !mounted) return;
    setState(() { if (index == null) { _customers.add(result); } else { _customers[index] = result; } }); await _saveCustomers();
  }
  Widget _customersPage() => ListView(padding: const EdgeInsets.all(16), children: [
    TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Pesquisar cliente por nome ou telefone', border: OutlineInputBorder()), onChanged: (v) => setState(() => _customerSearch = v.trim().toLowerCase())),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text('Carteira de clientes', style: Theme.of(context).textTheme.titleLarge)), FilledButton.icon(onPressed: () => _editCustomer(), icon: const Icon(Icons.person_add_alt_1), label: const Text('Novo'))]),
    const SizedBox(height: 10),
    Card(child: Padding(padding: const EdgeInsets.all(14), child: Text('${_customers.length} clientes registados', style: const TextStyle(fontWeight: FontWeight.bold)))),
    if (_customers.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Os clientes serão adicionados automaticamente ao registar encomendas. Também pode adicioná-los manualmente.')),
    ..._customers.asMap().entries.where((entry) => entry.value.name.toLowerCase().contains(_customerSearch) || entry.value.phone.toLowerCase().contains(_customerSearch)).map((entry) { final i = entry.key; final customer = entry.value; return Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person_outline)), title: Text(customer.name), subtitle: Text([if (customer.phone.isNotEmpty) customer.phone, if (customer.notes.isNotEmpty) customer.notes].join(' · ')), trailing: PopupMenuButton<String>(onSelected: (v) async { if (v == 'edit') await _editCustomer(customer: customer, index: i); if (v == 'delete') { setState(() => _customers.removeAt(i)); await _saveCustomers(); } }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'delete', child: Text('Apagar'))]))); }),
  ]);
  Future<void> _changeOrderStatus(_Order order, String status) async {
    final i = _orders.indexOf(order);
    if (i < 0 || order.status == status) return;
    if (status == 'Concluída' && !order.stockDeducted) {
      final orderLines = order.lines;
      if (orderLines.isEmpty || orderLines.any((item) => (_recipes[item.product] ?? []).isEmpty)) {
        setState(() => order.status = status);
        await _saveOrders();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Encomenda concluída. Falta ficha técnica em pelo menos um produto; stock não descontado.')));
        return;
      }
      final requirements = <_Ingredient, double>{};
      for (final item in orderLines) {
        for (final line in (_recipes[item.product] ?? [])) {
          final matches = _ingredients.where((e) => e.name == line.ingredient);
          if (matches.isEmpty) continue;
          final ingredient = matches.first;
          requirements[ingredient] = (requirements[ingredient] ?? 0) + line.quantity * item.quantity;
        }
      }
      final insufficient = requirements.entries.where((e) => e.key.stockQuantity < e.value).toList();
      if (insufficient.isNotEmpty) {
        final details = insufficient.map((e) => '${e.key.name}: disponível ${e.key.stockQuantity} ${e.key.unit}, necessário ${e.value} ${e.key.unit}').join('; ');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock insuficiente. ${details}')));
        return;
      }
      setState(() {
        for (final entry in requirements.entries) {
          final ingredient = entry.key;
          final idx = _ingredients.indexOf(ingredient);
          _ingredients[idx] = _Ingredient(ingredient.name, ingredient.unit, ingredient.pricePerUnit, stockQuantity: ingredient.stockQuantity - entry.value, minimumStock: ingredient.minimumStock);
        }
        order.stockDeducted = true;
        order.status = status;
      });
      await _saveCostData();
    } else {
      setState(() => order.status = status);
    }
    await _saveOrders();
  }
  Future<void> _registerPayment(_Order order) async {
    final amount = TextEditingController();
    String method = 'MBWay';
    DateTime date = DateTime.now();
    final remaining = order.total - order.paidTotal;
    final result = await showDialog<_PaymentEntry>(context: context, builder: (c) => StatefulBuilder(builder: (c, refresh) => AlertDialog(
      title: const Text('Registar recebimento'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Em falta: € ${remaining.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: amount, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Valor recebido (€)')),
        DropdownButtonFormField<String>(value: method, decoration: const InputDecoration(labelText: 'Método'), items: const ['Dinheiro','MBWay','Transferência','Outro'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { if (v != null) refresh(() => method = v); }),
        ListTile(contentPadding: EdgeInsets.zero, title: Text('Data: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'), trailing: IconButton(icon: const Icon(Icons.calendar_month), onPressed: () async { final picked = await showDatePicker(context: c, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100)); if (picked != null) refresh(() => date = picked); })),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')), FilledButton(onPressed: () { final v = double.tryParse(amount.text.trim().replaceAll(',', '.')); if (v == null || v <= 0 || v > remaining + 0.001) return; Navigator.pop(c, _PaymentEntry(v, method, date)); }, child: const Text('Guardar'))],
    )));
    amount.dispose();
    if (result == null || !mounted) return;
    setState(() { order.payments.add(result); });
    await _saveOrders();
  }
  Future<void> _pickOrderDate(bool from) async {
    final picked = await showDatePicker(context: context, initialDate: (from ? _orderFrom : _orderTo) ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() { if (from) { _orderFrom = picked; } else { _orderTo = picked; } });
  }
  Widget _ordersPage() {
    final filtered = _orders.where((o) {
      final q = _orderSearch.toLowerCase();
      final matchesText = o.customer.toLowerCase().contains(q) || o.phone.toLowerCase().contains(q) || o.product.toLowerCase().contains(q);
      final day = DateTime(o.created.year, o.created.month, o.created.day);
      final after = _orderFrom == null || !day.isBefore(DateTime(_orderFrom!.year, _orderFrom!.month, _orderFrom!.day));
      final before = _orderTo == null || !day.isAfter(DateTime(_orderTo!.year, _orderTo!.month, _orderTo!.day));
      return matchesText && after && before;
    }).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text('Encomendas e vendas', style: Theme.of(context).textTheme.titleLarge)), FilledButton.icon(onPressed: _newOrder, icon: const Icon(Icons.add), label: const Text('Nova'))]),
    const SizedBox(height: 10),
    TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Pesquisar encomenda, cliente ou produto', border: OutlineInputBorder()), onChanged: (v) => setState(() => _orderSearch = v.trim())),
    const SizedBox(height: 8),
    Wrap(spacing: 8, children: [
      OutlinedButton.icon(onPressed: () => _pickOrderDate(true), icon: const Icon(Icons.calendar_today), label: Text(_orderFrom == null ? 'De: início' : 'De: '+_orderFrom!.day.toString()+'/'+_orderFrom!.month.toString()+'/'+_orderFrom!.year.toString())),
      OutlinedButton.icon(onPressed: () => _pickOrderDate(false), icon: const Icon(Icons.event), label: Text(_orderTo == null ? 'Até: fim' : 'Até: '+_orderTo!.day.toString()+'/'+_orderTo!.month.toString()+'/'+_orderTo!.year.toString())),
      if (_orderFrom != null || _orderTo != null) TextButton(onPressed: () => setState(() { _orderFrom = null; _orderTo = null; }), child: const Text('Limpar datas')),
    ]),
    Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Column(children: [Text(_orders.length.toString(), style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)), const Text('Total')]),
      Column(children: [Text(_orders.where((e) => e.status == 'Pendente').length.toString(), style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)), const Text('Pendentes')]),
      Column(children: [Text('€ ' + _orders.where((e) => e.status == 'Concluída').fold<double>(0, (sum, e) => sum + e.total).toStringAsFixed(2), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Text('Concluído')]),
    ]))),
    if (_orders.isEmpty) const Padding(padding: EdgeInsets.all(28), child: Center(child: Text('Ainda não existem encomendas. Toque em Nova para registar a primeira.'))),
    if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('Nenhuma encomenda corresponde à pesquisa ou ao período selecionado.')),
    ...filtered.map((o) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(o.customer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), Text('€ ' + o.total.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))]),
      ...o.lines.map((line) => Text(line.product + ' · ' + line.quantity.toString() + ' × €' + line.unitPrice.toStringAsFixed(2))),
      if (o.phone.isNotEmpty) Text('Contacto: ' + o.phone),
      if (o.dueDate != null) Text('Prazo de entrega: '+o.dueDate!.day.toString().padLeft(2, '0')+'/'+o.dueDate!.month.toString().padLeft(2, '0')+'/'+o.dueDate!.year.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
      Text(o.created.day.toString().padLeft(2, '0') + '/' + o.created.month.toString().padLeft(2, '0') + '/' + o.created.year.toString() + ' · ' + o.payment),
      if (o.notes.isNotEmpty) Text('Obs.: ' + o.notes),
      Text('Recebido: € ${o.paidTotal.toStringAsFixed(2)} · Em falta: € ${(o.total - o.paidTotal).clamp(0, double.infinity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
      if (o.total - o.paidTotal > 0.009) Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () => _registerPayment(o), icon: const Icon(Icons.payments_outlined), label: const Text('Registar pagamento'))),
      if (o.payments.isNotEmpty) ...o.payments.asMap().entries.map((entry) { final paymentIndex = entry.key; final p = entry.value; return Padding(padding: const EdgeInsets.only(left: 8, top: 2), child: Row(children: [Expanded(child: Text('• ${p.date.day.toString().padLeft(2, '0')}/${p.date.month.toString().padLeft(2, '0')}/${p.date.year} · ${p.method}: € ${p.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.grey))), IconButton(tooltip: 'Anular recebimento', visualDensity: VisualDensity.compact, iconSize: 18, onPressed: () async { final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Anular recebimento?'), content: Text('Remover o recebimento de € ${p.amount.toStringAsFixed(2)}?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Manter')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Anular'))])); if (ok == true && mounted) { setState(() => o.payments.removeAt(paymentIndex)); await _saveOrders(); } }, icon: const Icon(Icons.delete_outline))])); }),
      Row(children: [const Text('Estado: '), DropdownButton<String>(value: o.status, items: const ['Pendente','Em preparação','Concluída','Cancelada'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { if (v != null) _changeOrderStatus(o, v); }), const Spacer(), IconButton(onPressed: () async { setState(() => _orders.remove(o)); await _saveOrders(); }, icon: const Icon(Icons.delete_outline))]),
    ]))))
  ]);
  }
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
class _Customer {
  _Customer(this.name, this.phone, this.notes, this.created);
  final String name; String phone; final String notes; final DateTime created;
  Map<String, dynamic> toJson() => {'name': name, 'phone': phone, 'notes': notes, 'created': created.toIso8601String()};
  factory _Customer.fromJson(Map<String, dynamic> j) => _Customer(j['name'] as String, (j['phone'] ?? '') as String, (j['notes'] ?? '') as String, DateTime.parse(j['created'] as String));
}
class _DraftOrderLine {
  _DraftOrderLine(this.product) : quantity = TextEditingController(text: '1');
  String product; final TextEditingController quantity;
  void dispose() => quantity.dispose();
}
class _OrderLine {
  _OrderLine(this.product, this.quantity, this.unitPrice);
  final String product; final double quantity, unitPrice;
  double get total => quantity * unitPrice;
  Map<String, dynamic> toJson() => {'product': product, 'quantity': quantity, 'unitPrice': unitPrice};
  factory _OrderLine.fromJson(Map<String, dynamic> j) => _OrderLine(j['product'] as String, (j['quantity'] as num).toDouble(), (j['unitPrice'] as num).toDouble());
}
class _Order {
  _Order(this.id, this.customer, this.phone, this.lines, this.payment, this.status, this.notes, this.created, {this.stockDeducted = false, this.dueDate, List<_PaymentEntry>? payments}) : payments = payments ?? [];
  final String id, customer, phone; final List<_OrderLine> lines; final String payment; String status; final String notes; final DateTime created; bool stockDeducted; final DateTime? dueDate; final List<_PaymentEntry> payments;
  double get paidTotal => payments.isNotEmpty ? payments.fold<double>(0, (s, p) => s + p.amount) : (payment != 'Por pagar' ? total : 0);
  String get product => lines.map((e) => e.product).join(', ');
  double get quantity => lines.fold(0, (s, e) => s + e.quantity);
  double get unitPrice => lines.isEmpty ? 0 : lines.first.unitPrice;
  double get total => lines.fold(0, (s, e) => s + e.total);
  Map<String, dynamic> toJson() => {'id': id, 'customer': customer, 'phone': phone, 'lines': lines.map((e) => e.toJson()).toList(), 'payment': payment, 'status': status, 'notes': notes, 'created': created.toIso8601String(), 'stockDeducted': stockDeducted, 'dueDate': dueDate?.toIso8601String(), 'payments': payments.map((p) => p.toJson()).toList()};
  factory _Order.fromJson(Map<String, dynamic> j) {
    final raw = j['lines'];
    final lines = raw is List
      ? raw.map((e) => _OrderLine.fromJson(Map<String, dynamic>.from(e))).toList()
      : <_OrderLine>[_OrderLine(j['product'] as String, (j['quantity'] as num).toDouble(), (j['unitPrice'] as num).toDouble())];
    return _Order(j['id'] as String, j['customer'] as String, (j['phone'] ?? '') as String, lines, j['payment'] as String, j['status'] as String, (j['notes'] ?? '') as String, DateTime.parse(j['created'] as String), stockDeducted: (j['stockDeducted'] as bool?) ?? false, dueDate: j['dueDate'] == null ? null : DateTime.tryParse(j['dueDate'] as String), payments: (j['payments'] as List? ?? []).map((e) => _PaymentEntry.fromJson(Map<String, dynamic>.from(e))).toList());
  }
}
class _PaymentEntry {
  _PaymentEntry(this.amount, this.method, this.date);
  final double amount; final String method; final DateTime date;
  Map<String, dynamic> toJson() => {'amount': amount, 'method': method, 'date': date.toIso8601String()};
  factory _PaymentEntry.fromJson(Map<String, dynamic> j) => _PaymentEntry((j['amount'] as num).toDouble(), j['method'] as String, DateTime.parse(j['date'] as String));
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

class _Expense {
  _Expense(this.description, this.category, this.amount, this.date);
  final String description, category;
  final double amount;
  final DateTime date;
  Map<String, dynamic> toJson() => {'description': description, 'category': category, 'amount': amount, 'date': date.toIso8601String()};
  factory _Expense.fromJson(Map<String, dynamic> j) => _Expense(j['description'] as String, j['category'] as String, (j['amount'] as num).toDouble(), DateTime.parse(j['date'] as String));
}
