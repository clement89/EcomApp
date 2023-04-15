class Queries {
  String createCartQueryString() {
    return """mutation {
  createEmptyCart
  }""";
  }

  String addItemToCartQueryString(
      {String cartId, String quantity, String sku}) {
    return """mutation {\n  addSimpleProductsToCart(\n    input: {\n      cart_id: \"$cartId\"\n      cart_items: [\n        {\n          data: {\n            quantity: $quantity\n            sku: \"$sku\"\n          }\n        }\n      ]\n    }\n  ) {\n    cart {\n      items {\n        id\n        product {\n          sku\n          stock_status\n        }\n        quantity\n      }\n    }\n  }\n}""";
  }

  String viewCartItemsQueryString({String cartId}) {
    return """{\n  cart(cart_id: \"$cartId\") {\n    email\n    billing_address {\n      city\n      country {\n        code\n        label\n      }\n      firstname\n      lastname\n      postcode\n      region {\n        code\n        label\n      }\n      street\n      telephone\n    }\n    shipping_addresses {\n      firstname\n      lastname\n      street\n      city\n      region {\n        code\n        label\n      }\n      country {\n        code\n        label\n      }\n      telephone\n      pickup_location_code\n      available_shipping_methods {\n        amount {\n          currency\n          value\n        }\n        available\n        carrier_code\n        carrier_title\n        error_message\n        method_code\n        method_title\n        price_excl_tax {\n          value\n          currency\n        }\n        price_incl_tax {\n          value\n          currency\n        }\n      }\n      selected_shipping_method {\n        amount {\n          value\n          currency\n        }\n        carrier_code\n        carrier_title\n        method_code\n        method_title\n      }\n    }\n    items {\n      id\n      product {\n        name\n        sku\n      }\n      quantity\n    }\n    available_payment_methods {\n      code\n      title\n    }\n    selected_payment_method {\n      code\n      title\n    }\n    applied_coupons {\n      code\n    }\n    prices {\n      grand_total {\n        value\n        currency\n      }\n    }\n  }\n}""";
  }

  String updateCartQueryString(
      {String cartId, String quantity, String cartItemUid}) {
    return """mutation {
  updateCartItems(
    input: {
      cart_id: \"$cartId\",
      cart_items: [
        {
          cart_item_id: $cartItemUid
          quantity: $quantity
        }
      ]
    }
  ){
    cart {
      items {
        id
        product {
          name
        }
        quantity
      }
      prices {
        grand_total{
          value
          currency
        }
      }
    }
  }
}""";
  }

  String deleteItemInCartQueryString({String cartId, String cartItemUid}) {
    return """mutation {
  removeItemFromCart(
    input: {
      cart_id: \"$cartId\",
      cart_item_id: $cartItemUid
    }
  )
 {
  cart {
    items {
      id
      product {
        name
      }
      quantity
    }
    prices {
      grand_total{
        value
        currency
      }
    }
  }
 }
}""";
  }
}
