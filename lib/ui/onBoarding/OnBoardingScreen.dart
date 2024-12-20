import 'package:easy_localization/easy_localization.dart' as easyLocal;
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController pageController = PageController();
  final List<String> _titlesList = [
    // easyLocal.tr('Welcome to FOODIES'),
    // 'Order Food'.tr(),
    'Welcome to the App'.tr(),
    'Easy Booking Process'.tr(),
    'Safe and Affordable'.tr(),
  ];

  final List<String> _subtitlesList = [
    // 'Hungry? Order food in just a few clicks and we\'ll take care of you.'.tr(),
    'Your Ride, Your Way!'.tr(),
    'Book a Ride in Just a Tap!'.tr(),
    'Affordable Rides, Safe Travels!'.tr(),
  ];

  final List<dynamic> _imageList = [
    'assets/images/intro_1.png',
    'assets/images/intro_2.png',
    'assets/images/intro_3.png',
  ];
  final List<dynamic> _darkimageList = [
    'assets/images/intro_1.png',
    'assets/images/intro_2.png',
    'assets/images/intro_3.png',
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? const Color(0XFF151618) : null,
      body: Stack(
        children: <Widget>[
          PageView.builder(
            itemBuilder: (context, index) => getPage(isDarkMode(context) ? _darkimageList[index] : _imageList[index], _titlesList[index], _subtitlesList[index], context,
                isDarkMode(context) ? (index + 1) == _darkimageList.length : (index + 1) == _imageList.length),
            controller: pageController,
            itemCount: isDarkMode(context) ? _darkimageList.length : _imageList.length,
            onPageChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          Visibility(
              visible: _currentIndex + 1 == _imageList.length,
              child: Positioned(
                  right: 13,
                  bottom: 17,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.94,
                      height: MediaQuery.of(context).size.height * 0.08,
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), backgroundColor: Color(COLOR_PRIMARY)),
                        child: Text(
                          "GET STARTED".tr(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          setFinishedOnBoarding();
                          pushReplacement(context, const AuthScreen());
                        },
                      )))
              //     onPressed: () {
              //       setFinishedOnBoarding();
              //       pushReplacement(context, AuthScreen());
              //     },
              //     child: Text(
              //       'Continue',
              //       style: TextStyle(
              //           fontSize: 14.0,
              //           color: Colors.white,
              //           fontWeight: FontWeight.bold),
              //     ).tr(),
              //   ),
              // )),
              ),
          Center(
              child: Padding(
            padding: const EdgeInsets.only(bottom: 130),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SmoothPageIndicator(
                controller: pageController,
                count: _imageList.length,
                effect: ScrollingDotsEffect(spacing: 20, activeDotColor: Color(COLOR_PRIMARY), dotColor: const Color(0XFFFBDBD1), dotWidth: 7, dotHeight: 7, fixedCenter: false),
              ),
            ),
          )),
          Visibility(
            visible: _currentIndex + 1 == _imageList.length,
            child: Positioned(
                left: 15,
                top: 30,
                child: GestureDetector(
                    onTap: () {
                      pageController.previousPage(duration: const Duration(milliseconds: 100), curve: Curves.bounceIn);
                    },
                    child: Icon(Icons.chevron_left, size: 40, color: isDarkMode(context) ? const Color(0xffFFFFFF) : null))),
          ),
          Visibility(
            visible: _currentIndex + 2 == _imageList.length,
            child: Positioned(
                left: 15,
                top: 30,
                child: GestureDetector(
                    onTap: () {
                      pageController.previousPage(duration: const Duration(milliseconds: 100), curve: Curves.bounceIn);
                    },
                    child: Icon(
                      Icons.chevron_left,
                      size: 40,
                      color: isDarkMode(context) ? const Color(0xffFFFFFF) : null,
                    ))),
          ),
          Visibility(
              visible: _currentIndex + 1 != _imageList.length,
              child: Positioned(
                  right: 20,
                  top: 40,
                  child: InkWell(
                      onTap: () {
                        setFinishedOnBoarding();
                        pushReplacement(context, const AuthScreen());
                      },
                      child: Text(
                        "SKIP".tr(),
                        style: const TextStyle(fontSize: 19, color: Color(0XFFFF683A)),
                      )))),
          Visibility(
              visible: _currentIndex + 1 != _imageList.length,
              child: Positioned(
                  right: 13,
                  bottom: 17,
                  child: InkWell(
                      onTap: () {},
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.94,
                          height: MediaQuery.of(context).size.height * 0.08,
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), backgroundColor: Color(COLOR_PRIMARY)),
                            child: Text(
                              "NEXT".tr(),
                              style: TextStyle(fontSize: 16, color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0XFF333333)),
                            ),
                            onPressed: () {
                              pageController.nextPage(duration: const Duration(milliseconds: 100), curve: Curves.bounceIn);
                            },
                          )))))
        ],
      ),
    );
  }

  Widget getPage(dynamic image, _titlesList, _subtitlesList, BuildContext context, bool isLastPage) {
    return Column(
      //  crossAxisAlignment: CrossAxisAlignment.stretch,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // image is String ?
        Expanded(
            child: Container(
                //  height:  MediaQuery.of(context).size.height*0.55,
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                    color: isDarkMode(context) ? const Color(0XFF242528) : const Color(0XFFFCEEE9),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.elliptical(400, 180), bottomRight: Radius.elliptical(400, 180))),
                child: Container(
                  margin: const EdgeInsets.only(right: 40, left: 40, top: 30),

                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage(image), fit: BoxFit.contain)),

                  //  child:
                  //       Image.asset(
                  //           image,
                  //           width: 50.00,
                  //           fit: BoxFit.contain,
                  //         )
                ))),
        SizedBox(height: MediaQuery.of(context).size.height * 0.08),
        Text(
          _titlesList,
          textAlign: TextAlign.center,
          style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0XFF333333), fontSize: 20),
        ),

        Padding(
            padding: const EdgeInsets.only(right: 35, left: 35, top: 30),
            child: Text(
              _subtitlesList,
              textAlign: TextAlign.center,
              style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0XFF333333), height: 2, letterSpacing: 1.2, fontSize: 15),
            )),
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        // : Icon(
        //     image as IconData,
        //     color: Colors.white,
        //     size: 150,
        //   ),
        // Text(
        //   title.toUpperCase(),
        //   style: TextStyle(
        //       color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
        //   textAlign: TextAlign.center,
        // ),
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Text(
        //     subTitle,
        //     style: TextStyle(color: Colors.white, fontSize: 14.0),
        //     textAlign: TextAlign.center,
        //   ),
        // ),
      ],
    );
  }

  Future<bool> setFinishedOnBoarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(FINISHED_ON_BOARDING, true);
  }
}
