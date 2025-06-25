import 'package:flutter/material.dart';
import 'login.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Tetap Terhubung",
      "subtitle": "Berkolaborasi dengan tim, melacak kemajuan, dan tetap diperbarui tentang jadwal kerja Anda.",
      "image": "assets/logo.png", 
    },
    {
      "title": "Selamat Datang",
      "subtitle": "Siap untuk mengelola tugas dengan lebih efisien dan tetap terorganisir dalam setiap hari kerja.",
      "image": "assets/logo.png",
    },
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() => _currentPage = page);
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) => _buildOnboardingPage(index),
              ),
            ),
            _buildPageIndicator(),
            _buildNavigationButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(int index) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (index != 0)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                )
              else
                const SizedBox(width: 48),
              TextButton(
                onPressed: _navigateToLogin,
                child: const Text(
                  "Skip",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Image.asset(
            onboardingData[index]['image']!,
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          Text(
            onboardingData[index]['title']!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              onboardingData[index]['subtitle']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index 
                ? const Color(0xFF001F3F) // Warna biru tua yang sama dengan login
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF001F3F), // Warna konsisten dengan login
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16),
          elevation: 2,
        ),
        child: Icon(
          _currentPage == onboardingData.length - 1
              ? Icons.check
              : Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
    );
  }
}