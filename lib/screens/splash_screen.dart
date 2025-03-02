import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    Timer(const Duration(seconds: 3), () async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          // Verificar si el usuario es recolector
          final recolectorDoc = await FirebaseFirestore.instance
              .collection('Recolectores')
              .doc(user.uid)
              .get();

          if (recolectorDoc.exists && recolectorDoc.data()?['isRecolector'] != null) {
            // Navegar a la pantalla de recolector
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/recolector_dashboard');
            }
          } else {
            // Navegar a la pantalla principal de usuario normal
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/main');
            }
          }
        } catch (e) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/bcuu.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 50),
              Text(
                'BioWay',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontFamily: 'Hammersmith_One',
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00A650),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}