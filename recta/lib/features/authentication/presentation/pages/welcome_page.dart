import 'package:flutter/material.dart';
import '../../../../core/theme/theme_manager.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    const bool isDebugMode = false; 

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            ThemeManager.getWelcomeImagePath(),
            fit: BoxFit.fill,
          ),

          Positioned(
            top: screenHeight * 0.68,
            left: screenWidth * 0.27,
            right: screenWidth * 0.27,
            height: screenHeight * 0.06,
            child: Container(
              decoration: BoxDecoration(
                color: isDebugMode ? Colors.red.withAlpha(102) : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  debugPrint("Misafir Girişi tıklandı!");
                },
              ),
            ),
          ),

          Positioned(
            top: screenHeight * 0.75,
            left: screenWidth * 0.27,
            right: screenWidth * 0.27,
            height: screenHeight * 0.06,
            child: Container(
              decoration: BoxDecoration(
                color: isDebugMode ? Colors.blue.withAlpha(102) : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  debugPrint("Oturum Aç tıklandı!");
                },
              ),
            ),
          ),

          Positioned(
            top: screenHeight * 0.82,
            left: screenWidth * 0.53,
            right: screenWidth * 0.18,
            height: screenHeight * 0.02,
            child: Container(
              color: isDebugMode ? Colors.green.withAlpha(102) : Colors.transparent,
              child: InkWell(
                onTap: () {
                  debugPrint("Hemen kaydol tıklandı!");
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}