import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatelessWidget {
  final LatLng center;
  final List<Marker> markers;
  final double height;
  final double zoom;

  const MapWidget({
    super.key,
    required this.center,
    required this.markers,
    this.height = 200,
    this.zoom = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FlutterMap(
          options: MapOptions(
            center: center,
            zoom: zoom,
            minZoom: 5,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sigab.app',
            ),
            MarkerLayer(
              markers: markers,
            ),
          ],
        ),
      ),
    );
  }
}
