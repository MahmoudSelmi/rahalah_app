import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'trip_tracking_screen.dart';
import 'profile_screen.dart';

class TripsRequestScreen extends StatefulWidget {
  const TripsRequestScreen({super.key});

  @override
  State<TripsRequestScreen> createState() => _TripsRequestScreenState();
}

class _TripsRequestScreenState extends State<TripsRequestScreen> {
  final TextEditingController _priceController = TextEditingController();
  final String? currentDriverId = FirebaseAuth.instance.currentUser?.uid;
  bool _isSendingOffer = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  // ميثود إجبارية لعمل تيست وحقن طلب في الفايربيز لو الـ Stream فاضي
  Future<void> _injectTestTrip() async {
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc('test_trip_id')
          .set({
            'passengerName': 'أحمد محمد (طالب تجربة)',
            'pickup': 'موقف المنصورة الرئيسي',
            'destination': 'جامعة الزقازيق - كلية الهندسة',
            'price': '120',
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "تم حقن طلب تجريبي في الفايربيز بنجاح! جاري العرض...",
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: const Color(0xFF3B82F6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      // خطأ في الحقن
    }
  }

  Future<void> _handleAcceptTrip(
    DocumentSnapshot tripDoc,
    String passengerPrice,
  ) async {
    if (currentDriverId == null) return;

    setState(() {
      _isSendingOffer = true;
    });

    String finalPrice = _priceController.text.isEmpty
        ? passengerPrice
        : _priceController.text;

    try {
      DocumentSnapshot driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(currentDriverId!)
          .get();

      if (!driverDoc.exists) {
        if (mounted) setState(() => _isSendingOffer = false);
        return;
      }

      var d = driverDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripDoc.id)
          .update({
            'status': 'confirmed',
            'price': finalPrice,
            'driverId': currentDriverId,
            'driverName': d['name'] ?? "سائق رحالة",
            'carType': d['carType'] ?? "سيارة خاصة",
            'plateNumber': d['plateNumber'] ?? "----",
            'acceptedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "تم قبول الطلب وبدء الرحلة بنجاح",
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      _priceController.clear();
      setState(() => _isSendingOffer = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TripTrackingScreen(
            tripId: tripDoc.id,
            isDriver: true,
            passengerName: '',
            driverName: d['name'] ?? "سائق رحالة",
          ),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _isSendingOffer = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A16),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF0F172A),
            child: const Center(
              child: Icon(Icons.map_rounded, size: 150, color: Colors.white10),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1526),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withOpacity(0.15),
                  ),
                ),
                child: const Text(
                  "طلبات الرحلات المتاحة",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('trips')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty ||
                  _isSendingOffer) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1526),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isSendingOffer
                              ? "جاري بدء الرحلة..."
                              : "رادار رحالة يبحث عن طلبات نشطة حالياً...",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 10),
                        // زرار المحاكاة لحل مشكلة التعليق فوراً وعرض الداتا
                        TextButton.icon(
                          onPressed: _injectTestTrip,
                          icon: const Icon(
                            Icons.add_to_photos_rounded,
                            color: Color(0xFF3B82F6),
                            size: 18,
                          ),
                          label: const Text(
                            "محاكاة طلب فوري",
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              var tripDoc = snapshot.data!.docs.first;
              var tripData = tripDoc.data() as Map<String, dynamic>;
              String passengerPrice = tripData['price']?.toString() ?? "0";

              return Align(
                alignment: Alignment.center,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1526),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF1E293B),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tripData['passengerName'] ?? "راكب",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildInfoRow(
                        Icons.arrow_upward,
                        tripData['pickup'] ?? "غير محدد",
                      ),
                      _buildInfoRow(
                        Icons.arrow_downward,
                        tripData['destination'] ?? "غير محدد",
                      ),
                      const Divider(height: 20, color: Color(0xFF1E293B)),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$passengerPrice EGP",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              ":سعر العميل",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "اكتب عرض سعر مخصص أو وافق مباشرة",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontFamily: 'Cairo',
                              fontSize: 12,
                            ),
                            prefixIcon: const Icon(
                              Icons.edit,
                              color: Color(0xFF3B82F6),
                              size: 20,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF030A16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('trips')
                                    .doc(tripDoc.id)
                                    .update({'status': 'cancelled'});

                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      "تم رفض الطلب والرجوع للرئيسية",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontFamily: 'Cairo'),
                                    ),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "رفض",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _handleAcceptTrip(tripDoc, passengerPrice),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "قبول / عرض",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
