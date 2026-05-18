import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'passenger_profile_screen.dart';

class PassengerRatingScreen extends StatefulWidget {
  final String? tripId;

  const PassengerRatingScreen({super.key, this.tripId});

  @override
  State<PassengerRatingScreen> createState() => _PassengerRatingScreenState();
}

class _PassengerRatingScreenState extends State<PassengerRatingScreen> {
  int _rating = 0;
  bool _isSubmitting = false;

  Future<void> _finishTripAndGoToProfile() async {
    if (widget.tripId == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId!)
          .update({
        'status': 'completed',
        'passengerRating': _rating,
        'completedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PassengerProfileScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ في حفظ البيانات: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/map.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Center(
            child: Text(
              "قيم تجربتك",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "كيف كانت الرحلة مع السائق؟",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          constraints: const BoxConstraints(),
                          onPressed: () => setState(() => _rating = index + 1),
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            size: 40,
                            color: index < _rating ? Colors.orange : Colors.grey,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _finishTripAndGoToProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "إنهاء الرحلة",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}