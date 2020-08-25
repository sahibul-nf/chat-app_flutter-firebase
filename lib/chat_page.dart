import 'package:chat_app/signin_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _msgC = TextEditingController();
  final _msgNode = FocusNode();

  final DatabaseReference root = FirebaseDatabase.instance.reference();
  final User user = FirebaseAuth.instance.currentUser;
  final User sender = FirebaseAuth.instance.currentUser;

  List<Map<dynamic, dynamic>> messages = [];

  // Map<dynamic, dynamic> _lastMsg;

  bool _isSignOut = false;

  void dispose() {
    _msgC.dispose();
    _msgNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseReference chatReference =
        root.child('/chats/${user.uid}/chats').reference();

    return Scaffold(
      backgroundColor: Color(0xff4258f3),
      bottomNavigationBar: Container(
        height: 70,
        child: BottomAppBar(
          color: Color(0xff4258f3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                iconSize: 30,
                icon: Icon(
                  Icons.person_outline,
                  color: Color(0xffb7cdf5),
                ),
                onPressed: null,
              ),
              IconButton(
                iconSize: 30,
                icon: Icon(
                  Icons.home,
                  color: Color(0xffb7cdf5),
                ),
                onPressed: null,
              ),
              IconButton(
                iconSize: 30,
                icon: Icon(
                  Icons.chat_bubble,
                  color: Colors.white,
                ),
                onPressed: null,
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xff4258f3),
        elevation: 0,
        leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(
                Icons.phone,
                size: 20,
                color: Colors.white,
              ),
            ),
            onPressed: null),
        title: Text(user.email),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _onSignOut,
            icon: _isSignOut
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                : Icon(Icons.exit_to_app, color: Colors.white),
          )
          // FlatButton.icon(
          //   onPressed: _onSignOut,
          //   icon: _isSignOut
          //       ? CircularProgressIndicator(
          //           valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
          //       : Icon(Icons.exit_to_app, color: Colors.white),
          //   label: Text(
          //     'Keluar',
          //     style: TextStyle(color: Colors.white),
          //   ),
          // )
        ],
      ),
      body: SafeArea(
          child: Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: chatReference.onValue,
                builder: (contex, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.active) {
                    final Event event = snapshot.data;
                    final Map<dynamic, dynamic> collection =
                        event.snapshot.value as Map<dynamic, dynamic>;
                    // snapshot.data.snapshot.value;

                    if (collection != null) {
                      final List<dynamic> messages = collection
                          .map((key, item) {
                            final Map<dynamic, dynamic> modifiedItem = (item
                                as Map<dynamic, dynamic>)
                              ..addAll({'key': key});
                            return MapEntry(key, modifiedItem);
                          })
                          .values
                          .toList()
                            ..sort((prev, next) {
                              final prevTime = prev['timestamp'];
                              final nextTime = next['timestamp'];

                              return nextTime - prevTime;
                            });

                      return ListView.builder(
                        padding: EdgeInsets.all(16),
                        reverse: true,
                        itemBuilder: (BuildContext context, int index) {
                          final Map<dynamic, dynamic> msg = messages[index];
                          final String text = msg['text'];
                          final String from = msg['from'];

                          final DateTime time =
                              DateTime.fromMicrosecondsSinceEpoch(
                                  msg['timestamp']);
                          final bool isMe = from == user.uid;

                          return GestureDetector(
                            onTap: () {
                              if (isMe) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                          title: Text('Menu'),
                                          children: [
                                            SimpleDialogOption(
                                              child: Text('Edit'),
                                              onPressed: () {
                                                _onEdit(msg);
                                              },
                                            ),
                                            SimpleDialogOption(
                                                child: Text('Delete'),
                                                onPressed: () {
                                                  _onDelete(msg);
                                                }),
                                          ]);
                                    });
                              }
                            },
                            child: Padding(
                              padding: isMe
                                  ? const EdgeInsets.only(
                                      left: 110, top: 20, bottom: 4)
                                  : const EdgeInsets.only(right: 110, top: 16),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    // margin: isMe ? EdgeInsets.only(top: 20) : EdgeInsets.only(top: 16),
                                    decoration: BoxDecoration(
                                        color: isMe
                                            ? Color(0xffb7cdf5).withOpacity(0.3)
                                            : Color(0xff4258f3),
                                        borderRadius: isMe
                                            ? BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                bottomLeft: Radius.circular(20),
                                                topRight: Radius.circular(20))
                                            : BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                                topRight: Radius.circular(20))),
                                    child: Text(
                                      text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            isMe ? Colors.black : Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    time
                                        .toIso8601String()
                                        .substring(0, 16)
                                        .replaceAll('T', ', '),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black26,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: messages.length,
                      );
                    }
                  }

                  return SizedBox.shrink();
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Color(0xffb7cdf5).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _msgC,
                      focusNode: _msgNode,
                      cursorColor: Color(0xff4258f3),
                      style: TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Masukkan pesan',
                        hintStyle: TextStyle(color: Colors.black38),
                      ),
                    ),
                  )),
                  IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Color(0xff4258f3),
                      ),
                      onPressed: _onSend)
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  void _onDelete(Map<dynamic, dynamic> msg) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Message'),
            content: Text('You are sure ?'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);

                  Navigator.pop(context);

                  final String key = msg['key'];

                  final String receiver =
                      user.uid == 'lvXQfDWQhdS9PmVpcuzq6dsOGfE3'
                          ? 'oID9nLfwDHMALP5sR8QXBjUthlh1'
                          : 'lvXQfDWQhdS9PmVpcuzq6dsOGfE3';

                  FirebaseDatabase.instance.reference()
                    ..child('/chats/${user.uid}/chats/$key').remove()
                    ..child('/chats/$receiver/chats/$key').remove();
                },
                child: Text('Ya'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Tidak'),
              )
            ],
          );
        });

    // Navigator.pop(context);

    // final String receiver = user.uid == 'lvXQfDWQhdS9PmVpcuzq6dsOGfE3'
    //     ? 'oID9nLfwDHMALP5sR8QXBjUthlh1'
    //     : 'lvXQfDWQhdS9PmVpcuzq6dsOGfE3';

    // FirebaseDatabase.instance.reference()
    //   ..child('/chats/${user.uid}/chats/$key').remove()
    //   ..child('/chats/$receiver/chats/$key').remove();
  }

  void _onEdit(Map<dynamic, dynamic> msg) {
    final String text = msg['text'];

    // _lastMsg = msg;
    _msgC.text = text;
    _msgNode.requestFocus();
  }

  void _onSend() {
    final String msg = _msgC.text.trim();

    if (msg.isNotEmpty) {
      // send firebase

      // hardcode
      final String receiver = sender.uid == 'lvXQfDWQhdS9PmVpcuzq6dsOGfE3'
          ? 'oID9nLfwDHMALP5sR8QXBjUthlh1'
          : 'lvXQfDWQhdS9PmVpcuzq6dsOGfE3';

      final DatabaseReference chats =
          root.child('/chats/${sender.uid}/chats').reference();

      final String key = chats.push().key;

      root.update({
        // sender
        '/chats/${sender.uid}/chats/$key': {
          'text': msg,
          'timestamp': DateTime.now().microsecondsSinceEpoch,
          'from': sender.uid
        },
        '/chats/${sender.uid}/with': receiver,

        // receiver
        '/chats/$receiver/chats/$key': {
          'text': msg,
          'timestamp': DateTime.now().microsecondsSinceEpoch,
          'from': sender.uid
        },
        '/chats/$receiver/with': sender.uid,
      });

      _msgC.clear();
    }
  }

  void _onSignOut() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Keluar'),
            content: Text('You are sure ?'),
            actions: [
              FlatButton(
                textColor: Colors.grey,
                child: Text('Ya'),
                onPressed: () async {
                  setState(() {
                    _isSignOut = true;
                  });

                  try {
                    await FirebaseAuth.instance.signOut();

                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => SignIn()));
                  } catch (e) {
                    setState(() {
                      _isSignOut = false;
                    });

                    print('Failed to sign out');
                  }
                },
              ),
              FlatButton(
                child: Text('Tidak'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}
