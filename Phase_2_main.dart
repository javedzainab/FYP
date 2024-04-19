import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:localstorage/localstorage.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ArCoreController arCoreController;
  bool isOriginPlaced = false; // To check if the origin has been placed
  //
  final LocalStorage storage = new LocalStorage('ar_objects.json');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARCore Flutter'),
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          loadAndPlaceObjects();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  void savePosition(String type, vector.Vector3 position) async {
    await storage.ready;
    List<dynamic> existingData = storage.getItem('positions') ?? [];
    existingData.add({
      'type': type,
      'x': position.x,
      'y': position.y,
      'z': position.z,
    });
    await storage.setItem('positions', existingData);
    print('Saved positions: $existingData');
  }


  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onNodeTap = (name) => print("Tapped $name");
    arCoreController.onPlaneTap = _handleOnPlaneTap;
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;
    if (!isOriginPlaced) {
      _addSphere(hit.pose.translation);
      isOriginPlaced = true; // Set origin as placed
    } else {
      _addCube(hit.pose.translation);
    }
  }

  void _addSphere(vector.Vector3 position, {bool placedPreviously = false}) {
    final material = ArCoreMaterial(color: Color.fromARGB(120, 66, 134, 244));
    final sphere = ArCoreSphere(materials: [material], radius: 0.1);
    final node = ArCoreNode(
      shape: sphere,
      position: position,
    );
    arCoreController.addArCoreNode(node);
    if (!placedPreviously) {
      savePosition('sphere', position);
    }
  }

  void _addCube(vector.Vector3 position, {bool placedPreviously = false}) {
    final material = ArCoreMaterial(color: Colors.blue, metallic: 1.0);
    final cube = ArCoreCube(materials: [material], size: vector.Vector3(0.1, 0.1, 0.1));
    final node = ArCoreNode(
      shape: cube,
      position: position,
    );
    arCoreController.addArCoreNode(node);
    if (!placedPreviously) {
      savePosition('cube', position);
    }
  }

  void loadAndPlaceObjects() async {
    await storage.ready;
    List<dynamic> storedPositions = storage.getItem('positions') ?? [];
    for (var positionData in storedPositions) {
      vector.Vector3 position = vector.Vector3(
        positionData['x'],
        positionData['y'],
        positionData['z'],
      );
      if (positionData['type'] == 'sphere') {
        _addSphere(position, placedPreviously: true);
      } else if (positionData['type'] == 'cube') {
        _addCube(position, placedPreviously: true);
      }
    }
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}
