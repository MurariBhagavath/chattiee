import 'package:chattiee/screens/chat_screen.dart';
import 'package:chattiee/screens/requests_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _usersDb = FirebaseFirestore.instance.collection('users');
  final _friendController = TextEditingController();
  Future logout() async {
    await _auth.signOut();
  }

  Future getUserDoc() async {
    return _usersDb.where('email', isEqualTo: _auth.currentUser!.email).get();
  }

  static var userDoc;
  @override
  void initState() {
    userDoc = getUserDoc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: CustomSearchDelegate());
              },
              icon: Icon(Icons.search)),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  CircleAvatar(radius: 40),
                  Text(_auth.currentUser!.email.toString()),
                ],
              ),
              decoration: BoxDecoration(color: Colors.pink),
            ),
            ListTile(title: Text('Account')),
            ListTile(
                title: Text('Requests'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RequestsScreen()));
                }),
            ListTile(title: Text('Logout'), onTap: logout),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: _usersDb
            .where('email', isEqualTo: _auth.currentUser!.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            var userData = snapshot.data!.docs[0].data();
            return RefreshIndicator(
              onRefresh: () async {},
              child: ListView.builder(
                itemCount: userData['friends'].length,
                itemBuilder: (BuildContext context, int index) {
                  var friendUN = userData['friends'][index].toString();
                  var friendUid = friendUN.substring(0, friendUN.indexOf("_"));
                  var friendName =
                      friendUN.substring(friendUN.indexOf("_") + 1);

                  return Container(
                    margin: EdgeInsets.fromLTRB(12, 12, 12, 3),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                    fName: friendName, fUid: friendUid)));
                      },
                      leading: CircleAvatar(
                        radius: 24,
                        child: Text(friendName[0]),
                      ),
                      title: Text(friendName),
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(child: Text('Error while loading!'));
          }
        },
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: query)
                .get()
                .asStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              } else if (snapshot.data!.docs.length == 0) {
                return Column(
                  children: [
                    Text('No results found'),
                  ],
                );
              } else {
                var results = snapshot.data!.docs[0].data();
                var curUser = FirebaseAuth.instance.currentUser;
                return ListView.builder(
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(results['full name']),
                      trailing: results['friends'].contains(
                                  "${FirebaseAuth.instance.currentUser!.uid}_${FirebaseAuth.instance.currentUser!.displayName}") ==
                              true
                          ? IconButton(
                              icon: FaIcon(FontAwesomeIcons.personCircleCheck),
                              onPressed: () {})
                          : IconButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(results['uid'])
                                    .update({
                                  'requests': FieldValue.arrayUnion([
                                    "${curUser!.uid}_${curUser.displayName}"
                                  ]),
                                });
                              },
                              icon: Icon(Icons.person_add)),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Center(child: Text('Search for user'))],
    );
  }
}
