import 'package:cianfafire/firestore_produtos/presentation/produto_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/listin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listin> listListins = [];

  //  chamando nossa instancia firebase para ser usada dentro do arquivo
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listin - Feira Colaborativa"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: (listListins.isEmpty)
          ? const Center(
              child: Text(
                "Nenhuma lista ainda.\nVamos criar a primeira?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: () {
                return refresh();
              },
              child: ListView(
                children: List.generate(
                  listListins.length,
                  (index) {
                    Listin model = listListins[index];
                    return Dismissible(
                      //que pode ser retirado da tela, excluir, comportamento de arrastar para o lado para excluir
                      //usado para captar o id do item que vai ser excluido
                      key: ValueKey<Listin>(model),
                      //só vai poder arrastar do fim para o começo
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8.0),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        remove(model);
                      },
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProdutoScreen(listin: model),
                              ));
                        },
                        onLongPress: () {
                          //para quando o usuário ficar com o dedo pressionado em cima do conteudo para editar
                          showFormModal(
                              model:
                                  model); //esse model que está sendo passado como parâmetro é o mesmo desse:Listin model = listListins[index];
                        },
                        leading: const Icon(Icons.list_alt_rounded),
                        title: Text(model.name),
                        // subtitle: Text(model.id),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  showFormModal({Listin? model}) {
    //quando os parâmetros estão dentro de chaves{} significa que são opcionais,  o ponto de interrogação ? significa que pode ou não ser nulo
    //metodo que é chamado quando clicamos no botao modal
    // Labels à serem mostradas no Modal
    String title = "Adicionar Listin";
    String confirmationButton = "Salvar";
    String skipButton = "Cancelar";

    // Controlador do campo que receberá o nome do Listin
    TextEditingController nameController = TextEditingController();

    // caso esteja editando:
    if (model != null) {
      // significa que passamos um model
      title = "Editando ${model.name}";
      nameController.text = model.name;
    }

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,

      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(title, style: Theme.of(context).textTheme.headline5),
              TextFormField(
                controller: nameController,
                decoration:
                    const InputDecoration(label: Text("Nome do Listin")),
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
                    child: Text(skipButton),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                      //botao de salvar
                      onPressed: () {
                        // criar um objeto listin com as infos
                        Listin listin = Listin(
                          id: const Uuid().v1(),
                          name: nameController.text,
                        );

                        // Usar id do model, para quando for fazer uma edição em um registro já existente.
                        if (model != null) {
                          listin.id = model.id;
                        }

                        //salvar no firestore
                        firestore.collection("listins").doc(listin.id).set(listin
                            .toMap()); //definindo a coleção, criando um novo documento, e passando como parametro o mesmo id do listin

                        // atualizar a lista
                        refresh();

                        // fechar o modal
                        Navigator.pop(context);
                      },
                      child: Text(confirmationButton)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // Metodo que será chamado nos momentos em que quisermos atualizar a tela
  refresh() async {
    // lista temporaria
    List<Listin> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection("listins")
        .get(); //ele pega todos os documentos que temos dentro da nossa listins (colecao)

    for (var doc in snapshot.docs) {
      temp.add(Listin.fromMap(doc
          .data())); //adiciona uma conversão do map do doc usando o construtor
    }

    setState(() {
      listListins = temp;
    });
  }

  void remove(Listin model) {
    firestore.collection('listins').doc(model.id).delete();
    refresh();
  }
}
