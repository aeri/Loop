import 'package:selit/class/item_class.dart';
import 'package:selit/util/api/api_config.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/class/items/filter_list_class.dart';
import 'package:flutter/foundation.dart'; // uso de @required
import 'package:http/http.dart' as http;
import 'dart:convert' as json;
import 'dart:io';

/// Interacciones con la API relacionadas con items (productos, objetos)
class ItemRequest {
  /// Obtener lista de items (para la pantalla principal)
  static Future<List<ItemClass>> getItems(
      {@required double lat,
      @required double lng,
      int size,
      int page,
      @required FilterListClass filters}) async {
    // Mapa empleado para generar los parámetros de la request
    // search, priceFrom/To, distance, category, types, sort
    Map<String, String> _params = filters.getFiltersMap();
    if (size != null) _params.putIfAbsent("\$size", () => size.toString());
    if (page != null) _params.putIfAbsent("\$page", () => page.toString());

    String _otherParameters = '?lat=$lat&lng=$lng';
    _params.forEach((key, value) => _otherParameters += '&$key=$value');

    print("Parametros: $_otherParameters");


    http.Response response;
    if (_params["type"] == "sale") {
      // Esperar la respuesta de la petición
      print('ITEM API PLAY ▶');
      response = await http
          .get('${APIConfig.BASE_URL}/products$_otherParameters', headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      });
      print('ITEM API STOP ◼');
    } else if (_params["type"] == "auction") {
      // Esperar la respuesta de la petición
      print('ITEM API PLAY ▶');
      response = await http
          .get('${APIConfig.BASE_URL}/auctions$_otherParameters', headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      });
      print('ITEM API STOP ◼');
    }
    //TODO: Subastas y ventas 
    else{
      // Esperar la respuesta de la petición
      print('ITEM API PLAY ▶');
      response = await http
          .get('${APIConfig.BASE_URL}/products$_otherParameters', headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      });
      print('ITEM API STOP ◼');
    }

    print(response.body);
    // Crear la lista de items a partir de la respuesta y devovlerla
    if (response.statusCode == 200) {
      List<ItemClass> products = new List<ItemClass>();
      String token = await Storage.loadToken();
      if (_params["type"] == "sale") {
        (json.jsonDecode(response.body) as List<dynamic>)
            .forEach((productJson) {
          products.add(ItemClass.fromJson(productJson, token));
        });
      } else if (_params["type"] == "auction") {
        (json.jsonDecode(response.body) as List<dynamic>)
            .forEach((productJson) {
          products.add(ItemClass.fromJsonAuctions(productJson, token));
        });
      }
      //TODO: Subastas y ventas 
      else{
        (json.jsonDecode(response.body) as List<dynamic>)
            .forEach((productJson) {
          products.add(ItemClass.fromJson(productJson, token));
        });
      }
      return products;
    } else {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Obtener listado de objetos en venta/vendidos por un usuario
  /// Por ahora se piden todos los items del usuario a la vez,
  /// sin cargar por páginas
  static Future<List<ItemClass>> getItemsFromUser(
      {@required int userId,
      @required double userLat,
      @required double userLng,
      @required String status}) async {
    // TODO workaround para ignorar la distancia de los objetos
    String _paramsString = '?lat=$userLat&lng=$userLng&distance=99999999.9';
    // Si status no es ni "en venta" ni "vendido", default a "en venta"
    String _statusParam = status == "vendido" ? status : "en venta";
    _paramsString += "&owner=$userId&status=$_statusParam";

    // Esperar la respuesta de la petición
    print('ITEM USER PLAY ▶');
    http.Response response = await http
        .get('${APIConfig.BASE_URL}/products$_paramsString', headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: await Storage.loadToken(),
    });
    print('ITEM USER STOP ◼');

    if (response.statusCode == 200) {
      List<ItemClass> products = new List<ItemClass>();
      String token = await Storage.loadToken();
      (json.jsonDecode(response.body) as List<dynamic>).forEach((productJson) {
        products.add(ItemClass.fromJson(productJson, token));
      });
      return products;
    } else {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Subir producto
  static Future<void> create(ItemClass item) async {
    final response = await http.post(
      '${APIConfig.BASE_URL}/products',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
      body: json.utf8.encode(json.jsonEncode(item.toJsonCreate())),
    );

    if (response.statusCode != 201) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Subir subasta
  static Future<void> createAuction(ItemClass item) async {
    print(json.jsonEncode(item.toJsonCreateAuction()));
    final response = await http.post(
      '${APIConfig.BASE_URL}/auctions',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
      body: json.utf8.encode(json.jsonEncode(item.toJsonCreateAuction())),
    );

    if (response.statusCode != 201) {
      print(response.statusCode);
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Actualizar producto
  static Future<void> edit(ItemClass item) async {
    int _productId = item.itemId;
    print(json.jsonEncode(item.toJsonEdit()));
    final response = await http.put(
      '${APIConfig.BASE_URL}/products/$_productId',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
      body: json.utf8.encode(json.jsonEncode(item.toJsonEdit())),
    );

    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

  ///Actualizar subasta
  static Future<void> editAuction(ItemClass item) async {
    int _auctionId = item.itemId;
    print(json.jsonEncode(item.toJsonEditAuction()));
    final response = await http.put(
      '${APIConfig.BASE_URL}/auctions/$_auctionId',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
      body: json.utf8.encode(json.jsonEncode(item.toJsonEditAuction())),
    );

    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Eliminar producto
  static Future<void> delete(ItemClass item) async {
    int _productId = item.itemId;
    final response = await http.delete(
      '${APIConfig.BASE_URL}/products/$_productId',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
    );

    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }
}
