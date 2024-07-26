import 'package:email_application/login/userController.dart';
import 'package:email_application/home.dart';
import 'package:email_application/login/signUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController  = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Color.fromRGBO(112, 179, 255, 0.612),
          ),
          Positioned(
            top: screenSize.height / 22.7,
            left: screenSize.width / 10,
            child: Container(
              width: screenSize.height / 4.54,
              height: screenSize.height / 4.54,
              decoration: BoxDecoration(
                color: Color.fromRGBO(38, 83, 136, 1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: screenSize.height / 22.7,
            right: screenSize.width / 10,
            child: Container(
              width: screenSize.height / 4.54,
              height: screenSize.height / 4.54,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: screenSize.height / 1.362,
              width: screenSize.width * 0.7,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Add Welcome Text here
                          Text(
                            'WELCOME\nBACK!',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: screenSize.height / 20),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              filled: true,
                              fillColor: Colors.grey[200],
                              labelStyle: TextStyle(fontWeight: FontWeight.w500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: "Password",
                              filled: true,
                              fillColor: Colors.grey[200],
                              labelStyle: TextStyle(fontWeight: FontWeight.w500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(
                                  _obscureText ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Don\'t have an account?'),
                              TextButton(
                            onPressed: () {
                              // Handle Sign Up navigation here
                              print("Navigate to Sign Up Screen");
                              Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => SignUpScreen(),
                                    ),
                                  );
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                            ],
                          ),
                          SizedBox(height: screenSize.height / 30),
                          ElevatedButton.icon(
                            onPressed: () async {
                              String? errorMessage = await UserController.loginWithFirebaseAuth(
                                emailController.text.toString(),
                                passwordController.text.toString(),
                              );

                              if (errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMessage)),
                                );
                              } else {
                                if (mounted) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => HomePage(),
                                    ),
                                  );
                                }
                              }
                            },
                            label: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),

                          SizedBox(height: 10),
                          // Add Sign Up Button here
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: Image.asset(
                        'assets/login.png', // Path to your image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

