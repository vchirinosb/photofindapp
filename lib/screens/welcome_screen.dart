import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photofindapp/screens/auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final List<String> imgList = [
    'assets/welcome/welcome1.jpg',
    'assets/welcome/welcome2.jpg',
    'assets/welcome/welcome3.jpg',
    'assets/welcome/welcome4.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const Padding(padding: EdgeInsets.symmetric(vertical: 30.0)),
              SizedBox(
                child: Text(
                  'Photo Explorer',
                  style: GoogleFonts.sacramento(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF4A460),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                  ),
                  items: imgList
                      .map((item) => Center(
                            child: Image.asset(item,
                                fit: BoxFit.cover, width: 1000),
                          ))
                      .toList(),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/icon/unsplash.png',
                            width: 60, height: 60),
                        const SizedBox(width: 50),
                        Image.asset('assets/icon/pexels.png',
                            width: 60, height: 60),
                        const SizedBox(width: 50),
                        Image.asset('assets/icon/pixabay.png',
                            width: 33, height: 33),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Search Your Favorites',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF4A460),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'Images Today!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF4A460),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const AuthScreen(
                                        isLogin: true,
                                      )),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF4A460),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFFF4A460),
                            ),
                          ),
                          child: const Text('Log In'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const AuthScreen(
                                        isLogin: false,
                                      )),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                color: Color(0xFF98FF98),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFFF4A460),
                            ),
                          ),
                          child: const Text('Sign Up'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
