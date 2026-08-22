import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OnlinePaymentScreen extends StatefulWidget {
  const OnlinePaymentScreen({super.key});

  @override
  State<OnlinePaymentScreen> createState() =>
      _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState
    extends State<OnlinePaymentScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController _customerController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  DateTime _selectedDateTime = DateTime.now();

  bool _saving = false;

  @override
  void dispose() {
    _customerController.dispose();
    _amountController.dispose();
    super.dispose();
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

  String _formatDateTime(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');
    final month =
        date.month.toString().padLeft(2, '0');
    final hour =
        date.hour.toString().padLeft(2, '0');
    final minute =
        date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} '
        '$hour:$minute';
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _selectedDateTime,
      ),
    );

    if (time == null) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _addPayment() async {
    final customer =
        _customerController.text.trim();

    final amount =
        double.tryParse(
      _amountController.text.trim(),
    );

    if (customer.isEmpty) {
      _showMessage(
        'Customer name enter karo.',
      );
      return;
    }

    if (amount == null || amount <= 0) {
      _showMessage(
        'Valid payment amount enter karo.',
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _firestore
          .collection('online_payments')
          .add({
        'customerName': customer,
        'amount': amount,
        'paymentDateTime':
            Timestamp.fromDate(
          _selectedDateTime,
        ),
        'createdAt':
            FieldValue.serverTimestamp(),
        'isDeleted': false,
      });

      if (!mounted) {
        return;
      }

      _customerController.clear();
      _amountController.clear();

      setState(() {
        _selectedDateTime =
            DateTime.now();
      });

      _showMessage(
        'Online payment added successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Payment save nahi hua.\n$e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _deletePayment(
    String documentId,
  ) async {
    try {
      await _firestore
          .collection('online_payments')
          .doc(documentId)
          .update({
        'isDeleted': true,
        'deletedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      _showMessage(
        'Payment delete queue mein chala gaya.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Delete failed.\n$e',
      );
    }
  }

  Future<void> _confirmDelete(
    String documentId,
  ) async {
    final result =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Payment?',
          ),
          content: const Text(
            'Payment ko delete mark kiya jayega. '
            'Tumhare 24-hour delete system ke according '
            'permanent cleanup baad mein hoga.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deletePayment(
        documentId,
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Online Payment',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream: _firestore
            .collection('online_payments')
            .snapshots(),
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

          final activePayments =
              docs.where((doc) {
            return doc.data()['isDeleted'] !=
                true;
          }).toList();

          double totalOnlinePayment = 0;

          for (final doc
              in activePayments) {
            totalOnlinePayment += _number(
              doc.data()['amount'],
            );
          }

          activePayments.sort(
            (a, b) {
              final aValue =
                  a.data()['paymentDateTime'];

              final bValue =
                  b.data()['paymentDateTime'];

              if (aValue is Timestamp &&
                  bValue is Timestamp) {
                return bValue
                    .compareTo(aValue);
              }

              return 0;
            },
          );

          return SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // TOTAL ONLINE PAYMENT
                  // =================================================

                  Container(
                    width:
                        double.infinity,
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
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons
                                  .payments_rounded,
                              color:
                                  Colors.white,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Total Online Payment',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white70,
                                fontSize:
                                    13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          '₹${totalOnlinePayment.toStringAsFixed(2)}',
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                28,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          '${activePayments.length} payment records',
                          style:
                              const TextStyle(
                            color:
                                Colors.white70,
                            fontSize:
                                12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // =================================================
                  // ADD PAYMENT
                  // =================================================

                  const Text(
                    'Add Online Payment',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  TextField(
                    controller:
                        _customerController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration:
                        InputDecoration(
                      labelText:
                          'Customer Name',
                      hintText:
                          'Enter customer name',
                      prefixIcon:
                          const Icon(
                        Icons.person_outline,
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  TextField(
                    controller:
                        _amountController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        InputDecoration(
                      labelText:
                          'Payment Amount',
                      hintText:
                          'Enter amount',
                      prefixIcon:
                          const Icon(
                        Icons
                            .currency_rupee_rounded,
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // =================================================
                  // DATE & TIME
                  // =================================================

                  InkWell(
                    onTap:
                        _pickDateTime,
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    child: Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      decoration:
                          BoxDecoration(
                        border: Border.all(
                          color:
                              const Color(
                            0xFFE5E7EB,
                          ),
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons
                                .calendar_month_rounded,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  'Payment Date & Time',
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.grey,
                                    fontSize:
                                        12,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  _formatDateTime(
                                    _selectedDateTime,
                                  ),
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        15,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons
                                .edit_calendar_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 54,
                    child:
                        ElevatedButton.icon(
                      onPressed: _saving
                          ? null
                          : _addPayment,
                      icon: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                              ),
                            )
                          : const Icon(
                              Icons
                                  .add_rounded,
                            ),
                      label: Text(
                        _saving
                            ? 'Saving...'
                            : 'Add Payment',
                        style:
                            const TextStyle(
                          fontSize:
                              15,
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
                            15,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // =================================================
                  // HISTORY
                  // =================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      const Text(
                        'Payment History',
                        style:
                            TextStyle(
                          fontSize:
                              19,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                      Text(
                        '${activePayments.length}',
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (activePayments
                      .isEmpty)
                    _emptyState()
                  else
                    ...activePayments.map(
                      (doc) {
                        return _paymentCard(
                          doc,
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _paymentCard(
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        doc,
  ) {
    final data = doc.data();

    final customer =
        data['customerName']
                ?.toString() ??
            'Unknown Customer';

    final amount = _number(
      data['amount'],
    );

    final paymentDate =
        data['paymentDateTime'];

    String dateText = '--';

    if (paymentDate is Timestamp) {
      dateText =
          _formatDateTime(
        paymentDate.toDate(),
      );
    }

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
      child:
          Padding(
        padding:
            const EdgeInsets.all(14),
        child:
            Row(
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
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    dateText,
                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                      fontSize: 11,
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
                  '₹${amount.toStringAsFixed(2)}',
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                IconButton(
                  onPressed: () {
                    _confirmDelete(
                      doc.id,
                    );
                  },
                  icon:
                      const Icon(
                    Icons
                        .delete_outline_rounded,
                    size: 21,
                  ),
                  tooltip:
                      'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(30),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
      ),
      child:
          const Column(
        children: [
          Icon(
            Icons
                .payments_outlined,
            size: 52,
            color:
                Colors.grey,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            'No online payments yet',
            style:
                TextStyle(
              fontSize:
                  17,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            'Add your first online payment to get started.',
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
}
