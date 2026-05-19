import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'passenger_profile_screen.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  تقييم الرحلة — نهاية الـ Flow (نمط داكن متناسق مع التطبيق)
// ══════════════════════════════════════════════════════════════════════════════

class PassengerRatingScreen extends StatefulWidget {
  final String? tripId;
  final String driverName;
  final String carModel;
  final double price;

  const PassengerRatingScreen({
    super.key,
    this.tripId,
    this.driverName = '',
    this.carModel = '',
    this.price = 0,
  });

  @override
  State<PassengerRatingScreen> createState() => _PassengerRatingScreenState();
}

class _PassengerRatingScreenState extends State<PassengerRatingScreen>
    with SingleTickerProviderStateMixin {
  int _rating = 0;
  bool _isSubmitting = false;
  late AnimationController _starAnim;

  final List<String> _tags = [
    'وقت مناسب',
    'سيارة نظيفة',
    'سائق محترم',
    'مريح',
    'آمن',
  ];
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _starAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _starAnim.forward();
  }

  @override
  void dispose() {
    _starAnim.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    try {
      if (widget.tripId != null) {
        await FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripId!)
            .update({
              'status': 'completed',
              'passengerRating': _rating,
              'ratingTags': _selectedTags.toList(),
              'completedAt': FieldValue.serverTimestamp(),
            });
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PassengerProfileScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  String get _ratingLabel {
    switch (_rating) {
      case 1:
        return 'سيئة جداً 😞';
      case 2:
        return 'مقبولة 😐';
      case 3:
        return 'جيدة 🙂';
      case 4:
        return 'ممتازة 😊';
      case 5:
        return 'رائعة جداً! 🌟';
      default:
        return 'قيّم رحلتك';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A16),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Header ─────────────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: Color(0xFF3B82F6),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'كيف كانت الرحلة؟',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),
              if (widget.driverName.isNotEmpty)
                Text(
                  'مع الكابتن ${widget.driverName}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontFamily: 'Cairo',
                  ),
                ),

              const SizedBox(height: 32),

              // ── Trip summary ───────────────────────────────────────────
              if (widget.carModel.isNotEmpty || widget.price > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  margin: const EdgeInsets.only(bottom: 28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1526),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.carModel.isNotEmpty)
                        Text(
                          widget.carModel,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      if (widget.price > 0)
                        Text(
                          '${widget.price.toInt()} EGP',
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                    ],
                  ),
                ),

              // ── Stars ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        i < _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: i < _rating ? 46 : 40,
                        color: i < _rating
                            ? const Color(0xFFF5A623)
                            : Colors.white12,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _ratingLabel,
                  key: ValueKey(_rating),
                  style: TextStyle(
                    color: _rating > 0
                        ? const Color(0xFFF5A623)
                        : Colors.white38,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Quick tags ─────────────────────────────────────────────
              if (_rating >= 4) ...[
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'ما الذي أعجبك؟',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _tags.map((tag) {
                    final selected = _selectedTags.contains(tag);
                    return GestureDetector(
                      onTap: () => setState(() {
                        selected
                            ? _selectedTags.remove(tag)
                            : _selectedTags.add(tag);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                              : const Color(0xFF0B1526),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF3B82F6)
                                : Colors.white12,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.white54,
                            fontSize: 13,
                            fontFamily: 'Cairo',
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              const SizedBox(height: 12),

              // ── Submit ─────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_rating == 0 || _isSubmitting)
                      ? null
                      : _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    disabledBackgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _rating == 0
                              ? 'اختر تقييمك أولاً'
                              : 'إنهاء الرحلة وإرسال التقييم',
                          style: TextStyle(
                            color: _rating > 0 ? Colors.white : Colors.white38,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Cairo',
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Skip
              GestureDetector(
                onTap: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const PassengerProfileScreen(),
                  ),
                  (route) => false,
                ),
                child: const Text(
                  'تخطي',
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 13,
                    fontFamily: 'Cairo',
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
