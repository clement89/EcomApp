import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const CART_KEY = "local_cart";
const NOTE = "note";
const NAME = "name";
const SKU = "sku";

class LocalStorage {
  encodeMap(value) {
    return jsonEncode(value);
  }

  setValue({String key, String value}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(key, value);
  }

  getValue({String key}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var value = await sp.getString(key);
    return jsonDecode(value);
  }

  getNoteForSku({String sku}) async {
    var localCart = await LocalCart;
    // var index = localCart.indexWhere((item) => item[sku] == newItem[sku]);
    var item =
        localCart.singleWhere((item) => item[SKU] == sku, orElse: () => null);
    if (item != null) {
      return item[NOTE];
    } else
      return "";
  }

  get LocalCart async {
    var localCart;
    try {
      localCart = await getValue(key: CART_KEY);
    } catch (e) {
      localCart = null;
    }
    if (localCart != null) {
      print("LOCAL_CART: $localCart");
      return localCart;
    } else
      return null;
  }

  addNewItemToCart({String sku, String name, String note}) async {
    if (note.isEmpty || note == null) {
      print("note was empty hence not saving");
      return;
    }
    String noteTrimmed = note.replaceAll("\\n", " ").trim();
    print("NOTE TRIMED: $noteTrimmed");
    var newItem = {
      SKU: sku,
      NAME: name,
      NOTE: noteTrimmed ?? "",
    };

    var localCart = await LocalCart;
    if (localCart != null) {
      var items = localCart.where((item) => item[SKU] == newItem[SKU]).toList();
      if (items.isEmpty) {
        //a newly to be added product
        localCart.add(newItem);
        setValue(key: CART_KEY, value: jsonEncode(localCart));
      } else {
        var index = localCart.indexWhere((item) => item[SKU] == newItem[SKU]);
        if (index != -1) {
          localCart[index][NOTE] = note.replaceAll("\\n", " ").trim();
          setValue(key: CART_KEY, value: jsonEncode(localCart));
        }
      }
    } else {
      //there was no local cart
      var cart = [];
      cart.add(newItem);
      setValue(key: CART_KEY, value: jsonEncode(cart));
    }
  }

  removeItem({String sku}) async {
    var localCart = await LocalCart;
    if (localCart == null) {
      print("nothing to remove");
      return;
    }
    var index = localCart.indexWhere((item) => item[SKU] == sku);
    print("index_to_remove: $index");
    if (index != -1) {
      localCart.removeAt(index);
      setValue(key: CART_KEY, value: jsonEncode(localCart));
    }
  }

  clearCart() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.containsKey(CART_KEY)) {
      await sp.remove(CART_KEY);
    }
  }

  get deliveryNote async {
    var localCart = await LocalCart;
    String notes = "";
    localCart.forEach((item) {
      String newLn = "\n";
      notes += newLn +
          item[NAME] +
          " " +
          "(${item[SKU]})" +
          newLn +
          item[NOTE] +
          newLn;
    });
    String header = "\n\n-----" + "\nProduct notes" + "\n-----\n";
    return header + notes;
  }
}
