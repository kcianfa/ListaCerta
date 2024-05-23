import 'dart:async';

import 'package:cianfafire/firestore_produtos/helpers/enum_order.dart';
import 'package:cianfafire/firestore_produtos/services/produto_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../firestore/models/listin.dart';
import '../model/produto.dart';
import 'widgets/list_tile_produto.dart';

class ProdutoScreen extends StatefulWidget {
  final Listin listin;
  const ProdutoScreen({super.key, required this.listin});

  @override
  State<ProdutoScreen> createState() => _ProdutoScreenState();
}

class _ProdutoScreenState extends State<ProdutoScreen> {
  List<Produto> listaProdutosPlanejados = [];

  List<Produto> listaProdutosPegos = [];

  ProdutoService produtoService = ProdutoService();

  OrdemProduto ordem = OrdemProduto.name;
  bool isDecrescente = false;

  //vai ser inicializado mas vai demorar um pouquinho, por isso é do tipo late
  late StreamSubscription listener;

  @override
  void initState() {
    //tratamento para quando a tela abre
    setupListeners();
    super.initState();
  }

  @override
  void dispose() {
    //isso será responsável por fechar a conexão e não ouvir mais em tempo real as alterações
    listener.cancel();
    // vai rodar quando a tela estiver sendo fechada
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listin.name),
        //actions controla tudo que está no canto inferior direito, são os três pontinhos de menu
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  child: Text("Ordenar por nome"),
                  value: OrdemProduto.name,
                ),
                const PopupMenuItem(
                  child: Text("Ordenar por quantidade"),
                  value: OrdemProduto.amount,
                ),
                const PopupMenuItem(
                  child: Text("Ordenar por preço"),
                  value: OrdemProduto.price,
                ),
              ];
            },
            onSelected: (value) {
              setState(() {
                if (ordem == value) {
                  isDecrescente = !isDecrescente;
                } else {
                  ordem = value;
                  isDecrescente = false;
                }
              });
              refresh();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return refresh();
        },
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    "R\$${calcularPrecoPegos().toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 42),
                  ),
                  const Text(
                    "total previsto para essa compra",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Planejados",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(listaProdutosPlanejados.length, (index) {
                Produto produto = listaProdutosPlanejados[index];
                return ListTileProduto(
                  produto: produto,
                  isComprado: false,
                  //aqui não está chamando a função, mas passando ela como argumento
                  showModal: showFormModal,
                  iconClick: alternarComprado,
                  trailClick: removerProduto,
                );
              }),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Comprados",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(listaProdutosPegos.length, (index) {
                Produto produto = listaProdutosPegos[index];
                return ListTileProduto(
                  produto: produto,
                  isComprado: true,
                  //aqui não está chamando a função, mas passando ela como argumento
                  showModal: showFormModal,
                  iconClick: alternarComprado,
                  trailClick: removerProduto,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  showFormModal({Produto? model}) {
    // Labels à serem mostradas no Modal
    String labelTitle = "Adicionar Produto";
    String labelConfirmationButton = "Salvar";
    String labelSkipButton = "Cancelar";

    // Controlador dos campos do produto
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    bool isComprado = false;

    // Caso esteja editando
    if (model != null) {
      labelTitle = "Editando ${model.name}";
      nameController.text = model.name;

      if (model.price != null) {
        priceController.text = model.price.toString();
      }

      if (model.amount != null) {
        amountController.text = model.amount.toString();
      }

      isComprado = model.isComprado;
    }

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(labelTitle, style: Theme.of(context).textTheme.headline5),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  label: Text("Nome do Produto*"),
                  icon: Icon(Icons.abc_rounded),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                decoration: const InputDecoration(
                  label: Text("Quantidade"),
                  icon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  label: Text("Preço"),
                  icon: Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      labelSkipButton,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Criar um objeto Produto com as infos
                      Produto produto = Produto(
                        id: const Uuid().v1(),
                        name: nameController.text,
                        isComprado: isComprado,
                      );

                      // Usar id do model
                      if (model != null) {
                        produto.id = model.id;
                      }

                      if (amountController.text != "") {
                        produto.amount = double.parse(amountController.text);
                      }

                      if (priceController.text != "") {
                        produto.price = double.parse(priceController.text);
                      }
                      // Salvar no Firestore
                      produtoService.adicionarProduto(
                        listinId: widget.listin.id,
                        produto: produto,
                      );

                      // Atualizar a lista
                      // refresh(); //Não precisa mais porque adicionamos a escuta automática

                      // Fechar o Modal
                      Navigator.pop(context);
                    },
                    child: Text(
                      labelConfirmationButton,
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  refresh({QuerySnapshot<Map<String, dynamic>>? snapshot}) async {
    List<Produto> produtoLidos = await produtoService.lerProdutos(
        listinId: widget.listin.id, ordem: ordem, isDecrescente: isDecrescente);

    if (snapshot != null) {
      verirficarAlteracoes(snapshot);
    }

    // filtrando os produtos localmente
    filtrarProdutos(produtoLidos);
  }

  filtrarProdutos(List<Produto> listaProdutos) {
    // filtrando os produtos localmente
    List<Produto> tempPlanejados = [];
    List<Produto> tempPegos = [];

    for (var produto in listaProdutos) {
      if (produto.isComprado) {
        tempPegos.add(produto);
      } else {
        tempPlanejados.add(produto);
      }
    }

    setState(() {
      listaProdutosPegos = tempPegos;
      listaProdutosPlanejados = tempPlanejados;
    });
  }

  alternarComprado(Produto produto) async {
    produto.isComprado = !produto.isComprado;

    await produtoService.alternarProduto(
        listinId: widget.listin.id, produto: produto);
  }

  setupListeners() {
    // ouvidores, função rensável para pegar as alterações em tempo real
    listener = produtoService.conectarStreamProdutos(
        refresh: refresh,
        listinId: widget.listin.id,
        ordem: ordem,
        isDecrescente: isDecrescente);
  }

  verirficarAlteracoes(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docChanges.length == 1) {
      for (DocumentChange docChange in snapshot.docChanges) {
        String tipoAlteracao = "";
        Color cor = Colors.green;

        switch (docChange.type) {
          case DocumentChangeType.added:
            tipoAlteracao = "Novo Produto: ";
            cor = Colors.green;
            break;
          case DocumentChangeType.modified:
            tipoAlteracao = "Produto Modificado: ";
            cor = Colors.orange;
            break;
          case DocumentChangeType.removed:
            tipoAlteracao = "Produto Removido: ";
            cor = Colors.red;
            break;
        }

        Produto produto =
            Produto.fromMap(docChange.doc.data() as Map<String, dynamic>);
        final snackBar = SnackBar(
          backgroundColor: cor,
          content: Text("$tipoAlteracao ${produto.name}"),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  removerProduto(Produto produto) async {
    await produtoService.removerProduto(
        listinId: widget.listin.id, produto: produto);
  }

  double calcularPrecoPegos() {
    double total = 0;

    for (Produto produto in listaProdutosPegos) {
      if (produto.amount != null && produto.price != null) {
        total += (produto.amount! * produto.price!);
        // o ! diz que não será nulo
      }
    }
    return total;
  }
}
