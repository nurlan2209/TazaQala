import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tazaqala/services/report_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tazaqala/utils/district_polygons.dart';
import 'package:provider/provider.dart';
import 'package:tazaqala/providers/auth_provider.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  File? _imageFile;
  LatLng? _selectedLatLng;
  final ImagePicker _picker = ImagePicker();
  final ReportService _reportService = ReportService();
  bool _isSubmitting = false;
  final MapController _mapController = MapController();

  final List<String> _categories = [
    'Қоқыс',
    'Жол бұзылуы',
    'Жарық жоқ',
    'Су ағып жатыр',
    'Ағаш кесу',
    'Басқа',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    final district = context.read<AuthProvider>().user?.district;
    final districtCenter = district != null ? DistrictPolygons.getCenter(district) : null;

    final initial = districtCenter ?? LatLng(position.latitude, position.longitude);
    if (mounted) {
      setState(() {
        _selectedLatLng = initial;
      });
      _mapController.move(initial, 13);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сурет таңдау'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камерадан түсіру'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галереядан таңдау'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_imageFile == null ||
        _selectedCategory == null ||
        _descriptionController.text.isEmpty ||
        _selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Барлық өрістер мен локацияны толтырыңыз')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _reportService.createReport(
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
        lat: _selectedLatLng!.latitude,
        lng: _selectedLatLng!.longitude,
        image: _imageFile!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Шағым сәтті жіберілді!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Қате: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final district = context.watch<AuthProvider>().user?.district;
    final polygon = district != null ? DistrictPolygons.polygons[district] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Хабарлама жасау'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Сурет қосу
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 48, color: Colors.grey[600]),
                    const SizedBox(height: 8),
                    Text('Сурет қосу', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Категория таңдау
            const Text('Категория', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
              DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              hint: const Text('Категорияны таңдаңыз'),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Сипаттама
            const Text('Сипаттама', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'Мәселені сипаттаңыз...',
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Локация картасы
            const Text('Орналасқан жерді таңдаңыз', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLatLng ?? (polygon != null ? DistrictPolygons.getCenter(district!) ?? const LatLng(51.1694, 71.4491) : const LatLng(51.1694, 71.4491)),
                    initialZoom: 13,
                    onTap: (tapPos, point) {
                      final allowed = _isInsideDistrict(point, polygon);
                      if (!allowed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Тек өз ауданыңыздың ішінде нүкте таңдаңыз')),
                        );
                        return;
                      }
                      setState(() {
                        _selectedLatLng = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.tazaqala',
                    ),
                    if (polygon != null)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: polygon,
                            color: Colors.green.withOpacity(0.15),
                            borderColor: Colors.green,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    if (_selectedLatLng != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLatLng!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedLatLng != null)
              Text(
                'Таңдалған нүкте: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            if (polygon != null)
              Text(
                'Аудан: $district',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            const SizedBox(height: 24),

            // Жіберу батырмасы
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Жіберу',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isInsideDistrict(LatLng point, List<LatLng>? polygon) {
    if (polygon == null || polygon.length < 3) return true;
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].latitude;
      final yi = polygon[i].longitude;
      final xj = polygon[j].latitude;
      final yj = polygon[j].longitude;

      final intersect = ((yi > point.longitude) != (yj > point.longitude)) &&
          (point.latitude < (xj - xi) * (point.longitude - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }
}
