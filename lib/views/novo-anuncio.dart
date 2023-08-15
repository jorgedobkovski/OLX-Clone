import 'dart:io';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx/models/anuncio.dart';
import 'package:olx/views/widgets/botaoCustomizado.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx/views/widgets/inputCustomizado.dart';
import 'package:validadores/Validador.dart';

class NovoAnuncio extends StatefulWidget {
  const NovoAnuncio({Key? key}) : super(key: key);

  @override
  State<NovoAnuncio> createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {

  List<File> _listaImagens = List.empty(growable: true);
  List<DropdownMenuItem<String>> _listaDropEstados = List.empty(growable: true);
  List<DropdownMenuItem<String>> _listaDropCategorias = List.empty(growable: true);
  final _formKey = GlobalKey<FormState>();
  Anuncio? _anuncio;
  BuildContext? _dialogContext;

  String _itemSelecionadoEstado = "";
  String _itemSelecionadoCategoria = "";


  _selecionarImagemGaleria() async {
    final imagemSelecionada = await ImagePicker().getImage(source: ImageSource.gallery);

    if (imagemSelecionada != null) {
      setState(() {
        // Convertendo PickedFile para File
        _listaImagens.add(File(imagemSelecionada.path));
      });
    }
  }

  _abrirDialog(BuildContext context){

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 20,),
              Text("Salvando anúncio..."),
            ],),
          );
        });

  }

  _salvarAnuncio() async {

    _abrirDialog( _dialogContext! );

    //Upload das imagens
    await _uploadImagens();

    print("lista imagens: ${_anuncio!.fotos.toString()}");

    //upload anuncio
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser!;
    String idUsuarioLogado = usuarioLogado.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("meus_anuncios")
    .doc( idUsuarioLogado )
    .collection("anuncio")
    .doc( _anuncio?.id )
    .set(_anuncio!.toMap()).then((_){

      Navigator.pop(_dialogContext!);
      Navigator.pop(context);

    });

  }

  Future _uploadImagens() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();

    for(var imagem in _listaImagens){

      String nomeImagem =DateTime.now().microsecondsSinceEpoch.toString();
      Reference arquivo = pastaRaiz
          .child("meus anuncios")
          .child(_anuncio!.id)
          .child(nomeImagem);

      UploadTask uploadTask = arquivo.putFile(imagem);
      TaskSnapshot taskSnapshot = await uploadTask;

      String url = await taskSnapshot.ref.getDownloadURL();
      _anuncio!.fotos.add(url);

    }

  }

  _controller(){
    return TextEditingController();
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropdown();
    _anuncio = Anuncio.gerarId();
  }

  _carregarItensDropdown(){
    _listaDropCategorias.add(
      DropdownMenuItem(child: Text("Automóvel"), value: "auto",)
    );
    _listaDropCategorias.add(
        DropdownMenuItem(child: Text("Imóvel"), value: "imovel",)
    );
    _listaDropCategorias.add(
        DropdownMenuItem(child: Text("Eletrônicos"), value: "eletro",)
    );
    _listaDropCategorias.add(
        DropdownMenuItem(child: Text("Moda"), value: "moda",)
    );
    _listaDropCategorias.add(
        DropdownMenuItem(child: Text("Esportes"), value: "esportes",)
    );

    for(var estado in Estados.listaEstadosSigla){
      _listaDropEstados.add(
          DropdownMenuItem(child: Text(estado), value: estado,)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Novo anúncio"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
              FormField<List>(
                initialValue: _listaImagens,
                validator: ( imagens ){
                  if(imagens?.length == 0){
                    return "Necessário selecionar uma imagem!";
                  }
                  return null;
                },
                builder: (state){
                  return Column(children: <Widget>[
                    Container(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                          itemCount: _listaImagens.length + 1,
                          itemBuilder: (context, indice){
                            if(indice == _listaImagens.length){
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap: (){
                                    _selecionarImagemGaleria();
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey[400],
                                    radius: 50,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Adicionar",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      )
                                    ],),
                                  ),
                                ),
                              );
                            }
                            if(_listaImagens.length > 0){
                              return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap:(){
                                    showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                            Image.file(_listaImagens[indice]),
                                            TextButton(
                                              child: Text("Excluir"),
                                              style: TextButton.styleFrom(
                                              primary: Colors.red),
                                                onPressed: (){
                                                  setState(() {
                                                    _listaImagens.removeAt(indice);
                                                    Navigator.of(context).pop();
                                                  });
                                                },
                                                ),
                                          ],

                                          ),
                                        )
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: FileImage(_listaImagens[indice]),
                                    child: Container(
                                      color: Color.fromRGBO(255, 255, 255, 0.4),
                                      alignment: Alignment.center,
                                      child: Icon(Icons.delete, color: Colors.red),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Container();
                          }),
                    ),
                    if(state.hasError)
                      Container(
                        child: Text(
                          "[${state.errorText}]",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      )
                  ],);
                },
              ),
              Row(children: <Widget>[
                Expanded(child: Padding(
                  padding: EdgeInsets.all(8),
                  child: DropdownButtonFormField(
                    hint: Text("Estados"),
                    onSaved: (estado){
                      _anuncio?.estado = estado!;
                    },
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20
                    ),
                    items: _listaDropEstados,
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório!")
                          .valido(valor);
                    },
                    onChanged: (valor){
                      setState(() {
                        _itemSelecionadoEstado = valor!;
                      });
                    },
                  ),
                )),
                Expanded(child: Padding(
                  padding: EdgeInsets.all(8),
                  child: DropdownButtonFormField(
                    hint: Text("Categorias"),
                    onSaved: (categoria){
                      _anuncio?.categoria = categoria!;
                    },
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20
                    ),
                    items: _listaDropCategorias,
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório!")
                          .valido(valor);
                    },
                    onChanged: (valor){
                      setState(() {
                        _itemSelecionadoCategoria = valor!;
                      });
                    },
                  ),
                )),
              ],),
              Padding(
                  padding: EdgeInsets.only(bottom: 15, top: 15),
                child: InputCustomizado(
                  controller: _controller(),
                  hint: "Título",
                  onSaved: (titulo){
                    _anuncio?.titulo = titulo!;
                  },
                  validator: (valor){
                    return Validador()
                        .add(Validar.OBRIGATORIO, msg: "Campo obrigatório!")
                        .valido(valor);
                  },
                ),
              ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    controller: _controller(),
                    hint: "Preço",
                    onSaved: (preco){
                      _anuncio?.preco = preco!;
                    },
                    inputFotmatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RealInputFormatter(moeda: true)
                    ],
                    type: TextInputType.number,
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório!")
                          .valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    controller: _controller(),
                    hint: "Telefone",
                    onSaved: (telefone){
                      _anuncio?.telefone = telefone!;
                    },
                    inputFotmatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter(),
                    ],
                    type: TextInputType.phone,
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório!")
                          .valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    controller: _controller(),
                    hint: "Descrição",
                    onSaved: (descricao){
                      _anuncio?.descricao = descricao!;
                    },
                    maxLines: null,
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório!")
                          .maxLength(200, msg: "Máximo de 200 caractéres")
                          .valido(valor);
                    },
                  ),
                ),

              BotaoCustomizado(
                texto: "Cadastrar anúncio",
                onPressed: (){
                  if(_formKey.currentState!.validate()){
                    //salva campos
                    _formKey.currentState!.save();
                    //configura dialog context
                    _dialogContext = context;
                    //salva anuncio
                    _salvarAnuncio();
                  }
                },
              )
            ],
            ),
          ),
        ),
      ),
    );
  }
}
