import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class RideConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> pickup;
  final Map<String, dynamic> destination;
  final Map<String, dynamic> rideType;
  final Map<String, dynamic> driver;
  final double price;
  final String paymentMethod;

  const RideConfirmationScreen({
    super.key,
    required this.pickup,
    required this.destination,
    required this.rideType,
    required this.driver,
    required this.price,
    required this.paymentMethod,
  });

  @override
  State<RideConfirmationScreen> createState() => _RideConfirmationScreenState();
}

class _RideConfirmationScreenState extends State<RideConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _successAnimController;
  late AnimationController _contentAnimController;
  late AnimationController _pulseAnimController;
  late AnimationController _etaAnimController;

  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;
  late Animation<double> _ringScale;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _pulse;
  late Animation<double> _etaProgress;

  int _etaSeconds = 240; // 4 minutes
  bool _rideStarted = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _successAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _etaAnimController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _etaSeconds),
    );

    _checkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _successAnimController,
        curve: const Interval(0.3, 0.9, curve: Curves.elasticOut),
      ),
    );
    _checkOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _successAnimController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );
    _ringScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _successAnimController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _contentFade = CurvedAnimation(
      parent: _contentAnimController,
      curve: Curves.easeOut,
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentAnimController,
            curve: Curves.easeOut,
          ),
        );
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseAnimController, curve: Curves.easeInOut),
    );
    _etaProgress = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _etaAnimController, curve: Curves.linear),
    );

    _successAnimController.forward().then((_) {
      _contentAnimController.forward();
      _etaAnimController.forward();
    });

    // Simulate ETA countdown
    _startEtaCountdown();
  }

  void _startEtaCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _etaSeconds > 0) {
        setState(() => _etaSeconds--);
        _startEtaCountdown();
      }
    });
  }

  @override
  void dispose() {
    _successAnimController.dispose();
    _contentAnimController.dispose();
    _pulseAnimController.dispose();
    _etaAnimController.dispose();
    super.dispose();
  }

  String get _etaDisplay {
    final mins = _etaSeconds ~/ 60;
    final secs = _etaSeconds % 60;
    if (mins > 0) return '$mins دقيقة ${secs > 0 ? '${secs}ث' : ''}';
    return '${_etaSeconds} ثانية';
  }

  @override
  Widget build(BuildContext context) {
    final rideColor = widget.rideType['color'] as Color;
    final driverColor = widget.driver['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFF030A16),
      body: SafeArea(
        child: FadeTransition(
          opacity: _contentFade,
          child: SlideTransition(
            position: _contentSlide,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Success header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      children: [
                        // Animated success icon
                        AnimatedBuilder(
                          animation: _successAnimController,
                          builder: (_, __) => Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer ring
                              Transform.scale(
                                scale: _ringScale.value,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.08),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              // Pulse ring
                              AnimatedBuilder(
                                animation: _pulse,
                                builder: (_, __) => Transform.scale(
                                  scale: _ringScale.value * _pulse.value,
                                  child: Container(
                                    width: 78,
                                    height: 78,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.15),
                                    ),
                                  ),
                                ),
                              ),
                              // Check
                              Transform.scale(
                                scale: _checkScale.value,
                                child: Opacity(
                                  opacity: _checkOpacity.value,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF10B981),
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Text(
                          'تم تأكيد الرحلة! 🎉',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'السائق في طريقه إليك',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ETA Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: _EtaCard(
                      etaDisplay: _etaDisplay,
                      etaProgress: _etaProgress,
                      driver: widget.driver,
                    ),
                  ),
                ),

                // Driver info
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _DriverDetailCard(
                      driver: widget.driver,
                      driverColor: driverColor,
                    ),
                  ),
                ),

                // Trip details
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _TripDetailsCard(
                      pickup: widget.pickup,
                      destination: widget.destination,
                      rideType: widget.rideType,
                      price: widget.price,
                      paymentMethod: widget.paymentMethod,
                    ),
                  ),
                ),

                // Action buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionBtn(
                            icon: Icons.phone_rounded,
                            label: 'اتصل بالسائق',
                            color: const Color(0xFF10B981),
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionBtn(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'رسالة للسائق',
                            color: const Color(0xFF3B82F6),
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionBtn(
                            icon: Icons.share_location_rounded,
                            label: 'شارك الرحلة',
                            color: const Color(0xFFA78BFA),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Cancel button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    child: GestureDetector(
                      onTap: () {
                        _showCancelDialog(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF87171).withOpacity(0.07),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFF87171).withOpacity(0.15),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cancel_outlined,
                              color: Color(0xFFF87171),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'إلغاء الرحلة',
                              style: TextStyle(
                                color: Color(0xFFF87171),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B1526),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF87171).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: Color(0xFFF87171),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'إلغاء الرحلة؟',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'السائق في طريقه، قد يترتب على الإلغاء رسوم',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'تراجع',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.popUntil(context, (r) => r.isFirst);
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF87171).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFF87171).withOpacity(0.3),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'إلغاء الرحلة',
                          style: TextStyle(
                            color: Color(0xFFF87171),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _EtaCard extends StatelessWidget {
  final String etaDisplay;
  final Animation<double> etaProgress;
  final Map<String, dynamic> driver;

  const _EtaCard({
    required this.etaDisplay,
    required this.etaProgress,
    required this.driver,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الوصول خلال',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    etaDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          AnimatedBuilder(
            animation: etaProgress,
            builder: (_, __) => Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 1 - etaProgress.value,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
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

class _DriverDetailCard extends StatelessWidget {
  final Map<String, dynamic> driver;
  final Color driverColor;

  const _DriverDetailCard({required this.driver, required this.driverColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1526),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: driverColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: driverColor.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(
                driver['avatar'],
                style: TextStyle(
                  color: driverColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  driver['car'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    driver['plate'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF5A623),
                    size: 16,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${driver['rating']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Text(
                '${driver['trips']} رحلة',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 10,
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

class _TripDetailsCard extends StatelessWidget {
  final Map<String, dynamic> pickup;
  final Map<String, dynamic> destination;
  final Map<String, dynamic> rideType;
  final double price;
  final String paymentMethod;

  const _TripDetailsCard({
    required this.pickup,
    required this.destination,
    required this.rideType,
    required this.price,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1526),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.my_location_rounded,
            iconColor: const Color(0xFF3B82F6),
            label: 'نقطة الانطلاق',
            value: pickup['name'],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Divider(color: Colors.white.withOpacity(0.05), height: 16),
          ),
          _DetailRow(
            icon: Icons.flag_rounded,
            iconColor: const Color(0xFF10B981),
            label: 'الوجهة',
            value: destination['name'],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Divider(color: Colors.white.withOpacity(0.05), height: 16),
          ),
          _DetailRow(
            icon: Icons.payments_rounded,
            iconColor: const Color(0xFFF5A623),
            label: 'طريقة الدفع',
            value: paymentMethod,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Divider(color: Colors.white.withOpacity(0.05), height: 16),
          ),
          _DetailRow(
            icon: Icons.monetization_on_outlined,
            iconColor: const Color(0xFFA78BFA),
            label: 'المبلغ',
            value: '${price.toStringAsFixed(0)} جنيه',
            valueColor: const Color(0xFFA78BFA),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
