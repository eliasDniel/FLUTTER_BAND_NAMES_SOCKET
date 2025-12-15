import 'dart:io';
import 'package:band_names_app/models/ban.dart';
import 'package:band_names_app/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  void _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    if (bands.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Band Names'),
        elevation: 2,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.online
                ? const Icon(Icons.check_circle, color: Colors.blueAccent)
                : const Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          _showGraph(context),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => _CustomBand(
                band: bands[index],
                onDismissed: (direction) =>
                    socketService.emit('delete-band', {'id': bands[index].id}),
              ),
            ),
          ),
        ],
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
        builder: (_) => AlertDialog(
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
        ),
      );
    }
    if (!Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
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
        ),
      );
    }
  }

  void addBandToList(String name) {
    if (name.isEmpty) return;
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.emit('add-band', {'name': name});
    Navigator.pop(context);
  }

  Widget _showGraph(BuildContext context) {
    Map<String, double> dataMap = new Map();
    for (var band in bands) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: const [Colors.blue, Colors.pink, Colors.orange, Colors.purple],
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        centerText: "BANDS",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendShape: BoxShape.circle,
          legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      ),
    );
  }
}

class _CustomBand extends StatelessWidget {
  final void Function(DismissDirection)? onDismissed;
  const _CustomBand({required this.band, required this.onDismissed});

  final Band band;

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: onDismissed,
      background: Container(
        padding: const EdgeInsets.only(left: 8),
        alignment: Alignment.centerLeft,
        color: Colors.red,
        child: const Text(
          'Delete Band',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(child: Text(band.name.substring(0, 2))),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        onTap: () => socketService.emit('vote-band', {'id': band.id}),
      ),
    );
  }
}
