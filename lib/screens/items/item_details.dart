import 'package:flutter/material.dart';
import 'package:selit/class/item_class.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:selit/screens/items/edit_item.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/util/api/item_request.dart';
import 'dart:async';

/// Detalles de un item/producto en venta: título, descripción, precio,
/// imágenes, etc. También se muestra información acerca de su usuario
/// dueño y su ubicación además de posibilidad para contactar con él.
class ItemDetails extends StatefulWidget {
  final ItemClass item;
  ItemDetails({this.item});
  @override
  State<StatefulWidget> createState() => _ItemDetails(item);
}

class _ItemDetails extends State<ItemDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ItemClass _item;

  // Constructor
  _ItemDetails(this._item);

  static final _styleTitle = TextStyle(
      fontSize: 20.0,
      color: Colors.black,
      fontWeight: FontWeight.bold);

  static final styleTagWhite = TextStyle(
      fontSize: 18.0,
      color: Colors.white,
      fontWeight: FontWeight.bold);

  static final styleTagBlack = TextStyle(
      fontSize: 22.0,
      color: Colors.black,
      fontWeight: FontWeight.bold);

  static IconData _filledFavorite = Icons.favorite;
  static IconData _emptyFavorite = Icons.favorite_border;
  bool _esFavorito = false;

  final Color _colorStatusBarGood = Colors.blue.withOpacity(0.5);
  final Color _colorStatusBarBad = Colors.red.withOpacity(0.5);

  IconData _favorite = Icons.favorite_border;

  void _favoritePressed() {
    setState(() {
      if(_esFavorito){
        _favorite = Icons.favorite_border;
        _esFavorito = false;
      }
      else{
        _favorite = Icons.favorite;
        _esFavorito = true;
      }
    });
  }

  static Widget _buildEditConditional;

  void showInSnackBar(String value, Color alfa) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      ),
      backgroundColor: alfa,
      duration: Duration(seconds: 3),
    ));
  }

  void _showDialogDeleteProduct() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("¿Seguro que quiere eliminar el producto?",
            style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          content: new Text("Si pulsa \"Eliminar\" el producto se eliminará. Los cambios no pueden deshacerse.",
            style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("CANCELAR",
                style: TextStyle(fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("ELIMINAR",
                style: TextStyle(fontSize: 16.0,
                  color: Colors.red,
                  fontWeight: FontWeight.bold)),
              onPressed: () {
                ItemRequest.delete(_item).then((_) {
                    showInSnackBar("Datos actualizados correctamente", _colorStatusBarGood);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                }).catchError((error) {
                  if (error == "No autorizado" || error == "Prohibido") {
                    showInSnackBar("Acción no autorizada", _colorStatusBarBad);
                  } else {
                    showInSnackBar("No hay conexión a internet", _colorStatusBarBad);
                  }
                });
              },
            ),
          ],
        );
      },
    );
}

  Widget _buildEditButton(){
    return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      new RaisedButton(
        padding: const EdgeInsets.all(8.0),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditItem(item: _item)));
        } ,
        child: new Text('Editar producto',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
      ),
      new RaisedButton(
        onPressed: () => _showDialogDeleteProduct(),
        textColor: Colors.white,
        color: Colors.red,
        padding: const EdgeInsets.all(8.0),
        child: new Text('Eliminar producto',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
      ),
    ],
);
  }
/*
  


padding: const EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
        alignment: Alignment.center,
        child: GestureDetector(
          child: Chip(
            avatar: Icon(Icons.edit),
            backgroundColor: Colors.yellow,
            label: Text('Editar producto',
                style: styleTagBlack),
          ),
        onTap: () => //Navigator.of(context).pushNamed('/edit-item', arguments: _item),
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditItem(item: _item))),
          //Navigator.of(context).pushNamed('/new-item', arguments: _item.owner),
        ),  
*/
  final _blendColor = Color.alphaBlend(Color(0x552B2B2B), Color(0xFFC0392B));

  void _leerIdUsuario() async{
    int idItem = _item.owner.user_id; 
    int miId = await Storage.loadUserId();
    print('Mi id: ' + miId.toString());
    miId = 1; 
    print('Mi id: ' + miId.toString());
    print('Item id: ' + idItem.toString());
      if(miId == idItem){
        setState(() {
          _buildEditConditional = _buildEditButton();
        });
        print('Holaaaa');
        print('Precio actual: ' + _item.price.toString());
      }
  }

  @override
  void initState() {
    super.initState();
    _buildEditConditional = null;
    _leerIdUsuario();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle =
        theme.textTheme.headline.copyWith(color: Colors.white);
    final TextStyle descriptionStyle = theme.textTheme.subhead;
    return new Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
          child: Container(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                  child: Column(children: <Widget>[
                Card(
                  elevation: 4.0,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // photo and title
                          SizedBox(
                            height: 250.0,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                new Container(
                                  child: new Carousel(
                                    images: [
                                      new AssetImage(
                                        'assets/img/login_logo.png',
                                        // package: destination.assetPackage,
                                      ),
                                      new AssetImage(
                                        'assets/img/profile_default.jpg',
                                        // package: destination.assetPackage,
                                      ),
                                      new AssetImage(
                                        'assets/img/login_logo.png',
                                        // package: destination.assetPackage,
                                      ),
                                      new AssetImage(
                                        'assets/img/profile_default.jpg',
                                        // package: destination.assetPackage,
                                      ),
                                    ],
                                    boxFit: BoxFit.scaleDown,
                                    showIndicator: true,
                                    autoplay: false,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ]),
                  ),
                ),

                Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _item?.title ?? '---',
                      style: descriptionStyle.copyWith(
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    )),
                Container(
                  child: _buildEditConditional),
                //_leerIdUsuario() == true ?_buildEditButton() : null, 
                Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                    child: DefaultTextStyle(
                        style: descriptionStyle,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(                                // three line description
                              mainAxisSize: MainAxisSize.max,
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Chip(
                                      backgroundColor: _blendColor,
                                      label: Text('En venta',
                                          style: styleTagWhite),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, left: 8.0),
                                  child: Text(
                                    '${_item?.price} ${_item?.currency}',
                                    style: styleTagBlack,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8.0, left: 8.0),
                              child: IconButton(
                                icon: Icon(_favorite),
                                color: Colors.red,
                                iconSize: 35.0,
                                tooltip: 'Favoritos',
                                onPressed: () {
                                  _favoritePressed();
                                },
                              ),
                            ),
                          ],
                        ))),

                Container(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 15.0),
                    child: Text(_item?.description ?? '---',
                        style:
                            TextStyle(fontSize: 15.0, color: Colors.black))),
                Container(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 20.0),
                    alignment: Alignment.centerLeft,
                    child: Text('Categorías: ' + _item.category,
                        style:
                            TextStyle(fontSize: 17.0, color: Colors.black54))),
              ])))),
    );
  }
}
