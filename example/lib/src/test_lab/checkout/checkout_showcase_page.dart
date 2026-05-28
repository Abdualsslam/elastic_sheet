import 'package:flutter/material.dart';
import 'models/checkout_enums.dart';
import 'models/stacked_section_data.dart';
import 'widgets/address_summary_tile.dart';
import 'widgets/checkout_bottom_bar.dart';
import 'widgets/checkout_field.dart';
import 'widgets/checkout_option_tile.dart';
import 'widgets/checkout_sheet_section.dart';
import 'widgets/choice_pill.dart';
import 'widgets/invoice_amount_row.dart';
import 'widgets/invoice_product_tile.dart';

class ElasticSheetCheckoutShowcasePage extends StatefulWidget {
  const ElasticSheetCheckoutShowcasePage({super.key});

  static const routeName = '/checkout-showcase';

  @override
  State<ElasticSheetCheckoutShowcasePage> createState() =>
      _ElasticSheetCheckoutShowcasePageState();
}

class _ElasticSheetCheckoutShowcasePageState
    extends State<ElasticSheetCheckoutShowcasePage> {
  static const double _subtotalAmount = 189.0;
  static const double _couponDiscountAmount = 20.0;
  static const double _taxRate = 0.15;

  bool _addressExpanded = false;
  bool _shippingExpanded = false;
  bool _paymentExpanded = false;
  bool _invoiceExpanded = false;
  bool _termsAccepted = false;
  bool _couponApplied = false;

  CheckoutAddressPreset _selectedAddress = CheckoutAddressPreset.home;
  CheckoutShippingMethod _selectedShippingMethod =
      CheckoutShippingMethod.standard;
  CheckoutPaymentMethod _selectedPaymentMethod = CheckoutPaymentMethod.card;
  String _selectedDeliverySlot = 'صباحًا (09:00 - 12:00)';

  String? _couponStatus;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  late final TextEditingController _streetController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _shippingNotesController;
  late final TextEditingController _cardNameController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _cardExpiryController;
  late final TextEditingController _cardCvvController;
  late final TextEditingController _couponController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'عبدالسلام معاد');
    _phoneController = TextEditingController(text: '967777123456');
    _cityController = TextEditingController(text: 'صنعاء');
    _streetController = TextEditingController(text: 'شارع الحرية - المبنى 12');
    _landmarkController = TextEditingController(text: 'بجوار مسجد الفجر');
    _shippingNotesController = TextEditingController(
      text: 'يرجى الاتصال قبل 15 دقيقة من الوصول.',
    );
    _cardNameController = TextEditingController();
    _cardNumberController = TextEditingController();
    _cardExpiryController = TextEditingController();
    _cardCvvController = TextEditingController();
    _couponController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _shippingNotesController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  String get _addressLabel => switch (_selectedAddress) {
    CheckoutAddressPreset.home => 'المنزل',
    CheckoutAddressPreset.office => 'العمل',
    CheckoutAddressPreset.family => 'منزل العائلة',
  };

  String get _shippingMethodLabel => switch (_selectedShippingMethod) {
    CheckoutShippingMethod.standard => 'شحن قياسي',
    CheckoutShippingMethod.express => 'شحن سريع',
    CheckoutShippingMethod.pickup => 'استلام من الفرع',
  };

  String get _paymentMethodLabel => switch (_selectedPaymentMethod) {
    CheckoutPaymentMethod.card => 'بطاقة بنكية',
    CheckoutPaymentMethod.wallet => 'محفظة إلكترونية',
    CheckoutPaymentMethod.cash => 'الدفع عند الاستلام',
  };

  double get _shippingAmount => switch (_selectedShippingMethod) {
    CheckoutShippingMethod.standard => 12.0,
    CheckoutShippingMethod.express => 24.0,
    CheckoutShippingMethod.pickup => 0.0,
  };

  double get _discountAmount => _couponApplied ? _couponDiscountAmount : 0.0;

  double get _taxableAmount {
    final net = _subtotalAmount - _discountAmount;
    return net > 0 ? net : 0;
  }

  double get _taxAmount => _taxableAmount * _taxRate;

  double get _totalAmount => _taxableAmount + _taxAmount + _shippingAmount;

  bool get _isAddressValid {
    final name = _nameController.text.trim();
    final phoneDigits = _digitsOnly(_phoneController.text);
    final city = _cityController.text.trim();
    final street = _streetController.text.trim();
    return name.isNotEmpty &&
        phoneDigits.length >= 9 &&
        city.isNotEmpty &&
        street.isNotEmpty;
  }

  bool get _isCardValid {
    final cardName = _cardNameController.text.trim();
    final cardNumber = _digitsOnly(_cardNumberController.text);
    final expiry = _cardExpiryController.text.trim();
    final cvv = _digitsOnly(_cardCvvController.text);
    final expiryPattern = RegExp(r'^\d{2}/\d{2}$');
    return cardName.isNotEmpty &&
        cardNumber.length == 16 &&
        expiryPattern.hasMatch(expiry) &&
        cvv.length == 3;
  }

  bool get _isPaymentValid =>
      _selectedPaymentMethod == CheckoutPaymentMethod.card
      ? _isCardValid
      : true;

  bool get _canConfirmPayment =>
      _termsAccepted && _isAddressValid && _isPaymentValid;

  void _toggleAddress() {
    setState(() {
      final nextValue = !_addressExpanded;
      _addressExpanded = nextValue;
      if (nextValue) {
        _shippingExpanded = false;
        _paymentExpanded = false;
      }
    });
  }

  void _toggleShipping() {
    setState(() {
      final nextValue = !_shippingExpanded;
      _shippingExpanded = nextValue;
      if (nextValue) {
        _addressExpanded = false;
        _paymentExpanded = false;
      }
    });
  }

  void _togglePayment() {
    setState(() {
      final nextValue = !_paymentExpanded;
      _paymentExpanded = nextValue;
      if (nextValue) {
        _addressExpanded = false;
        _shippingExpanded = false;
      }
    });
  }

  void _toggleInvoice() {
    setState(() => _invoiceExpanded = !_invoiceExpanded);
  }

  void _selectAddress(CheckoutAddressPreset preset) {
    setState(() {
      _selectedAddress = preset;
      switch (preset) {
        case CheckoutAddressPreset.home:
          _cityController.text = 'صنعاء';
          _streetController.text = 'شارع الحرية - المبنى 12';
          _landmarkController.text = 'بجوار مسجد النور';
        case CheckoutAddressPreset.office:
          _cityController.text = 'عدن';
          _streetController.text = 'خور مكسر - برج الأعمال 3';
          _landmarkController.text = 'الطابق الخامس';
        case CheckoutAddressPreset.family:
          _cityController.text = 'حضرموت';
          _streetController.text = 'الحوطة - شارع السوق القديم';
          _landmarkController.text = 'قرب الصيدلية المركزية';
      }
    });
  }

  void _selectShippingMethod(CheckoutShippingMethod method) {
    setState(() => _selectedShippingMethod = method);
  }

  void _selectPaymentMethod(CheckoutPaymentMethod method) {
    setState(() => _selectedPaymentMethod = method);
  }

  void _applyCoupon() {
    final normalized = _couponController.text.trim().toUpperCase();
    setState(() {
      if (normalized == 'ELASTIC20') {
        _couponApplied = true;
        _couponStatus = 'تم تطبيق الخصم بنجاح';
      } else {
        _couponApplied = false;
        _couponStatus = 'كوبون غير صالح';
      }
    });
  }

  void _confirmPayment() {
    if (!_canConfirmPayment) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم تأكيد الطلب بنجاح')));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF4F6FB),
          surfaceTintColor: Colors.transparent,
          title: const Text('صفحة الدفع'),
        ),
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            key: const Key('checkout_showcase_page'),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                sliver: SliverList.list(
                  children: [
                    _buildHeaderCard(context),
                    const SizedBox(height: 16),
                    _buildPatternGuide(context),
                    const SizedBox(height: 14),
                    _buildInteractiveStack(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CheckoutBottomBar(
          totalAmount: _totalAmount,
          canConfirm: _canConfirmPayment,
          onConfirm: _confirmPayment,
        ),
      ),
    );
  }

  Widget _buildInteractiveStack() {
    double currentTop = 0;
    final List<double> calculatedTops = [];
    double maxExtent = 0;

    final behaviors = [
      CheckoutSheetBehavior.push,
      CheckoutSheetBehavior.push,
      CheckoutSheetBehavior.floating,
      CheckoutSheetBehavior.docked,
    ];
    final expandedStates = [
      _addressExpanded,
      _shippingExpanded,
      _paymentExpanded,
      _invoiceExpanded,
    ];
    final expandedHeights = [356.0, 320.0, 360.0, 390.0];
    const double collapsedHeight = 72.0;
    const double spacing = 16.0;

    for (int i = 0; i < 4; i++) {
      calculatedTops.add(currentTop);

      final behavior = behaviors[i];
      final isExpanded = expandedStates[i];
      final expHeight = expandedHeights[i];

      double itemHeightContribution = 0;
      final double visualHeight = isExpanded ? expHeight : collapsedHeight;

      if (behavior == CheckoutSheetBehavior.push) {
        itemHeightContribution = visualHeight + spacing;
      } else if (behavior == CheckoutSheetBehavior.floating) {
        itemHeightContribution = collapsedHeight + spacing;
      } else if (behavior == CheckoutSheetBehavior.docked) {
        itemHeightContribution = visualHeight;
      }

      currentTop += itemHeightContribution;

      final double itemBottom = calculatedTops[i] + visualHeight;
      if (itemBottom > maxExtent) {
        maxExtent = itemBottom;
      }
    }

    final items = [
      StackedSectionData(
        index: 0,
        top: calculatedTops[0],
        isExpanded: _addressExpanded,
        expandedHeight: 356,
        behavior: CheckoutSheetBehavior.push,
        child: _buildAddressSection(),
      ),
      StackedSectionData(
        index: 1,
        top: calculatedTops[1],
        isExpanded: _shippingExpanded,
        expandedHeight: 320,
        behavior: CheckoutSheetBehavior.push,
        child: _buildShippingSection(),
      ),
      StackedSectionData(
        index: 2,
        top: calculatedTops[2],
        isExpanded: _paymentExpanded,
        expandedHeight: 360,
        behavior: CheckoutSheetBehavior.floating,
        child: _buildPaymentSection(),
      ),
      StackedSectionData(
        index: 3,
        top: calculatedTops[3],
        isExpanded: _invoiceExpanded,
        expandedHeight: 390,
        behavior: CheckoutSheetBehavior.docked,
        child: _buildInvoiceSection(),
      ),
    ];

    // Build the dynamic paint order:
    // Non-active floating / regular items first, active floating items last.
    final basePaintOrder = [items[3], items[1], items[0], items[2]];
    final List<StackedSectionData> paintOrder = [];

    // 1. Draw non-active floating and other items
    for (final item in basePaintOrder) {
      if (!(item.behavior == CheckoutSheetBehavior.floating && item.isExpanded)) {
        paintOrder.add(item);
      }
    }
    // 2. Draw active floating items on top
    for (final item in basePaintOrder) {
      if (item.behavior == CheckoutSheetBehavior.floating && item.isExpanded) {
        paintOrder.add(item);
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      height: maxExtent,
      child: Stack(
        clipBehavior: Clip.none,
        children: paintOrder.map((item) {
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            key: ValueKey('checkout_section_${item.index}'),
            top: item.top,
            left: 0,
            right: 0,
            child: item.child,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F1FF), Color(0xFFF6FAFF)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'طلب متجر Elastic Sheet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'راجع العنوان وطريقة الدفع والفاتورة قبل تأكيد الطلب.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Push · Floating · Docked',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF075985),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternGuide(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: const Color(0xFF64748B),
          height: 1.35,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Existing checkout pieces, different layout behavior',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Address and shipping push the next rows down. Payment expands as a floating surface above the invoice. Invoice stays as the docked order summary.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return CheckoutSheetSection(
      keyName: 'address',
      accent: const Color(0xFF0F766E),
      isExpanded: _addressExpanded,
      onToggle: _toggleAddress,
      onCollapse: () => setState(() => _addressExpanded = false),
      collapsedSummary: AddressSummaryTile(
        summaryKey: const Key('checkout_address_summary_text'),
        title: 'العنوان',
        subtitle: '$_addressLabel • ${_cityController.text.trim()}',
        icon: Icons.location_on_outlined,
      ),
      expandedChild: _buildAddressExpandedContent(),
      expandedContentKey: const Key('checkout_address_expanded'),
      toggleKey: const Key('checkout_address_toggle'),
      collapseKey: const Key('checkout_address_collapse'),
      expandedHeight: 356,
    );
  }

  Widget _buildAddressExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoicePill(
              tapTargetKey: const Key('checkout_address_option_home'),
              label: 'المنزل',
              selected: _selectedAddress == CheckoutAddressPreset.home,
              onTap: () => _selectAddress(CheckoutAddressPreset.home),
            ),
            ChoicePill(
              tapTargetKey: const Key('checkout_address_option_office'),
              label: 'العمل',
              selected: _selectedAddress == CheckoutAddressPreset.office,
              onTap: () => _selectAddress(CheckoutAddressPreset.office),
            ),
            ChoicePill(
              tapTargetKey: const Key('checkout_address_option_family'),
              label: 'منزل العائلة',
              selected: _selectedAddress == CheckoutAddressPreset.family,
              onTap: () => _selectAddress(CheckoutAddressPreset.family),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CheckoutField(
          fieldKey: const Key('checkout_address_name_field'),
          controller: _nameController,
          labelText: 'اسم المستلم',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        CheckoutField(
          fieldKey: const Key('checkout_address_phone_field'),
          controller: _phoneController,
          labelText: 'رقم الهاتف',
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CheckoutField(
                fieldKey: const Key('checkout_address_city_field'),
                controller: _cityController,
                labelText: 'المدينة',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CheckoutField(
                fieldKey: const Key('checkout_address_street_field'),
                controller: _streetController,
                labelText: 'الشارع',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        CheckoutField(
          fieldKey: const Key('checkout_address_landmark_field'),
          controller: _landmarkController,
          labelText: 'علامة مميزة (اختياري)',
        ),
      ],
    );
  }

  Widget _buildShippingSection() {
    return CheckoutSheetSection(
      keyName: 'shipping',
      accent: const Color(0xFF2563EB),
      isExpanded: _shippingExpanded,
      onToggle: _toggleShipping,
      onCollapse: () => setState(() => _shippingExpanded = false),
      collapsedSummary: AddressSummaryTile(
        summaryKey: const Key('checkout_shipping_summary_text'),
        title: 'الشحن',
        subtitle: '$_shippingMethodLabel • $_selectedDeliverySlot',
        icon: Icons.local_shipping_outlined,
      ),
      expandedChild: _buildShippingExpandedContent(),
      expandedContentKey: const Key('checkout_shipping_expanded'),
      toggleKey: const Key('checkout_shipping_toggle'),
      collapseKey: const Key('checkout_shipping_collapse'),
      expandedHeight: 320,
    );
  }

  Widget _buildShippingExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutOptionTile(
          tapTargetKey: const Key('checkout_shipping_method_standard'),
          title: 'شحن قياسي',
          subtitle: '2-3 أيام',
          trailing: '+${_formatCurrency(12)}',
          selected: _selectedShippingMethod == CheckoutShippingMethod.standard,
          onTap: () => _selectShippingMethod(CheckoutShippingMethod.standard),
        ),
        const SizedBox(height: 8),
        CheckoutOptionTile(
          tapTargetKey: const Key('checkout_shipping_method_express'),
          title: 'شحن سريع',
          subtitle: 'خلال 24 ساعة',
          trailing: '+${_formatCurrency(24)}',
          selected: _selectedShippingMethod == CheckoutShippingMethod.express,
          onTap: () => _selectShippingMethod(CheckoutShippingMethod.express),
        ),
        const SizedBox(height: 8),
        CheckoutOptionTile(
          tapTargetKey: const Key('checkout_shipping_method_pickup'),
          title: 'استلام من الفرع',
          subtitle: 'من دون رسوم شحن',
          trailing: _formatCurrency(0),
          selected: _selectedShippingMethod == CheckoutShippingMethod.pickup,
          onTap: () => _selectShippingMethod(CheckoutShippingMethod.pickup),
        ),
        const SizedBox(height: 12),
        Text(
          'نافذة التسليم',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF374151),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoicePill(
              tapTargetKey: const Key('checkout_shipping_slot_morning'),
              label: 'صباحًا (09:00 - 12:00)',
              selected: _selectedDeliverySlot == 'صباحًا (09:00 - 12:00)',
              onTap: () => setState(() {
                _selectedDeliverySlot = 'صباحًا (09:00 - 12:00)';
              }),
            ),
            ChoicePill(
              tapTargetKey: const Key('checkout_shipping_slot_afternoon'),
              label: 'ظهرًا (13:00 - 16:00)',
              selected: _selectedDeliverySlot == 'ظهرًا (13:00 - 16:00)',
              onTap: () => setState(() {
                _selectedDeliverySlot = 'ظهرًا (13:00 - 16:00)';
              }),
            ),
            ChoicePill(
              tapTargetKey: const Key('checkout_shipping_slot_evening'),
              label: 'مساءً (18:00 - 21:00)',
              selected: _selectedDeliverySlot == 'مساءً (18:00 - 21:00)',
              onTap: () => setState(() {
                _selectedDeliverySlot = 'مساءً (18:00 - 21:00)';
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),
        CheckoutField(
          fieldKey: const Key('checkout_shipping_notes_field'),
          controller: _shippingNotesController,
          labelText: 'ملاحظات الشحن (اختياري)',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return CheckoutSheetSection(
      keyName: 'payment',
      accent: const Color(0xFF7C3AED),
      isExpanded: _paymentExpanded,
      onToggle: _togglePayment,
      onCollapse: () => setState(() => _paymentExpanded = false),
      collapsedSummary: AddressSummaryTile(
        summaryKey: const Key('checkout_payment_summary_text'),
        title: 'طريقة الدفع',
        subtitle: _paymentMethodLabel,
        icon: Icons.credit_card_outlined,
      ),
      expandedChild: _buildPaymentExpandedContent(),
      expandedContentKey: const Key('checkout_payment_expanded'),
      toggleKey: const Key('checkout_payment_toggle'),
      collapseKey: const Key('checkout_payment_collapse'),
      expandedHeight: 360,
    );
  }

  Widget _buildPaymentExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutOptionTile(
          tapTargetKey: const Key('checkout_payment_method_card'),
          title: 'بطاقة بنكية',
          subtitle: 'Visa / MasterCard',
          trailing: 'افتراضي',
          selected: _selectedPaymentMethod == CheckoutPaymentMethod.card,
          onTap: () => _selectPaymentMethod(CheckoutPaymentMethod.card),
        ),
        const SizedBox(height: 8),
        CheckoutOptionTile(
          tapTargetKey: const Key('checkout_payment_method_wallet'),
          title: 'محفظة إلكترونية',
          subtitle: 'Apple Pay / Google Pay',
          trailing: 'فوري',
          selected: _selectedPaymentMethod == CheckoutPaymentMethod.wallet,
          onTap: () => _selectPaymentMethod(CheckoutPaymentMethod.wallet),
        ),
        const SizedBox(height: 8),
        CheckoutOptionTile(
          tapTargetKey: const Key('checkout_payment_method_cash'),
          title: 'الدفع عند الاستلام',
          subtitle: 'ادفع عند وصول الطلب',
          trailing: 'نقدًا',
          selected: _selectedPaymentMethod == CheckoutPaymentMethod.cash,
          onTap: () => _selectPaymentMethod(CheckoutPaymentMethod.cash),
        ),
        if (_selectedPaymentMethod == CheckoutPaymentMethod.card) ...[
          const SizedBox(height: 12),
          CheckoutField(
            fieldKey: const Key('checkout_card_name_field'),
            controller: _cardNameController,
            labelText: 'اسم حامل البطاقة',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          CheckoutField(
            fieldKey: const Key('checkout_card_number_field'),
            controller: _cardNumberController,
            labelText: 'رقم البطاقة',
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CheckoutField(
                  fieldKey: const Key('checkout_card_expiry_field'),
                  controller: _cardExpiryController,
                  labelText: 'MM/YY',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CheckoutField(
                  fieldKey: const Key('checkout_card_cvv_field'),
                  controller: _cardCvvController,
                  labelText: 'CVV',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInvoiceSection() {
    return CheckoutSheetSection(
      keyName: 'invoice',
      accent: const Color(0xFFD97706),
      isExpanded: _invoiceExpanded,
      onToggle: _toggleInvoice,
      onCollapse: () => setState(() => _invoiceExpanded = false),
      collapsedSummary: AddressSummaryTile(
        summaryKey: const Key('checkout_invoice_summary_text'),
        title: 'الفاتورة',
        subtitle: 'الإجمالي ${_formatCurrency(_totalAmount)}',
        icon: Icons.receipt_long_outlined,
      ),
      expandedChild: _buildInvoiceExpandedContent(),
      expandedContentKey: const Key('checkout_invoice_expanded'),
      toggleKey: const Key('checkout_invoice_toggle'),
      collapseKey: const Key('checkout_invoice_collapse'),
      expandedHeight: 390,
    );
  }

  Widget _buildInvoiceExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InvoiceProductTile(
          title: 'حقيبة أدوات مكتبية',
          subtitle: 'لون فحمي • عدد 1',
          price: '129.00 ر.س',
        ),
        const SizedBox(height: 8),
        const InvoiceProductTile(
          title: 'مصباح سطح مرن',
          subtitle: 'لون أبيض • عدد 1',
          price: '60.00 ر.س',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CheckoutField(
                fieldKey: const Key('checkout_coupon_field'),
                controller: _couponController,
                labelText: 'كود الخصم',
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                key: const Key('checkout_apply_coupon_button'),
                onPressed: _applyCoupon,
                child: const Text('تطبيق'),
              ),
            ),
          ],
        ),
        if (_couponStatus != null) ...[
          const SizedBox(height: 8),
          Text(
            _couponStatus!,
            key: const Key('checkout_coupon_status_text'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _couponApplied
                  ? const Color(0xFF0F766E)
                  : const Color(0xFFB91C1C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 12),
        InvoiceAmountRow(
          label: 'المجموع الفرعي',
          valueKey: const Key('checkout_invoice_subtotal_amount'),
          value: _formatCurrency(_subtotalAmount),
        ),
        const SizedBox(height: 6),
        InvoiceAmountRow(
          label: 'الضريبة (15%)',
          valueKey: const Key('checkout_invoice_tax_amount'),
          value: _formatCurrency(_taxAmount),
        ),
        const SizedBox(height: 6),
        InvoiceAmountRow(
          label: 'رسوم الشحن',
          valueKey: const Key('checkout_invoice_shipping_amount'),
          value: _formatCurrency(_shippingAmount),
        ),
        const SizedBox(height: 6),
        InvoiceAmountRow(
          label: 'الخصم',
          valueKey: const Key('checkout_invoice_discount_amount'),
          value: '-${_formatCurrency(_discountAmount)}',
        ),
        const Divider(height: 18),
        InvoiceAmountRow(
          label: 'الإجمالي',
          valueKey: const Key('checkout_invoice_total_amount'),
          value: _formatCurrency(_totalAmount),
          emphasize: true,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(14),
          ),
          child: CheckboxListTile(
            key: const Key('checkout_terms_checkbox'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            title: const Text('أوافق على شروط الدفع والاسترجاع'),
            value: _termsAccepted,
            onChanged: (value) =>
                setState(() => _termsAccepted = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(2)} ر.س';
  }

  String _digitsOnly(String text) {
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
