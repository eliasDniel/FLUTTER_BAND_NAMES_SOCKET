import 'package:band_names_app/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);


    if (socketService.serverStatus == ServerStatus.connecting) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Server Status')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Server Status: ${socketService.serverStatus.name}',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          socketService.emit('emit-message', {
            'nombre': 'Flutter',
            'message': 'Hola desde Flutter',
          });
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}
