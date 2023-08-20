import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../util/Configuracoes.dart';


class Anuncios extends StatefulWidget {
  const Anuncios({Key? key}) : super(key: key);

  @override
  State<Anuncios> createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {

  List<String> itensMenu = [""];
  String? _itemSelecionadoEstado;
  String? _itemSelecionadoCategoria;
  List<DropdownMenuItem<String>> _listaDropEstados = List.empty(growable: true);
  List<DropdownMenuItem<String>> _listaDropCategorias = List.empty(growable: true);

  _escolhaMenuItem(String itemEscolhido){

    switch(itemEscolhido){
      case "Meus anúncios":
        Navigator.pushNamed(context, "/meus-anuncios");
        break;
      case "Entrar / Cadastrar":
        Navigator.pushNamed(context, "/login");
        break;
      case "Deslogar":
        _deslogarUsuario();
        break;

    }

  }

  _deslogarUsuario() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushNamed(context, "/login");
  }

  Future _verificarUsuarioLogado() async{

    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;

    if( usuarioLogado == null ){
      itensMenu = ["Entrar / Cadastrar"];
    }else{
      itensMenu=[
        "Meus anúncios", "Deslogar"
      ];
    }

  }

  _carregarItensDropdown(){

    _listaDropCategorias = Configuracoes.getCategorias();
    _listaDropEstados = Configuracoes.getEstados();

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _carregarItensDropdown();
    _verificarUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OLX"),
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: _escolhaMenuItem,
              itemBuilder: (context){
                return itensMenu.map((String item){
                  return PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList();
              },
          )
        ],
      ),
      body: Container(
        child: Column(children: <Widget>[
          Row(children: <Widget>[
            Expanded(
              child: DropdownButtonHideUnderline(
                child: Center(
                  child: DropdownButton(
                    iconEnabledColor: Color(0xff9c27b0),
                    value: _itemSelecionadoEstado,
                    items: _listaDropEstados,
                    style: TextStyle(
                        fontSize: 22,
                      color: Colors.black,
                    ),
                    onChanged: (estado){
                      setState((){
                        _itemSelecionadoEstado = estado;
                      });
                    },
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.grey[200],
              width: 2,
              height: 60,
            ),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: Center(
                  child: DropdownButton(
                    iconEnabledColor: Color(0xff9c27b0),
                    value: _itemSelecionadoCategoria,
                    items: _listaDropCategorias,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                    ),
                    onChanged: (categoria){
                      setState((){
                        _itemSelecionadoCategoria = categoria;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
          )
        ],),
      ),
    );
  }
}
