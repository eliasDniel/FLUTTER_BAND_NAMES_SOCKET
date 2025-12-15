import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;
  ServerStatus get serverStatus => _serverStatus;

  SocketService() {
    initConfig();
  }

  void initConfig() {
    IO.Socket socket = IO.io('http://192.168.1.11:3000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });
    socket.onDisconnect((_) {

      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });
    
    socket.on('new-message', (dynamic payload) {
      print('Nuevo Mensaje');
      print('Nombre: ${payload['nombre']}');
      print('Mensaje: ${payload['message']}');
    });
  }
}
