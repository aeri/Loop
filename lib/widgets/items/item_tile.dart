import 'package:flutter/material.dart';
import 'package:selit/class/item_class.dart';
import 'package:selit/screens/items/item_details.dart';

/// Tile de objeto para la visualizacion en 1 columna
class ItemTile extends StatelessWidget {
  final ItemClass _item;
  ItemTile(this._item);

  static final _styleTitle =
      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
  static final _styleDescription =
      TextStyle(fontSize: 14.0, color: Colors.grey[700]);
  // Nota: stylePrice usa el color rojo de la aplicación (ver más abajo)
  static final _stylePrice =
      TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900);

  static const double height = 129.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            //SectionTitle(title: 'Tappable'),
            SizedBox(
              height: height,
              child: Card(
                // This ensures that the Card's children (including the ink splash) are clipped correctly.
                clipBehavior: Clip.antiAlias,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.grey[300], width: 1.0)),
                child: InkWell(
                  onTap: () => Navigator.of(context)
                      .pushNamed('/item-details', arguments: _item),
                  splashColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  highlightColor: Colors.transparent,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      // TODO si el producto no tiene imágenes, no mostrar ni Image ni SizedBox
                      // Primera imágen del producto
                      Image.network(
                          'https://images.pexels.com/photos/1140991/pexels-photo-1140991.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260', // TODO sustituir por .images
                          width: 100.0,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          color: Colors.white12, // filtro para blanquear
                          colorBlendMode: BlendMode.srcOver),
                      // Borde entre la imagen y el resto
                      SizedBox.fromSize(
                        size: Size(1.0, double.infinity),
                        child: Container(color: Colors.grey[300]),
                      ),
                      // Titulo, descripción, precio
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(_item?.title ?? '---',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: _styleTitle),
                              Expanded(
                                child: Stack(
                                  children: <Widget>[
                                    ClipRect(
                                      child: Text(_item?.description ?? '---',
                                          maxLines: 10,
                                          style: _styleDescription),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment(0, -1.0),
                                            end: Alignment(0, 1.0),
                                            stops: [
                                              0.8,
                                              0.9
                                            ],
                                            colors: [
                                              Colors.white12,
                                              Colors.white,
                                            ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox.fromSize(
                                size: Size(double.infinity, 20.0),
                                child: Text(
                                  '${_item?.price} ${_item?.currency}',
                                  textAlign: TextAlign.end,
                                  style: _stylePrice.copyWith(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  /*ListTile(
                        title: Text(_item?.title ?? '---'),
                        subtitle: Text(_item.description ?? '---', overflow: TextOverflow.ellipsis, textAlign: TextAlign.left,maxLines:5),
                        trailing: Text('${_item?.price} ${_item?.currency}'),
                        leading: Container(
                          margin: EdgeInsets.only(left: 6.0, bottom: 15.0),
                          child: Image.network('https://i.imgur.com/rqSvE0T.png', // TODO sustituir por .images
                            width: 65.0, fit: BoxFit.fill)
                        ),
                      ),*/
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
