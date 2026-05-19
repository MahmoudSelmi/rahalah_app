import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'car_selection_screen.dart';

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

  // إعدادات خرائط جوجل
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(
    30.0444,
    31.2357,
  ); // الإحداثيات الافتراضية (القاهرة كمثال)
  final Set<Marker> _markers = {};

  // الستايل الداكن الاحترافي للخريطة (Retro/Dark) matching مع ألوان واجهتك
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
    _determinePosition(); // جلب موقع المستخدم فوراً عند فتح الشاشة

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _panelAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  // دالة ذكية لتحديد وتحريك الكاميرا لموقع المستخدم الحالي
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
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

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_initialPosition, 15.0),
    );
  }

  // تحديث الـ Markers بشكل تفاعلي على الخريطة
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
          // 🗺️ خرائط جوجل الحقيقية والاحترافية بديلة الصورة الثابتة
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 13.5,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _mapController?.setMapStyle(
                  _darkMapStyle,
                ); // تطبيق ستايل الخريطة الغامق
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled:
                  false, // سنقوم بعمل زر مخصص متناسق مع التصميم لاحقاً إذا أردت
              zoomControlsEnabled:
                  false, // إخفاء أزرار الزووم الافتراضية لشكل أكثر أناقة
              compassEnabled: false,
            ),
          ),

          // طبقة الظلال العلوية والسفلية (Gradients) لجعل واجهة المستخدم مقروءة وفخمة
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF030A16).withOpacity(0.6),
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF030A16).withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // اللوحة السفلية المدعومة بالأنيميشن (دون أي تغيير في الستاتيل)
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
                              _destinationController.text.isEmpty) {
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarSelectionScreen(
                                pickup: _currentLocationController.text,
                                destination: _destinationController.text,
                                // يمكنك هنا تمرير خطوط الطول والعرض للـ CarSelectionScreen إذا كنت بحاجة إليها لاحقاً
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
                    // إضافة Marker وهمي محاكي للواقع عند إدخال نص لتجربة مرئية ممتازة
                    _updateMarkers(
                      LatLng(
                        _initialPosition.latitude + 0.002,
                        _initialPosition.longitude + 0.002,
                      ),
                      tempController.text,
                      isPickup: true,
                    );
                  } else {
                    _destinationController.text = tempController.text;
                    // وضع علامة الوجهة على الخريطة وعمل زووم تلقائي باتجاهها
                    LatLng destLatLng = LatLng(
                      _initialPosition.latitude - 0.005,
                      _initialPosition.longitude - 0.005,
                    );
                    _updateMarkers(
                      destLatLng,
                      tempController.text,
                      isPickup: false,
                    );
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(destLatLng, 14.0),
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
