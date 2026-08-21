import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'edit_entry_screen.dart';

class EntriesScreen extends StatelessWidget {
  EntriesScreen({super.key});

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Entries',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('mill_entries')
            .where(
              'isDeleted',
              isEqualTo: false,
            )
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

          final docs =
              snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              return _entryCard(
                context,
                doc.id,
                doc.data(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _entryCard(
    BuildContext context,
    String documentId,
    Map<String, dynamic> data,
  ) {
    final customerName =
        data['customerName']?.toString() ??
            'Unknown Customer';

    final product =
        data['product']?.toString() ??
            'Unknown Product';

    final kg = _toDouble(
      data['quantityKg'],
    );

    final total = _toDouble(
      data['totalAmount'],
    );

    final paid = _toDouble(
      data['paidAmount'],
    );

    final udhaar = _toDouble(
      data['udhaarAmount'],
    );

    final timestamp =
        data['entryDateTime'];

    String dateText = '';

    if (timestamp is Timestamp) {
      dateText = _formatDateTime(
        timestamp.toDate(),
      );
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEAF5F0),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF176B52),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$product • '
                      '${_formatNumber(kg)} KG',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditEntryScreen(
                          documentId: documentId,
                          entry: data,
                        ),
                      ),
                    );
                  }

                  if (value == 'delete') {
                    _deleteEntry(
                      context,
                      documentId,
                    );
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                        ),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(height: 1),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _info(
                  'Total',
                  _currency(total),
                ),
              ),
              Expanded(
                child: _info(
                  'Paid',
                  _currency(paid),
                ),
              ),
              Expanded(
                child: _info(
                  'Udhaar',
                  _currency(udhaar),
                ),
              ),
            ],
          ),

          if (dateText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                dateText,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _deleteEntry(
    BuildContext context,
    String documentId,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Entry?',
          ),
          content: const Text(
            'Entry 24 hours ke liye '
            'temporarily delete hogi. '
            'Uske baad permanently delete '
            'ki jayegi.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
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

    if (confirm != true) {
      return;
    }

    try {
      await _firestore
          .collection('mill_entries')
          .doc(documentId)
          .update({
        'isDeleted': true,
        'deletedAt':
            FieldValue.serverTimestamp(),
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Entry deleted. 24 hours ke andar restore ki ja sakti hai.',
          ),
        ),
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Firebase error: '
            '${e.message ?? e.code}',
          ),
        ),
      );
    }
  }

  Widget _info(
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 55,
              color: Colors.grey,
            ),
            SizedBox(height: 14),
            Text(
              'No entries yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Your mill entries will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  static double _toDouble(
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

  static String _formatNumber(
    double value,
  ) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  static String _currency(
    double value,
  ) {
    if (value == value.roundToDouble()) {
      return '₹${value.toInt()}';
    }

    return '₹${value.toStringAsFixed(2)}';
  }

  static String _formatDateTime(
    DateTime dateTime,
  ) {
    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;

    final minute = dateTime.minute
        .toString()
        .padLeft(2, '0');

    final period =
        dateTime.hour >= 12
            ? 'PM'
            : 'AM';

    return '${dateTime.day}/'
        '${dateTime.month}/'
        '${dateTime.year} • '
        '$hour:$minute $period';
  }
}
