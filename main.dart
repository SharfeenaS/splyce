import 'package:flutter/material.dart';
import 'settlement.dart';

void main() => runApp(const SplyceApp());

const members = ['Diyana', 'Riya', 'Raseena', 'Sharfeena'];

class Request {
  final String type, text, by;
  String status = 'Open'; // Open -> Accepted -> Done
  String? acceptedBy;
  Request(this.type, this.text, this.by);
}

class SplyceApp extends StatelessWidget {
  const SplyceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Splyce',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const Home(),
      );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  String me = members[0];
  final expenses = <Expense>[];
  final requests = <Request>[];

  String rs(int paise) => '₹${(paise / 100).toStringAsFixed(2)}';

  Future<void> addExpense() async {
    final title = TextEditingController(), amt = TextEditingController();
    String payer = me;
    final selected = {...members};
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text('Add expense'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'What for?')),
              TextField(controller: amt, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (₹)')),
              DropdownButtonFormField<String>(
                value: payer,
                decoration: const InputDecoration(labelText: 'Paid by'),
                items: members.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => set(() => payer = v!),
              ),
              Wrap(spacing: 6, children: members.map((m) => FilterChip(
                    label: Text(m),
                    selected: selected.contains(m),
                    onSelected: (s) => set(() => s ? selected.add(m) : selected.remove(m)),
                  )).toList()),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(amt.text);
                if (v == null || v <= 0 || selected.isEmpty) return;
                setState(() => expenses.add(Expense(title.text.isEmpty ? 'Expense' : title.text, payer, (v * 100).round(), selected.toList())));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addRequest() async {
    final text = TextEditingController();
    String type = 'Lift';
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text('New request'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Lift', label: Text('Lift')),
                ButtonSegment(value: 'Carry', label: Text('Carry')),
                ButtonSegment(value: 'Borrow', label: Text('Borrow')),
              ],
              selected: {type},
              onSelectionChanged: (s) => set(() => type = s.first),
            ),
            TextField(controller: text, decoration: const InputDecoration(labelText: 'e.g. Need a lift to Thrissur')),
          ]),
          actions: [
            FilledButton(
              onPressed: () {
                if (text.text.isEmpty) return;
                setState(() => requests.insert(0, Request(type, text.text, me)));
                Navigator.pop(ctx);
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  Widget expensesTab() => expenses.isEmpty
      ? const Center(child: Text('No expenses yet. Tap + to add one.'))
      : ListView(children: expenses.reversed.map((e) => ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text(e.title),
            subtitle: Text('${e.payer} paid · split with ${e.participants.length}'),
            trailing: Text(rs(e.amount)),
          )).toList());

  Widget settleTab() {
    final net = computeBalances(expenses);
    final debts = minimizeCashFlow(net);
    return ListView(padding: const EdgeInsets.all(12), children: [
      Text('Balances', style: Theme.of(context).textTheme.titleMedium),
      ...net.entries.map((e) => ListTile(
            dense: true,
            title: Text(e.key),
            trailing: Text(e.value >= 0 ? 'gets ${rs(e.value)}' : 'owes ${rs(-e.value)}',
                style: TextStyle(color: e.value >= 0 ? Colors.green : Colors.red)),
          )),
      const Divider(),
      Text('Settle up (${debts.length} payments)', style: Theme.of(context).textTheme.titleMedium),
      ...debts.map((d) => Card(child: ListTile(
            leading: const Icon(Icons.arrow_forward),
            title: Text('${d.from} pays ${d.to}'),
            trailing: Text(rs(d.amount)),
          ))),
    ]);
  }

  Widget requestsTab() => requests.isEmpty
      ? const Center(child: Text('No requests yet. Tap + to post one.'))
      : ListView(children: requests.map((r) => Card(
            child: ListTile(
              leading: Icon(r.type == 'Lift' ? Icons.directions_car : r.type == 'Carry' ? Icons.inventory_2 : Icons.handshake),
              title: Text(r.text),
              subtitle: Text('${r.type} · ${r.by} · ${r.status}${r.acceptedBy != null ? " by ${r.acceptedBy}" : ""}'),
              trailing: r.status == 'Done'
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : FilledButton.tonal(
                      onPressed: () => setState(() {
                        if (r.status == 'Open' && r.by != me) {
                          r.status = 'Accepted';
                          r.acceptedBy = me;
                        } else if (r.status == 'Accepted') {
                          r.status = 'Done';
                        }
                      }),
                      child: Text(r.status == 'Open' ? 'Accept' : 'Mark done'),
                    ),
            ),
          )).toList());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Splyce'),
          actions: [
            DropdownButton<String>(
              value: me,
              underline: const SizedBox(),
              items: members.map((m) => DropdownMenuItem(value: m, child: Text('As $m'))).toList(),
              onChanged: (v) => setState(() => me = v!), // demo: switch user on one phone
            ),
          ],
        ),
        body: [expensesTab(), settleTab(), requestsTab()][tab],
        floatingActionButton: tab == 1 ? null : FloatingActionButton(onPressed: tab == 0 ? addExpense : addRequest, child: const Icon(Icons.add)),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Expenses'),
            NavigationDestination(icon: Icon(Icons.balance), label: 'Settle'),
            NavigationDestination(icon: Icon(Icons.groups), label: 'Requests'),
          ],
        ),
      );
}
