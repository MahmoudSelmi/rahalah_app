import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _panelAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
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
          // الخريطة التفاعلية في الخلفية
          Positioned.fill(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(500),
              minScale: 1.0,
              maxScale: 3.5,
              child: Image.network(
                'https://raw.githubusercontent.com/flutter-it/map_styles/main/dark_map_v2.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.black),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF030A16).withOpacity(0.3),
                    Colors.transparent,
                    const Color(0xFF030A16),
                  ],
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
                  } else {
                    _destinationController.text = tempController.text;
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
