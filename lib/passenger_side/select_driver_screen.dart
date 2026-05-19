import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'payment_screen.dart';

class SelectDriverScreen extends StatefulWidget {
  final Map<String, dynamic> pickup;
  final Map<String, dynamic> destination;

  const SelectDriverScreen({
    super.key,
    required this.pickup,
    required this.destination,
  });

  @override
  State<SelectDriverScreen> createState() => _SelectDriverScreenState();
}

class _SelectDriverScreenState extends State<SelectDriverScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSearching = true;

  late AnimationController _searchAnimController;
  late AnimationController _cardsAnimController;
  late AnimationController _pulseAnimController;
  late Animation<double> _pulseAnim;

  final List<Map<String, dynamic>> _rideTypes = [
    {
      'type': 'رحالة X',
      'desc': 'اقتصادي • 4 مقاعد',
      'icon': Icons.directions_car_rounded,
      'color': Color(0xFF3B82F6),
      'price': 45,
      'time': 3,
      'promo': null,
    },
    {
      'type': 'رحالة XL',
      'desc': 'SUV فضفاض • 6 مقاعد',
      'icon': Icons.airport_shuttle_rounded,
      'color': Color(0xFF10B981),
      'price': 75,
      'time': 5,
      'promo': 'خصم 15%',
    },
    {
      'type': 'رحالة VIP',
      'desc': 'فاخر • تكييف مميز',
      'icon': Icons.star_rounded,
      'color': Color(0xFFF5A623),
      'price': 120,
      'time': 7,
      'promo': null,
    },
  ];

  final List<Map<String, dynamic>> _drivers = [
    {
      'name': 'أحمد محمود',
      'car': 'تويوتا كورولا',
      'plate': 'أ ب ج • 1234',
      'rating': 4.9,
      'trips': 1240,
      'color': Color(0xFF3B82F6),
      'distance': '2.3 كم',
      'eta': '4 دقائق',
      'avatar': 'أ',
    },
    {
      'name': 'محمد علي',
      'car': 'هيونداي توسان',
      'plate': 'د هـ و • 5678',
      'rating': 4.7,
      'trips': 876,
      'color': Color(0xFF10B981),
      'distance': '1.8 كم',
      'eta': '3 دقائق',
      'avatar': 'م',
    },
    {
      'name': 'عمر إبراهيم',
      'car': 'مرسيدس E-Class',
      'plate': 'ز ح ط • 9012',
      'rating': 5.0,
      'trips': 2100,
      'color': Color(0xFFF5A623),
      'distance': '3.1 كم',
      'eta': '6 دقائق',
      'avatar': 'ع',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _cardsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseAnimController, curve: Curves.easeInOut),
    );

    // Simulate finding drivers
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() => _isSearching = false);
        _cardsAnimController.forward();
      }
    });
    _searchAnimController.forward();
  }

  @override
  void dispose() {
    _searchAnimController.dispose();
    _cardsAnimController.dispose();
    _pulseAnimController.dispose();
    super.dispose();
  }

  double get _selectedPrice {
    final base = (_rideTypes[_selectedIndex]['price'] as int).toDouble();
    if (_rideTypes[_selectedIndex]['promo'] != null) {
      return base * 0.85;
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A16),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  _CircleBtn(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'اختر نوع الرحلة',
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

            // Trip info card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _TripInfoCard(
                pickup: widget.pickup,
                destination: widget.destination,
              ),
            ),

            const SizedBox(height: 16),

            if (_isSearching)
              Expanded(child: _SearchingView(pulseAnim: _pulseAnim))
            else
              Expanded(
                child: FadeTransition(
                  opacity: _cardsAnimController,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _cardsAnimController,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Ride type selector
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 4,
                                    bottom: 10,
                                  ),
                                  child: Text(
                                    'نوع الرحلة',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                                ...List.generate(_rideTypes.length, (i) {
                                  return _RideTypeCard(
                                    data: _rideTypes[i],
                                    isSelected: _selectedIndex == i,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _selectedIndex = i);
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        // Nearby drivers
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Text(
                              'السائقون القريبون',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 130,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _drivers.length,
                              itemBuilder: (_, i) =>
                                  _DriverCard(driver: _drivers[i], index: i),
                            ),
                          ),
                        ),

                        // Bottom spacer
                        const SliverToBoxAdapter(child: SizedBox(height: 120)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),

      // Floating confirm button
      bottomNavigationBar: _isSearching
          ? const SizedBox.shrink()
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1526),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'السعر التقديري',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Row(
                        children: [
                          if (_rideTypes[_selectedIndex]['promo'] != null) ...[
                            Text(
                              '${_rideTypes[_selectedIndex]['price']} جنيه',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 12,
                                fontFamily: 'Cairo',
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '${_selectedPrice.toStringAsFixed(0)} جنيه',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, animation, __) => PaymentScreen(
                              pickup: widget.pickup,
                              destination: widget.destination,
                              rideType: _rideTypes[_selectedIndex],
                              driver:
                                  _drivers[_selectedIndex % _drivers.length],
                              price: _selectedPrice,
                            ),
                            transitionsBuilder: (_, animation, __, child) {
                              return SlideTransition(
                                position:
                                    Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(
                              milliseconds: 400,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (_rideTypes[_selectedIndex]['color'] as Color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.payment_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'اختر طريقة الدفع',
                            style: TextStyle(
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
                ],
              ),
            ),
    );
  }
}

class _SearchingView extends StatelessWidget {
  final Animation<double> pulseAnim;
  const _SearchingView({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: pulseAnim,
          builder: (_, __) => Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100 * pulseAnim.value,
                height: 100 * pulseAnim.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFF3B82F6,
                  ).withOpacity(0.05 * (1.2 - pulseAnim.value) * 5),
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF3B82F6),
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'جاري البحث عن السائقين...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'نبحث عن أقرب سائق إليك',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 32),
        // Animated dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, __) {
                final offset = math.sin(
                  (pulseAnim.value * math.pi * 2) + (i * 1.2),
                );
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFF3B82F6,
                    ).withOpacity(0.4 + offset * 0.3),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _TripInfoCard extends StatelessWidget {
  final Map<String, dynamic> pickup;
  final Map<String, dynamic> destination;

  const _TripInfoCard({required this.pickup, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF3B82F6),
                ),
              ),
              Container(
                width: 1.5,
                height: 24,
                color: Colors.white.withOpacity(0.15),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.5),
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pickup['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  destination['name'] ?? 'الوجهة',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.route_rounded,
                  color: Color(0xFF3B82F6),
                  size: 16,
                ),
                const SizedBox(height: 2),
                Text(
                  '8.4 كم',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
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

class _RideTypeCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isSelected;
  final VoidCallback onTap;

  const _RideTypeCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = data['color'] as Color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : const Color(0xFF0B1526),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.5)
                : Colors.white.withOpacity(0.05),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                data['icon'] as IconData,
                color: isSelected ? color : Colors.white.withOpacity(0.5),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        data['type'],
                        style: TextStyle(
                          color: isSelected ? color : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      if (data['promo'] != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            data['promo'],
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    data['desc'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
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
                  '${data['price']} جنيه',
                  style: TextStyle(
                    color: isSelected ? color : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  '${data['time']} دقائق',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
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

class _DriverCard extends StatelessWidget {
  final Map<String, dynamic> driver;
  final int index;

  const _DriverCard({required this.driver, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = driver['color'] as Color;
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 10, left: index == 0 ? 0 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1526),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF5A623),
                          size: 11,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${driver['rating']}',
                          style: const TextStyle(
                            color: Color(0xFFF5A623),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            driver['car'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
              fontFamily: 'Cairo',
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                driver['eta'],
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                driver['distance'],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
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
