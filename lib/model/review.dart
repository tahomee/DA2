import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewsServices {
  Future<List<DocumentSnapshot>> getAllReviewsByItemID(
      String locationID) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('idLocation', isEqualTo: locationID)
        .get();
    return snapshot.docs;
  }

  Future<String> createReview(
      String id,
      String user,
      String idLocation,
      String name,
      String userImg,
      String content,
      String score,
      ) async {
    CollectionReference reviewsRef = FirebaseFirestore.instance.collection('reviews');
    DocumentReference docRef = await reviewsRef.add({
      'id': id,
      'name': name,
      'user': user,
      'user_img': userImg,
      'content': content,
      'idLocation': idLocation,
      'score': score,
      'createdAt': DateTime.now().toUtc().toString(),
      'updatedAt': DateTime.now().toUtc().toString(),
    });
    return docRef.id;
  }
}

  // void reloadReviews(String locationID) async {
  //   ReviewsServices rs = ReviewsServices();
  //   QuerySnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('reviews')
  //       .where('idLocation', isEqualTo: locationID)
  //       .get();
  // }

