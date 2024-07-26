import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'email.dart'; // Import file chứa Email class

class InboxDetails extends StatefulWidget {
  final Email email;
  final String collection;
  InboxDetails({required this.email,required this.collection});

  @override
  State<InboxDetails> createState() => _InboxDetailsState();
}

class _InboxDetailsState extends State<InboxDetails> {
  @override
  Widget build(BuildContext context) {
    var sz = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
              SizedBox(width: sz.width / 50),
              IconButton(icon: Icon(Icons.warning), onPressed: () {}),
              SizedBox(width: sz.width / 50),
              IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteCurrentEmail(context)),
            ],
          ),
          Padding(
            padding:  EdgeInsets.only(left: sz.width / 15),
            child: Text(
              'Subject: ${widget.email.title}',
              style: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ),
          
          SizedBox(height: 8),
          Padding(
            padding:  EdgeInsets.only(top:sz.width / 50, left:sz.width / 50, right:sz.width / 50),
            child: Row(
              children: [
                Text(
                  'From: ${widget.email.contact}',
                  style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                 Expanded(
                   child: Text(
                    ' ${widget.email.received}',
                    style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.end,
                  ),
                 ),
                
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.all(sz.width / 50),
            child: Text(
              widget.email.message,
              style: TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.normal, fontSize: 16, color: Colors.black),
            ),
          ),
          SizedBox(height: 16),
         
          SizedBox(height: 16),
          
        ],
      ),
    );
  }
  Future<void> _deleteCurrentEmail(BuildContext context) async {
  print('Starting delete process');
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String userEmail = user.email!;
    String docId = widget.email.docId;
    String collection = widget.collection;

    print('User Email: $userEmail');
    print('Document ID: $docId');
    print('Collection: $collection');

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('account')
          .where('email', isEqualTo: userEmail)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot accountDoc = querySnapshot.docs.first;
        String accountDocId = accountDoc.id;
        
        // Lấy tài liệu hiện tại từ collection
        DocumentReference currentDocRef = FirebaseFirestore.instance
            .collection('account')
            .doc(accountDocId)
            .collection(collection)
            .doc(docId);
        
        DocumentSnapshot currentDocSnapshot = await currentDocRef.get();
        
        if (currentDocSnapshot.exists) {
          // Cast data to Map<String, dynamic>
          Map<String, dynamic> data = currentDocSnapshot.data() as Map<String, dynamic>;
          
          // Di chuyển tài liệu đến collection 'trash'
          await FirebaseFirestore.instance
              .collection('account')
              .doc(accountDocId)
              .collection('trash')
              .doc(docId)
              .set(data);
          
          // Xóa tài liệu từ collection hiện tại
          await currentDocRef.delete();
          
          print('Email successfully moved to trash and deleted from current collection');
          Navigator.pop(context);
        } else {
          print('Document does not exist');
        }
      } else {
        print('No matching user document found');
      }
    } catch (e) {
      print('Error deleting email: $e');
    }
  } else {
    print('No user is currently signed in');
  }
}



}



