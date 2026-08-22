```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  int _selectedPeriod = 0;

  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'All Time',
  ];

  Stream<QuerySnapshot<Map<String, dynamic>>> _entriesStream() {
    return _firestore
        .collection('mill_entries')
        .snapshots();
  }

  double _number(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  bool _isDeleted(Map<String, dynamic> data) {
    return data['isDeleted'] == true;
  }

  DateTime? _getDate(Map<String, dynamic> data) {
    final entryDate = data['entryDateTime'];

    if (entryDate is Timestamp) {
      return entryDate.toDate();
    }

    final createdAt = data['createdAt'];

    if (createdAt is Timestamp) {
      return createdAt.toDate();
    }

    return null;
  }

  bool _isInSelectedPeriod(DateTime? date) {
    if (_selectedPeriod == 3) {
      return true;
    }

    if (date == null) {
      return false;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final entryDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

    if (_selectedPeriod == 0) {
      return entryDay == today;
    }

    if (_selectedPeriod == 1) {
      final monday = today.subtract(
        Duration(
          days: today.weekday - 1,
        ),
      );

      final nextMonday = monday.add(
        const Duration(days: 7),
      );

      return !entryDay.isBefore(monday) &&
          entryDay.isBefore(nextMonday);
    }

    final monthStart = DateTime(
      now.year,
      now.month,
      1,
    );

    final nextMonth = DateTime(
      now.year,
      now.month + 1,
      1,
    );

    return !entryDay.isBefore(monthStart) &&
        entryDay.isBefore(nextMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _entriesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Firebase error:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          final filteredDocs = allDocs.where((doc) {
            final data = doc.data();

            if (_isDeleted(data)) {
              return false;
            }

            return _isInSelectedPeriod(
              _getDate(data),
            );
          }).toList();

          double totalKg = 0;
          double totalSales = 0;
          double totalPaid = 0;
          double totalUdhaar = 0;

          final customers = <String>{};

          for (final doc in filteredDocs) {
            final data = doc.data();

            totalKg += _number(
              data['quantityKg'],
            );

            totalSales += _number(
              data['totalAmount'],
            );

            totalPaid += _number(
              data['paidAmount'],
            );

            totalUdhaar += _number(
              data['udhaarAmount'],
            );

            final customer =
                data['customerName']
                        ?.toString()
                        .trim() ??
                    '';

            if (customer.isNotEmpty) {
              customers.add(customer);
            }
          }

          final remaining =
              totalSales - totalPaid;

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(
                const Duration(
                  milliseconds: 300,
                ),
              );
            },
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _periodSelector(),

                  const SizedBox(height: 20),

                  const Text(
                    'Business Overview',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _reportCard(
                          title: 'Total KG',
                          value:
                              '${totalKg.toStringAsFixed(2)} KG',
                          icon:
                              Icons.scale_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _reportCard(
                          title: 'Entries',
                          value:
                              '${filteredDocs.length}',
                          icon: Icons
                              .receipt_long_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _reportCard(
                          title: 'Customers',
                          value:
                              '${customers.length}',
                          icon: Icons
                              .people_alt_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _reportCard(
                          title: 'Sales',
                          value:
                              '₹${totalSales.toStringAsFixed(2)}',
                          icon: Icons
                              .currency_rupee_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Payment Overview',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _largeMoneyCard(
                    title: 'Total Paid',
                    value:
                        '₹${totalPaid.toStringAsFixed(2)}',
                    icon:
                        Icons.payments_rounded,
                  ),

                  const SizedBox(height: 12),

                  _largeMoneyCard(
                    title: 'Total Udhaar',
                    value:
                        '₹${totalUdhaar.toStringAsFixed(2)}',
                    icon: Icons
                        .account_balance_wallet_rounded,
                  ),

                  const SizedBox(height: 12),

                  _largeMoneyCard(
                    title: 'Remaining Amount',
                    value:
                        '₹${remaining.toStringAsFixed(2)}',
                    icon: Icons
                        .pending_actions_rounded,
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Report Entries',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${filteredDocs.length} entries',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (filteredDocs.isEmpty)
                    _emptyReport()
                  else
                    ...filteredDocs.map(
                      (doc) => _entryCard(
                        doc.data(),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _periodSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(
          _periods.length,
          (index) {
            final selected =
                _selectedPeriod == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = index;
                  });
                },
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Text(
                    _periods[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _reportCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _largeMoneyCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(14),
              color: const Color(0xFFEAF5F1),
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryCard(
    Map<String, dynamic> data,
  ) {
    final customer =
        data['customerName']
                ?.toString() ??
            'Unknown Customer';

    final kg = _number(
      data['quantityKg'],
    );

    final total = _number(
      data['totalAmount'],
    );

    final paid = _number(
      data['paidAmount'],
    );

    final udhaar = _number(
      data['udhaarAmount'],
    );

    final date = _getDate(data);

    return Card(
      margin:
          const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    customer.isEmpty
                        ? '?'
                        : customer[0]
                            .toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer,
                        style:
                            const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${kg.toStringAsFixed(2)} KG',
                        style:
                            const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _miniInfo(
                    'Paid',
                    '₹${paid.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    'Udhaar',
                    '₹${udhaar.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    'Date',
                    _formatDate(date),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniInfo(
    String title,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _emptyReport() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 52,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'No report data',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'There are no entries for the selected period.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '--';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
```
