import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'trips_request_screen.dart';
import '../../welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _carPlateController = TextEditingController();

  bool _isSaving = false;
  bool _isLoading = true;

  int _totalTrips = 0;
  int _totalPassengers = 0;
  double _totalEarned = 0;
  double _myRating = 0;
  int _ratingCount = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Colors – same dark palette as passenger but with emerald accent instead of blue
  static const Color _bg = Color(0xFF030A16);
  static const Color _card = Color(0xFF0B1526);
  static const Color _accent = Color(0xFF10B981); // emerald (driver identity)
  static const Color _blue = Color(0xFF3B82F6);
  static const Color _amber = Color(0xFFF5A623);
  static const Color _red = Color(0xFFF87171);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _fetchDriverData();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _carModelController.dispose();
    _carPlateController.dispose();
    super.dispose();
  }

  Future<void> _fetchDriverData() async {
    if (user == null) return;
    try {
      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(user!.uid)
          .get();

      if (driverDoc.exists && mounted) {
        final d = driverDoc.data()!;
        _nameController.text = d['name']?.toString() ?? '';
        _emailController.text = d['email']?.toString() ?? user?.email ?? '';
        _phoneController.text = d['phone']?.toString() ?? '';
        _ageController.text = d['age']?.toString() ?? '';
        _carModelController.text = d['carModel']?.toString() ?? '';
        _carPlateController.text = d['carPlate']?.toString() ?? '';
        _myRating = double.tryParse(d['rating']?.toString() ?? '0') ?? 0;
        _ratingCount = int.tryParse(d['ratingCount']?.toString() ?? '0') ?? 0;
      }

      final tripsSnap = await FirebaseFirestore.instance
          .collection('trips')
          .where('driverId', isEqualTo: user!.uid)
          .where('status', isEqualTo: 'completed')
          .get();

      double earned = 0;
      Set<String> passengers = {};
      for (var doc in tripsSnap.docs) {
        final data = doc.data();
        earned += double.tryParse(data['price']?.toString() ?? '0') ?? 0;
        if (data['passengerId'] != null) passengers.add(data['passengerId']);
      }

      if (mounted) {
        setState(() {
          _totalTrips = tripsSnap.docs.length;
          _totalPassengers = passengers.length;
          _totalEarned = earned;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateDriverData() async {
    if (user == null || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(user!.uid)
          .update({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'age': _ageController.text.trim(),
            'carModel': _carModelController.text.trim(),
            'carPlate': _carPlateController.text.trim(),
          });
      if (mounted) _showSnack('تم تحديث البيانات بنجاح', _accent);
    } catch (e) {
      if (mounted) _showSnack('خطأ: ${e.toString()}', _red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DriverEditSheet(
        formKey: _formKey,
        nameController: _nameController,
        phoneController: _phoneController,
        ageController: _ageController,
        carModelController: _carModelController,
        carPlateController: _carPlateController,
        isSaving: _isSaving,
        onSave: _updateDriverData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const WelcomeScreen();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('drivers')
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snap) {
        Map<String, dynamic> data = {};
        if (snap.hasData && snap.data!.exists) {
          data = snap.data!.data() as Map<String, dynamic>;
          if (_nameController.text.isEmpty) {
            _nameController.text = data['name']?.toString() ?? '';
          }
        }

        final name = data['name']?.toString() ?? 'كابتن';
        final email = data['email']?.toString() ?? user?.email ?? '';
        final joinDate = data['createdAt'] as Timestamp?;
        final carModel = data['carModel']?.toString() ?? '';
        final carPlate = data['carPlate']?.toString() ?? '';
        final isOnline = data['isOnline'] as bool? ?? false;

        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _accent))
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // ── Top bar ──────────────────────────────────────
                          SliverToBoxAdapter(
                            child: _TopBar(
                              onBack: () => Navigator.pop(context),
                              onEdit: _showEditSheet,
                            ),
                          ),

                          // ── Hero card ────────────────────────────────────
                          SliverToBoxAdapter(
                            child: _DriverHero(
                              name: name,
                              email: email,
                              joinDate: joinDate,
                              carModel: carModel,
                              carPlate: carPlate,
                              isOnline: isOnline,
                              myRating: _myRating,
                              ratingCount: _ratingCount,
                            ),
                          ),

                          // ── Stats ─────────────────────────────────────────
                          SliverToBoxAdapter(
                            child: _StatsRow(
                              totalTrips: _totalTrips,
                              totalPassengers: _totalPassengers,
                              totalEarned: _totalEarned,
                            ),
                          ),

                          // ── Divider ───────────────────────────────────────
                          SliverToBoxAdapter(
                            child: Container(
                              height: 1,
                              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),

                          // ── Section label ─────────────────────────────────
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                16,
                                20,
                                10,
                              ),
                              child: Text(
                                'الحساب'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),

                          // ── Menu ──────────────────────────────────────────
                          SliverToBoxAdapter(
                            child: _DriverMenuList(
                              totalTrips: _totalTrips,
                              myRating: _myRating,
                              onEditProfile: _showEditSheet,
                              onTrips: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TripsRequestScreen(),
                                ),
                              ),
                            ),
                          ),

                          // ── Trips history ─────────────────────────────────
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                16,
                                20,
                                10,
                              ),
                              child: Text(
                                'آخر الرحلات'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),

                          SliverToBoxAdapter(
                            child: _TripsHistory(driverId: user!.uid),
                          ),

                          // ── Logout ────────────────────────────────────────
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                32,
                              ),
                              child: GestureDetector(
                                onTap: _signOut,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _red.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _red.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.logout_rounded,
                                        color: _red,
                                        size: 19,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'تسجيل الخروج',
                                        style: TextStyle(
                                          color: _red,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
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
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEdit;
  const _TopBar({required this.onBack, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleBtn(icon: Icons.arrow_back_rounded, onTap: onBack),
          const Text(
            'الملف الشخصي',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              fontFamily: 'Cairo',
            ),
          ),
          _CircleBtn(icon: Icons.edit_outlined, onTap: onEdit),
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
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HERO SECTION  (driver-specific: car badge, online status)
// ═══════════════════════════════════════════════════════════════════
class _DriverHero extends StatelessWidget {
  final String name;
  final String email;
  final Timestamp? joinDate;
  final String carModel;
  final String carPlate;
  final bool isOnline;
  final double myRating;
  final int ratingCount;

  const _DriverHero({
    required this.name,
    required this.email,
    required this.joinDate,
    required this.carModel,
    required this.carPlate,
    required this.isOnline,
    required this.myRating,
    required this.ratingCount,
  });

  String _formatJoinDate() {
    if (joinDate == null) return '';
    final d = joinDate!.toDate();
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'إبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return 'عضو منذ ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          // Avatar + online dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 2.5,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    color: const Color(0xFF1E293B),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 46,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF10B981) : Colors.white24,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF030A16),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Name
          Text(
            'كابتن $name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'Cairo',
            ),
          ),

          const SizedBox(height: 3),

          // Join date
          if (_formatJoinDate().isNotEmpty)
            Text(
              _formatJoinDate(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),

          const SizedBox(height: 10),

          // Rating row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StarRow(rating: myRating),
              const SizedBox(width: 6),
              Text(
                myRating > 0 ? myRating.toStringAsFixed(1) : '0.0',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($ratingCount تقييم)',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Car badge (unique to driver)
          if (carModel.isNotEmpty || carPlate.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions_car_filled_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  if (carModel.isNotEmpty)
                    Text(
                      carModel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  if (carModel.isNotEmpty && carPlate.isNotEmpty)
                    Container(
                      width: 1,
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  if (carPlate.isNotEmpty)
                    Text(
                      carPlate,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
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

class _StarRow extends StatelessWidget {
  final double rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && (i < rating);
        return Icon(
          filled
              ? Icons.star_rounded
              : half
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded,
          color: const Color(0xFFF5A623),
          size: 17,
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// STATS ROW  (driver stats: trips, passengers, earned)
// ═══════════════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  final int totalTrips;
  final int totalPassengers;
  final double totalEarned;

  const _StatsRow({
    required this.totalTrips,
    required this.totalPassengers,
    required this.totalEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.route_rounded,
            iconColor: const Color(0xFF3B82F6),
            value: '$totalTrips',
            label: 'رحلة منجزة',
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.people_outline_rounded,
            iconColor: const Color(0xFF10B981),
            value: '$totalPassengers',
            label: 'راكب فريد',
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.monetization_on_outlined,
            iconColor: const Color(0xFFF5A623),
            value: '${totalEarned.toInt()}',
            label: 'EGP أرباح',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1526),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MENU LIST
// ═══════════════════════════════════════════════════════════════════
class _DriverMenuList extends StatelessWidget {
  final int totalTrips;
  final double myRating;
  final VoidCallback onEditProfile;
  final VoidCallback onTrips;

  const _DriverMenuList({
    required this.totalTrips,
    required this.myRating,
    required this.onEditProfile,
    required this.onTrips,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'تعديل البيانات الشخصية',
            subtitle: 'الاسم، الهاتف، العمر، السيارة',
            onTap: onEditProfile,
          ),
          const SizedBox(height: 6),
          _MenuItem(
            icon: Icons.search_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: 'استكشاف طلبات الرحلات',
            subtitle: 'شوف الطلبات المتاحة دلوقتي',
            badge: 'جديد',
            badgeColor: const Color(0xFF3B82F6),
            onTap: onTrips,
          ),
          const SizedBox(height: 6),
          _MenuItem(
            icon: Icons.history_rounded,
            iconColor: const Color(0xFFF5A623),
            title: 'رحلاتي المكتملة',
            subtitle: 'سجل كل رحلاتك السابقة',
            badge: '$totalTrips رحلة',
            badgeColor: const Color(0xFFF5A623),
            onTap: () {},
          ),
          const SizedBox(height: 6),
          _MenuItem(
            icon: Icons.star_outline_rounded,
            iconColor: const Color(0xFFF5A623),
            title: 'تقييماتي',
            subtitle: 'آراء الركاب فيك',
            badge: myRating > 0 ? '${myRating.toStringAsFixed(1)} ★' : null,
            badgeColor: const Color(0xFFF5A623),
            onTap: () {},
          ),
          const SizedBox(height: 6),
          _MenuItem(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: const Color(0xFFA78BFA),
            title: 'أرباحي والمحفظة',
            subtitle: 'رصيدك وطرق الاستلام',
            onTap: () {},
          ),
          const SizedBox(height: 6),
          _MenuItem(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFFF87171),
            title: 'الأمان والخصوصية',
            subtitle: 'كلمة السر والبيانات',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1526),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: (badgeColor ?? const Color(0xFF10B981)).withValues(
                    alpha: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: badgeColor ?? const Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(
              Icons.arrow_back_ios_rounded,
              size: 14,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TRIPS HISTORY WIDGET
// ═══════════════════════════════════════════════════════════════════
class _TripsHistory extends StatelessWidget {
  final String driverId;
  const _TripsHistory({required this.driverId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'completed')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لا توجد رحلات مكتملة بعد',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontFamily: 'Cairo',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        var docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          Timestamp? aT =
              aData['completedAt'] as Timestamp? ??
              aData['createdAt'] as Timestamp?;
          Timestamp? bT =
              bData['completedAt'] as Timestamp? ??
              bData['createdAt'] as Timestamp?;
          if (aT == null || bT == null) return 0;
          return bT.compareTo(aT);
        });

        // show max 5 recent trips
        final limited = docs.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: limited.length,
          itemBuilder: (context, index) {
            final trip = limited[index].data() as Map<String, dynamic>;
            DateTime? date =
                (trip['completedAt'] as Timestamp?)?.toDate() ??
                (trip['createdAt'] as Timestamp?)?.toDate();
            final formattedDate = date != null
                ? DateFormat('yyyy-MM-dd  •  HH:mm').format(date)
                : '--';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1526),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  // Price badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${trip['price'] ?? 0}\nEGP',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip['destination'] ?? 'الوجهة',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trip['passengerName'] ?? 'راكب',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.25),
                            fontSize: 10,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFF87171),
                    size: 16,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// EDIT BOTTOM SHEET  (driver-specific fields: carModel, carPlate)
// ═══════════════════════════════════════════════════════════════════
class _DriverEditSheet extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController ageController;
  final TextEditingController carModelController;
  final TextEditingController carPlateController;
  final bool isSaving;
  final VoidCallback onSave;

  const _DriverEditSheet({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.ageController,
    required this.carModelController,
    required this.carPlateController,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B1526),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'تعديل بيانات الكابتن',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 20),

              // Personal section label
              _SheetSectionLabel(label: 'البيانات الشخصية'),
              const SizedBox(height: 12),

              _SheetField(
                label: 'الاسم بالكامل',
                controller: nameController,
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              _SheetField(
                label: 'رقم الهاتف',
                controller: phoneController,
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _SheetField(
                label: 'العمر',
                controller: ageController,
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              // Car section label
              _SheetSectionLabel(label: 'بيانات السيارة'),
              const SizedBox(height: 12),

              _SheetField(
                label: 'موديل السيارة',
                controller: carModelController,
                icon: Icons.directions_car_filled_rounded,
              ),
              const SizedBox(height: 12),
              _SheetField(
                label: 'رقم اللوحة',
                controller: carPlateController,
                icon: Icons.confirmation_number_outlined,
              ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          onSave();
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'حفظ التغييرات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Cairo',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetSectionLabel extends StatelessWidget {
  final String label;
  const _SheetSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;

  const _SheetField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontFamily: 'Cairo',
      ),
      cursorColor: const Color(0xFF10B981),
      validator: (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontFamily: 'Cairo',
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.3),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF87171)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFF87171),
          fontFamily: 'Cairo',
          fontSize: 11,
        ),
      ),
    );
  }
}
