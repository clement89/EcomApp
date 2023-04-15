import 'package:Nesto/services/connectivity_check_service.dart';
import 'package:Nesto/widgets/edge_cases/connection_lost.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectivityWidget extends StatelessWidget {
  ConnectivityWidget({@required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    return connectionStatus == ConnectivityStatus.Offline
        ? ConnectionLostWidget()
        : child;
  }
}
