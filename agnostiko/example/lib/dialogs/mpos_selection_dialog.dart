import 'package:flutter/material.dart';

import 'package:agnostiko/agnostiko.dart';
import '../../utils/locale.dart';

Future<BluetoothDevice?> showMPOSSelectionDialog(
  BuildContext context,
  List<BluetoothDevice> bondedDevices,
) async {
  final mediaQuery = MediaQuery.of(context);

  // ordenamos la lista para que muestre los dispositivos conectados primero
  bondedDevices.sort((a, b) {
    if (a.isConnected && !b.isConnected) {
      return -1;
    } else if (b.isConnected && !a.isConnected) {
      return 1;
    }
    return 0;
  });

  return showDialog<BluetoothDevice?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Center(child: Text(getLocalizations(context).selectDevice)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        content: Container(
          height: (mediaQuery.size.height * 3) / 5,
          width: mediaQuery.size.width / 2,
          child: _bondedDevicesList(context, bondedDevices),
        ),
      );
    },
  );
}

ListView _bondedDevicesList(
  BuildContext context,
  List<BluetoothDevice> bondedDevices,
) {
  return ListView(
    children: ListTile.divideTiles(
      context: context,
      tiles: bondedDevices.map((device) {
        return ListTile(
          leading: device.isConnected
              ? Icon(Icons.mobile_friendly, color: Colors.green)
              : Icon(Icons.mobile_off, color: Colors.grey),
          title: Text(device.name ?? ""),
          subtitle: device.isConnected
              ? Text(
                  getLocalizations(context).connected,
                  style: TextStyle(color: Colors.green),
                )
              : Text(
                  getLocalizations(context).paired,
                  style: TextStyle(color: Colors.grey),
                ),
          onTap: () {
            Navigator.pop(context, device);
          },
        );
      }).toList(),
    ).toList(),
  );
}
