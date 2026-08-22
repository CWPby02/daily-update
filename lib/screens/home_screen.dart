import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'entries_screen.dart';
import 'new_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  int _selectedIndex = 0;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final List<String> _titles = [
    'Daily Update',
    'Entries',
    'Payment',
    'Reports',
  ];

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _entriesStream() {
    // Simple query — composite index ki
    // zarurat nahi hogi.
    return _firestore
        .collection('mill_entries')
        .snapshots();
  }

  bool _isDeleted(
    Map<String, dynamic> data,
  ) {
    return data['isDeleted'] == true;
  }

  double _numberValue(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  DateTime? _entryDate(
    Map<String, dynamic> data,
  ) {
    final value =
        data['entryDateTime'];

    if (value is Timestamp) {
      return value.toDate();
    }

    final created =
        data['createdAt'];

    if (created is Timestamp) {
      return created.toDate();
    }

    return null;
  }

  void _onNavigationChanged(
    int index,
  ) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final pages = [
      _homePage(),
      const EntriesScreen(),
      _paymentPage(),
      _reportsPage(),
    ];

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Update',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Mill Management',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : AppBar(
              title: Text(
                _titles[
                    _selectedIndex],
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            _selectedIndex,
        onDestinationSelected:
            _onNavigationChanged,
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
            selectedIcon: Icon(
              Icons.receipt_long_rounded,
            ),
            label: 'Entries',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.payments_outlined,
            ),
            selectedIcon: Icon(
              Icons.payments_rounded,
            ),
            label: 'Payment',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            selectedIcon: Icon(
              Icons.bar_chart_rounded,
            ),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOME
  // ============================================================

  Widget _homePage() {
    return StreamBuilder<
        QuerySnapshot<
            Map<String, dynamic>>>(
      stream:
          _entriesStream(),
      builder:
          (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(
                24,
              ),
              child: Text(
                'Firebase error:\n${snapshot.error}',
                textAlign:
                    TextAlign.center,
              ),
            ),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        final documents =
            snapshot.data?.docs
                    .toList() ??
                [];

        // Sirf active entries.
        final activeEntries =
            documents
                .where(
                  (doc) =>
                      !_isDeleted(
                    doc.data(),
                  ),
                )
                .toList();

        // ======================================================
        // CALCULATIONS
        // ======================================================

        double totalKg = 0;
        double sales = 0;
        double paid = 0;
        double udhaar = 0;

        for (final doc
            in activeEntries) {
          final data =
              doc.data();

          totalKg +=
              _numberValue(
            data['quantityKg'],
          );

          sales +=
              _numberValue(
            data['totalAmount'],
          );

          paid +=
              _numberValue(
            data['paidAmount'],
          );

          udhaar +=
              _numberValue(
            data['udhaarAmount'],
          );
        }

        // Latest first.
        activeEntries.sort(
          (a, b) {
            final dateA =
                _entryDate(
              a.data(),
            );

            final dateB =
                _entryDate(
              b.data(),
            );

            if (dateA == null &&
                dateB == null) {
              return 0;
            }

            if (dateA == null) {
              return 1;
            }

            if (dateB == null) {
              return -1;
            }

            return dateB.compareTo(
              dateA,
            );
          },
        );

        return SafeArea(
          child:
              RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(
                const Duration(
                  milliseconds: 300,
                ),
              );
            },
            child:
                SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  // ==========================================
                  // WELCOME
                  // ==========================================

                  Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius
                              .circular(
                        22,
                      ),
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(
                            0xFF176B52,
                          ),
                          Color(
                            0xFF0E4D3B,
                          ),
                        ],
                      ),
                    ),
                    child:
                        const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Good Day 👋',
                          style:
                              TextStyle(
                            color:
                                Colors.white70,
                            fontSize:
                                14,
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          'Manage your mill easily.',
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                21,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ==========================================
                  // OVERVIEW
                  // ==========================================

                  const Text(
                    "Today's Overview",
                    style:
                        TextStyle(
                      fontSize:
                          18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                            _summaryCard(
                          title:
                              'Total KG',
                          value:
                              '${totalKg.toStringAsFixed(2)} KG',
                          icon: Icons
                              .scale_rounded,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child:
                            _summaryCard(
                          title:
                              'Sales',
                          value:
                              '₹${sales.toStringAsFixed(2)}',
                          icon: Icons
                              .currency_rupee_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                            _summaryCard(
                          title:
                              'Paid',
                          value:
                              '₹${paid.toStringAsFixed(2)}',
                          icon: Icons
                              .payments_rounded,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child:
                            _summaryCard(
                          title:
                              'Udhaar',
                          value:
                              '₹${udhaar.toStringAsFixed(2)}',
                          icon: Icons
                              .account_balance_wallet_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ==========================================
                  // NEW ENTRY
                  // ==========================================

                  SizedBox(
                    width:
                        double.infinity,
                    height: 56,
                    child:
                        ElevatedButton
                            .icon(
                      onPressed:
                          () async {
                        await Navigator
                            .push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const NewEntryScreen(),
                          ),
                        );

                        if (mounted) {
                          setState(
                            () {},
                          );
                        }
                      },
                      icon:
                          const Icon(
                        Icons
                            .add_rounded,
                      ),
                      label:
                          const Text(
                        'New Mill Entry',
                        style:
                            TextStyle(
                          fontSize:
                              16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      style:
                          ElevatedButton
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

                  const SizedBox(
                    height: 28,
                  ),

                  // ==========================================
                  // RECENT ENTRIES
                  // ==========================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Text(
                        'Recent Entries',
                        style:
                            const TextStyle(
                          fontSize:
                              18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      if (activeEntries
                          .isNotEmpty)
                        TextButton(
                          onPressed:
                              () {
                            _onNavigationChanged(
                              1,
                            );
                          },
                          child:
                              const Text(
                            'View All',
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  if (activeEntries
                      .isEmpty)
                    _emptyRecentEntries()
                  else
                    ...activeEntries
                        .take(5)
                        .map(
                      (doc) {
                        return _recentEntryCard(
                          doc.data(),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // RECENT ENTRY CARD
  // ============================================================

  Widget _recentEntryCard(
    Map<String, dynamic> data,
  ) {
    final customer =
        data['customerName']
                ?.toString() ??
            'Unknown';

    final product =
        data['product']
                ?.toString() ??
            '';

    final kg =
        _numberValue(
      data['quantityKg'],
    );

    final total =
        _numberValue(
      data['totalAmount'],
    );

    final paid =
        _numberValue(
      data['paidAmount'],
    );

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      elevation: 0,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        side:
            const BorderSide(
          color:
              Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          14,
        ),
        child: Row(
          children: [
            CircleAvatar(
              child:
                  Text(
                customer.isEmpty
                    ? '?'
                    : customer[0]
                        .toUpperCase(),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    customer,
                    style:
                        const TextStyle(
                      fontSize:
                          15,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    '$product • '
                    '${kg.toStringAsFixed(2)} KG',
                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                      fontSize:
                          12,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .end,
              children: [
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  'Paid ₹${paid.toStringAsFixed(2)}',
                  style:
                      const TextStyle(
                    color:
                        Colors.grey,
                    fontSize:
                        11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyRecentEntries() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        28,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE5E7EB,
          ),
        ),
      ),
      child:
          const Column(
        children: [
          Icon(
            Icons
                .receipt_long_outlined,
            size: 42,
            color:
                Colors.grey,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            'No entries yet',
            style:
                TextStyle(
              fontSize:
                  16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Add your first mill entry to get started.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  Colors.grey,
              fontSize:
                  13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT PAGE
  // ============================================================

  Widget _paymentPage() {
    return SafeArea(
      child:
          Center(
        child:
            Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child:
              const Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Icon(
                Icons
                    .payments_rounded,
                size:
                    64,
                color:
                    Color(
                  0xFF176B52,
                ),
              ),
              SizedBox(
                height:
                    16,
              ),
              Text(
                'Payment Management',
                style:
                    TextStyle(
                  fontSize:
                      21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              SizedBox(
                height:
                    8,
              ),
              Text(
                'Paid aur Udhaar ka complete management yahan hoga.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REPORTS PAGE
  // ============================================================

  Widget _reportsPage() {
    return SafeArea(
      child:
          Center(
        child:
            Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child:
              const Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Icon(
                Icons
                    .bar_chart_rounded,
                size:
                    64,
                color:
                    Color(
                  0xFF176B52,
                ),
              ),
              SizedBox(
                height:
                    16,
              ),
              Text(
                'Reports',
                style:
                    TextStyle(
                  fontSize:
                      21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              SizedBox(
                height:
                    8,
              ),
              Text(
                'Daily, weekly aur monthly mill reports yahan milengi.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE5E7EB,
          ),
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Icon(icon),
          const SizedBox(
            height: 12,
          ),
          Text(
            value,
            style:
                const TextStyle(
              fontSize:
                  20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            title,
            style:
                const TextStyle(
              color:
                  Colors.grey,
              fontSize:
                  13,
            ),
          ),
        ],
      ),
    );
  }
}
