import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/favourite.dart';

class FavouriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get favourites reference for the current user
  CollectionReference _getFavouritesRef() {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('favourites');
  }

  // Get all favorites for current user
  Future<List<Favourite>> getFavourites() async {
    try {
      if (currentUserId == null) {
        return [];
      }

      QuerySnapshot snapshot = await _getFavouritesRef().get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Include document ID as favouriteId if not present
        if (!data.containsKey('favouriteId')) {
          data['favouriteId'] = doc.id;
        }
        // Make sure userId is set
        if (!data.containsKey('userId')) {
          data['userId'] = currentUserId!;
        }
        return Favourite.fromJson(data);
      }).toList();
    } catch (e) {
      print("Error fetching favourites: $e");
      return [];
    }
  }

  // Check if a product is in favorites
  Future<bool> isFavourite(String productId) async {
    try {
      if (currentUserId == null) {
        return false;
      }

      QuerySnapshot docs = await _getFavouritesRef()
          .where("productId", isEqualTo: productId)
          .limit(1)
          .get();

      return docs.docs.isNotEmpty;
    } catch (e) {
      print("Error checking if product is favourite: $e");
      return false;
    }
  }

  // Toggle favorite status and return the new status
  Future<bool> toggleFavourite(
      String productId, BuildContext context, String productName) async {
    try {
      if (currentUserId == null) {
        // Show error if not logged in
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Vui lòng đăng nhập để thêm sản phẩm vào danh sách yêu thích'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }

      // Check current favorite status
      bool isCurrentlyFavourite = await isFavourite(productId);

      if (isCurrentlyFavourite) {
        // Remove from favorites
        await removeFromFavourite(productId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa $productName khỏi danh sách yêu thích'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return false; // Return new status (not favorited)
      } else {
        // Add to favorites
        await addToFavourite(productId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm $productName vào danh sách yêu thích'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return true; // Return new status (favorited)
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      print("Error toggling favourite status: $e");
      // Return current status if there was an error
      return await isFavourite(productId);
    }
  }

  // Add to favorites
  Future<bool> addToFavourite(String productId) async {
    try {
      if (currentUserId == null) {
        return false;
      }

      // Check if already in favorites to avoid duplicates
      QuerySnapshot existingDocs = await _getFavouritesRef()
          .where("productId", isEqualTo: productId)
          .limit(1)
          .get();

      // If already exists, don't add again
      if (existingDocs.docs.isNotEmpty) {
        return false;
      }

      // Generate a unique ID for the favorite
      DocumentReference docRef = _getFavouritesRef().doc();

      // Save just the essential information
      await docRef.set({
        "favouriteId": docRef.id,
        "productId": productId,
        "userId": currentUserId,
      });

      return true;
    } catch (e) {
      print("Error adding to favourites: $e");
      return false;
    }
  }

  // Remove from favorites
  Future<bool> removeFromFavourite(String productId) async {
    try {
      if (currentUserId == null) {
        return false;
      }

      // Find the favorite document with this productId
      QuerySnapshot docs = await _getFavouritesRef()
          .where("productId", isEqualTo: productId)
          .limit(1)
          .get();

      if (docs.docs.isEmpty) {
        return false;
      }

      // Delete the document
      await docs.docs.first.reference.delete();
      return true;
    } catch (e) {
      print("Error removing from favourites: $e");
      return false;
    }
  }
}
