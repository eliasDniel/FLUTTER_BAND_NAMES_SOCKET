import 'dart:io';

import 'package:band_names_app/models/ban.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Piso 21', votes: 5),
    Band(id: '2', name: 'Morat', votes: 3),
    Band(id: '3', name: 'Aventura', votes: 4),
    Band(id: '4', name: 'CNCO', votes: 2),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Band Names'), elevation: 2),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, index) {
          final band = bands[index];
          return _CustomBand(
            band: band,
            onDismissed: (direction) {
              debugPrint('Direction: $direction');
              debugPrint('id: ${band.id}');
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addBand() {
    final TextEditingController textController = TextEditingController();

    if (!Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('New band name:'),
            content: TextField(
              controller: textController,
              //onChanged: (value) => print(value),
            ),
            actions: [
              MaterialButton(
                onPressed: () => addBandToList(textController.text),
                elevation: 5,
                textColor: Colors.blue,
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }
    if (!Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('New band name:'),
            content: CupertinoTextField(
              controller: textController,
              //onChanged: (value) => print(value),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => addBandToList(textController.text),
                child: const Text('Add'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss'),
              ),
            ],
          );
        },
      );
    }
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }
    Navigator.pop(context);
  }
}

class _CustomBand extends StatelessWidget {
  final void Function(DismissDirection)? onDismissed;
  const _CustomBand({required this.band, required this.onDismissed});

  final Band band;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: onDismissed,
      background: Container(
        padding: const EdgeInsets.only(left: 8),
        alignment: Alignment.centerLeft,
        color: Colors.red,
        child: const Text('Delete Band', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      child: ListTile(
        leading: CircleAvatar(child: Text(band.name.substring(0, 2))),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        onTap: () {
          debugPrint(band.name);
        },
      ),
    );
  }
}
