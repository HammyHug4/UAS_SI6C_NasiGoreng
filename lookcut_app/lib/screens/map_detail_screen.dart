import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lookcut_app/l10n/generated/app_localizations.dart';
import 'package:lookcut_app/models/post_model.dart';

class MapDetailScreen extends StatefulWidget {
  final PostModel post;

  const MapDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<MapDetailScreen> createState() =>
      _MapDetailScreenState();
}

class _MapDetailScreenState
    extends State<MapDetailScreen> {

  late double latitude;
  late double longitude;

  @override
  void initState() {
    super.initState();

    latitude = double.tryParse(
          widget.post.latitude ?? '0',
        ) ??
        0;

    longitude = double.tryParse(
          widget.post.longitude ?? '0',
        ) ??
        0;
  }

  // OPEN GOOGLE MAPS
  Future<void> openGoogleMaps() async {
    final Uri googleMapUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(
        googleMapUrl,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // BUILD MAP
  Widget buildMap() {
    final LatLng point = LatLng(
      latitude,
      longitude,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 420,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15,
            interactionOptions:
                const InteractionOptions(
              flags:
                  InteractiveFlag.all,
            ),
          ),
          children: [

            // MAP TILE
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName:
                  'com.lookcut.maps',
            ),

            // MARKER
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 100,
                  height: 100,
                  child: Column(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),
                        ),
                        child: Text(
                          widget.post.barberName ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 50,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 