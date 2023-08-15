import 'package:flutter/material.dart';

class BotaoCustomizado extends StatelessWidget {

  final String texto;
  final Color corTexto;
  final VoidCallback onPressed;

  BotaoCustomizado({
    required this.texto,
    this.corTexto = Colors.white,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:this.onPressed,
      child: Text(this.texto,
        style: TextStyle(
            color: this.corTexto,fontSize: 20
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: Color(0xff9c27b0),
        padding: EdgeInsets.fromLTRB(32, 16, 31, 16),
      ),
    );
  }
}
