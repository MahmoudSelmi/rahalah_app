import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ride_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> pickup;
  final Map<String, dynamic> destination;
  final Map<String, dynamic> rideType;
  final Map<String, dynamic> driver;
  final double price;

  const PaymentScreen({
    super.key,
    required this.pickup,
    required this.destination,
    required this.rideType,
    required this.driver,
    required this.price,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  int _selectedPayment = 0; // 0=cash, 1=visa
  bool _isConfirming = false;
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  late AnimationController _pageAnimController;
  late AnimationController _cardFlipController;
  late Animation<double> _pageFade;
  late Animation<Offset> _pageSlide;
  late Animation<double> _cardFlip;

  @override
  void initState() {
    super.initState();
    _pageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pageFade = CurvedAnimation(
      parent: _pageAnimController,
      curve: Curves.easeOut,
    );
    _pageSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _pageAnimController, curve: Curves.easeOut),
        );
    _cardFlip = CurvedAnimation(
      parent: _cardFlipController,
      curve: Curves.easeInOut,
    );

    _pageAnimController.forward();
  }

  @override
  void dispose() {
    _pageAnimController.dispose();
    _cardFlipController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _confirmPayment() async {
    HapticFeedback.mediumImpact();
    setState(() => _isConfirming = true);

    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => RideConfirmationScreen(
            pickup: widget.pickup,
            destination: widget.destination,
            rideType: widget.rideType,
            driver: widget.driver,
            price: widget.price,
            paymentMethod: _selectedPayment == 0 ? 'كاش' : 'فيزا',
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A16),
      body: SafeArea(
        child: FadeTransition(
          opacity: _pageFade,
          child: SlideTransition(
            position: _pageSlide,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        _CircleBtn(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          'طريقة الدفع',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),

                // Price summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: _PriceSummary(
                      price: widget.price,
                      rideType: widget.rideType,
                    ),
                  ),
                ),

                // Payment method selector
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4, bottom: 12),
                          child: Text(
                            'اختر طريقة الدفع',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _PaymentOption(
                                icon: Icons.payments_rounded,
                                label: 'كاش',
                                sublabel: 'ادفع للسائق',
                                color: const Color(0xFF10B981),
                                isSelected: _selectedPayment == 0,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedPayment = 0);
                                  _cardFlipController.reverse();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PaymentOption(
                                icon: Icons.credit_card_rounded,
                                label: 'فيزا / كارت',
                                sublabel: 'دفع إلكتروني',
                                color: const Color(0xFF3B82F6),
                                isSelected: _selectedPayment == 1,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedPayment = 1);
                                  _cardFlipController.forward();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Card form (visa only)
                if (_selectedPayment == 1)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: AnimatedBuilder(
                        animation: _cardFlip,
                        builder: (_, child) => FadeTransition(
                          opacity: _cardFlip,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(_cardFlip),
                            child: child,
                          ),
                        ),
                        child: _CardForm(
                          cardController: _cardController,
                          expiryController: _expiryController,
                          cvvController: _cvvController,
                        ),
                      ),
                    ),
                  ),

                // Driver summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _DriverSummary(driver: widget.driver),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1526),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _isConfirming ? null : _confirmPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedPayment == 0
                  ? const Color(0xFF10B981)
                  : const Color(0xFF3B82F6),
              disabledBackgroundColor:
                  (_selectedPayment == 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFF3B82F6))
                      .withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isConfirming
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedPayment == 0
                            ? Icons.check_circle_rounded
                            : Icons.lock_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _selectedPayment == 0
                            ? 'تأكيد الرحلة • كاش'
                            : 'دفع آمن • ${widget.price.toStringAsFixed(0)} جنيه',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final double price;
  final Map<String, dynamic> rideType;

  const _PriceSummary({required this.price, required this.rideType});

  @override
  Widget build(BuildContext context) {
    final color = rideType['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(rideType['icon'] as IconData, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rideType['type'],
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  rideType['desc'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${price.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'جنيه مصري',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : const Color(0xFF0B1526),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.5)
                : Colors.white.withOpacity(0.06),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : Colors.white.withOpacity(0.4),
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo',
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 10,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 13,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardForm extends StatelessWidget {
  final TextEditingController cardController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;

  const _CardForm({
    required this.cardController,
    required this.expiryController,
    required this.cvvController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1526),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mock card visual
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'VISA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                      child: const Icon(
                        Icons.credit_card_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  '**** **** **** 1234',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'اسم حامل الكارت',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '12/26',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _CardField(
            label: 'رقم البطاقة',
            controller: cardController,
            hint: '•••• •••• •••• ••••',
            keyboardType: TextInputType.number,
            icon: Icons.credit_card_rounded,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CardField(
                  label: 'تاريخ الانتهاء',
                  controller: expiryController,
                  hint: 'MM / YY',
                  keyboardType: TextInputType.number,
                  icon: Icons.calendar_month_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CardField(
                  label: 'CVV',
                  controller: cvvController,
                  hint: '•••',
                  keyboardType: TextInputType.number,
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final IconData icon;
  final bool obscure;

  const _CardField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontFamily: 'Cairo',
      ),
      cursorColor: const Color(0xFF3B82F6),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontFamily: 'Cairo',
          fontSize: 12,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.2),
          fontFamily: 'Cairo',
        ),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.3), size: 18),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.07)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
      ),
    );
  }
}

class _DriverSummary extends StatelessWidget {
  final Map<String, dynamic> driver;

  const _DriverSummary({required this.driver});

  @override
  Widget build(BuildContext context) {
    final color = driver['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                driver['avatar'],
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  '${driver['car']} • ${driver['plate']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFF5A623),
                size: 15,
              ),
              const SizedBox(width: 4),
              Text(
                '${driver['rating']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
