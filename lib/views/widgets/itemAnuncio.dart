import 'package:flutter/material.dart';
import 'package:olx/models/anuncio.dart';

class ItemAnuncio extends StatelessWidget {

  late Anuncio anuncio;
  VoidCallback? onTapItem;
  VoidCallback? onPressedRemover;

  ItemAnuncio({
    required this.anuncio,
    this.onTapItem,
    this.onPressedRemover
    });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(children: <Widget>[

            SizedBox(
              width: 120,
              height: 120,
              child: Image.network(
                anuncio.fotos[0],
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    anuncio.titulo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("R\$ ${anuncio.preco}"),
                ],),
              ),
            ),
            if(this.onPressedRemover!=null) Expanded(
              flex: 1,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(10)),
                ),
                onPressed: (){},
                child: Icon(Icons.delete, color: Colors.white,),
              ),
            ),

          ],),
        ),
      ),
    );
  }
}
