import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditEntryScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> entry;

  const EditEntryScreen({
    super.key,
    required this.documentId,
    required this.entry,
  });

  @override
  State<EditEntryScreen> createState() =>
      _EditEntryScreenState();
}

class _EditEntryScreenState
    extends State<EditEntryScreen> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _customerController;

  late final TextEditingController
      _kgController;

  late final TextEditingController
      _paidController;

  late final TextEditingController
      _udhaarController;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  late String _selectedProduct;

  late bool _paymentReceived;

  late bool _udhaarTaken;

  late DateTime _selectedDateTime;

  bool _isUpdating = false;

  final Map<String, double> _prices = {
    'Aata': 2.0,
    'Besan': 2.0,
    'Ghatha': 1.5,
  };

  @override
  void initState() {
    super.initState();

    _customerController =
        TextEditingController(
      text:
          widget.entry['customerName']
                  ?.toString() ??
              '',
    );

    _kgController =
        TextEditingController(
      text: _numberText(
        widget.entry['quantityKg'],
      ),
    );

    _paidController =
        TextEditingController(
      text: _numberText(
        widget.entry['paidAmount'],
      ),
    );

    _udhaarController =
        TextEditingController(
      text: _numberText(
        widget.entry['udhaarAmount'],
      ),
    );

    final product =
        widget.entry['product']
            ?.toString();

    _selectedProduct =
        _prices.containsKey(product)
            ? product!
            : 'Aata';

    _paymentReceived =
        widget.entry['paymentReceived'] ==
            true;

    _udhaarTaken =
        widget.entry['udhaarTaken'] ==
            true;

    final timestamp =
        widget.entry['entryDateTime'];

    if (timestamp is Timestamp) {
      _selectedDateTime =
          timestamp.toDate();
    } else {
      _selectedDateTime =
          DateTime.now();
    }

    _kgController.addListener(
      _refresh,
    );

    _paidController.addListener(
      _refresh,
    );

    _udhaarController.addListener(
      _refresh,
    );
  }

  static String _numberText(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    if (value is num) {
      if (value == value.toInt()) {
        return value.toInt().toString();
      }

      return value.toString();
    }

    return value.toString();
  }

  double get _totalAmount {
    final kg =
        double.tryParse(
              _kgController.text,
            ) ??
            0;

    final price =
        _prices[_selectedProduct] ??
            0;

    return kg * price;
  }

  double get _paidAmount {
    return double.tryParse(
          _paidController.text,
        ) ??
        0;
  }

  double get _udhaarAmount {
    return double.tryParse(
          _udhaarController.text,
        ) ??
        0;
  }

  double get _remainingAmount {
    final remaining =
        _totalAmount -
            _paidAmount;

    return remaining < 0
        ? 0
        : remaining;
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _kgController.dispose();
    _paidController.dispose();
    _udhaarController.dispose();

    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date =
        await showDatePicker(
      context: context,
      initialDate:
          _selectedDateTime,
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime(2100),
    );

    if (date == null ||
        !mounted) {
      return;
    }

    final time =
        await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(
        _selectedDateTime,
      ),
    );

    if (time == null ||
        !mounted) {
      return;
    }

    setState(() {
      _selectedDateTime =
          DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _updateEntry() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_paymentReceived &&
        _paidAmount <= 0) {
      _showMessage(
        'Paid amount enter karo.',
      );
      return;
    }

    if (_udhaarTaken &&
        _udhaarAmount <= 0) {
      _showMessage(
        'Udhaar amount enter karo.',
      );
      return;
    }

    if (_isUpdating) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final kg =
          double.parse(
        _kgController.text
            .trim(),
      );

      final pricePerKg =
          _prices[
              _selectedProduct]!;

      final totalAmount =
          kg * pricePerKg;

      final paidAmount =
          _paymentReceived
              ? _paidAmount
              : 0.0;

      final udhaarAmount =
          _udhaarTaken
              ? _udhaarAmount
              : 0.0;

      await _firestore
          .collection(
            'mill_entries',
          )
          .doc(widget.documentId)
          .update({
        'customerName':
            _customerController
                .text
                .trim(),

        'product':
            _selectedProduct,

        'quantityKg': kg,

        'pricePerKg':
            pricePerKg,

        'totalAmount':
            totalAmount,

        'paymentReceived':
            _paymentReceived,

        'paidAmount':
            paidAmount,

        'udhaarTaken':
            _udhaarTaken,

        'udhaarAmount':
            udhaarAmount,

        'entryDateTime':
            Timestamp.fromDate(
          _selectedDateTime,
        ),

        'updatedAt':
            FieldValue
                .serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      _showMessage(
        'Entry update ho gayi ✅',
      );

      Navigator.pop(
        context,
        true,
      );
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Firebase error: '
        '${e.message ?? e.code}',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Entry update nahi hui.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        behavior:
            SnackBarBehavior
                .floating,
      ),
    );
  }

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final day =
        dateTime.day
            .toString()
            .padLeft(2, '0');

    final month =
        dateTime.month
            .toString()
            .padLeft(2, '0');

    final hour =
        dateTime.hour == 0
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

    return '$day/$month/'
        '${dateTime.year} • '
        '$hour:$minute $period';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final total =
        _totalAmount;

    final remaining =
        _remainingAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Entry',
          style: TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            32,
          ),
          children: [
            _sectionTitle(
              'Customer Details',
              'Entry ki information edit karo',
            ),

            const SizedBox(
              height: 12,
            ),

            _textField(
              controller:
                  _customerController,
              label:
                  'Grahak Name',
              hint:
                  'Example: Ramesh Kumar',
              icon:
                  Icons.person_outline_rounded,
              validator:
                  (value) {
                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {
                  return 'Grahak ka naam enter karo';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 24,
            ),

            _sectionTitle(
              'Mill Details',
              'Product aur quantity update karo',
            ),

            const SizedBox(
              height: 12,
            ),

            DropdownButtonFormField<
                String>(
              initialValue:
                  _selectedProduct,
              decoration:
                  InputDecoration(
                labelText:
                    'Product',
                prefixIcon:
                    const Icon(
                  Icons
                      .category_outlined,
                ),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),
                ),
              ),
              items: _prices
                  .keys
                  .map(
                (product) {
                  final price =
                      _prices[
                          product]!;

                  return DropdownMenuItem<
                      String>(
                    value:
                        product,
                    child:
                        Text(
                      '$product • '
                      '₹${price.toStringAsFixed(1)}/KG',
                    ),
                  );
                },
              ).toList(),
              onChanged:
                  (value) {
                if (value ==
                    null) {
                  return;
                }

                setState(() {
                  _selectedProduct =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 14,
            ),

            _textField(
              controller:
                  _kgController,
              label:
                  'Quantity (KG)',
              hint:
                  'Example: 25',
              icon:
                  Icons
                      .scale_outlined,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal:
                    true,
              ),
              validator:
                  (value) {
                final kg =
                    double.tryParse(
                  value ?? '',
                );

                if (kg == null ||
                    kg <= 0) {
                  return 'Valid KG enter karo';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 18,
            ),

            _amountCard(
              title:
                  'Total Amount',
              amount:
                  total,
              subtitle:
                  '${_kgController.text.isEmpty ? '0' : _kgController.text} KG × '
                  '₹${_prices[_selectedProduct]!.toStringAsFixed(1)}',
            ),

            const SizedBox(
              height: 24,
            ),

            _sectionTitle(
              'Payment',
              'Payment aur udhaar update karo',
            ),

            const SizedBox(
              height: 10,
            ),

            SwitchListTile(
              contentPadding:
                  EdgeInsets.zero,
              title:
                  const Text(
                'Payment Received',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),
              subtitle:
                  const Text(
                'Customer ne payment diya hai',
              ),
              value:
                  _paymentReceived,
              onChanged:
                  (value) {
                setState(() {
                  _paymentReceived =
                      value;
                });
              },
            ),

            if (_paymentReceived)
              ...[
                const SizedBox(
                  height: 8,
                ),
                _textField(
                  controller:
                      _paidController,
                  label:
                      'Paid Amount',
                  hint:
                      'Example: 100',
                  icon: Icons
                      .currency_rupee_rounded,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal:
                        true,
                  ),
                ),
              ],

            const SizedBox(
              height: 12,
            ),

            SwitchListTile(
              contentPadding:
                  EdgeInsets.zero,
              title:
                  const Text(
                'Udhaar',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),
              subtitle:
                  const Text(
                'Customer ne udhaar liya hai',
              ),
              value:
                  _udhaarTaken,
              onChanged:
                  (value) {
                setState(() {
                  _udhaarTaken =
                      value;
                });
              },
            ),

            if (_udhaarTaken)
              ...[
                const SizedBox(
                  height: 8,
                ),
                _textField(
                  controller:
                      _udhaarController,
                  label:
                      'Udhaar Amount',
                  hint:
                      'Example: 50',
                  icon: Icons
                      .account_balance_wallet_outlined,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal:
                        true,
                  ),
                ),
              ],

            const SizedBox(
              height: 18,
            ),

            if (total > 0)
              _amountCard(
                title:
                    'Remaining',
                amount:
                    remaining,
                subtitle:
                    'Total amount - Paid amount',
              ),

            const SizedBox(
              height: 24,
            ),

            _sectionTitle(
              'Date & Time',
              'Entry ka date aur time',
            ),

            const SizedBox(
              height: 12,
            ),

            InkWell(
              borderRadius:
                  BorderRadius
                      .circular(
                16,
              ),
              onTap:
                  _selectDateTime,
              child:
                  Container(
                padding:
                    const EdgeInsets
                        .all(
                  17,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),
                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFE1E5E9,
                    ),
                  ),
                ),
                child:
                    Row(
                  children: [
                    const Icon(
                      Icons
                          .calendar_month_outlined,
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
                          const Text(
                            'Entry Date & Time',
                            style:
                                TextStyle(
                              fontSize:
                                  12,
                              color:
                                  Colors.grey,
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
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons
                          .edit_calendar_outlined,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            SizedBox(
              height: 56,
              child:
                  ElevatedButton.icon(
                onPressed:
                    _isUpdating
                        ? null
                        : _updateEntry,
                icon:
                    _isUpdating
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
                                .save_rounded,
                          ),
                label:
                    Text(
                  _isUpdating
                      ? 'Updating...'
                      : 'Update Entry',
                  style:
                      const TextStyle(
                    fontSize:
                        16,
                    fontWeight:
                        FontWeight
                            .w700,
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
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 19,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: 3,
        ),
        Text(
          subtitle,
          style:
              const TextStyle(
            color:
                Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required
        TextEditingController
            controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType?
        keyboardType,
    String? Function(
            String?)?
        validator,
  }) {
    return TextFormField(
      controller:
          controller,
      keyboardType:
          keyboardType,
      validator:
          validator,
      decoration:
          InputDecoration(
        labelText:
            label,
        hintText:
            hint,
        prefixIcon:
            Icon(icon),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius
                  .circular(
            16,
          ),
        ),
      ),
    );
  }

  Widget _amountCard({
    required
        String title,
    required
        double amount,
    required
        String subtitle,
  }) {
    return Container(
      padding:
          const EdgeInsets
              .all(18),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFEFF8F4,
        ),
        borderRadius:
            BorderRadius
                .circular(
          18,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFD2EADF,
          ),
        ),
      ),
      child:
          Row(
        children: [
          const CircleAvatar(
            radius: 24,
            child: Icon(
              Icons
                  .currency_rupee_rounded,
            ),
          ),
          const SizedBox(
            width: 14,
          ),
          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize:
                        13,
                    color:
                        Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style:
                      const TextStyle(
                    fontSize:
                        23,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
                Text(
                  subtitle,
                  style:
                      const TextStyle(
                    fontSize:
                        11,
                    color:
                        Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
