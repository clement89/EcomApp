import 'package:flutter/material.dart';

import 'product.dart';

class CartItem with ChangeNotifier {
  int itemId, quantity, quantityMagento, maximumQuantity, minimumQuantity;
  Product product;
  bool hasVariants = false;
  List<Product> variants = [];
  bool productInStockMagento;
  double rowTotal, finalRowTotal, taxAmount, finalTax, discountAmount;

  setVariants(List<Product> _variants) {
    variants.clear();
    variants.addAll(_variants);
  }

  CartItem({
    @required this.itemId,
    @required this.product,
    @required this.quantity,
    this.productInStockMagento,
    this.quantityMagento,
    this.maximumQuantity,
    this.minimumQuantity,
    @required this.finalTax,
    @required this.taxAmount,
    @required this.rowTotal,
    @required this.finalRowTotal,
    @required this.discountAmount,
  }) {
    if (product.inStock) {
      if (productInStockMagento) {
        if (!(product.isBackOrder ?? false) == true) {
          if (quantity > quantityMagento) {
            hasVariants = true;
          } else {
            if (quantity > maximumQuantity) {
              hasVariants = true;
            }
          }
        }
      } else {
        hasVariants = true;
      }
    } else {
      hasVariants = true;
    }
  }
}
