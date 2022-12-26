import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.fName, required this.fUid});
  final String fName;
  final String fUid;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _chatDb = FirebaseFirestore.instance.collection('chatroom');
  final _messageController = TextEditingController();
  var chatRoomId;

  @override
  void initState() {
    if (_auth.currentUser!.uid.toString()[0].codeUnits[0] >
        widget.fUid[0].codeUnits[0]) {
      chatRoomId = "${_auth.currentUser!.uid}_${widget.fUid}";
    } else {
      chatRoomId = "${widget.fUid}_${_auth.currentUser!.uid}";
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      appBar: AppBar(
        title: Text(widget.fName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _chatDb
                  .doc(chatRoomId)
                  .collection('chats')
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  print(snapshot.data!.docs.length);
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var msgBody = snapshot.data!.docs[index].data();
                        var userMsg = msgBody['sent'] == _auth.currentUser!.uid;
                        return Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: Row(
                            mainAxisAlignment: userMsg
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                constraints:
                                    BoxConstraints(maxWidth: w * 2 / 3),
                                decoration: BoxDecoration(
                                  borderRadius: userMsg
                                      ? BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                          bottomLeft: Radius.circular(8),
                                        )
                                      : BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                  color: userMsg
                                      ? Colors.pink.shade400
                                      : Colors.white,
                                ),
                                child: Text(msgBody['message']),
                              ),
                            ],
                          ),
                        );
                      });
                } else {
                  return Center(child: Text('Error'));
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.pink.shade100,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24)),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      await _chatDb.doc(chatRoomId).collection('chats').add({
                        'sent': _auth.currentUser!.uid,
                        'message': _messageController.text.trim(),
                        'time': DateTime.now(),
                      });
                      _messageController.clear();
                    },
                    icon: Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
