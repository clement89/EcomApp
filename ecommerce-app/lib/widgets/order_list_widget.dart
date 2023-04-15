import 'package:Nesto/providers/orders_provider.dart';
import 'package:Nesto/screens/order_listing_screen.dart';
import 'package:Nesto/widgets/edge_cases/no_completed_orders.dart';
import 'package:Nesto/widgets/product_list_container_orders.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductList extends StatelessWidget {


  Function navigatePage(String orderid,BuildContext ctx) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (context) {
          return OrderListingScreen(
            orderid: orderid,
          );
        },
      ),
    );
  }
  Widget ContainerSelect(int index, BuildContext ctx) {
    var provider =
        Provider.of<OrderProvider>(ctx).orderlistofcompletedtest[index];
    if (provider.status == 'cancelled'||provider.status == 'canceled') {
      return InkWell(
        onTap: () {
          navigatePage(provider.orderid, ctx);
        },
        child: ProductListContainer(
          provider.title,
          provider.datetime,
          provider.increment_id,
          provider.noitem,
          provider.price,
          'assets/svg/place_holder_3_arun.svg',
          Colors.red,
        ),
      );
    } else if (provider.status == 'delivered') {
      return InkWell(
        onTap: () {
          navigatePage(provider.orderid, ctx);
        },
        child: ProductListContainer(
          provider.title,
          provider.datetime,
          provider.increment_id,
          provider.noitem,
          provider.price,
          'assets/svg/place_holder_4_arun.svg',
          Colors.green,
        ),
      );
    } else if (provider.status == 'return_initiated') {
      return InkWell(
        onTap: () {
          navigatePage(provider.orderid, ctx);
        },
        child: ProductListContainer(
          provider.title,
          provider.datetime,
          provider.increment_id,
          provider.noitem,
          provider.price,
          'assets/svg/place_holder_4_arun.svg',
          Colors.green,
        ),
      );
    } else if (provider.status == 'returned') {
      return InkWell(
        onTap: () {
          navigatePage(provider.orderid, ctx);
        },
        child: ProductListContainer(
          provider.title,
          provider.datetime,
          provider.increment_id,
          provider.noitem,
          provider.price,
          'assets/svg/place_holder_4_arun.svg',
          Colors.green,
        ),
      );
    } else if (provider.status == 'return_collected') {
      return InkWell(
        onTap: () {
          navigatePage(provider.orderid, ctx);
        },
        child: ProductListContainer(
          provider.title,
          provider.datetime,
          provider.increment_id,
          provider.noitem,
          provider.price,
          'assets/svg/place_holder_4_arun.svg',
          Colors.green,
        ),
      );
    } else if (provider.status == 'closed') {
      return InkWell(
        onTap: () {
          navigatePage(provider.orderid, ctx);
        },
        child: ProductListContainer(
          provider.title,
          provider.datetime,
          provider.increment_id,
          provider.noitem,
          provider.price,
          'assets/svg/place_holder_4_arun.svg',
          Colors.green,
        ),
      );
    }else if (provider.status == 'return_cancelled') {
      return InkWell(
        onTap: () {
          navigatePage(provider.orderid, ctx);
        },
        child: ProductListContainer(
          provider.title,
          provider.datetime,
          provider.increment_id,
          provider.noitem,
          provider.price,
          'assets/svg/place_holder_3_arun.svg',
          Colors.red,
        ),
      );
    } /*else {
      return InkWell(
        onTap: () {
          navigatePage(provider.orderid, ctx);
        },
        child: ProductListContainer(
          provider.title,
          provider.datetime,
          provider.increment_id,
          provider.noitem,
          provider.price,
          'assets/svg/place_holder_4_arun.svg',
          Colors.green,
        ),
      );
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<OrderProvider>(context)
                .orderlistofcompletedtest
                .length ==
            0
        ? Container(
            child: NoCompletedOrdersWidget(),
          )
        : Container(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: Provider.of<OrderProvider>(context)
                  .orderlistofcompletedtest
                  .length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ContainerSelect(index, context),
                    ],
                  ),
                );
              },
            ),
          );
  }
}
