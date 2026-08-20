import 'package:flutter/material.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF176B52),
                      Color(0xFF0E4D3B),
                    ],
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Day 👋',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Manage your mill easily.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
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
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _card(
                      'Total KG',
                      '0 KG',
                      Icons.scale_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _card(
                      'Sales',
                      '₹0',
                      Icons.currency_rupee_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _card(
                      'Paid',
                      '₹0',
                      Icons.payments_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _card(
                      'Udhaar',
                      '₹0',
                      Icons.account_balance_wallet_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'New Mill Entry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Recent Entries',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Color(0xFFE5E7EB),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Add your first mill entry to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {},
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Entries',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            label: 'Payment',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _card(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
