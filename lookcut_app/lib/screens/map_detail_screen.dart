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

  // LOCATION CARD
  Widget buildLocationCard() {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    Colors.orange.shade100,
                child: Icon(
                  Icons.location_on,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.barbershopLocation,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.post.barberName ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // LATITUDE
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.my_location),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${l10n.latitude} : $latitude',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // LONGITUDE
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.explore),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${l10n.longitude} : $longitude',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(l10n.locationDetail),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          buildMap(),
          const SizedBox(height: 20),
          buildLocationCard(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: openGoogleMaps,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.directions),
              label: Text(l10n.openInGoogleMaps),
            ),
          ),
        ],
      ),
    );
  }
}
