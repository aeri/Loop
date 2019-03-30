import 'package:flutter/material.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/item_class.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:selit/util/api/item_request.dart';
import 'package:selit/util/bubble_indication_painter.dart';
import 'package:selit/widgets/items/item_tile.dart';
import 'package:selit/widgets/star_rating.dart';
import 'package:selit/widgets/profile_picture.dart';

/// Perfil de usuario: muestra sus datos, foto de perfil y
/// dos listas: una con los productos en venta y otra con los vendidos
/// Recibe el ID de usuario a mostrar y muestra un perfil por defecto
/// hasta que recibe los datos.
class Profile extends StatefulWidget {
  final int userId;

  /// Página de perfil para el usuario userId
  Profile({@required this.userId});

  @override
  _ProfileState createState() => new _ProfileState(userId);
}

class _ProfileState extends State<Profile> {
  // Estilos para los diferentes textos
  static final _styleNombre = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.white);
  static final _styleSexoEdad = const TextStyle(
      fontStyle: FontStyle.italic, fontSize: 15.0, color: Colors.white);
  static final _styleUbicacion =
      const TextStyle(fontSize: 15.0, color: Colors.white);
  static final _styleReviews =
      const TextStyle(fontSize: 15.0, color: Colors.white);
  static final _styleNothing =
      const TextStyle(fontSize: 20.0, color: Colors.grey);
  static final _textAlignment = TextAlign.left;

  /// Controlador tabs "en venta" y "vendido"
  PageController _pageController = PageController(initialPage: 0);

  /// Color de "en venta" (necesario alternarlo entre blanco-negro)
  Color _tabColorLeft = Colors.black;

  /// Color de "vendido" (necesario alternarlo entre blanco-negro)
  Color _tabColorRight = Colors.white;

  // Objetos en venta y vendidos
  List<ItemClass> _itemsEnVenta = <ItemClass>[];
  List<ItemClass> _itemsVendidos = <ItemClass>[];

  /// Usuario a mostrar en el perfil (null = placeholder)
  static UsuarioClass _user;

  _ProfileState(int _userId) {
    _loadProfile(_userId);
  }

  // TODO solamente está aqui para cargar las cervezas de test
  @override
  void initState() {
    super.initState();
    listenForItems();
  }

  void listenForItems() async {
    final Stream<ItemClass> stream = await ItemRequest.getItems();
    stream.listen((ItemClass item) {
      setState(() => _itemsEnVenta.add(item));
    });
  }

  Future<void> _loadProfile(int _userId) async {
    // Mostrar usuario placeholder mientras carga el real
    if (_user == null) {
      UsuarioRequest.getUserById(_userId).then((realUser) {
        setState(() {
          _user = realUser;
        });
      });
    }
  }

  // Pulsación del boton "en venta"
  void _onPressedEnVenta() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    setState(() {
      _tabColorLeft = Colors.black;
      _tabColorRight = Colors.white;
    });
  }

  // Pulsación del boton "vendidos"
  void _onPressedVendidos() {
    _pageController.animateToPage(1,
        duration: Duration(milliseconds: 300), curve: Curves.decelerate);
  }

  /// Constructor para los botones "en venta" y "vendido"
  Widget _buildTabButton(displayText, onPress, textColor) {
    return Expanded(
      child: FlatButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: onPress,
        child: Text(
          displayText,
          style:
              TextStyle(color: textColor, fontSize: 16.0, fontFamily: "Nunito"),
        ),
      ),
    );
  }

  /// Widget correspondiente al perfil del usuario _user
  /// Si un campo de _user es nulo, se muestran los campos por defecto
  Widget _buildProfile() {
    // wTopStack (parte superior junto con botón de edición)
    // wUserData (parte superior)
    // - wUserDataLeft (parte izquierda: foto de perfil, estrellas)
    // - wUserDataRight (parte derecha: nombre, apellidos, etc.)
    // wProductList (parte inferior)
    // - wProductListSelling (parte izquierda: lista de productos en venta)
    // - wProductListSold (parte derecha: lista de productos vendidos)

    Widget wUserDataLeft = Expanded(
      flex: 4,
      child: Container(
        margin: EdgeInsets.only(left: 25),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20),
              child: ClipOval(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ProfilePicture(_user?.urlPerfil),
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 10),
                child: StarRating(starRating: _user?.numeroEstrellas ?? 5)),
            Container(
                margin: EdgeInsets.only(top: 5, bottom: 15),
                alignment: Alignment.center,
                child: Text('${_user?.reviews} reviews',
                    style: _styleReviews, textAlign: _textAlignment))
          ],
        ),
      ),
    );

    Widget wUserDataRight = Expanded(
      flex: 6,
      child: Container(
          margin: EdgeInsets.only(left: 25, right: 10),
          child: Column(
            children: <Widget>[
              Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(top: 30),
                  child: Text(_user?.nombre ?? '---',
                      style: _styleNombre, textAlign: _textAlignment)),
              Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 5),
                  child: Text(_user?.apellidos ?? '---',
                      style: _styleNombre, textAlign: _textAlignment)),
              Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 10),
                  child: Text('${_user?.sexo}, ${_user?.edad} años',
                      style: _styleSexoEdad, textAlign: _textAlignment)),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 30),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(2),
                      child: Icon(Icons.location_on, color: Colors.white),
                    ),
                    Text(
                      _user?.ubicacionCiudad ?? '---',
                      style: _styleUbicacion,
                      textAlign: _textAlignment,
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 5, left: 15, bottom: 15),
                child: Text(
                  _user?.ubicacionResto ?? '---',
                  style: _styleUbicacion,
                  textAlign: _textAlignment,
                ),
              )
            ],
          )),
    );

    Widget wUserData = Container(
      padding: EdgeInsets.only(top: 30),
      child: Row(children: <Widget>[wUserDataLeft, wUserDataRight]),
    );

    Widget wTopStack = Stack(children: <Widget>[
      wUserData,
      Positioned(
        right: _user != null ? 10 : -50,
        top: 40,
        child: IconButton(
          icon: Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamed('/edit-profile', arguments: _user);
          },
        ),
      ),
    ]);

    Widget wProductListSelling = _itemsEnVenta.isEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.not_interested, color: Colors.grey, size: 65.0),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Text('Nada por aquí...', style: _styleNothing),
              )
            ],
          )
        : Container(
            margin: EdgeInsets.only(top: 5),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 15),
              itemCount: _itemsEnVenta.length,
              itemBuilder: (context, index) => ItemTile(_itemsEnVenta[index]),
            ),
          );

    Widget wProductListSold = _itemsVendidos.isEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.not_interested, color: Colors.grey, size: 65.0),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Text('Nada por aquí...', style: _styleNothing),
              )
            ],
          )
        : Container(
            margin: EdgeInsets.only(top: 5),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 15),
              itemCount: _itemsVendidos.length,
              itemBuilder: (context, index) => ItemTile(_itemsVendidos[index]),
            ),
          );

    // NOTA: la 'sincronizacion rapida' de los cambios de Flutter no
    // suele funcionar con los cambios realizados a las listas,
    // mejor reiniciar del todo
    Widget wProductList = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: (MediaQuery.of(context).size.width - 300) / 2),
          decoration: BoxDecoration(
            color: Color(0x552B2B2B),
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          child: CustomPaint(
            painter: TabIndicationPainter(pageController: _pageController),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildTabButton("En venta", _onPressedEnVenta, _tabColorLeft),
                _buildTabButton("Vendidos", _onPressedVendidos, _tabColorRight),
              ],
            ),
          ),
        ),
      ),
      body: PageView(
          controller: _pageController,
          onPageChanged: (pageIndex) {
            if (pageIndex == 0) {
              // en venta
              setState(() {
                _tabColorLeft = Colors.black;
                _tabColorRight = Colors.white;
              });
            } else {
              // vendidos
              setState(() {
                _tabColorLeft = Colors.white;
                _tabColorRight = Colors.black;
              });
            }
          },
          children: <Widget>[wProductListSelling, wProductListSold]),
    );

    return Column(
      children: <Widget>[
        wTopStack,
        Expanded(
          child: wProductList,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment(0.15, -1.0),
                    end: Alignment(-0.15, 1.0),
                    stops: [
                      0.6,
                      0.6
                    ],
                    colors: [
                      Theme.of(context).primaryColor,
                      Colors.grey[100],
                    ]),
              ),
            ),
          ),
          _buildProfile(),
        ],
      ),
    );
  }
}
