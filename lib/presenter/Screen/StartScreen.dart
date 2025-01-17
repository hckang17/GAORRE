import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'LoginScreen.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SvgPicture.asset(
            "assets/image/waveform/gaorre_wave_shadow.svg",
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          SvgPicture.asset(
            "assets/image/waveform/gaorre_wave.svg",
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Text(
                  "가 오 리",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Dovemayo_gothic',
                    fontSize: 64,
                    color: Color(0xFF72AAD8),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.25,
                    backgroundColor: Color(0xFFE6F4FE),
                    backgroundImage: AssetImage("assets/image/logo/gaorre.png"),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "원격 웨이팅 접수 서비스(점주)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Dovemayo_gothic',
                    fontSize: 24,
                    color: Color(0xFF72AAD8),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginScreenWidget()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF72AAD8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.9, 60),
                  ),
                  child: Text(
                    "로그인",
                    style: TextStyle(
                      fontFamily: 'Dovemayo_gothic',
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 20,
              color: Color(0xFF72AAD8),
            ),
          ),
        ],
      ),
    );
  }
}
