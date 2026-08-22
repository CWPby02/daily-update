import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() =>
      _EntriesScreenState();
}

class _EntriesScreenState
    extends State<EntriesScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool _isDeleting = false;

  // ============================================================
  // FIREBASE STREAM
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _entriesStream() {
    // IMPORTANT:
    // Yahan where + orderBy nahi use kiya gaya.
    // Isliye composite index ki zarurat nahi hogi.
    return _firestore
        .collection('mill_entries')
        .snapshots();
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteEntry(
    String documentId,
    Map<String, dynamic> data,
  ) async {
    if (_isDeleting) {
      return;
    }

    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Entry?',
          ),
          content: const Text(
            'Entry delete karne ke baad 24 hours tak recovery ke liye rakhi jayegi.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await _firestore
          .collection('mill_entries')
          .doc(documentId)
          .update({
        'isDeleted': true,
        'deletedAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      _showMessage(
        'Entry deleted. 24 hours ke andar recover ki ja sakti hai.',
      );
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Delete error: ${e.message ?? e.code}',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Entry delete nahi hui.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // ============================================================
  // RECOVER
  // ============================================================

  Future<void> _recoverEntry(
    String documentId,
  ) async {
    try {
      await _firestore
          .collection('mill_entries')
          .doc(documentId)
          .update({
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      _showMessage(
        'Entry recover ho gayi ✅',
      );
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Recover error: ${e.message ?? e.code}',
      );
    }
  }

  // ============================================================
  // EDIT
  // ============================================================

  Future<void> _editEntry(
    String documentId,
    Map<String, dynamic> data,
  ) async {
    final customerController =
        TextEditingController(
      text:
          _stringValue(
        data['customerName'],
      ),
    );

    final quantityController =
        TextEditingController(
      text:
          _numberValue(
        data['quantityKg'],
      ),
    );

    final paidController =
        TextEditingController(
      text:
          _numberValue(
        data['paidAmount'],
      ),
    );

    final udhaarController =
        TextEditingController(
      text:
          _numberValue(
        data['udhaarAmount'],
      ),
    );

    String product =
        _stringValue(
          data['product'],
        ).isEmpty
            ? 'Aata'
            : _stringValue(
                data['product'],
              );

    bool paymentReceived =
        data['paymentReceived'] ==
            true;

    bool udhaarTaken =
        data['udhaarTaken'] ==
            true;

    final result =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Edit Entry',
              ),
              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    TextField(
                      controller:
                          customerController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Customer Name',
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    DropdownButtonFormField<
                        String>(
                      initialValue:
                          product,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Product',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value:
                              'Aata',
                          child:
                              Text(
                            'Aata',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'Besan',
                          child:
                              Text(
                            'Besan',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'Ghatha',
                          child:
                              Text(
                            'Ghatha',
                          ),
                        ),
                      ],
                      onChanged:
                          (value) {
                        if (value ==
                            null) {
                          return;
                        }

                        setDialogState(
                          () {
                            product =
                                value;
                          },
                        );
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    TextField(
                      controller:
                          quantityController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal:
                            true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Quantity KG',
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    SwitchListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      title:
                          const Text(
                        'Payment Received',
                      ),
                      value:
                          paymentReceived,
                      onChanged:
                          (value) {
                        setDialogState(
                          () {
                            paymentReceived =
                                value;
                          },
                        );
                      },
                    ),

                    if (paymentReceived)
                      TextField(
                        controller:
                            paidController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal:
                              true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Paid Amount',
                        ),
                      ),

                    SwitchListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      title:
                          const Text(
                        'Udhaar',
                      ),
                      value:
                          udhaarTaken,
                      onChanged:
                          (value) {
                        setDialogState(
                          () {
                            udhaarTaken =
                                value;
                          },
                        );
                      },
                    ),

                    if (udhaarTaken)
                      TextField(
                        controller:
                            udhaarController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal:
                              true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Udhaar Amount',
                        ),
                      ),
                  ],
                ),
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
                      const Text(
                    'Cancel',
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      true,
                    );
                  },
                  child:
                      const Text(
                    'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      customerController.dispose();
      quantityController.dispose();
      paidController.dispose();
      udhaarController.dispose();
      return;
    }

    final quantity =
        double.tryParse(
          quantityController
              .text
              .trim(),
        ) ??
        0;

    final paid =
        paymentReceived
            ? double.tryParse(
                  paidController
                      .text
                      .trim(),
                ) ??
                0
            : 0;

    final udhaar =
        udhaarTaken
            ? double.tryParse(
                  udhaarController
                      .text
                      .trim(),
                ) ??
                0
            : 0;

    final price =
        _priceForProduct(
      product,
    );

    final total =
        quantity * price;

    try {
      await _firestore
          .collection('mill_entries')
          .doc(documentId)
          .update({
        'customerName':
            customerController
                .text
                .trim(),
        'product':
            product,
        'quantityKg':
            quantity,
        'pricePerKg':
            price,
        'totalAmount':
            total,
        'paymentReceived':
            paymentReceived,
        'paidAmount':
            paid,
        'udhaarTaken':
            udhaarTaken,
        'udhaarAmount':
            udhaar,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      _showMessage(
        'Entry updated ✅',
      );
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Update error: ${e.message ?? e.code}',
      );
    } finally {
      customerController.dispose();
      quantityController.dispose();
      paidController.dispose();
      udhaarController.dispose();
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double _priceForProduct(
    String product,
  ) {
    switch (product) {
      case 'Besan':
        return 2.0;

      case 'Ghatha':
        return 1.5;

      case 'Aata':
      default:
        return 2.0;
    }
  }

  String _stringValue(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  String _numberValue(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    if (value is num) {
      return value.toString();
    }

    return value.toString();
  }

  DateTime? _dateFromData(
    Map<String, dynamic> data,
  ) {
    final value =
        data['entryDateTime'];

    if (value is Timestamp) {
      return value.toDate();
    }

    final createdAt =
        data['createdAt'];

    if (createdAt is Timestamp) {
      return createdAt.toDate();
    }

    return null;
  }

  bool _isDeleted(
    Map<String, dynamic> data,
  ) {
    return data['isDeleted'] == true;
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream:
            _entriesStream(),
        builder:
            (context, snapshot) {
          if (snapshot.hasError) {
            return _errorView(
              snapshot.error
                  .toString(),
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
              snapshot.data
                      ?.docs
                      .toList() ??
                  [];

          // ------------------------------------------------------
          // APP SIDE SORTING
          // ------------------------------------------------------

          documents.sort(
            (a, b) {
              final dateA =
                  _dateFromData(
                a.data(),
              );

              final dateB =
                  _dateFromData(
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

          // ------------------------------------------------------
          // ACTIVE ENTRIES
          // ------------------------------------------------------

          final activeEntries =
              documents
                  .where(
                    (doc) =>
                        !_isDeleted(
                      doc.data(),
                    ),
                  )
                  .toList();

          // ------------------------------------------------------
          // DELETED ENTRIES
          // ------------------------------------------------------

          final deletedEntries =
              documents
                  .where(
                    (doc) =>
                        _isDeleted(
                      doc.data(),
                    ),
                  )
                  .toList();

          if (activeEntries.isEmpty &&
              deletedEntries.isEmpty) {
            return _emptyView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Stream automatically refresh hota hai.
              await Future.delayed(
                const Duration(
                  milliseconds: 300,
                ),
              );
            },
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                30,
              ),
              children: [
                // ------------------------------------------------
                // ACTIVE ENTRIES
                // ------------------------------------------------

                if (activeEntries
                    .isNotEmpty) ...[
                  Text(
                    'All Entries (${activeEntries.length})',
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  ...activeEntries.map(
                    (doc) {
                      return _entryCard(
                        doc.id,
                        doc.data(),
                      );
                    },
                  ),
                ],

                // ------------------------------------------------
                // DELETED ENTRIES
                // ------------------------------------------------

                if (deletedEntries
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 28,
                  ),

                  const Text(
                    'Recently Deleted',
                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  const Text(
                    'Deleted entries 24 hours tak recover ki ja sakti hain.',
                    style:
                        TextStyle(
                      color:
                          Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  ...deletedEntries.map(
                    (doc) {
                      return _deletedCard(
                        doc.id,
                        doc.data(),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ENTRY CARD
  // ============================================================

  Widget _entryCard(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final customer =
        _stringValue(
      data['customerName'],
    );

    final product =
        _stringValue(
      data['product'],
    );

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

    final udhaar =
        _numberValue(
      data['udhaarAmount'],
    );

    final date =
        _dateFromData(data);

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 0,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
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
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    customer
                            .isEmpty
                        ? '?'
                        : customer[0]
                            .toUpperCase(),
                  ),
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
                      Text(
                        customer
                                .isEmpty
                            ? 'Unknown Customer'
                            : customer,
                        style:
                            const TextStyle(
                          fontSize:
                              17,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        product,
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<
                    String>(
                  onSelected:
                      (value) {
                    if (value ==
                        'edit') {
                      _editEntry(
                        documentId,
                        data,
                      );
                    }

                    if (value ==
                        'delete') {
                      _deleteEntry(
                        documentId,
                        data,
                      );
                    }
                  },
                  itemBuilder:
                      (context) {
                    return const [
                      PopupMenuItem(
                        value:
                            'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .edit_outlined,
                            ),
                            SizedBox(
                              width:
                                  10,
                            ),
                            Text(
                              'Edit',
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value:
                            'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .delete_outline,
                            ),
                            SizedBox(
                              width:
                                  10,
                            ),
                            Text(
                              'Delete',
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            Row(
              children: [
                Expanded(
                  child:
                      _infoItem(
                    'Quantity',
                    '$kg KG',
                  ),
                ),
                Expanded(
                  child:
                      _infoItem(
                    'Total',
                    '₹$total',
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            Row(
              children: [
                Expanded(
                  child:
                      _infoItem(
                    'Paid',
                    '₹$paid',
                  ),
                ),
                Expanded(
                  child:
                      _infoItem(
                    'Udhaar',
                    '₹$udhaar',
                  ),
                ),
              ],
            ),

            if (date != null) ...[
              const SizedBox(
                height: 14,
              ),
              Text(
                _formatDateTime(
                  date,
                ),
                style:
                    const TextStyle(
                  color:
                      Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DELETED CARD
  // ============================================================

  Widget _deletedCard(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final customer =
        _stringValue(
      data['customerName'],
    );

    final product =
        _stringValue(
      data['product'],
    );

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      elevation: 0,
      color:
          const Color(0xFFFFF8F8),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        side:
            const BorderSide(
          color:
              Color(0xFFF0DADA),
        ),
      ),
      child: ListTile(
        leading:
            const Icon(
          Icons
              .delete_outline_rounded,
        ),
        title:
            Text(
          customer.isEmpty
              ? 'Unknown Customer'
              : customer,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
        subtitle:
            Text(product),
        trailing:
            TextButton(
          onPressed:
              () {
            _recoverEntry(
              documentId,
            );
          },
          child:
              const Text(
            'Recover',
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem(
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
            fontSize: 12,
            color:
                Colors.grey,
          ),
        ),
        const SizedBox(
          height: 3,
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

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyView() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          32,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons
                  .receipt_long_outlined,
              size: 58,
              color:
                  Colors.grey,
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'No entries yet',
              style:
                  TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            const Text(
              'New Mill Entry add karne ke baad yahan dikhegi.',
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
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorView(
    String error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              size: 55,
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Entries load nahi hui',
              style:
                  TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              error,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final day =
        dateTime.day
            .toString()
            .padLeft(
          2,
          '0',
        );

    final month =
        dateTime.month
            .toString()
            .padLeft(
          2,
          '0',
        );

    final hour =
        dateTime.hour == 0
            ? 12
            : dateTime.hour > 12
                ? dateTime.hour - 12
                : dateTime.hour;

    final minute =
        dateTime.minute
            .toString()
            .padLeft(
          2,
          '0',
        );

    final period =
        dateTime.hour >= 12
            ? 'PM'
            : 'AM';

    return '$day/$month/${dateTime.year} • '
        '$hour:$minute $period';
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}
