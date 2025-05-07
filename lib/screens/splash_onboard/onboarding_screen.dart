import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class OnBoard {
  final String image, title, description;

  OnBoard({
    required this.image,
    required this.title,
    required this.description,
  });
}

// OnBoarding content list
final List<OnBoard> demoData = [
  OnBoard(
    image: "assets/images/onboard1.png",
    title: "Trade Crypto with P2P Sharp Drop",
    description:
        "Buy Crypto, Sell crypto, or trade gift cards seamlessly with instant support",
  ),
  OnBoard(
    image: "assets/images/onboard2.png",
    title: "Secure Transactions Guaranteed",
    description:
        "Your funds are protected with military-grade encryption and secure protocols",
  ),
  OnBoard(
    image: "assets/images/onboard3.png",
    title: "Global P2P Marketplace",
    description:
        "Connect with traders worldwide and get the best rates for your transactions",
  ),
];

// OnBoardingScreen
class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  // Variables
  late PageController _pageController;
  int _pageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Initialize page controller
    _pageController = PageController(initialPage: 0);
    // Automatic scroll behaviour
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageIndex < 2) {
        _pageIndex++;
      } else {
        _pageIndex = 0;
      }

      _pageController.animateToPage(
        _pageIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    // Dispose everything
    _pageController.dispose();
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        // Background gradient
        decoration:  BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: Column(
          children: [
            // Carousel area
            Expanded(
              child: PageView.builder(
                onPageChanged: (index) {
                  setState(() {
                    _pageIndex = index;
                  });
                },
                itemCount: demoData.length,
                controller: _pageController,
                itemBuilder:
                    (context, index) => OnBoardContent(
                      title: demoData[index].title,
                      description: demoData[index].description,
                      image: demoData[index].image,
                    ),
              ),
            ),
            // Indicator area
            Padding(
              padding: EdgeInsets.only(bottom: Dimensions.height50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    demoData.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(right: Dimensions.width10),
                      child: DotIndicator(isActive: index == _pageIndex),
                    ),
                  ),
                ],
              ),
            ),
            // White space
            SizedBox(height: Dimensions.height10),
            // Button area
            InkWell(
              onTap: () {
                Get.offAllNamed(AppRoutes.signupScreen);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: Dimensions.height18),
                height: Dimensions.height50,
                width: Dimensions.width360,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(Dimensions.radius30),
                ),
                child: InkWell(
                  onTap: () {
                    Get.offAllNamed(AppRoutes.signupScreen);
                  },
                  child: Center(
                    child: Text(
                      'Join us Today',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.black,
                        fontSize: Dimensions.font18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: Dimensions.height50 + 20),
          ],
        ),
      ),
    );
  }
}

// OnBoarding area widget
class OnBoardContent extends StatelessWidget {
  const OnBoardContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width50,
            vertical: Dimensions.height50,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Image.asset(
            fit: BoxFit.cover,
            image,

          ),
        ),
        const Spacer(),
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        SizedBox(height: Dimensions.height10),
        Text(
          description,
          textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyLarge,

        ),
        const Spacer(),
      ],
    );
  }
}

// Dot indicator widget
class DotIndicator extends StatelessWidget {
  const DotIndicator({this.isActive = false, super.key});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.white,
        border: isActive ? null : Border.all(color: Theme.of(context).primaryColor),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
