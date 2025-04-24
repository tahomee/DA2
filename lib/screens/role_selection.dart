import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/logo.png', height: 100),

              const SizedBox(height: 24),
              const Text(
                'XIN CHÀO!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B6332),
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cho WeGo biết bạn là ai?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 32),
              _buildRoleButton(
                context,
                label: 'Doanh nghiệp',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/signup',
                    arguments: {'role': 'business'},
                  );

                },
              ),
              const SizedBox(height: 16),
              _buildRoleButton(
                context,
                label: 'Người du lịch',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/signup',
                    arguments: {'role': 'traveler'},
                  );

                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0x90FFD166),
          foregroundColor: const Color(0xFF3B6332),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF3B6332)),

          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}
