import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/config/app_colors.dart';
import 'package:flutter_app/src/store/model.dart';
import 'package:flutter_app/src/util/route_utils.dart';
import 'package:flutter_app/ui/other/my_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _accountControl = TextEditingController();
  final TextEditingController _passwordControl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _accountFocus = FocusNode();
  bool passwordShow = false;
  String _accountErrorMessage = '';
  String _passwordErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _accountControl.text = Model.instance.getAccount();
    _passwordControl.text = Model.instance.getPassword();
  }

  void _loginPress(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      Model.instance.setAccount(_accountControl.text.toString());
      Model.instance.setPassword(_passwordControl.text.toString());
      await Model.instance.saveUserData();
      MyToast.show(R.current.loginSave);
      //Get.back<bool>(result: true);
      RouteUtils.toMainScreen();
    }
  }

  String? _validatorAccount(String value) {
    if (value.isNotEmpty) {
      _accountErrorMessage = '';
    } else {
      setState(() {
        _accountErrorMessage = R.current.accountNull;
      });
    }
    return _accountErrorMessage.isNotEmpty ? _accountErrorMessage : null;
  }

  String? _validatorPassword(String value) {
    if (value.isNotEmpty) {
      _passwordErrorMessage = '';
    } else {
      setState(() {
        _passwordErrorMessage = R.current.passwordNull;
      });
    }
    return _passwordErrorMessage.isNotEmpty ? _passwordErrorMessage : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTopDecoration(),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Material(
                      elevation: 2,
                      borderRadius: const BorderRadius.all(Radius.circular(32)),
                      child: TextFormField(
                        controller: _accountControl,
                        cursorColor: Colors.blue[800],
                        textInputAction: TextInputAction.done,
                        focusNode: _accountFocus,
                        onEditingComplete: () {
                          _accountFocus.unfocus();
                          FocusScope.of(context).requestFocus(_passwordFocus);
                        },
                        validator: (value) => _validatorAccount(value!),
                        decoration: InputDecoration(
                          hintText: R.current.account,
                          errorStyle: const TextStyle(
                            height: 0,
                            fontSize: 0,
                          ),
                          prefixIcon: const Icon(
                            Icons.account_circle,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    if (_accountErrorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          _accountErrorMessage,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    Material(
                      elevation: 2,
                      borderRadius: const BorderRadius.all(Radius.circular(32)),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _passwordControl,
                              cursorColor: Colors.blue[800],
                              obscureText: !passwordShow,
                              focusNode: _passwordFocus,
                              onEditingComplete: () {
                                _passwordFocus.unfocus();
                              },
                              validator: (value) => _validatorPassword(value!),
                              decoration: InputDecoration(
                                hintText: R.current.password,
                                errorStyle: const TextStyle(
                                  height: 0,
                                  fontSize: 0,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 13,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: (!passwordShow)
                                ? const Icon(EvaIcons.eyeOffOutline)
                                : const Icon(EvaIcons.eyeOutline),
                            onPressed: () {
                              setState(() {
                                passwordShow = !passwordShow;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    if (_passwordErrorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          _passwordErrorMessage,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 25,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                        onPressed: () => _loginPress(context),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.1,
                            right: MediaQuery.of(context).size.width * 0.1,
                          ),
                          child: Text(
                            R.current.login,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDecoration() {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: WaveClipper1(),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.lightBlue,
                ],
              ),
            ),
          ),
        ),
        ClipPath(
          clipper: WaveClipper2(),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x442196f3),
                  Color(0x4403a9f4),
                ],
              ),
            ),
            child: Column(),
          ),
        ),
        ClipPath(
          clipper: WaveClipper3(),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0x222196f3), Color(0x2203a9f4)]),
            ),
            child: Column(),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.36,
          alignment: Alignment.center,
          child: const Icon(
            Icons.account_circle,
            color: Colors.white,
            size: 120,
          ),
        ),
      ],
    );
  }
}

class WaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 29 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 60);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 15 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 40);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper3 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * .7, size.height - 40);
    var firstControlPoint = Offset(size.width * .25, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 45);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
