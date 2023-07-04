import 'package:chat_app_firebase/pages/auth/login_page.dart';
import 'package:chat_app_firebase/pages/home_page.dart';
import 'package:chat_app_firebase/services/auth_services.dart';
import 'package:chat_app_firebase/services/database_service.dart';
import 'package:chat_app_firebase/services/storage_service.dart';
import 'package:chat_app_firebase/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  String userName;
  String email;

  ProfilePage({Key? key, required this.email, required this.userName})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  String profilePic = "";
  bool isUploading = false;
  bool isRemoving = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gettingProfilePic();
  }

  gettingProfilePic() async {
    String downloadUrl =
        await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .getProfilePicture();
    if (downloadUrl.isNotEmpty) {
      setState(() {
        profilePic = downloadUrl;
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
          child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 50),
        children: <Widget>[
          profilePic != ""
              ? CircleAvatar(
                  radius: 75,
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(profilePic),
                  onBackgroundImageError: (exception, stackTrace) {
                    Icon(
                      Icons.account_circle,
                      size: 150,
                      color: Colors.grey[700],
                    );
                  },
                )
              : Icon(
                  Icons.account_circle,
                  size: 150,
                  color: Colors.grey[700],
                ),
          const SizedBox(
            height: 15,
          ),
          Text(
            widget.userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          ),
          const Divider(
            height: 2,
          ),
          ListTile(
            onTap: () {
              nextScreen(context, const HomePage());
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.group),
            title: const Text(
              "Groups",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () {},
            selected: true,
            selectedColor: Theme.of(context).primaryColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.group),
            title: const Text(
              "Profile",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () async {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await authService.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (route) => false);
                          },
                          icon: const Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  });
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.exit_to_app),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      )),
      body: isUploading || isRemoving
          ? Center(child: CircularProgressIndicator())
          : Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    children: <Widget>[
                      profilePic != ""
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(profilePic),
                              radius: 130,
                            )
                          : Icon(
                              Icons.account_circle,
                              size: 200,
                              color: Colors.grey[700],
                            ),
                      Positioned(
                        bottom: 15,
                        right: 30,
                        child: GestureDetector(
                          onTap: profileChangePopUp,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Full Name", style: TextStyle(fontSize: 17)),
                      Text(widget.userName,
                          style: const TextStyle(fontSize: 17)),
                    ],
                  ),
                  const Divider(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Email", style: TextStyle(fontSize: 17)),
                      Text(widget.email, style: const TextStyle(fontSize: 17)),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  profileChangePopUp() {
    showDialog(
      // if there is uploading then cannot click anywhere
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Profile Photo",
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                height: 2,
                thickness: 2,
              ),
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                title: const Text("Upload from camera"),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    isUploading = true;
                  });
                  // Handle gallery upload
                  StorageService(uid: FirebaseAuth.instance.currentUser!.uid)
                      .uploadFromCamera()
                      .then((value) {
                    gettingProfilePic();
                  });
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                title: const Text("Upload from gallery"),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    isUploading = true;
                  });
                  // Handle gallery upload
                  StorageService(uid: FirebaseAuth.instance.currentUser!.uid)
                      .uploadFromGallery()
                      .then((value) {
                    gettingProfilePic();
                  });
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                title: const Text("Remove photo"),
                onTap: () {
                  // Call the function to remove profile photo
                  setState(() {
                    isRemoving = true;
                  });
                  removeProfilePhoto();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to remove the profile photo
  removeProfilePhoto() async {
    // Remove the profile picture URL from the database
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .removeProfilePicture();

    // Delete the profile picture from the storage
    await StorageService(uid: FirebaseAuth.instance.currentUser!.uid)
        .removeProfilePicture();

    setState(() {
      profilePic = "";
      isRemoving = false;
    });
  }
}
