import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // 🗺️ باقة الخرائط الحقيقية
import 'package:geolocator/geolocator.dart'; // 📍 باقة تحديد الموقع والـ GPS
import 'package:cloud_firestore/cloud_firestore.dart';

// ==========================================
// 1️⃣ الشاشة الأولى: اختيار الوجهة مع خريطة جوجل الحقيقية والكاميرا
// ==========================================
class SelectDestinationScreen extends StatefulWidget {
  const SelectDestinationScreen({super.key});

  @override
  State<SelectDestinationScreen> createState() =>
      _SelectDestinationScreenState();
}

class _SelectDestinationScreenState extends State<SelectDestinationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _currentLocationController =
      TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _panelAnimation;

  // 🛠️ متحكمات وإعدادات جوجل ماب الحقيقية لتشغيل الكاميرا والـ Markers
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(
    30.0444,
    31.2357,
  ); // إحداثيات القاهرة الافتراضية
  final Set<Marker> _markers = {};

  // الستايل الاحترافي الداكن المطبق مباشرة على خريطة جوجل الحقيقية
  final String _darkMapStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#030a16"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#746855"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#242f3e"}]},
    {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
    {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
    {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#111e36"}]},
    {"featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [{"color": "#6b9a76"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#1b2840"}]},
    {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#212f4d"}]},
    {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#9ca2ad"}]},
    {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#2c3e5d"}]},
    {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#1f2d44"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#0a1120"}]},
    {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#515c6d"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _determinePosition(); // جلب لوكيشن المستخدم الحقيقي فوراً وتحريك الكاميرا له

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _panelAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  // 🎥 دالة تحديد الموقع الجغرافي وتحريك كاميرا جوجل ماب تلقائياً
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _updateMarkers(_initialPosition, "موقعك الحالي", isPickup: true);
    });

    // تحريك الكاميرا لموقع المستخدم الحقيقي بالزووم
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_initialPosition, 16.0),
    );
  }

  // دالة تحديث وعرض العلامات (Markers) التفاعلية على جوجل ماب
  void _updateMarkers(LatLng position, String title, {required bool isPickup}) {
    final markerId = MarkerId(isPickup ? 'pickup' : 'destination');
    final marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: title),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        isPickup ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
      ),
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId == markerId);
      _markers.add(marker);
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _animationController.dispose();
    _currentLocationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _openInputSheet(bool isCurrentLocation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildInputInterface(isCurrentLocation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A16),
      body: Stack(
        children: [
          // 🗺️ خرائط جوجل الحقيقية والاحترافية بديلة الصورة الثابتة القديمة
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _mapController?.setMapStyle(
                  _darkMapStyle,
                ); // تطبيق الستايل المظلم الاحترافي
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF030A16).withOpacity(0.4),
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF030A16).withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: _panelAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _panelAnimation.value),
                child: child,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 26,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF0B1526),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "إلى أين تريد الذهاب؟",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAddressBox(
                      "موقع الركوب الحالي",
                      Icons.my_location_rounded,
                      const Color(0xFF00E676),
                      _currentLocationController,
                      () => _openInputSheet(true),
                    ),
                    const SizedBox(height: 16),
                    _buildAddressBox(
                      "وجهتك المقصودة",
                      Icons.location_on_rounded,
                      const Color(0xFFEF4444),
                      _destinationController,
                      () => _openInputSheet(false),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentLocationController.text.isEmpty ||
                              _destinationController.text.isEmpty)
                            return;

                          // الانتقال لشاشة اختيار السيارة وتمرير العناوين المكتوبة لربط الـ Flow كاملاً
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarSelectionScreen(
                                pickup: _currentLocationController.text,
                                destination: _destinationController.text,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "البحث عن كابتن",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressBox(
    String hint,
    IconData icon,
    Color color,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    bool hasText = controller.text.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasText ? color.withOpacity(0.3) : Colors.white10,
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                hasText ? controller.text : hint,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: hasText ? Colors.white : Colors.white30,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputInterface(bool isCurrentLocation) {
    TextEditingController tempController = TextEditingController(
      text: isCurrentLocation
          ? _currentLocationController.text
          : _destinationController.text,
    );
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 16,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1526),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: tempController,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
            decoration: InputDecoration(
              hintText: isCurrentLocation
                  ? "اكتب موقع الركوب..."
                  : "اكتب وجهتك...",
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (isCurrentLocation) {
                    _currentLocationController.text = tempController.text;
                    _updateMarkers(
                      _initialPosition,
                      tempController.text,
                      isPickup: true,
                    );
                  } else {
                    _destinationController.text = tempController.text;
                    // 🎥 محاكاة إحداثيات للوجهة وعمل زووم تفاعلي بالكاميرا عليها باتجاه الماركر الأحمر
                    LatLng destLatLng = LatLng(
                      _initialPosition.latitude - 0.015,
                      _initialPosition.longitude - 0.015,
                    );
                    _updateMarkers(
                      destLatLng,
                      tempController.text,
                      isPickup: false,
                    );
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(destLatLng, 14.5),
                    );
                  }
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
              ),
              child: const Text(
                "تأكيد العنوان",
                style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2️⃣ الشاشة الثانية: اختيار فئة السيارة وإنشاء مستند الرحلة في Firestore
// ==========================================
class CarSelectionScreen extends StatelessWidget {
  final String pickup;
  final String destination;

  const CarSelectionScreen({
    super.key,
    required this.pickup,
    required this.destination,
  });

  void _createTripAndNavigate(BuildContext context, String basePrice) async {
    try {
      // رفع بيانات الرحلة الأساسية الممررة للـ Firestore وتوليد الـ Trip ID الفرعي تلقائياً
      final docRef = await FirebaseFirestore.instance.collection('trips').add({
        'pickup': pickup,
        'destination': destination,
        'status': 'created',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        // تمرير الـ tripId الفعلي وكافة تفاصيل العناوين والأسعار لشاشة الكباتن الثالثة
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AvailableDriversScreen(
              tripId: docRef.id,
              pickup: pickup,
              destination: destination,
              passengerPrice: basePrice,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error creating trip: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1526),
        title: const Text(
          "اختر الفئة",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_car_filled_rounded,
              color: Color(0xFF3B82F6),
              size: 100,
            ),
            const SizedBox(height: 24),
            Text(
              "من: $pickup",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "إلى: $destination",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _createTripAndNavigate(
                  context,
                  "120.0",
                ), // السعر المبدئي المحسوب للفئة كمثال
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "تأكيد الفئة والبحث عن عروض",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    fontSize: 15,
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

// ==========================================
// 3️⃣ الشاشة الثالثة: عروض السائقين المتاحة بالـ Firebase (كودك الأصلي كاملاً بدون أي حذف)
// ==========================================
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

  // Controllers للفيزا لربط حركة كارت الـ UI بالأنيميشن أثناء الكتابة التفاعلية
  final TextEditingController _cardNumController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardExpController = TextEditingController();
  final TextEditingController _cardCvcController = TextEditingController();

  void _executeFirebaseOrder(
    Map<String, dynamic> driver,
    String paymentType,
  ) async {
    setState(() {
      _isTripRequested = true;
      _requestedDriverName = driver['driverName'];
    });

    try {
      // تحديث بيانات نفس مستند الـ tripId في الفايربيز بدون تعارض
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

  // شيت الدفع المطور والـ الكارت المتحرك التفاعلي
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
                          Navigator.pop(context);
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
    // قائمة السائقين الخمسة كاملة وبدون تعديل حرف واحد من كودك
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
                    style: const TextStyle(
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
                            Row(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                              style: const TextStyle(
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
                                const SizedBox(width: 12),
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
