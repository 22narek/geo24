import 'dart:math';
import 'package:flutter/material.dart';

class GeoScreen extends StatefulWidget {
  const GeoScreen({Key? key}) : super(key: key);

  @override
  State<GeoScreen> createState() => _GeoScreenState();
}

class _GeoScreenState extends State<GeoScreen> {
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _zoomController = TextEditingController();
  List<int>? _tileNumber;

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Geoservice'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 40.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 15),
              TextFormFieldWidget(
                controller: _latitudeController,
                text: 'Latitude',
              ),
              const SizedBox(height: 15),
              TextFormFieldWidget(
                controller: _longitudeController,
                text: 'Longitude',
              ),
              const SizedBox(height: 15),
              TextFormFieldWidget(
                controller: _zoomController,
                text: 'Zoom Level',
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: _calculate,
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Calculate',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              if (_tileNumber != null)
                Center(
                  child: Text(
                    'Results: ${_tileNumber![0]}, ${_tileNumber![1]}',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              const SizedBox(height: 15),
              if (_tileNumber != null)
                SizedBox(
                    height: 250,
                    child: Image.network(
                        'https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=${_tileNumber![0]}&y=${_tileNumber![1]}&z=${_zoomController.text}&scale=1&lang=ru_RU'))
            ],
          ),
        ),
      ),
    );
  }

  void _calculate() {
    final latitude = double.tryParse(_latitudeController.text);
    final longitude = double.tryParse(_longitudeController.text);
    final z = int.tryParse(_zoomController.text);

    if (latitude != null && longitude != null && z != null) {
      setState(() {
        _tileNumber = pixelsToTileNumber(
          geoToPixels(latitude, longitude, projections[0], z)[0],
          geoToPixels(latitude, longitude, projections[0], z)[1],
        );
        FocusManager.instance.primaryFocus?.unfocus();
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter valid values'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
    }
  }
}

class TextFormFieldWidget extends StatelessWidget {
  const TextFormFieldWidget({
    super.key,
    required TextEditingController controller,
    required this.text,
  }) : _controller = controller;

  final TextEditingController _controller;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(
            color: Colors.blue,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 2.0,
          ),
        ),
        labelText: text,
      ),
    );
  }
}

//found on the internet
var projections = [
  {
    'name': 'wgs84Mercator',
    'eccentricity': 0.0818191908426,
  },
];

List<double> geoToPixels(
  double latitude,
  double longitude,
  Map<String, dynamic> projection,
  int z,
) {
  double xP, yP, rho, beta, phi, theta;
  const pi = 3.141592653589793;

  rho = pow(2, z + 8) / 2;
  beta = latitude * pi / 180;
  phi = (1 - projection['eccentricity'] * sin(beta)) /
      (1 + projection['eccentricity'] * sin(beta));
  theta = tan(pi / 4 + beta / 2) * pow(phi, projection['eccentricity'] / 2);

  xP = rho * (1 + longitude / 180);
  yP = rho * (1 - log(theta) / pi);

  return [xP, yP];
}

List<int> pixelsToTileNumber(double x, double y) {
  return [x ~/ 256, y ~/ 256];
}
