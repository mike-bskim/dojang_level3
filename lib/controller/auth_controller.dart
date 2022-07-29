import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/login.dart';
import '../screens/welcome.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  // 아래 3줄은 Getx login 할때 핵심 기본 코드임
  // Get.find() 대신 접근 가능한 방법
  static AuthController instance = Get.find();
  // 선언가능한 다른 방식, final _user = Rxn<User?>();, Rxn<User?> get user => _user;
  late Rx<User?> _user;
  FirebaseAuth authentication = FirebaseAuth.instance;

  // loading indicator
  RxBool isLoading = false.obs;

  Rx<User?> get user => _user;

  @override
  void onReady() {
    // getx 초기화 이후 호출됨,
    // 네트워크를 통해서 전달되는 다양한 정보를 가지고 기능 구현하기 위해서 초기화를 시켜줄때 좋음,
    super.onReady();
    debugPrint('AuthController >> onReady');
    _user = Rx<User?>(authentication.currentUser);
    // 스트림 처리
    _user.bindStream(authentication.userChanges());
    // ever(listener, callback)
    ever(_user, _moveToPage);
  }

  @override
  void onInit() {
    // getx 인스턴스 생성전에 호출됨, 인스턴스와 관련된 것을 호출시 주의할것,
    debugPrint('AuthController >> onInit');
    once(isLoading, (_) => debugPrint("isLoading 최초 호출($isLoading)"));
    ever(isLoading, (_) => debugPrint("isLoading 매번 호출($isLoading)"));
    super.onInit();
  }

  _moveToPage(User? user) {
    if (user == null) {
      Get.offAll(() => const LoginPage());
    } else {
      // debugPrint(user.toString());
      // debugPrint(user.email.toString());
      Get.offAll(() => const WelcomePage());
    }
    isLoading(false);
  }

  void register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await authentication
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => debugPrint('생성완료:[${value.user}]'));
      // 4. sign up 할때 사용자 이름도 입력받고 그걸 Storage 에 user 컬렉션 아래에 추가할것.
      var doc = FirebaseFirestore.instance.collection('users').doc(user.value!.uid);
      await doc.set({
        'id': doc.id,
        'datetime': DateTime.now().toString(),
        'email': email,
        'name': name,
      });
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error message",
        "User message",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        titleText: const Text(
          "Registration is failed",
          style: TextStyle(color: Colors.white),
        ),
        messageText: Text(
          e.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
  }

  // 1. 로그인 구현
  void login({required String email, required String passWord}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: passWord);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        debugPrint(e.code.toString());
        myDialog(msg: "Wrong email or Wrong password");
      }
      isLoading.value = false;
    }
  }

  void myDialog({required String msg}) {
    Get.defaultDialog(
      title: "Notice",
      middleText: msg,
      backgroundColor: Colors.blue,
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white),
    );
  }

  void logout() {
    authentication.signOut();
  }
}
