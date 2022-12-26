import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RequestsScreen extends StatefulWidget {
  RequestsScreen({Key? key}) : super(key: key);

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final _auth = FirebaseAuth.instance;
  final _usersDb = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
      ),
      body: StreamBuilder(
        stream: _usersDb
            .where('email', isEqualTo: _auth.currentUser!.email)
            .get()
            .asStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            var userData = snapshot.data!.docs[0].data();
            return ListView.builder(
                itemCount: userData['requests'].length,
                itemBuilder: (context, index) {
                  var friendUN = userData['requests'][index].toString();
                  var friendUid = friendUN.substring(0, friendUN.indexOf("_"));
                  var friendName =
                      friendUN.substring(friendUN.indexOf('_') + 1);
                  return ListTile(
                    leading: CircleAvatar(child: Text(friendName[0])),
                    title: Text(friendName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await _usersDb.doc(_auth.currentUser!.uid).update({
                              'friends': FieldValue.arrayUnion(
                                  ["${friendUid}_$friendName"]),
                              'requests': FieldValue.arrayRemove(
                                  ["${friendUid}_$friendName"]),
                            });
                            await _usersDb.doc(friendUid).update({
                              'friends': FieldValue.arrayUnion([
                                "${userData['uid']}_${userData['full name']}"
                              ]),
                            });
                          },
                          icon: FaIcon(FontAwesomeIcons.check),
                        ),
                        IconButton(
                          onPressed: () async {
                            await _usersDb.doc(_auth.currentUser!.uid).update({
                              'requests': FieldValue.arrayRemove(
                                ["${friendUid}_$friendName"],
                              ),
                            });
                          },
                          icon: FaIcon(FontAwesomeIcons.xmark),
                        ),
                      ],
                    ),
                  );
                });
          } else {
            return Text('error');
          }
        },
      ),
    );
  }
}
