import 'dart:async';

import 'package:cianfafire/firestore_produtos/helpers/enum_order.dart';
import 'package:cianfafire/firestore_produtos/model/produto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ProdutoService {
  //agora tenho o id do usuário logado dentro da minha classe
  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  adicionarProduto({required String listinId, required Produto produto}) {
    // Salvar no Firestore
    firestore
        .collection(uid)
        .doc(listinId)
        .collection("produtos")
        .doc(produto.id)
        .set(produto.toMap());
  }

  Future<List<Produto>> lerProdutos(
      {required String listinId,
      required OrdemProduto ordem,
      required bool isDecrescente}) async {
    List<Produto> temp = [];
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore //mesma coisa que essa verificação if(snapshot == null)
            .collection(uid)
            .doc(listinId)
            .collection("produtos")
            // .where("isComprado", isEqualTo: isComprado)
            .orderBy(ordem.name,
                descending:
                    isDecrescente) //esse é o name dos enums , nome do valor que estamos armazenando no widget
            .get();

    for (var doc in snapshot.docs) {
      Produto produto = Produto.fromMap(doc.data());
      temp.add(produto);
    }

    return temp;
  }

  Future<void> alternarProduto(
      {required String listinId, required Produto produto}) async {
    return await firestore
        .collection(uid)
        .doc(listinId)
        .collection("produtos")
        .doc(produto.id)
        .update({"isComprado": produto.isComprado});
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      conectarStreamProdutos({
    required Function refresh,
    required String listinId,
    required OrdemProduto ordem,
    required bool isDecrescente,
  }) {
    return firestore
        .collection(uid)
        .doc(listinId)
        .collection("produtos")
        .orderBy(ordem.name, descending: isDecrescente)
        .snapshots()
        .listen(
      (snapshot) {
        refresh(snapshot: snapshot);
      },
    );
  }

  Future<void> removerProduto(
      {required String listinId, required Produto produto}) async {
    return firestore
        .collection(uid)
        .doc(listinId)
        .collection("produtos")
        .doc(produto.id)
        .delete();
  }
}
