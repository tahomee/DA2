import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stour/screens/home.dart';
import 'package:stour/widgets/timeline.dart';
import 'package:stour/util/const.dart';
import 'package:stour/screens/profile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stour/assets/icons/timeline_svg.dart';
import 'package:stour/assets/icons/home_svg.dart';
import 'package:stour/assets/icons/account_svg.dart';

import '../main.dart';

List icons = [
  Icons.timeline_outlined,
  Icons.home_outlined,
  Icons.person_outline,
];

List<Widget> pages = [
  const Timeline(),
  const Home(),
  const Profile(),
  // const ReviewScreen(),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,

      bottomNavigationBar: HomeBottomBar(
        onTap: navigationTapped,
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              // onPageChanged: onPageChanged,
              children: List.generate(3, (index) => pages[index]),
            ),
          ),
        ],
      ),
    );
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }
  void checkAndNotifyUpcomingTours() async {
    final now = DateTime.now();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final savedTours = userDoc.data()?['saveTours'] ?? [];

    for (String tourId in savedTours) {
      final tourDoc = await FirebaseFirestore.instance.collection('tours').doc(tourId).get();
      if (tourDoc.exists) {
        final data = tourDoc.data()!;
        final startDate = (data['departureDate'] as Timestamp).toDate();
        final completed =data['completed'];
        final diff = startDate.difference(now).inDays;

        if (diff >= 0 && diff <= 3 && !completed ) {
          // Gửi local notification
          await flutterLocalNotificationsPlugin.show(
            tourId.hashCode, // ID
            'Sắp đến ngày khởi hành!',
            'Còn $diff ngày nữa tới tour: ${data['name']}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'upcoming_tour_channel',
                'Upcoming Tours',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  void initState() {
    _pageController = PageController(initialPage: 1);
    checkAndNotifyUpcomingTours();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class HomeBottomBar extends StatelessWidget {
  final Function(int) onTap;
  const HomeBottomBar({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Constants.navBG,
      buttonBackgroundColor: Constants.navBG,
      index: 1,
      items: [
      SvgPicture.string(
      timelineSVG,
      height: 30,
      width: 30,
    ),
      SvgPicture.string(
      homeSVG,
      height: 30,
      width: 30,
    ),
      SvgPicture.string(
      accountSVG,
      height: 30,
      width: 30,
    )
      ],
      onTap: onTap,
    );
  }
}
