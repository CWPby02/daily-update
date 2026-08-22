import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState
    extends State<PaymentScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _entriesStream() {
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

  bool _isDeleted(
    Map<String, dynamic> data,
  ) {
    return data['isDeleted'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream: _entriesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
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

          final docs =
              snapshot.data?.docs ?? [];

          final active =
              docs.where((doc) {
            return !_isDeleted(
              doc.data(),
            );
          }).toList();

          double totalSales = 0;
          double totalPaid = 0;
          double totalUdhaar = 0;

          for (final doc in active) {
            final data = doc.data();

            totalSales += _number(
              data['totalAmount'],
            );

            totalPaid += _number(
              data['paidAmount'],
            );

            totalUdhaar += _number(
              data['udhaarAmount'],
            );
          }

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // SUMMARY
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        'Total Sales',
                        '₹${totalSales.toStringAsFixed(2)}',
                        Icons
                            .currency_rupee_rounded,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: _summaryCard(
                        'Paid',
                        '₹${totalPaid.toStringAsFixed(2)}',
                        Icons
                            .payments_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 12,
                ),

                _summaryCard(
                  'Total Udhaar',
                  '₹${totalUdhaar.toStringAsFixed(2)}',
                  Icons
                      .account_balance_wallet_rounded,
                ),

                const SizedBox(
                  height: 28,
                ),

                const Text(
                  'Customer Payments',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                if (active.isEmpty)
                  _emptyState()
                else
                  ...active.map(
                    (doc) {
                      return _paymentCard(
                        doc.data(),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(
            height: 12,
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
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

  Widget _paymentCard(
    Map<String, dynamic> data,
  ) {
    final customer =
        data['customerName']
                ?.toString() ??
            'Unknown Customer';

    final total = _number(
      data['totalAmount'],
    );

    final paid = _number(
      data['paidAmount'],
    );

    final udhaar = _number(
      data['udhaarAmount'],
    );

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 0,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
        side: const BorderSide(
          color:
              Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
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
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    customer,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
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

            const SizedBox(
              height: 16,
            ),

            Row(
              children: [
                Expanded(
                  child: _paymentInfo(
                    'Paid',
                    '₹${paid.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _paymentInfo(
                    'Udhaar',
                    '₹${udhaar.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentInfo(
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
            fontSize: 12,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          value,
          style:
              const TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(30),
      child: const Column(
        children: [
          Icon(
            Icons
                .payments_outlined,
            size: 52,
            color: Colors.grey,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            'No payment records',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
