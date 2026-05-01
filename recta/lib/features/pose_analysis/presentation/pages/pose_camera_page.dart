import 'package:flutter/material.dart';

class PoseCameraPage extends StatefulWidget {
  const PoseCameraPage({super.key});

  @override
  State<PoseCameraPage> createState() => _PoseCameraPageState();
}

class _PoseCameraPageState extends State<PoseCameraPage> {
  bool isMenuOpen = false;

  final List<String> movements = [
    'Squat',
    'Lunge',
    'Şınav',
    'Plank',
    'Deadlift',
    'Mekik',
    'Barfiks',
    'Omuz Presi',
    'Dumbbell Curl',
    'Jumping Jack',
  ];

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF183B36);
    const Color lightGreen = Color(0xFFC2DC8E);

    return Scaffold(
      backgroundColor: darkGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: lightGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'HAREKET ANALİZİ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Center Silhouette Placeholder
                  Center(
                    child: Icon(
                      Icons.accessibility_new,
                      size: 250,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  
                  // Top right clock icon
                  const Positioned(
                    top: 16,
                    right: 16,
                    child: Icon(
                      Icons.access_time,
                      color: Colors.black87,
                      size: 28,
                    ),
                  ),

                  // Hamburger Menu Button (visible when menu is closed)
                  if (!isMenuOpen)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isMenuOpen = true;
                          });
                        },
                        child: const Icon(
                          Icons.menu,
                          color: Colors.black87,
                          size: 32,
                        ),
                      ),
                    ),

                  // Sidebar panel
                  if (isMenuOpen)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            right: BorderSide(color: Colors.black, width: 2.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, top: 16.0, right: 12.0, bottom: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'HAREKET SEÇİMİ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isMenuOpen = false;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.menu,
                                      color: Colors.black87,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                                color: Colors.black, thickness: 1.5, height: 0),
                            Expanded(
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: movements.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                        color: Colors.black,
                                        thickness: 1,
                                        height: 0),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        isMenuOpen = false;
                                        // Movement selection logic would go here
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 12),
                                      child: Text(
                                        movements[index],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            '(YÖNLENDİRMELER)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0, left: 24.0, right: 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(width: 32), // Placeholder to balance info icon
                const Spacer(),
                
                // Camera Capture Icon
                Icon(
                  Icons.camera, // Looks like an aperture in material design
                  color: lightGreen,
                  size: 70,
                ),
                
                const Spacer(),
                
                // Info Icon
                Icon(
                  Icons.info_outline,
                  color: lightGreen,
                  size: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
