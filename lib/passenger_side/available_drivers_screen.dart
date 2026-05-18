import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvailableDriversScreen extends StatefulWidget {
  final String tripId;
  final String pickup;
  final String destination;
  final String passengerPrice;

  const AvailableDriversScreen({
    super.key,
    required this.tripId,
    required this.pickup,
    required this.destination,
    required this.passengerPrice,
  });

  @override
  State<AvailableDriversScreen> createState() => _AvailableDriversScreenState();
}

class _AvailableDriversScreenState extends State<AvailableDriversScreen> {
  String _selectedPaymentMethod = "كاش";
  bool _isTripRequested = false;
  String _requestedDriverName = "";

  // Controllers للفيزا عشان الـ UI يتحرك مع الكتابة
  final TextEditingController _cardNumController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardExpController = TextEditingController();
  final TextEditingController _cardCvcController = TextEditingController();

  void _executeFirebaseOrder(
    Map<String, dynamic> driver,
    String paymentType,
  ) async {
    // بنثبت الحالة هنا فوراً عشان شاشة "تم الطلب" تظهر وثبت
    setState(() {
      _isTripRequested = true;
      _requestedDriverName = driver['driverName'];
    });

    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .update({
            'status': 'waitingForDriverAcceptance',
            'driverName': driver['driverName'],
            'carModel': driver['carModel'],
            'price': driver['price'].toString(),
            'paymentMethod': paymentType,
            'plateNumber': driver['plateNumber'],
          });
    } catch (e) {
      debugPrint("Firebase Error: $e");
    }
  }

  // شيت الدفع المطور (الـ UI التفاعلي المتحرك)
  void _showVisaPaymentSheet(Map<String, dynamic> driver) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setCardState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- الكارت الافتراضي المتحرك (البيانات تظهر عليه فوراً) ---
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.wifi, color: Colors.white),
                              Text(
                                "VISA",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            _cardNumController.text.isEmpty
                                ? "•••• •••• •••• ••••"
                                : _cardNumController.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "CARD HOLDER",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 9,
                                    ),
                                  ),
                                  Text(
                                    _cardNameController.text.isEmpty
                                        ? "YOUR NAME"
                                        : _cardNameController.text
                                              .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "EXPIRES",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 9,
                                    ),
                                  ),
                                  Text(
                                    _cardExpController.text.isEmpty
                                        ? "MM/YY"
                                        : _cardExpController.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // --- حقول الإدخال اللي بتحرك الـ UI ---
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        children: [
                          _buildVisaInput(
                            "اسم صاحب البطاقة",
                            Icons.person,
                            _cardNameController,
                            (v) => setCardState(() {}),
                          ),
                          const SizedBox(height: 12),
                          _buildVisaInput(
                            "رقم البطاقة",
                            Icons.credit_card,
                            _cardNumController,
                            (v) => setCardState(() {}),
                            isNum: true,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildVisaInput(
                                  "تاريخ الانتهاء",
                                  Icons.calendar_month,
                                  _cardExpController,
                                  (v) => setCardState(() {}),
                                  isNum: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildVisaInput(
                                  "CVC",
                                  Icons.lock,
                                  _cardCvcController,
                                  (v) => setCardState(() {}),
                                  isNum: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          ); // بيقفل الشيت وبس من غير ما يرجع الشاشة الأساسية لورا
                          _executeFirebaseOrder(driver, 'Visa');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "تأكيد الدفع والطلب",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVisaInput(
    String hint,
    IconData icon,
    TextEditingController controller,
    Function(String) onChange, {
    bool isNum = false,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChange,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.white24,
          fontSize: 13,
          fontFamily: 'Cairo',
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // الكباتن كاملة بدون حذف أي كابتن قديم
    final List<Map<String, dynamic>> mockDrivers = [
      {
        'driverName': 'أحمد كمال',
        'driverGender': 'ذكر',
        'driverAge': 35,
        'driverRating': '4.9',
        'carModel': 'مرسيدس بنز الفئة S',
        'carColor': 'أسود ملكي',
        'price': (double.tryParse(widget.passengerPrice) ?? 100.0) + 20.0,
        'avatarUrl':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300',
        'carUrl':
            'https://images.unsplash.com/photo-1617788138017-80ad40651399?q=80&w=500',
        'plateNumber': 'أ ج ر ١٢٣٤',
      },
      {
        'driverName': 'مريم السيد',
        'driverGender': 'أنثى',
        'driverAge': 31,
        'driverRating': '5.0',
        'carModel': 'رينج روفر',
        'carColor': 'أسود مات',
        'price': (double.tryParse(widget.passengerPrice) ?? 100.0) + 45.0,
        'avatarUrl':
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=300',
        'carUrl':
            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=500',
        'plateNumber': 'ط س ق ٥٦٧٨',
      },
      {
        'driverName': 'يوسف الحسن',
        'driverGender': 'ذكر',
        'driverAge': 48,
        'driverRating': '4.8',
        'carModel': 'بي إم دبليو الفئة ٥',
        'carColor': 'برونزي ملكي',
        'price': (double.tryParse(widget.passengerPrice) ?? 100.0) + 10.0,
        'avatarUrl':
            'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=300',
        'carUrl':
            'https://images.unsplash.com/photo-1555215695-3004980ad54e?q=80&w=500',
        'plateNumber': 'ق ر ب ٩١٢٣',
      },
      {
        'driverName': 'خالد المصطفى',
        'driverGender': 'ذكر',
        'driverAge': 38,
        'driverRating': '4.9',
        'carModel': 'مرسيدس بنز الفئة S',
        'carColor': 'أسود ملكي',
        'price': (double.tryParse(widget.passengerPrice) ?? 100.0) + 50.0,
        'avatarUrl':
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=300',
        'carUrl':
            'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?q=80&w=500',
        'plateNumber': 'م س ر ٢٤٦٨',
      },
      {
        'driverName': 'فاطمة النور',
        'driverGender': 'أنثى',
        'driverAge': 31,
        'driverRating': '5.0',
        'carModel': 'رينج روفر',
        'carColor': 'أسود غير لامع',
        'price': (double.tryParse(widget.passengerPrice) ?? 100.0) + 70.0,
        'avatarUrl':
            'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?q=80&w=300',
        'carUrl':
            'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?q=80&w=500',
        'plateNumber': 'ن و ر ١١١١',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF030A16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1526),
        title: const Text(
          "عروض السائقين المتاحة",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isTripRequested
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF00E676),
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "تم الطلب بنجاح!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "بانتظار موافقة الكابتن $_requestedDriverName لبدء الرحلة",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(color: Color(0xFFFFB300)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: mockDrivers.length,
                    itemBuilder: (context, index) {
                      final driver = mockDrivers[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1526),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withOpacity(0.15),
                          ),
                        ),
                        child: Column(
                          children: [
                            // تم تعديل التوزيع هنا لتجنب التصاق السعر بالاسم
                            Row(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // عشان يفصل الفلوس عن الداتا تماما
                              children: [
                                Expanded(
                                  child: Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Image.network(
                                          driver['avatarUrl'],
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              driver['driverName'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                            Text(
                                              "${driver['driverGender']} • ${driver['driverAge']} سنة",
                                              textDirection: TextDirection.rtl,
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12), // مسافة أمان ثابتة
                                Text(
                                  "${driver['price']} EGP",
                                  style: const TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                driver['carUrl'],
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_selectedPaymentMethod == "فيزا") {
                                    _showVisaPaymentSheet(driver);
                                  } else {
                                    _executeFirebaseOrder(driver, 'Cash');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  "طلب الكابتن",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // شريط الدفع السفلي
                Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 10,
                    top: 10,
                    left: 20,
                    right: 20,
                  ),
                  color: const Color(0xFF0B1526),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      const Text(
                        "الحساب:",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const Spacer(),
                      _buildPayChip(
                        "كاش",
                        Icons.money,
                        _selectedPaymentMethod == "كاش",
                        () => setState(() => _selectedPaymentMethod = "كاش"),
                      ),
                      const SizedBox(width: 10),
                      _buildPayChip(
                        "فيزا",
                        Icons.credit_card,
                        _selectedPaymentMethod == "فيزا",
                        () => setState(() => _selectedPaymentMethod = "فيزا"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPayChip(
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF3B82F6).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF3B82F6) : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.white38,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
