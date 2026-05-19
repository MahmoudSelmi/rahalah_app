import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../welcome_screen.dart';
import 'map_screen.dart'; // ← Updated import

class PassengerProfileScreen extends StatefulWidget {
  const PassengerProfileScreen({super.key});

  @override
  State<PassengerProfileScreen> createState() => _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen>
    with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isSaving = false;
  String? _localImagePath;
  int _totalTrips = 0;
  int _ratedDrivers = 0;
  double _totalSpent = 0;
  double _myRating = 0;
  int _ratingCount = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
    _loadLocalProfileImage();
    _loadTripStats();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalProfileImage() async {
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _localImagePath = prefs.getString('passenger_avatar_${user!.uid}');
    });
  }

  Future<void> _loadTripStats() async {
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('trips')
        .where('passengerId', isEqualTo: user!.uid)
        .where('status', isEqualTo: 'completed')
        .get();

    double total = 0;
    int rated = 0;
    for (var doc in snap.docs) {
      final data = doc.data();
      total += double.tryParse(data['price']?.toString() ?? '0') ?? 0;
      if (data['driverRating'] != null) rated++;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final userData = userDoc.data();

    if (mounted) {
      setState(() {
        _totalTrips = snap.docs.length;
        _ratedDrivers = rated;
        _totalSpent = total;
        _myRating =
            double.tryParse(userData?['rating']?.toString() ?? '0') ?? 0;
        _ratingCount =
            int.tryParse(userData?['ratingCount']?.toString() ?? '0') ?? 0;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (pickedFile != null && user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('passenger_avatar_${user!.uid}', pickedFile.path);
      setState(() => _localImagePath = pickedFile.path);
    }
  }

  Future<void> _updatePassengerData() async {
    if (user == null || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'age': _ageController.text.trim(),
            'bio': _bioController.text.trim(),
          });
      if (mounted) _showSnack("تم تحديث الحساب بنجاح", const Color(0xFF10B981));
    } catch (e) {
      if (mounted) _showSnack("خطأ: ${e.toString()}", const Color(0xFFEF4444));
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

  /// ── الجديد: فتح MapScreen ← المدخل الأول للـ flow كله ──
  void _startRideFlow() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const MapScreenPro(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  void _showEditSheet(Map<String, dynamic> data) {
    _nameController.text = data['name']?.toString() ?? '';
    _phoneController.text = data['phone']?.toString() ?? '';
    _ageController.text = data['age']?.toString() ?? '';
    _bioController.text = data['bio']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSheet(
        formKey: _formKey,
        nameController: _nameController,
        phoneController: _phoneController,
        ageController: _ageController,
        bioController: _bioController,
        isSaving: _isSaving,
        onSave: _updatePassengerData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const WelcomeScreen();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snap) {
        Map<String, dynamic> data = {};
        if (snap.hasData && snap.data!.exists) {
          data = snap.data!.data() as Map<String, dynamic>;
          _nameController.text = data['name']?.toString() ?? '';
          _emailController.text =
              data['email']?.toString() ?? user?.email ?? '';
        }

        final name = data['name']?.toString() ?? 'مستعمل رحالة';
        final email = data['email']?.toString() ?? user?.email ?? '';
        final joinDate = data['createdAt'] as Timestamp?;

        return Scaffold(
          backgroundColor: const Color(0xFF030A16),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _TopBar(
                        onBack: () => Navigator.pop(context),
                        onMore: () => _showEditSheet(data),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _HeroSection(
                        name: name,
                        email: email,
                        joinDate: joinDate,
                        localImagePath: _localImagePath,
                        myRating: _myRating,
                        ratingCount: _ratingCount,
                        onPickImage: _pickImage,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _StatsRow(
                        totalTrips: _totalTrips,
                        ratedDrivers: _ratedDrivers,
                        totalSpent: _totalSpent,
                      ),
                    ),
                    SliverToBoxAdapter(child: _Divider()),
                    SliverToBoxAdapter(child: _SectionLabel(label: 'الحساب')),
                    SliverToBoxAdapter(
                      child: _MenuList(
                        totalTrips: _totalTrips,
                        myRating: _myRating,
                        onEditProfile: () => _showEditSheet(data),
                        onRequestRide: _startRideFlow, // ← Updated
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _LogoutButton(onLogout: _signOut),
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

// ── All widget classes below are identical to the original ──
// ── Only _MenuList.onTrips is renamed to onRequestRide ──

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMore;

  const _TopBar({required this.onBack, required this.onMore});

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
          _CircleBtn(icon: Icons.more_horiz_rounded, onTap: onMore),
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

class _HeroSection extends StatelessWidget {
  final String name;
  final String email;
  final Timestamp? joinDate;
  final String? localImagePath;
  final double myRating;
  final int ratingCount;
  final VoidCallback onPickImage;

  const _HeroSection({
    required this.name,
    required this.email,
    required this.joinDate,
    required this.localImagePath,
    required this.myRating,
    required this.ratingCount,
    required this.onPickImage,
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3B82F6),
                    width: 2.5,
                  ),
                ),
                child: ClipOval(
                  child: localImagePath != null
                      ? Image.file(File(localImagePath!), fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFF1E293B),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 44,
                            color: Colors.white38,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF030A16),
                      width: 2,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                left: -2,
                child: GestureDetector(
                  onTap: onPickImage,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF030A16),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 3),
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

class _StatsRow extends StatelessWidget {
  final int totalTrips;
  final int ratedDrivers;
  final double totalSpent;

  const _StatsRow({
    required this.totalTrips,
    required this.ratedDrivers,
    required this.totalSpent,
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
            iconBg: const Color(0xFF3B82F6),
            value: '$totalTrips',
            label: 'رحلة تمت',
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.people_outline_rounded,
            iconColor: const Color(0xFF10B981),
            iconBg: const Color(0xFF10B981),
            value: '$ratedDrivers',
            label: 'راكب قيّمته',
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.monetization_on_outlined,
            iconColor: const Color(0xFFF5A623),
            iconBg: const Color(0xFFF5A623),
            value: '${totalSpent.toInt()}',
            label: 'EGP إجمالي',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
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
                color: iconBg.withValues(alpha: 0.12),
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      color: Colors.white.withValues(alpha: 0.05),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.35),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  final int totalTrips;
  final double myRating;
  final VoidCallback onEditProfile;
  final VoidCallback onRequestRide; // ← renamed from onTrips

  const _MenuList({
    required this.totalTrips,
    required this.myRating,
    required this.onEditProfile,
    required this.onRequestRide,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: 'تعديل البيانات الشخصية',
            subtitle: 'الاسم، الهاتف، العمر',
            onTap: onEditProfile,
          ),
          const SizedBox(height: 6),

          // ── زر "اطلب رحلة" — يبدأ الـ full flow ──
          _MenuItem(
            icon: Icons.add_location_alt_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'اطلب رحلة جديدة',
            subtitle: 'حدد موقعك واختار وجهتك',
            badge: 'ابدأ الآن',
            badgeColor: const Color(0xFF10B981),
            onTap: onRequestRide,
          ),

          const SizedBox(height: 6),
          _MenuItem(
            icon: Icons.history_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: 'رحلاتي السابقة',
            subtitle: 'كل رحلاتك السابقة',
            badge: '$totalTrips رحلة',
            badgeColor: const Color(0xFF3B82F6),
            onTap: () {},
          ),
          const SizedBox(height: 6),
          _MenuItem(
            icon: Icons.star_outline_rounded,
            iconColor: const Color(0xFFF5A623),
            title: 'تقييماتي',
            subtitle: 'الكباتن اللي قيّمتهم',
            badge: myRating > 0 ? '${myRating.toStringAsFixed(1)} ★' : null,
            badgeColor: const Color(0xFF3B82F6),
            onTap: () {},
          ),
          const SizedBox(height: 6),
          _MenuItem(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: const Color(0xFFA78BFA),
            title: 'المحفظة والمدفوعات',
            subtitle: 'رصيدك وطرق الدفع',
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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
                  color: (badgeColor ?? const Color(0xFF3B82F6)).withValues(
                    alpha: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: badgeColor ?? const Color(0xFF3B82F6),
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

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: GestureDetector(
        onTap: onLogout,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFF87171).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF87171).withValues(alpha: 0.15),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFF87171), size: 19),
              SizedBox(width: 10),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Color(0xFFF87171),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditSheet extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController ageController;
  final TextEditingController bioController;
  final bool isSaving;
  final VoidCallback onSave;

  const _EditSheet({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.ageController,
    required this.bioController,
    required this.isSaving,
    required this.onSave,
  });

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
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
        key: widget.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              'تعديل البيانات الشخصية',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 20),
            _SheetField(
              label: 'الاسم بالكامل',
              controller: widget.nameController,
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            _SheetField(
              label: 'رقم الهاتف',
              controller: widget.phoneController,
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _SheetField(
              label: 'العمر',
              controller: widget.ageController,
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _SheetField(
              label: 'الحالة / Bio',
              controller: widget.bioController,
              icon: Icons.description_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: widget.isSaving
                    ? null
                    : () {
                        widget.onSave();
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: widget.isSaving
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
      cursorColor: const Color(0xFF3B82F6),
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
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
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
