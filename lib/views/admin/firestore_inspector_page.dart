import 'package:flutter/material.dart';
import 'package:studycompanion_app/utils/firestore_data_inspector.dart';

/// Admin page to inspect Firestore database contents
/// This helps verify if data seeding worked correctly
class FirestoreInspectorPage extends StatefulWidget {
  const FirestoreInspectorPage({super.key});

  @override
  State<FirestoreInspectorPage> createState() => _FirestoreInspectorPageState();
}

class _FirestoreInspectorPageState extends State<FirestoreInspectorPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _inspectionReport;
  String _statusMessage = 'Tap "Inspect Database" to check Firestore contents';

  Future<void> _inspectDatabase() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Inspecting Firestore database...';
    });

    try {
      final report = await FirestoreDataInspector.inspectDatabase();
      
      setState(() {
        _inspectionReport = report;
        _isLoading = false;
        
        if (report['isEmpty'] == true) {
          _statusMessage = '❌ Database is EMPTY. No documents found.';
        } else {
          _statusMessage = '✅ Database has ${report['totalDocuments']} documents';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error inspecting database: $e';
      });
    }
  }

  Future<void> _quickCount() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Counting documents...';
    });

    try {
      await FirestoreDataInspector.quickCount();
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Check console for quick count results';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Database Inspector'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: _getStatusColor(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _getStatusIcon(),
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_inspectionReport != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Total: ${_inspectionReport!['totalDocuments']} documents',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _inspectDatabase,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search),
              label: const Text('Inspect Database'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _quickCount,
              icon: const Icon(Icons.speed),
              label: const Text('Quick Count (Check Console)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Results Display
            if (_inspectionReport != null) ...[
              const Text(
                'Collection Details:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              ...(() {
                final collections = _inspectionReport!['collections'];
                if (collections == null) return <Widget>[];
                
                final collectionsMap = collections is Map<String, dynamic> 
                    ? collections 
                    : Map<String, dynamic>.from(collections as Map);
                
                return collectionsMap.entries.map((entry) {
                  final collectionName = entry.key;
                  final dataValue = entry.value;
                  
                  final data = dataValue is Map<String, dynamic>
                      ? dataValue
                      : Map<String, dynamic>.from(dataValue as Map);
                  
                  final count = data['count'] ?? 0;
                  final sampleIdsValue = data['sampleIds'];
                  final sampleIds = sampleIdsValue != null 
                      ? (sampleIdsValue is List<dynamic> 
                          ? sampleIdsValue 
                          : List<dynamic>.from(sampleIdsValue as List))
                      : null;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        count > 0 ? Icons.check_circle : Icons.cancel,
                        color: count > 0 ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        collectionName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Documents: $count'),
                          if (sampleIds != null && sampleIds.isNotEmpty)
                            Text(
                              'Samples: ${sampleIds.join(", ")}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              })(),
            ],
            
            const SizedBox(height: 24),
            
            // Instructions Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'What This Shows:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Number of documents in each collection\n'
                      '• Sample document IDs from each collection\n'
                      '• Whether your database is empty or populated\n'
                      '• Check console logs for detailed output',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (_isLoading) return Colors.orange;
    if (_inspectionReport == null) return Colors.grey;
    if (_inspectionReport!['isEmpty'] == true) return Colors.red;
    return Colors.green;
  }

  IconData _getStatusIcon() {
    if (_isLoading) return Icons.hourglass_empty;
    if (_inspectionReport == null) return Icons.cloud_outlined;
    if (_inspectionReport!['isEmpty'] == true) return Icons.storage_outlined;
    return Icons.cloud_done;
  }
}
