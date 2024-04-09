import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARCore Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
        // useMaterial3: true, // Uncomment if using Material 3.0
      ),
      home: const ARViewPage(),
    );
  }
}

class ARViewPage extends StatefulWidget {
  const ARViewPage({Key? key}) : super(key: key);

  @override
  _ARViewPageState createState() => _ARViewPageState();
}

class _ARViewPageState extends State<ARViewPage> {
  late ArCoreController arCoreController;

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARCore Flutter Demo'),
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true,
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    _addSphere();
    _addCubes();
  }

  void _addSphere() {
    final material = ArCoreMaterial(color: Colors.deepOrange);
    final sphere = ArCoreSphere(materials: [material], radius: 0.1);
    final node = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(0, 0, 0), // Origin at (0,0,0)
    );
    arCoreController.addArCoreNode(node);
  }

  void _addCubes() {
    final material = ArCoreMaterial(color: Colors.blue);
    for (int i = 1; i <= 10; i++) {
      final cube = ArCoreCube(materials: [material], size: vector.Vector3(0.1, 0.1, 0.1));
      final node = ArCoreNode(
        shape: cube,
        position: vector.Vector3(i.toDouble(), 0, -i.toDouble()),
      );
      arCoreController.addArCoreNode(node);
    }
  }
}
