import 'package:flutter/material.dart';
import 'settlement.dart';
import 'theme.dart';

const baseMembers = ['Diyana', 'Riya', 'Raseena', 'Sharfeena'];

class Request {
  final String type, text, by;
  String status = 'Open'; // Open -> Accepted -> Done
  String? acceptedBy;
  Request(this.type, this.text, this.by);
}

class HomePage extends StatefulWidget {
  final String userName;
  final VoidCallback onSignOut;
  const HomePage({super.key, required this.userName, required this.onSignOut});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  late String me = widget.userName;
  late final List<String> members = [...baseMembers, if (!baseMembers.contains(widget.userName)) widget.userName];
  final expenses = <Expense>[];
  final requests = <Request>[];

  String rs(int p) => '₹${(p / 100).toStringAsFixed(2)}';

  Widget avatar(String n, {double r = 18}) => CircleAvatar(
        radius: r,
        backgroundColor: const Color(0xFFE3EAF4),
        child: Text(initials(n), style: TextStyle(color: navy, fontSize: r * 0.7, fontWeight: FontWeight.w600)),
      );

  Widget empty(IconData i, String t, String s) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 44, color: border),
          const SizedBox(height: 12),
          Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(s, style: const TextStyle(color: muted)),
        ]),
      );

  Widget page(List<Widget> children) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(padding: const EdgeInsets.all(16), children: children),
        ),
      );

  Widget heading(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted, letterSpacing: 1)),
      );

  Future<void> addExpense() async {
    final title = TextEditingController(), amt = TextEditingController();
    String payer = me;
    final selected = {...members};
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('New expense'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 12),
                TextField(controller: amt, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (₹)')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: payer,
                  decoration: const InputDecoration(labelText: 'Paid by'),
                  items: members.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => set(() => payer = v!),
                ),
                const SizedBox(height: 16),
                const Text('Split equally between', style: TextStyle(color: muted, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 4, children: members.map((m) => FilterChip(
                      label: Text(m),
                      selected: selected.contains(m),
                      showCheckmark: false,
                      selectedColor: const Color(0xFFE3EAF4),
                      side: const BorderSide(color: border),
                      onSelected: (s) => set(() => s ? selected.add(m) : selected.remove(m)),
                    )).toList()),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(amt.text);
                if (v == null || v <= 0 || selected.isEmpty) return;
                setState(() => expenses.add(Expense(title.text.trim().isEmpty ? 'Expense' : title.text.trim(), payer, (v * 100).round(), selected.toList())));
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
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
          backgroundColor: Colors.white,
          title: const Text('New request'),
          content: SizedBox(
            width: 400,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'Lift', label: Text('Lift')),
                  ButtonSegment(value: 'Carry', label: Text('Carry')),
                  ButtonSegment(value: 'Borrow', label: Text('Borrow')),
                ],
                selected: {type},
                onSelectionChanged: (s) => set(() => type = s.first),
              ),
              const SizedBox(height: 16),
              TextField(controller: text, decoration: const InputDecoration(labelText: 'Details', hintText: 'Lift to Thrissur at 6 pm')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (text.text.trim().isEmpty) return;
                setState(() => requests.insert(0, Request(type, text.text.trim(), me)));
                Navigator.pop(ctx);
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  Widget statCard(String label, String value, {Color? color}) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: muted, fontSize: 12)),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color ?? ink)),
            ]),
          ),
        ),
      );

  Widget expensesTab() {
    final total = expenses.fold<int>(0, (s, e) => s + e.amount);
    final mine = computeBalances(expenses)[me] ?? 0;
    return page([
      Row(children: [
        statCard('Group spend', rs(total)),
        const SizedBox(width: 8),
        statCard(mine >= 0 ? 'You are owed' : 'You owe', rs(mine.abs()), color: mine >= 0 ? positive : negative),
      ]),
      heading('Expenses'),
      if (expenses.isEmpty)
        Padding(padding: const EdgeInsets.only(top: 60), child: empty(Icons.receipt_long_outlined, 'No expenses yet', 'Use the button below to add the first one.'))
      else
        ...expenses.reversed.map((e) => Card(
              child: ListTile(
                leading: avatar(e.payer),
                title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${e.payer} paid · ${e.participants.length} people', style: const TextStyle(color: muted)),
                trailing: Text(rs(e.amount), style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            )),
    ]);
  }

  Widget settleTab() {
    final net = computeBalances(expenses);
    final debts = minimizeCashFlow(net);
    if (net.isEmpty) return empty(Icons.balance_outlined, 'Nothing to settle', 'Balances appear once expenses are added.');
    return page([
      heading('Balances'),
      Card(
        child: Column(children: [
          for (final e in net.entries.toList()..sort((a, b) => b.value.compareTo(a.value))) ...[
            ListTile(
              leading: avatar(e.key),
              title: Text(e.key),
              trailing: Text(
                e.value >= 0 ? '+ ${rs(e.value)}' : '− ${rs(-e.value)}',
                style: TextStyle(fontWeight: FontWeight.w600, color: e.value >= 0 ? positive : negative),
              ),
            ),
            if (e.key != (net.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).last.key) const Divider(),
          ],
        ]),
      ),
      heading('Suggested payments · ${debts.length}'),
      if (debts.isEmpty) const Card(child: ListTile(title: Text('Everyone is settled up.')))
      else ...debts.map((d) => Card(
            child: ListTile(
              leading: avatar(d.from),
              title: Text('${d.from} pays ${d.to}'),
              trailing: Text(rs(d.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          )),
    ]);
  }

  Color statusColor(String s) => s == 'Open' ? accent : s == 'Accepted' ? const Color(0xFFB54708) : positive;

  Widget requestsTab() => requests.isEmpty
      ? empty(Icons.groups_outlined, 'No requests yet', 'Post a lift, carry or borrow request for the group.')
      : page(requests.map((r) {
          final icon = r.type == 'Lift' ? Icons.directions_car_outlined : r.type == 'Carry' ? Icons.inventory_2_outlined : Icons.swap_horiz;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Icon(icon, color: navy),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.text, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${r.type} · ${r.by}${r.acceptedBy != null ? " · accepted by ${r.acceptedBy}" : ""}', style: const TextStyle(color: muted, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(r.status.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: statusColor(r.status))),
                  ]),
                ),
                if (r.status != 'Done')
                  OutlinedButton(
                    onPressed: () => setState(() {
                      if (r.status == 'Open' && r.by != me) {
                        r.status = 'Accepted';
                        r.acceptedBy = me;
                      } else if (r.status == 'Accepted') {
                        r.status = 'Done';
                      }
                    }),
                    child: Text(r.status == 'Open' ? 'Accept' : 'Complete'),
                  ),
              ]),
            ),
          );
        }).toList());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Splyce'),
          actions: [
            PopupMenuButton<String>(
              tooltip: 'Account',
              offset: const Offset(0, 48),
              onSelected: (v) => v == '__out' ? widget.onSignOut() : setState(() => me = v),
              itemBuilder: (_) => [
                const PopupMenuItem(enabled: false, child: Text('View as (demo)', style: TextStyle(fontSize: 12))),
                ...members.map((m) => CheckedPopupMenuItem(value: m, checked: m == me, child: Text(m))),
                const PopupMenuDivider(),
                const PopupMenuItem(value: '__out', child: Text('Sign out')),
              ],
              child: Padding(padding: const EdgeInsets.only(right: 16), child: avatar(me, r: 16)),
            ),
          ],
        ),
        body: [expensesTab(), settleTab(), requestsTab()][tab],
        floatingActionButton: tab == 1
            ? null
            : FloatingActionButton.extended(
                onPressed: tab == 0 ? addExpense : addRequest,
                backgroundColor: navy,
                foregroundColor: Colors.white,
                elevation: 1,
                icon: const Icon(Icons.add),
                label: Text(tab == 0 ? 'Add expense' : 'New request'),
              ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Expenses'),
            NavigationDestination(icon: Icon(Icons.balance_outlined), selectedIcon: Icon(Icons.balance), label: 'Settle'),
            NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Requests'),
          ],
        ),
      );
}
