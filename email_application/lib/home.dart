import 'package:email_application/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sidebarx/sidebarx.dart';
import 'sideBarX.dart';
import 'package:google_fonts/google_fonts.dart';
import 'email.dart';
import 'inboxDetails.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // Cập nhật trạng thái isSelected thành false cho tất cả emails trong các collection
    _updateAllEmailsSelection();
  }

  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  List<Email> emails = [];
  bool _isMinimized = false;
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    var sz = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        backgroundColor: canvasColor,
        title: Text(_getTitleByIndex(_controller.selectedIndex),
            style: TextStyle(color: white)),
        actions: [
          _controller.selectedIndex == 5
              ? IconButton(
                  icon: Icon(Icons.delete, color: white),
                  onPressed: _deleteForeverEmails)
              : IconButton(
                  icon: Icon(Icons.delete, color: white),
                  onPressed: () => _deleteSelectedEmails(
                      _getCollectionByIndex(_controller.selectedIndex))),
          IconButton(
              icon: Icon(Icons.refresh, color: white), onPressed: _refreshApp),
          IconButton(icon: Icon(Icons.report, color: white), onPressed: () {}),
          IconButton(
              icon: Icon(Icons.more_vert, color: white), onPressed: () {}),
          IconButton(
              icon: Icon(Icons.logout, color: white), onPressed: _logOut),
        ],
      ),
      body: Row(
        children: [
          ExampleSidebarX(
            controller: _controller,
            onSelectIndex: _setSelectedIndex,
            onComposeEmail: _composeEmail,
          ),
          Expanded(
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                child: _getContentByIndex(_controller.selectedIndex, sz)),
          ),
        ],
      ),
    );
  }

  void _composeEmail() {
    if (_overlayEntry != null) {
      return;
    }

    final TextEditingController recipientController = TextEditingController();
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    var sz = MediaQuery.of(context).size;
    OverlayState overlayState = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: sz.width / 2.5,
              height: _isMinimized ? 40 : sz.height / 1.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Dialog(
                insetPadding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      height: 40,
                      color: Colors.grey[200],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Compose Email',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                icon: _isMinimized
                                    ? Icon(Icons.maximize)
                                    : Icon(Icons.minimize),
                                onPressed: () {
                                  setState(() {
                                    _isMinimized = !_isMinimized;
                                    _overlayEntry!.markNeedsBuild();
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.crop_square),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  _overlayEntry!.remove();
                                  _overlayEntry = null;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!_isMinimized)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: recipientController,
                                decoration: InputDecoration(
                                  labelText: 'Người nhận',
                                  border: InputBorder.none,
                                ),
                              ),
                              Divider(),
                              TextField(
                                controller: subjectController,
                                decoration: InputDecoration(
                                  labelText: 'Tiêu đề',
                                  border: InputBorder.none,
                                ),
                              ),
                              Divider(),
                              Expanded(
                                child: TextField(
                                  controller: messageController,
                                  expands: true,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final recipient = recipientController.text;
                                  final subject = subjectController.text;
                                  final message = messageController.text;

                                  if (recipient.isNotEmpty &&
                                      subject.isNotEmpty &&
                                      message.isNotEmpty) {
                                    await _sendEmail(
                                        recipient, subject, message);

                                    // Xóa overlay sau khi gửi email
                                    _overlayEntry!.remove();
                                    _overlayEntry = null;
                                  }
                                },
                                child: Text('Send'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(_overlayEntry!);
  }

  Widget _getContentByIndex(int index, Size sz) {
    switch (index) {
      case 0:
        return _fetchContent(index, sz, _streamEmails);
      case 1:
        return _fetchContent(index, sz, _streamSent);
      case 2:
        return _fetchContent(index, sz, _streamNote);
      case 3:
        return _fetchContent(index, sz, _streamEmails);
      case 4:
        return _fetchContent(index, sz, _streamEmails);
      case 5:
        return _fetchContent(index, sz, _streamTrash);
      default:
        return _fetchContent(index, sz, _streamEmails);
    }
  }

  Widget _fetchContent(int indexx, Size sz, Stream<List<Email>> fetchEmail()) {
    return StreamBuilder<List<Email>>(
      stream: fetchEmail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No emails found.'));
        }
        emails = snapshot.data!;
        return ListView.builder(
          itemCount: emails.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: index == 0 ? Radius.circular(20) : Radius.zero,
                ),
                color: emails[index].isSelected
                    ? const Color.fromARGB(255, 192, 191, 191)
                    : Colors.white,
              ),
              child: ListTile(
                leading: SizedBox(
                  width: sz.width / 5.5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: emails[index].isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            emails[index].isSelected = value ?? false;

                            print(emails[index].isSelected);
                            switch (indexx) {
                              case 0:
                                _updateField(emails[index].docId, 'inbox',
                                    'isSelected', emails[index].isSelected);
                              case 1:
                                _updateField(emails[index].docId, 'sent',
                                    'isSelected', emails[index].isSelected);
                              case 2:
                                _updateField(emails[index].docId, 'inbox',
                                    'isSelected', emails[index].isSelected);
                              case 5:
                                _updateField(emails[index].docId, 'trash',
                                    'isSelected', emails[index].isSelected);
                            }
                          });
                        },
                        checkColor: Colors.black,
                        activeColor: Colors.grey,
                      ),
                      IconButton(
                        icon: Icon(
                          emails[index].isNoted
                              ? Icons.star
                              : Icons.star_border,
                          color: emails[index].isNoted ? Colors.yellow : null,
                        ),
                        onPressed: () async {
                          setState(() {
                            emails[index].isNoted = !emails[index].isNoted;
                          });
                          switch (indexx) {
                            case 0:
                              _updateField(emails[index].docId, 'inbox',
                                  'isNoted', emails[index].isNoted);
                            case 1:
                              _updateField(emails[index].docId, 'sent',
                                  'isNoted', emails[index].isNoted);
                            case 2:
                              _updateField(emails[index].docId, 'inbox',
                                  'isNoted', emails[index].isNoted);
                            case 5:
                              _updateField(emails[index].docId, 'trash',
                                  'isNoted', emails[index].isNoted);
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          emails[index].contact,
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(
                  emails[index].title,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  emails[index].message,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                  ),
                ),
                trailing: Text(emails[index].received),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InboxDetails(email: emails[index], collection: _getCollectionByIndex(indexx),),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _sendEmail(
      String recipient, String subject, String message) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('account')
          .where('email', isEqualTo: recipient)
          .get();
      String formattedDate = DateFormat('dd/MM/yy').format(DateTime.now());
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot accountDoc = querySnapshot.docs.first;

        await FirebaseFirestore.instance
            .collection('account')
            .doc(accountDoc.id)
            .collection('inbox')
            .add({
          'contact': userEmail,
          'title': subject,
          'message': message,
          'received': formattedDate,
          'isSelected': false,
          'isNoted': false,
        });

        print("đã gủi");
      }
      final querySnapshot2 = await FirebaseFirestore.instance
          .collection('account')
          .where('email', isEqualTo: userEmail)
          .get();
      if (querySnapshot2.docs.isNotEmpty) {
        DocumentSnapshot accountDoc = querySnapshot2.docs.first;

        await FirebaseFirestore.instance
            .collection('account')
            .doc(accountDoc.id)
            .collection('sent')
            .add({
          'contact': recipient,
          'title': subject,
          'message': message,
          'received': formattedDate,
          'isSelected': false,
          'isNoted': false,
        });
        print("đã gủi 2");
      }
    }
  }

  Stream<List<Email>> _streamEmails() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      return FirebaseFirestore.instance
          .collection('account')
          .where('email', isEqualTo: userEmail)
          .snapshots()
          .switchMap((querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          return Stream.value(<Email>[]);
        } else {
          DocumentSnapshot accountDoc = querySnapshot.docs.first;
          return FirebaseFirestore.instance
              .collection('account')
              .doc(accountDoc.id)
              .collection('inbox')
              .snapshots()
              .map((inboxSnapshot) {
            return inboxSnapshot.docs.map((doc) {
              return Email(
                docId: doc.id,
                contact: doc['contact'],
                title: doc['title'],
                message: doc['message'],
                received: doc['received'],
                isSelected: doc['isSelected'],
                isNoted: doc['isNoted'],
              );
            }).toList();
          });
        }
      });
    }
    return Stream.value(<Email>[]);
  }

  Stream<List<Email>> _streamNote() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      return FirebaseFirestore.instance
          .collection('account')
          .where('email', isEqualTo: userEmail)
          .snapshots()
          .switchMap((querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          return Stream.value(<Email>[]);
        } else {
          DocumentSnapshot accountDoc = querySnapshot.docs.first;
          return FirebaseFirestore.instance
              .collection('account')
              .doc(accountDoc.id)
              .collection('inbox')
              .where('isNoted', isEqualTo: true)
              .snapshots()
              .map((inboxSnapshot) {
            return inboxSnapshot.docs.map((doc) {
              return Email(
                docId: doc.id,
                contact: doc['contact'],
                title: doc['title'],
                message: doc['message'],
                received: doc['received'],
                isSelected: doc['isSelected'],
                isNoted: doc['isNoted'],
              );
            }).toList();
          });
        }
      });
    }
    return Stream.value(<Email>[]);
  }

  Stream<List<Email>> _streamSent() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      return FirebaseFirestore.instance
          .collection('account')
          .where('email', isEqualTo: userEmail)
          .snapshots()
          .switchMap((querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          return Stream.value(<Email>[]);
        } else {
          DocumentSnapshot accountDoc = querySnapshot.docs.first;
          return FirebaseFirestore.instance
              .collection('account')
              .doc(accountDoc.id)
              .collection('sent')
              .snapshots()
              .map((inboxSnapshot) {
            return inboxSnapshot.docs.map((doc) {
              return Email(
                docId: doc.id,
                contact: doc['contact'],
                title: doc['title'],
                message: doc['message'],
                received: doc['received'],
                isSelected: doc['isSelected'],
                isNoted: doc['isNoted'],
              );
            }).toList();
          });
        }
      });
    }
    return Stream.value(<Email>[]);
  }

  Stream<List<Email>> _streamTrash() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      return FirebaseFirestore.instance
          .collection('account')
          .where('email', isEqualTo: userEmail)
          .snapshots()
          .switchMap((querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          return Stream.value(<Email>[]);
        } else {
          DocumentSnapshot accountDoc = querySnapshot.docs.first;
          return FirebaseFirestore.instance
              .collection('account')
              .doc(accountDoc.id)
              .collection('trash')
              .snapshots()
              .map((inboxSnapshot) {
            return inboxSnapshot.docs.map((doc) {
              return Email(
                docId: doc.id,
                contact: doc['contact'],
                title: doc['title'],
                message: doc['message'],
                received: doc['received'],
                isSelected: doc['isSelected'],
                isNoted: doc['isNoted'],
              );
            }).toList();
          });
        }
      });
    }
    return Stream.value(<Email>[]);
  }

  Future<void> _updateField(
      String docId, String collection, String field, bool value) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('account')
          .where('email', isEqualTo: userEmail)
          .get();
      DocumentSnapshot accountDoc = querySnapshot.docs.first;
      FirebaseFirestore.instance
          .collection('account')
          .doc(accountDoc.id)
          .collection(collection)
          .doc(docId)
          .update({field: value});
    }
  }

  Future<void> _deleteSelectedEmails(String collection) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      print('selected');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('account')
          .where('email', isEqualTo: userEmail)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot accountDoc = querySnapshot.docs.first;

        // Lấy danh sách tài liệu được chọn từ collection
        final inboxQuery = await FirebaseFirestore.instance
            .collection('account')
            .doc(accountDoc.id)
            .collection(collection)
            .where('isSelected', isEqualTo: true)
            .get();

        // Di chuyển các tài liệu vào collection 'trash'
        for (var doc in inboxQuery.docs) {
          final docData = doc.data();
          await FirebaseFirestore.instance
              .collection('account')
              .doc(accountDoc.id)
              .collection('trash')
              .doc(doc.id)
              .set(docData);

          // Cập nhật field isSelected thành false
          await FirebaseFirestore.instance
              .collection('account')
              .doc(accountDoc.id)
              .collection(collection)
              .doc(doc.id)
              .update({'isSelected': false});

          // Xóa tài liệu từ collection
          await FirebaseFirestore.instance
              .collection('account')
              .doc(accountDoc.id)
              .collection(collection)
              .doc(doc.id)
              .delete();
        }
      }
    }
  }

  Future<void> _deleteForeverEmails() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('account')
          .where('email', isEqualTo: userEmail)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot accountDoc = querySnapshot.docs.first;

        // Lấy danh sách tài liệu được chọn từ collection 'trash'
        final trashQuery = await FirebaseFirestore.instance
            .collection('account')
            .doc(accountDoc.id)
            .collection('trash')
            .where('isSelected', isEqualTo: true)
            .get();

        // Xóa các tài liệu khỏi collection 'trash'
        for (var doc in trashQuery.docs) {
          await FirebaseFirestore.instance
              .collection('account')
              .doc(accountDoc.id)
              .collection('trash')
              .doc(doc.id)
              .delete();
        }
      }
    }
  }

  Future<void> _updateAllEmailsSelection() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('account')
          .where('email', isEqualTo: userEmail)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot accountDoc = querySnapshot.docs.first;

        // Danh sách các collection cần cập nhật
        List<String> collections = ['inbox', 'sent', 'note', 'trash'];

        // Lặp qua từng collection và cập nhật trạng thái isSelected thành false cho tất cả tài liệu
        for (String collection in collections) {
          final emailQuery = await FirebaseFirestore.instance
              .collection('account')
              .doc(accountDoc.id)
              .collection(collection)
              .get();

          for (var doc in emailQuery.docs) {
            await FirebaseFirestore.instance
                .collection('account')
                .doc(accountDoc.id)
                .collection(collection)
                .doc(doc.id)
                .update({'isSelected': false});
          }
        }
      }
    }
  }

  void _refreshApp() async {
    // Cập nhật trạng thái isSelected thành false cho tất cả email trong collection hiện tại
    await _updateAllEmailsSelection();
    setState(() {});
  }

  void _logOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _setSelectedIndex(int index) {
    setState(() {
      _controller.selectIndex(index);
    });
  }
}

String _getTitleByIndex(int index) {
  switch (index) {
    case 0:
      return 'Hộp thư đến';
    case 1:
      return 'Đã gửi';
    case 2:
      return 'Có gắn dấu sao';
    case 3:
      return 'Thư rác';
    case 4:
      return 'Spam/Ham';
    case 5:
      return 'Thùng rác';
    default:
      return 'Not found page';
  }
}

String _getCollectionByIndex(int index) {
  switch (index) {
    case 0:
      return 'inbox';
    case 1:
      return 'sent';
    case 2:
      return 'note';
    case 3:
      return 'Thư rác';
    case 4:
      return 'Spam/Ham';
    case 5:
      return 'trash';
    default:
      return 'Not found page';
  }
}
