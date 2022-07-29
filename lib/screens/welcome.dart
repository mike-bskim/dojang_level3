import 'package:flutter/material.dart';

import '../controller/auth_controller.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(fontSize: 20);
    SizedBox sizedBox = const SizedBox(height: 8);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome', style: textStyle),
              sizedBox,
              // 3. 이메일 주소 화면에 표시
              Text(AuthController.instance.user.value!.email.toString(), style: textStyle),
              sizedBox,
              Text(AuthController.instance.user.value!.uid.toString(), style: textStyle),
              sizedBox,
              IconButton(
                onPressed: () {
                  AuthController.instance.logout();
                },
                icon: const Icon(Icons.login_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
