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

  final List<String> _titles = [
    'Daily Update',
    'Entries',
    'Payment',
    'Reports',
  ];

  void _onNavigationChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      EntriesScreen(),
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
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : AppBar(
              title: Text(
                _titles[_selectedIndex],
                style: const TextStyle(
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
  // HOME PAGE
  // ============================================================

  Widget _homePage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
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

            const SizedBox(
              height: 24,
            ),

            const Text(
              "Today's Overview",
              style: TextStyle(
                fontSize: 18,
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
                  child: _summaryCard(
                    title: 'Total KG',
                    value: '0 KG',
                    icon:
                        Icons.scale_rounded,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: _summaryCard(
                    title: 'Sales',
                    value: '₹0',
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
                  child: _summaryCard(
                    title: 'Paid',
                    value: '₹0',
                    icon: Icons
                        .payments_rounded,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: _summaryCard(
                    title: 'Udhaar',
                    value: '₹0',
                    icon: Icons
                        .account_balance_wallet_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 24,
            ),

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
                style:
                    ElevatedButton.styleFrom(
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 28,
            ),

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
                TextButton(
                  onPressed: () {
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
              height: 8,
            ),

            Container(
              width: double.infinity,
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
              child: const Column(
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
                      fontSize: 16,
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
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT PAGE — TEMPORARY
  // ============================================================

  Widget _paymentPage() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEAF5F0,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                ),
                child: const Icon(
                  Icons
                      .payments_rounded,
                  size: 42,
                  color:
                      Color(0xFF176B52),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              const Text(
                'Payment Management',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                'Paid aur Udhaar ka complete management yahan hoga.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
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
  // REPORTS PAGE — TEMPORARY
  // ============================================================

  Widget _reportsPage() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEAF5F0,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                ),
                child: const Icon(
                  Icons
                      .bar_chart_rounded,
                  size: 42,
                  color:
                      Color(0xFF176B52),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              const Text(
                'Reports',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                'Daily, weekly aur monthly mill reports yahan milengi.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
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
          const EdgeInsets.all(16),
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
              fontSize: 21,
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
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
