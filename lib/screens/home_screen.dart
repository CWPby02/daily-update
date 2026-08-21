import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'new_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Update',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Mill Management',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('mill_entries')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _errorState(
              snapshot.error.toString(),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          final todayEntries = documents.where((doc) {
            final data = doc.data();

            final timestamp =
                data['entryDateTime'];

            if (timestamp is! Timestamp) {
              return false;
            }

            final date = timestamp.toDate();
            final now = DateTime.now();

            return date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
          }).toList();

          double totalKg = 0;
          double totalSales = 0;
          double totalPaid = 0;
          double totalUdhaar = 0;

          for (final doc in todayEntries) {
            final data = doc.data();

            totalKg +=
                _toDouble(data['quantityKg']);

            totalSales +=
                _toDouble(data['totalAmount']);

            totalPaid +=
                _toDouble(data['paidAmount']);

            totalUdhaar +=
                _toDouble(data['udhaarAmount']);
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                // Firestore Stream automatically refreshes.
                await Future<void>.delayed(
                  const Duration(milliseconds: 300),
                );
              },
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(22),
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xFF176B52),
                            Color(0xFF0E4D3B),
                          ],
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Day 👋',
                            style: TextStyle(
                              color:
                                  Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Manage your mill easily.',
                            style: TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Today's Overview",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // First row
                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            title: 'Total KG',
                            value:
                                '${_formatNumber(totalKg)} KG',
                            icon:
                                Icons.scale_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _summaryCard(
                            title: 'Sales',
                            value:
                                _formatCurrency(
                              totalSales,
                            ),
                            icon: Icons
                                .currency_rupee_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Second row
                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            title: 'Paid',
                            value:
                                _formatCurrency(
                              totalPaid,
                            ),
                            icon:
                                Icons.payments_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _summaryCard(
                            title: 'Udhaar',
                            value:
                                _formatCurrency(
                              totalUdhaar,
                            ),
                            icon: Icons
                                .account_balance_wallet_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // New Entry Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child:
                          ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NewEntryScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add_rounded,
                        ),
                        label: const Text(
                          'New Mill Entry',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton
                            .styleFrom(
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text(
                          'Recent Entries',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        if (documents.isNotEmpty)
                          Text(
                            '${documents.length} total',
                            style:
                                const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (documents.isEmpty)
                      _emptyState()
                    else
                      ...documents
                          .take(5)
                          .map(
                            (doc) =>
                                _entryCard(
                              doc.data(),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // Bottom Navigation
      bottomNavigationBar:
          NavigationBar(
        selectedIndex: 0,
        onDestinationSelected:
            (index) {
          // Navigation will be connected later.
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.receipt_long_outlined,
            ),
            label: 'Entries',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.payments_outlined,
            ),
            label: 'Payment',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value.toStringAsFixed(2);
  }

  static String _formatCurrency(double value) {
    if (value == value.roundToDouble()) {
      return '₹${value.toInt()}';
    }

    return '₹${value.toStringAsFixed(2)}';
  }

  Widget _entryCard(
    Map<String, dynamic> data,
  ) {
    final customerName =
        data['customerName']
            ?.toString() ??
        'Unknown Customer';

    final product =
        data['product']
            ?.toString() ??
        'Unknown Product';

    final kg =
        _toDouble(
      data['quantityKg'],
    );

    final total =
        _toDouble(
      data['totalAmount'],
    );

    final paid =
        _toDouble(
      data['paidAmount'],
    );

    final udhaar =
        _toDouble(
      data['udhaarAmount'],
    );

    final timestamp =
        data['entryDateTime'];

    String dateText = '';

    if (timestamp is Timestamp) {
      dateText =
          _formatDateTime(
        timestamp.toDate(),
      );
    }

    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEAF5F0,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color:
                      Color(0xFF176B52),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      '$product • ${_formatNumber(kg)} KG',
                      style:
                          const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                _formatCurrency(total),
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(
            height: 1,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _entryInfo(
                  'Paid',
                  _formatCurrency(
                    paid,
                  ),
                ),
              ),
              Expanded(
                child: _entryInfo(
                  'Udhaar',
                  _formatCurrency(
                    udhaar,
                  ),
                ),
              ),
              Expanded(
                child: _entryInfo(
                  'Time',
                  dateText.isEmpty
                      ? '--'
                      : dateText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _entryInfo(
    String title,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(28),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 42,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'No entries yet',
            style:
                TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Add your first mill entry to get started.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(
    String error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            const Text(
              'Dashboard data load nahi hua',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;

    final minute =
        dateTime.minute
            .toString()
            .padLeft(2, '0');

    final period =
        dateTime.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
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
            style:
                const TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style:
                const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
