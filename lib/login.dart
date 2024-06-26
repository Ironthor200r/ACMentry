import 'package:analytics/home.dart';
import 'package:analytics/reg.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Log successful login event to Firebase Analytics
      _logLoginEvent(userCredential);

      // Add additional logic after successful login if needed

      // Navigate to the home page or any other page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  // Log successful login event with Firebase Analytics
  void _logLoginEvent(UserCredential userCredential) {
    _firebaseAnalytics.logEvent(
      name: 'login_successful',
      parameters: {
        'method': 'email-password',
        'user_id': userCredential.user?.uid ?? 'unknown',
      },
    );
    print('login_successful event logged');
  }

  // Log login button clicked event with Firebase Analytics
  void _logLoginButtonClickedEvent() {
    _firebaseAnalytics.logEvent(
      name: 'login_button_clicked',
      parameters: {
        'button_text': 'Sign Up',
        'screen_name': 'LoginPage',
      },
    );
    print('login_button_clicked event logged');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 221, 219, 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Pink paint dripping from the top
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              child: CustomPaint(
                painter: DrippingPaintPainter(),
                child: Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  left: 0,
                  right: 0,
                  child: Center(),
                ),
              ),
            ),
            // Black portion for the login
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Let's Sign You In",
                    style: TextStyle(
                      color: Color.fromRGBO(233, 87, 92, 1),
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Email TextField
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(150.0),
                    ),
                    child: TextField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.grey,
                        ),
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(150.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  // Password TextField
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(150.0),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.grey,
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(150.0),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        filled: true,
                        fillColor: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Take Me In Button with Gradient
                  ElevatedButton(
                    onPressed: () {
                      _logLoginButtonClickedEvent(); // Log the button click event
                      _login(); // Call the login method
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey; // Disabled color
                          }
                          return Color.fromRGBO(
                              235, 105, 144, 1); // Normal color
                        },
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 30.0,
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.0), // Add some spacing
                  // Want to make a new account? Sign up Button
                  TextButton(
                    onPressed: () {
                      // Navigate to the registration page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegistrationPage()),
                      );
                    },
                    child: Text(
                      "Want to make a new account? Sign up",
                      style: TextStyle(color: Color.fromRGBO(239, 122, 125, 1)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrippingPaintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.fromRGBO(235, 105, 144, 1),
          Color.fromRGBO(230, 166, 185, 1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(
        Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)),
      )
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
          size.width / 4, size.height - 150, size.width / 2, size.height + 150)
      ..quadraticBezierTo(
          4 * size.width / 6, 2 * size.height / 2, size.width, size.height + 50)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
