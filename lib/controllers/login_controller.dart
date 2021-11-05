import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class LoginController extends GetxController {
  final _auth = FirebaseAuth.instance;
  RxBool estaLogado = false.obs;
  RxString state = 'A LOGAR'.obs;
  RxString userLogged = ''.obs;

  String verificId = '';

  String? nameUserLogged = '';
  String photoUserLogged =
      'https://i.pinimg.com/originals/56/2e/fc/562efc6231a0b03e13ea715ae1ad9f1c.png';
  //'https://st2.depositphotos.com/3433891/6661/i/600/depositphotos_66613339-stock-photo-man-with-crossed-arms.jpg';

  //dados do amigo
  String friendSelected = '';
  String nameFriend = '';
  String playerId = '';
  String photoFriend = '';
  String statusFriend = '';

  @override
  void onInit() {
    _auth.setLanguageCode("pt-br");
    verificarLogado();
    super.onInit();
  }

  void verificarLogado() {
    User? user = _auth.currentUser;
    if (user != null) {
      estaLogado.value = true;
      userLogged.value = user.phoneNumber!;
      nameUserLogged = user.displayName;
    } else {
      estaLogado.value = false;
    }
  }

  Future verifyPhone(phoneNumber) async {
    //RecaptchaVerifier r = RecaptchaVerifier();

    userLogged.value = phoneNumber;
    //state.value = 'LOADING';
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        codeSent: (String verificationId, int? forceResendingToken) {
          verificId = verificationId;
          state.value = 'SUCCESSSMS';
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificId = verificationId;
          //state.value = 'ERRORSMS';
        },
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {
          //print(phoneAuthCredential);
          //state.value = 'SUCCESSSMS';
        },
        verificationFailed: (FirebaseAuthException error) {
          // ignore: avoid_print
          print(error);
          state.value = 'ERRORSMS';
        });
  }

  Future signInWithPhoneNumber(codeSMS) async {
    state.value = 'LOADING';
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificId,
        smsCode: codeSMS,
      );

      await _auth.signInWithCredential(credential);

      state.value = 'SUCCESS';
      estaLogado.value = true;
    } catch (e) {
      state.value = 'ERROR';
    }
  }

  Future saveDataFirestore(name, photoURL, recado) async {
    state.value = 'LOADING';
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userLogged.value)
        .set({
      'phone': userLogged.value,
      'name': name,
      'photo': photoURL,
      'phrase': recado,
      'status': 'Online',
      'playerId': await getPlayerId()
    }).catchError((e) {
      state.value = 'ERROR';
    }).then((value) {
      state.value = 'SUCCESS';
      _auth.currentUser!.updateDisplayName(name);
      nameUserLogged = name;
    });
  }

  Future<String?> getPlayerId() async {
    final status = await OneSignal.shared.getDeviceState();
    return status?.userId;
  }

  signOut() async {
    await _auth.signOut();
  }
}
