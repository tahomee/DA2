import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stour/util/places.dart';
import 'package:intl/intl.dart';
import 'package:stour/screens/view_saved_tour.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stour/util/const.dart';

class SavedTour extends StatefulWidget {
  const SavedTour({super.key});

  @override
  State<SavedTour> createState() => _SavedTourState();
}

class _SavedTourState extends State<SavedTour> {
  final TextEditingController _tourNameController = TextEditingController();
  List<SavedTourClass> savedTours = [];
  bool isLoading = true; // Trạng thái loading

  @override
  void initState() {
    super.initState();
    fetchSavedTours();

  }
  Future<void> fetchSavedTours() async {
    setState(() {
      isLoading = true; // Đặt trạng thái là đang tải
    });

    try {
      // Fetch dữ liệu từ Firestore
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        print("Không có người dùng đăng nhập");
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final saveTours = List<String>.from(userDoc.data()?['saveTours'] ?? []);

      if (saveTours.isEmpty) {
        print("Không tìm thấy tour đã lưu");
        return;
      }

      List<SavedTourClass> fetchedTours = [];
      for (var tourId in saveTours) {
        final tourDoc = await FirebaseFirestore.instance
            .collection('tours')
            .doc(tourId)
            .get();

        if (tourDoc.exists) {
          SavedTourClass savedTour = SavedTourClass.fromDocument(tourDoc);
          fetchedTours.add(savedTour);
        } else {
          print("Không tìm thấy tour với ID $tourId");
        }
      }

      setState(() {
        savedTours = fetchedTours; // Cập nhật dữ liệu và thay đổi trạng thái
        isLoading = false; // Đặt trạng thái tải xong
      });

    } catch (e) {
      setState(() {
        isLoading = false; // Nếu có lỗi, vẫn thay đổi trạng thái
      });
      print("Lỗi khi tải dữ liệu tour đã lưu: $e");
    }
  }

  void _showRenameDialog(BuildContext context, int index) {
    _tourNameController.text = savedTours[index].name; // Hiển thị tên cũ

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đổi tên'),
          content: TextField(
            controller: _tourNameController,
            decoration: const InputDecoration(hintText: 'Tên mới'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy',
                  style: TextStyle(
                    color: Color.fromARGB(255, 35, 52, 10),
                  )),
              onPressed: () {
                _tourNameController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lưu',
                  style: TextStyle(
                    color: Color.fromARGB(255, 35, 52, 10),
                  )),
              onPressed: () async {
                String newName = _tourNameController.text.trim();
                if (newName.isNotEmpty) {
                  String tourId = savedTours[index].id;

                  try {
                    await FirebaseFirestore.instance
                        .collection('tours')
                        .doc(tourId)
                        .update({'name': newName});

                    setState(() {
                      savedTours[index].name = newName;
                    });
                  } catch (e) {
                    print("Lỗi khi cập nhật tên tour: $e");
                  }
                }
                _tourNameController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showContextMenu(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Đổi tên',
                    style: TextStyle(
                      color: Color.fromARGB(255, 35, 52, 10),
                    )),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showRenameDialog(context, index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Xóa lịch trình',
                    style: TextStyle(
                      color: Color.fromARGB(255, 35, 52, 10),
                    )),
                onTap: () async {
                  Navigator.of(ctx).pop();

                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId == null) {
                    print("Không có người dùng đăng nhập");
                    return;
                  }

                  String tourId = savedTours[index].id;

                  try {
                    // Xóa tourId khỏi danh sách saveTours của user
                    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
                    await userRef.update({
                      'saveTours': FieldValue.arrayRemove([tourId])
                    });

                    // Nếu bạn muốn xóa luôn tour khỏi collection 'tours', bỏ comment dòng dưới:
                    // await FirebaseFirestore.instance.collection('tours').doc(tourId).delete();

                    setState(() {
                      savedTours.removeAt(index);
                    });
                  } catch (e) {
                    print("Lỗi khi xóa tour: $e");
                  }
                },
              ),
            ],
          );
        });
  }


  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LỊCH TRÌNH ĐÃ LƯU',
          style: TextStyle(
            color: Color.fromARGB(255, 35, 52, 10),
          ),
        ),
        backgroundColor: Constants.lightgreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 35, 52, 10)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedTours.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Thật trống trải...',
                style: GoogleFonts.roboto(
                    fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 30),
              Text('Có vẻ như bạn chưa tạo cho mình một lịch trình nào',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: const Color.fromARGB(255, 35, 52, 10),
                    fontSize: 16,
                  )),
              const SizedBox(height: 20),
              Text(
                'Hãy tạo cho mình một lịch trình bằng chức năng thiết kế lịch trình ngay nhé!',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  color: const Color.fromARGB(255, 35, 52, 10),
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
      )
          : ListView.builder(
        itemCount: savedTours.length,
        itemBuilder: (BuildContext context, int index) {
          SavedTourClass tour = savedTours[index];
          return ListTile(
            title: Text(tour.name,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
                'Được tạo vào: ${DateFormat.yMd().format(tour.timeSaved)}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ViewSavedTour(
                      savedTour: savedTours[index],
                    );
                  },
                ),
              );
            },
            onLongPress: () {
              _showContextMenu(context, index);
            },
          );
        },
      ),
    );
  }
}
