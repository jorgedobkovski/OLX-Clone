import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/models/anuncio.dart';
import 'package:olx/views/widgets/itemAnuncio.dart';

class MeusAnuncios extends StatefulWidget {
  const MeusAnuncios({Key? key}) : super(key: key);

  @override
  State<MeusAnuncios> createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {

  final _controller = StreamController<QuerySnapshot>.broadcast();
  late String _idUsuarioLogado;

  _recuperarDadosUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser!;
    _idUsuarioLogado = usuarioLogado.uid;
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios()async{

    await _recuperarDadosUsuarioLogado();

    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
      .collection("meus_anuncios")
      .doc(_idUsuarioLogado)
      .collection("anuncios")
      .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });

    return stream;
  }

  _removerAnuncio(String idAnuncio){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("meus_anuncios")
        .doc(_idUsuarioLogado)
        .collection("anuncios")
        .doc(idAnuncio)
        .delete().then((_){
          db.collection("anuncios")
              .doc(idAnuncio)
              .delete();
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {

    var carregandoDados = Center(
      child: Column(children: <Widget>[
        Text("Carregando anúncios..."),
        CircularProgressIndicator()
      ],),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Meus anúncios"),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.pushNamed(context, "/novo-anuncio");
        },
      ),
      body: StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot){

          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return carregandoDados;
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if(snapshot.hasError)
                return Text("Erro ao recuperar os dados!");

              QuerySnapshot querySnapshot = snapshot.data!;
              return ListView.builder(
                  itemCount: querySnapshot.docs.length,
                  itemBuilder: (_, indice){
                    List<DocumentSnapshot> anuncios = querySnapshot.docs.toList();
                    DocumentSnapshot documentSnapshot = anuncios[indice];
                    Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);

                    return ItemAnuncio(
                      anuncio: anuncio,
                      onPressedRemover: (){
                        showDialog(
                            context: context,
                            builder: (context){
                              return AlertDialog(
                                title: Text("Confirmar"),
                                content: Text("Deseja realmente excluir o anúncio?"),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: (){
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Cancelar",
                                      style: TextStyle(color: Colors.black),
                                      ),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                                    ),
                                  ),
                                  TextButton(
                                      onPressed: (){
                                        _removerAnuncio(anuncio.id);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Remover",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            }
                        );
                      },
                    );
                  });
          }
          return Container();
        },
      ),
    );
  }
}
