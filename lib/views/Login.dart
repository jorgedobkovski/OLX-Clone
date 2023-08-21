import 'package:flutter/material.dart';
import 'package:olx/models/usuario.dart';
import 'package:olx/views/widgets/botaoCustomizado.dart';
import 'package:olx/views/widgets/inputCustomizado.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerEmail = TextEditingController(text: "jorge@gmail.com");
  TextEditingController _controllerSenha = TextEditingController(text: "12343567");

  bool _cadastrar = false;
  String _mensagemErro = "";
  String _textoBotao = "Entrar";

  _cadastrarUsuario(Usuario usuario){
    
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.createUserWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha
    ).then((firabaseUser){
      Navigator.pushReplacementNamed(context, "/");
    });
    
  }

  _logarUsuario(Usuario usuario){

    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(
      email: usuario.email,
      password: usuario.senha,
    ).then((firebaseUser){
      Navigator.pushReplacementNamed(context, "/");
    });

  }

  _validarCampos(){

    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if(email.isNotEmpty && email.contains("@")){
      if(senha.isNotEmpty && senha.length>6){

        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        if(_cadastrar){
          _cadastrarUsuario(usuario);
        } else {
          _logarUsuario(usuario);
        }

      } else {
        setState((){
          _mensagemErro = "Preencha a senha! digite mais de 6 caracteres!";
        });
      }
    } else {
      setState(() {
        _mensagemErro = "Preencha o e-mail válido.";
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "images/logo.png",
                    width: 200,
                    height: 100,
                  ),
                ),
                InputCustomizado(
                  controller: _controllerEmail,
                  hint: "E-mail",
                  autofocus: true,
                  type: TextInputType.emailAddress,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 5)
                ),
                InputCustomizado(
                  controller: _controllerSenha,
                  hint: "Senha",
                  obscure: true
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Logar"),
                    Switch(
                        value: _cadastrar,
                        onChanged: (bool valor){
                          setState(() {
                            _cadastrar = valor;
                            _textoBotao = "Entrar";
                            if(_cadastrar){
                              _textoBotao = "Cadastrar";
                            }
                          });
                        }
                    ),
                    Text("Cadastrar")
                  ],
                ),
                BotaoCustomizado(
                    texto: _textoBotao,
                    onPressed: _validarCampos,
                ),
                TextButton(
                    onPressed: (){
                      Navigator.pushReplacementNamed(context, "/");
                    }, 
                    child: Text("Ir para anúncios")
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(_mensagemErro, style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red
                  ),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
