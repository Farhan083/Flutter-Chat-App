import 'dart:io';

import 'package:chat_app_firebase/services/database_service.dart';
import 'package:chat_app_firebase/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class StorageService {
  final String? uid;

  StorageService({this.uid});

  Future<void> uploadFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxHeight: 512,
        maxWidth: 512);

    if (pickedFile != null) {
      // Get the file name and path
      // String fileName = pickedFile.path.split('/').last;
      // String filePath = pickedFile.path;

      // Reference to the storage location
      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${uid}.jpg');

      // upload the files
      await storageReference.putFile(File(pickedFile.path));

      // get the download url
      String downloadURL = await storageReference.getDownloadURL();

      // Update the profile picture URL in the database
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .updateProfilePicture(downloadURL);
    }
  }

  Future<void> uploadFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
      maxHeight: 512,
      maxWidth: 512,
    );

    if (pickedFile != null) {
      // Get the file name and path
      // String fileName = pickedFile.path.split('/').last;
      // String filePath = pickedFile.path;

      // Reference to the storage location
      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${uid}.jpg');

      // Upload the file
      await storageReference.putFile(File(pickedFile.path));

      // Get the download URL
      String downloadURL = await storageReference.getDownloadURL();

      // Update the profile picture URL in the database
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .updateProfilePicture(downloadURL);
    }
  }

  // delete profile photo
  Future<void> removeProfilePicture() async {
    // Reference to the profile picture file in the storage
    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('profile_pictures/${uid}.jpg');

    // Delete the profile picture file
    await storageReference.delete();
  }
}
