import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  entrarUsuario({
    required String email,
    required String senha,
  }) {
    print("Metodo entrar usuario");
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
    }
  }
}
