import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserController {
  static Future<String?> loginWithFirebaseAuth(String email, String password) async {
  try {
    // Đăng nhập với email và mật khẩu
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Trả về null nếu đăng nhập thành công (no error message)
    return null;
  } on FirebaseAuthException catch (e) {
    // Xử lý các lỗi cụ thể từ Firebase Authentication và trả về thông báo lỗi
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'The user has been disabled.';
      default:
        return 'An undefined Error happened: ${e.code}';
    }
  } catch (e) {
    // Xử lý các lỗi khác và trả về thông báo lỗi
    return 'Error: ${e.toString()}';
  }
}


  static Future<User?> registerWithFirebaseAuth(
      String email, String password,BuildContext context) async {
    try {
      // Tạo tài khoản mới với email và mật khẩu
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Trả về thông tin người dùng nếu đăng ký thành công
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Hiển thị Snackbar với các lỗi cụ thể từ Firebase Authentication
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The password provided is too weak.'),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The account already exists for that email.'),
          ),
        );
      }
    } catch (e) {
      // Xử lý các lỗi khác
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    // Trả về null nếu đăng ký không thành công
    return null;
  }
}