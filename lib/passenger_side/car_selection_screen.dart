import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'available_drivers_screen.dart';

class CarSelectionScreen extends StatefulWidget {
  final String pickup;
  final String destination;

  const CarSelectionScreen({
    super.key,
    required this.pickup,
    required this.destination,
  });

  @override
  State<CarSelectionScreen> createState() => _CarSelectionScreenState();
}

class _CarSelectionScreenState extends State<CarSelectionScreen> {
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;

  void _submitAndNavigate() async {
    if (_priceController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('trips')
          .add({
            'passengerId': FirebaseAuth.instance.currentUser?.uid,
            'passengerName': 'عمار',
            'pickup': widget.pickup,
            'destination': widget.destination,
            'price': _priceController.text,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AvailableDriversScreen(
            tripId: docRef.id,
            pickup: widget.pickup,
            destination: widget.destination,
            passengerPrice: _priceController.text,
          ),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A16),
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              child: Image.network(
                'https://raw.githubusercontent.com/flutter-it/map_styles/main/dark_map_v2.png',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.black),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              decoration: const BoxDecoration(
                color: Color(0xFF0B1526),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "تحديد السعر المقترح",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: "كم تود أن تدفع؟",
                          hintStyle: TextStyle(
                            color: Colors.white24,
                            fontSize: 16,
                            fontFamily: 'Cairo',
                          ),
                          suffixText: "EGP",
                          suffixStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Cairo',
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitAndNavigate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "تأكيد وعرض الكباتن",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
