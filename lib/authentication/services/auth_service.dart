import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> entrarUsuario(
      {required String email, required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: senha);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-credential":
          return "O e-mail não está cadastrado/ou senha incorreta.";
        case "wrong-password":
          return "Senha incorreta.";
      }
      return e.code;
    }

    return null;
  }

  Future<String?> cadastrarUsuario({
    //se houver um erro, virá em string, se der certo vai vir em nulo
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      await userCredential.user!.updateDisplayName(nome);
      print("funcionou! chegamos ate essa linha");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "O e-mail já está em uso.";
      }
      return e.code; //caso não seja um dos casos que eu conheça
    }
    return null; //caso não caia em nenhuma excesão.
  }

  Future<String?> redefinicaoSenha({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }

  Future<String?> deslogar() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }

  Future<String?> removerConta({required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: _firebaseAuth.currentUser!.email!,
        password: senha,
      );
      await _firebaseAuth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }
}
