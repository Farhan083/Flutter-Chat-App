import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  //reference for our collection
  // THIS IS BASICALLY THE PATH OF THE DATABSE IN THE FIRESTORE
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // saving the userdata
  // THIS IS THE DATABASE WHICH WE ARE CREATING IN THE FIRESTORE
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  //getting user data by searching the database
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
    // this snapshot would contain the user data of this email
  }

  //get user groups
  getUserGroups() async {
    // this return a stream
    return userCollection.doc(uid).snapshots();
  }

  // CREATING A GROUP
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupdocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    // after executing the above command a group id will be
    // generated which we will update below

    // update the members
    await groupdocumentReference.update({
      "members": FieldValue.arrayUnion(["${id}_$userName"]),
      "groupId": groupdocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupdocumentReference.id}_$groupName"]),
    });
  }

  // getting the chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  //get group admin
  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  //get group members
  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //search
  searchByName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  // function -> bool (to check user is present in the group
  // or not)

  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];

    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // very important function
  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupdocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove them or if not then re join

    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupdocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupdocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  //send message
  sendMessage(String groupId, Map<String, dynamic> chatMesasageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMesasageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMesasageData['message'],
      "recentMessageSender": chatMesasageData['sender'],
      "recentMessageTime": chatMesasageData['time'].toString(),
    });
  }

  // updating the profile picture of the user
  updateProfilePicture(String downloadURL) async {
    userCollection.doc(uid).update({
      "profilePic": downloadURL,
    });
  }

  // get user profile picture
  Future<String> getProfilePicture() async {
    DocumentSnapshot documentSnapshot = await userCollection.doc(uid).get();
    // return documentSnapshot.get('profilePic') as String;
    String profilePic = documentSnapshot['profilePic'];
    return profilePic;
  }

  //remove user profile picture
  // Remove profile picture URL from the user's data in the database
  Future removeProfilePicture() async {
    userCollection.doc(uid).update({
      "profilePic": "",
    });
  }
}
