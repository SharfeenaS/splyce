/// Amounts are stored in paise (int) to avoid floating point errors.
class Expense {
  final String title;
  final String payer;
  final int amount;
  final List<String> participants;
  Expense(this.title, this.payer, this.amount, this.participants);
}

class Debt {
  final String from, to;
  final int amount;
  Debt(this.from, this.to, this.amount);
  @override
  String toString() => '$from -> $to: $amount';
}

/// Net balance per person: positive = is owed money, negative = owes money.
Map<String, int> computeBalances(List<Expense> expenses) {
  final net = <String, int>{};
  for (final e in expenses) {
    final n = e.participants.length;
    if (n == 0) continue;
    final share = e.amount ~/ n;
    var remainder = e.amount - share * n; // spread leftover paise
    net[e.payer] = (net[e.payer] ?? 0) + e.amount;
    for (final p in e.participants) {
      final extra = remainder > 0 ? 1 : 0;
      remainder -= extra;
      net[p] = (net[p] ?? 0) - (share + extra);
    }
  }
  return net;
}

/// Minimum cash flow: repeatedly settle the largest debtor with the largest creditor.
List<Debt> minimizeCashFlow(Map<String, int> net) {
  final bal = Map<String, int>.from(net)..removeWhere((_, v) => v == 0);
  final result = <Debt>[];
  while (bal.isNotEmpty) {
    final creditor = bal.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final debtor = bal.entries.reduce((a, b) => a.value <= b.value ? a : b);
    if (creditor.value <= 0 || debtor.value >= 0) break;
    final amt = creditor.value < -debtor.value ? creditor.value : -debtor.value;
    result.add(Debt(debtor.key, creditor.key, amt));
    bal[creditor.key] = creditor.value - amt;
    bal[debtor.key] = debtor.value + amt;
    bal.removeWhere((_, v) => v == 0);
  }
  return result;
}
