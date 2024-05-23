import 'package:flutter/material.dart';

showSnackBar(
    {required BuildContext context,
    required String mensagem,
    bool isErro = true}) {
  //se a pessoa não passar nada, o isErro vai ser True
  SnackBar snackBar = SnackBar(
    content: Text(mensagem),
    backgroundColor: (isErro) ? Colors.red : Colors.green,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
