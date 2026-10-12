import 'package:flutter_test/flutter_test.dart';
import 'package:splyce/settlement.dart';

void main() {
  test('equal split, one payer', () {
    final b = computeBalances([Expense('Dinner', 'A', 60000, ['A', 'B', 'C'])]);
    expect(b['A'], 40000);
    expect(b['B'], -20000);
    final d = minimizeCashFlow(b);
    expect(d.length, 2);
  });

  test('balances always sum to zero (odd paise)', () {
    final b = computeBalances([Expense('Taxi', 'A', 10001, ['A', 'B', 'C'])]);
    expect(b.values.reduce((x, y) => x + y), 0);
  });

  test('cycle collapses to zero payments', () {
    final b = computeBalances([
      Expense('1', 'A', 10000, ['B']),
      Expense('2', 'B', 10000, ['C']),
      Expense('3', 'C', 10000, ['A']),
    ]);
    expect(minimizeCashFlow(b), isEmpty);
  });

  test('fewer payments than naive pairwise', () {
    final ex = [
      Expense('1', 'A', 30000, ['A', 'B', 'C', 'D']),
      Expense('2', 'B', 20000, ['A', 'B', 'C', 'D']),
    ];
    final naive = ex.fold<int>(0, (s, e) => s + e.participants.where((p) => p != e.payer).length);
    expect(minimizeCashFlow(computeBalances(ex)).length, lessThanOrEqualTo(naive));
  });
}
