// lib/screens/payment_form_screen.dart
// Phase 6F: Payment form screen.
//
// Route: /payment/form?id=VIOLATION_ID&method=card|wallet
// On success → ViolationsProvider.markPaid(id) → /payment/success?id=X

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/violation.dart';
import '../providers/violations_provider.dart';
import '../theme/app_theme.dart';

class PaymentFormScreen extends StatefulWidget {
  final String violationId;
  final String method; // 'card' | 'wallet'
  const PaymentFormScreen(
      {super.key, required this.violationId, required this.method});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen>
    with SingleTickerProviderStateMixin {
  // Card fields
  final _nameCtrl = TextEditingController();
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  // Wallet fields
  final _phoneCtrl = TextEditingController();
  final _pinCtrls =
      List.generate(4, (_) => TextEditingController());
  final _pinFocuses = List.generate(4, (_) => FocusNode());

  bool _processing = false;

  // Shake animation
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );

    // Card number formatter
    _cardCtrl.addListener(_formatCardNumber);
    // Expiry formatter
    _expiryCtrl.addListener(_formatExpiry);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _nameCtrl.dispose();
    _cardCtrl.removeListener(_formatCardNumber);
    _cardCtrl.dispose();
    _expiryCtrl.removeListener(_formatExpiry);
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _phoneCtrl.dispose();
    for (final c in _pinCtrls) {
      c.dispose();
    }
    for (final f in _pinFocuses) {
      f.dispose();
    }
    super.dispose();
  }

  // ── Card number: insert spaces every 4 digits ──────────────────────────────
  String? _lastFormatted;

  void _formatCardNumber() {
    final raw = _cardCtrl.text.replaceAll(' ', '');
    if (raw.length > 16) return;
    final parts = <String>[];
    for (var i = 0; i < raw.length; i += 4) {
      parts.add(raw.substring(i, (i + 4).clamp(0, raw.length)));
    }
    final formatted = parts.join(' ');
    if (formatted == _lastFormatted) return;
    _lastFormatted = formatted;
    _cardCtrl.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // ── Expiry: auto-insert '/' after MM ──────────────────────────────────────
  String? _lastExpiry;

  void _formatExpiry() {
    final raw = _expiryCtrl.text.replaceAll('/', '');
    if (raw.length > 4) return;
    String formatted = raw;
    if (raw.length >= 2) {
      formatted = '${raw.substring(0, 2)}/${raw.substring(2)}';
    }
    if (formatted == _lastExpiry) return;
    _lastExpiry = formatted;
    _expiryCtrl.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  bool get _isValid {
    if (widget.method == 'card') {
      return _nameCtrl.text.trim().isNotEmpty &&
          _cardCtrl.text.replaceAll(' ', '').length == 16 &&
          _expiryCtrl.text.length == 5 &&
          _cvvCtrl.text.length == 3;
    } else {
      return _phoneCtrl.text.trim().isNotEmpty &&
          _pinCtrls.every((c) => c.text.length == 1);
    }
  }

  // ── Payment ────────────────────────────────────────────────────────────────

  Future<void> _pay() async {
    if (!_isValid) {
      _shakeCtrl.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _processing = true);

    // Mock 1.5s processing delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Mark paid
    await context
        .read<ViolationsProvider>()
        .markPaid(widget.violationId);

    setState(() => _processing = false);

    // Replace current route so back won't return here
    if (mounted) {
      context.pushReplacement(
          '/payment/success?id=${widget.violationId}');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ViolationsProvider>();
    final ViolationData? violation = provider.violations
        .where((v) => v.violationId == widget.violationId)
        .firstOrNull;

    final fineStr = violation != null
        ? 'EGP ${violation.fineAmount.toStringAsFixed(2)}'
        : 'EGP —';
    final shortId = () {
      final parts = widget.violationId.split('_');
      return parts.length >= 3 ? '#${parts.last}' : '#${widget.violationId}';
    }();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _Header(
                  title: 'Payment Details',
                  onBack: () => context.pop(),
                ),

                // Summary row
                _SummaryRow(fineStr: fineStr, shortId: shortId),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.method == 'card')
                          _CardForm(
                            nameCtrl: _nameCtrl,
                            cardCtrl: _cardCtrl,
                            expiryCtrl: _expiryCtrl,
                            cvvCtrl: _cvvCtrl,
                          )
                        else
                          _WalletForm(
                            phoneCtrl: _phoneCtrl,
                            pinCtrls: _pinCtrls,
                            pinFocuses: _pinFocuses,
                          ),

                        const SizedBox(height: 16),

                        // Demo notice
                        _DemoNotice(),

                        const SizedBox(height: 24),

                        // Pay button with shake
                        AnimatedBuilder(
                          animation: _shakeAnim,
                          builder: (_, child) {
                            final offset = _shakeCtrl.isAnimating
                                ? 8 *
                                    (0.5 -
                                        (_shakeAnim.value - 0.5).abs())
                                : 0.0;
                            return Transform.translate(
                              offset: Offset(offset * 2, 0),
                              child: child,
                            );
                          },
                          child: _PayButton(
                            label: 'Pay $fineStr',
                            onPressed: _processing ? null : _pay,
                            isProcessing: _processing,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Full-screen processing overlay
          if (_processing)
            Container(
              color: Colors.black.withValues(alpha: 0.55),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                          color: AppColors.primary),
                      SizedBox(height: 16),
                      Text(
                        'Processing payment…',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
            onPressed: onBack,
          ),
          Text(
            title,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String fineStr;
  final String shortId;
  const _SummaryRow({required this.fineStr, required this.shortId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.bgCard,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Violation $shortId',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          Text(
            fineStr,
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── Card form ─────────────────────────────────────────────────────────────────

class _CardForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController cardCtrl;
  final TextEditingController expiryCtrl;
  final TextEditingController cvvCtrl;

  const _CardForm({
    required this.nameCtrl,
    required this.cardCtrl,
    required this.expiryCtrl,
    required this.cvvCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.credit_card_rounded, label: 'Card Details'),
        const SizedBox(height: 16),
        _Field(
          label: 'Cardholder Name',
          controller: nameCtrl,
          hint: 'FULL NAME',
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 14),
        _Field(
          label: 'Card Number',
          controller: cardCtrl,
          hint: '1234 5678 9012 3456',
          keyboardType: TextInputType.number,
          maxLength: 19,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Expiry Date',
                controller: expiryCtrl,
                hint: 'MM/YY',
                keyboardType: TextInputType.number,
                maxLength: 5,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _Field(
                label: 'CVV',
                controller: cvvCtrl,
                hint: '•••',
                keyboardType: TextInputType.number,
                maxLength: 3,
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Wallet form ───────────────────────────────────────────────────────────────

class _WalletForm extends StatelessWidget {
  final TextEditingController phoneCtrl;
  final List<TextEditingController> pinCtrls;
  final List<FocusNode> pinFocuses;

  const _WalletForm({
    required this.phoneCtrl,
    required this.pinCtrls,
    required this.pinFocuses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Wallet Details'),
        const SizedBox(height: 16),
        _Field(
          label: 'Phone Number',
          controller: phoneCtrl,
          hint: '+20 1XX XXX XXXX',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        const Text(
          'Wallet PIN',
          style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 56,
                height: 64,
                child: TextField(
                  controller: pinCtrls[i],
                  focusNode: pinFocuses[i],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  obscureText: true,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.bgSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) {
                    if (v.length == 1 && i < 3) {
                      FocusScope.of(context)
                          .requestFocus(pinFocuses[i + 1]);
                    } else if (v.isEmpty && i > 0) {
                      FocusScope.of(context)
                          .requestFocus(pinFocuses[i - 1]);
                    }
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLength,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: AppColors.textMuted, fontSize: 14),
            counterText: '',
            filled: true,
            fillColor: AppColors.bgSurface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _DemoNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.warning, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is a demonstration',
                  style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  'No real payment will be made. For UI/UX demonstration only.',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isProcessing;
  const _PayButton(
      {required this.label,
      required this.onPressed,
      required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEB4425),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFFEB4425).withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: isProcessing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Text(
                label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}