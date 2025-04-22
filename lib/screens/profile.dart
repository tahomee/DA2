import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:stour/screens/profile_post.dart';
import 'package:stour/screens/saved_tour.dart';
import 'package:stour/assets/icons/bio_svg.dart' as BioIcon;
import 'package:stour/assets/icons/locate_svg.dart' as LocateIcon;
import 'package:stour/widgets/profile_img.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final int _selectedEvent = 0;
  int _currentIndex = 2;

  final List<IconData> icons = [
    Icons.timeline_outlined,
    Icons.home_outlined,
    Icons.person_outline,
  ];

  final List<Widget> _pages = [const PostScreen()];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                profileImage(size),
                profileInfo(),
                profileActivity(),
                profileEvents(size),
                _pages[_selectedEvent],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget profileEvents(Size size) {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEventButton("Bài viết", 0, "2"),
            _buildEventButton("Đánh giá", 1, "2"),
            _buildEventButton("Lịch trình", 2, "2"),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton("Thêm bài viết"),
            _buildActionButton("Lịch trình đã lưu", onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedTour(),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }

  Widget _buildEventButton(String title, int index, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 35, 52, 10),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 35, 52, 10),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, {VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFECB3),
        border: Border.all(color: const Color(0xFF2D4D0A)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          foregroundColor: const Color(0xFF2D4D0A),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  Widget profileInfo() {
    return Column(
      children: [
        const Text(
          "HBT",
          style: TextStyle(
            color: Color.fromARGB(255, 35, 52, 10),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(BioIcon.bioSVG, height: 16, width: 16),
            const SizedBox(width: 4),
            const Text(
              "Cần Thơ",
              style: TextStyle(
                color: Color.fromARGB(255, 35, 52, 10),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 16),
            SvgPicture.string(LocateIcon.locateSVG, height: 16, width: 16),
            const SizedBox(width: 4),
            const Text(
              "Thích đi loanh quanh",
              style: TextStyle(
                color: Color.fromARGB(255, 35, 52, 10),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget profileActivity() {
    return const SizedBox(height: 16); // Placeholder or custom widget
  }
}