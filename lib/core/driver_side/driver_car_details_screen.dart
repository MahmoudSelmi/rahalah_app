import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

class DriverCarDetailsScreen extends StatefulWidget {
  const DriverCarDetailsScreen({super.key});

  @override
  State<DriverCarDetailsScreen> createState() => _DriverCarDetailsScreenState();
}

class _DriverCarDetailsScreenState extends State<DriverCarDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _carLicenseController = TextEditingController();
  final TextEditingController _licenseDetailsController =
      TextEditingController();
  final TextEditingController _carBrandController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _productionYearController =
      TextEditingController();
  bool _isLoading = false;

  void _saveCarDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('drivers')
              .doc(user.uid)
              .update({
                'carLicense': _carLicenseController.text.trim(),
                'licenseDetails': _licenseDetailsController.text.trim(),
                'carBrand': _carBrandController.text.trim(),
                'plateNumber': _plateNumberController.text.trim(),
                'productionYear': _productionYearController.text.trim(),
                'setupComplete': true,
              });

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
              (route) => false,
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "خطأ في حفظ البيانات: ${e.toString()}",
              textAlign: TextAlign.right,
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1526),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "بيانات السيارة",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Form(
                key: _formKey,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel("رخصة السيارة"),
                      _buildTextField(
                        "ادخل رقم رخصة السيارة",
                        _carLicenseController,
                      ),
                      const SizedBox(height: 20),
                      _buildFieldLabel("بيانات الرخصة"),
                      _buildTextField(
                        "ادخل رقم الرخصة",
                        _licenseDetailsController,
                      ),
                      const SizedBox(height: 20),
                      _buildFieldLabel("ماركة العربية"),
                      _buildTextField(
                        "ادخل ماركة العربية",
                        _carBrandController,
                      ),
                      const SizedBox(height: 20),
                      _buildFieldLabel("رقم اللوحة"),
                      _buildTextField("ادخل الرقم", _plateNumberController),
                      const SizedBox(height: 20),
                      _buildFieldLabel("سنة الصنع"),
                      _buildTextField(
                        "ادخل سنة الصنع",
                        _productionYearController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withOpacity(0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _saveCarDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "إتمام التسجيل",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
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
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFFCBD5E1),
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: const Color(0xFF3B82F6),
      validator: (value) {
        if (value == null || value.isEmpty) return "هذا الحقل مطلوب";
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.2),
          fontSize: 13,
          fontFamily: 'Cairo',
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: const Color(0xFF0B1526),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFF87171),
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
