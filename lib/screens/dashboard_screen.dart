import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AdminService adminService = AdminService();

  List places = [];
  bool isLoading = true;

  String selectedStatus = '';

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  Future<void> fetchPlaces() async {
    final result = await adminService.getPlaces(selectedStatus);

    setState(() {
      places = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<String>(
            initialValue: selectedStatus.isEmpty ? null : selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Filter Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: '', child: Text('Semua')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'approved', child: Text('Approved')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              DropdownMenuItem(value: 'archived', child: Text('Archived')),
            ],
            onChanged: (value) {
              setState(() {
                selectedStatus = value ?? '';
                isLoading = true;
              });

              fetchPlaces();
            },
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    place['name'] ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place['address'] ?? '-'),

                      const SizedBox(height: 8),

                      Chip(
                        label: Text(place['status'] ?? '-'),
                        backgroundColor: place['status'] == 'approved'
                            ? Colors.green.shade100
                            : place['status'] == 'rejected'
                            ? Colors.red.shade100
                            : Colors.orange.shade100,
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await adminService.approvePlace(place['id']);

                          fetchPlaces();
                        },
                        child: const Text('Approve'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await adminService.rejectPlace(
                            place['id'],
                            'Tidak sesuai',
                          );

                          fetchPlaces();
                        },
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedStatus.isEmpty
                        ? null
                        : selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Filter Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Semua')),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'approved',
                        child: Text('Approved'),
                      ),
                      DropdownMenuItem(
                        value: 'rejected',
                        child: Text('Rejected'),
                      ),
                      DropdownMenuItem(
                        value: 'archived',
                        child: Text('Archived'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value ?? '';
                        isLoading = true;
                      });

                      fetchPlaces();
                    },
                  ),
                ),

                Expanded(
                  child: places.isEmpty
                      ? const Center(child: Text('Tidak ada place'))
                      : ListView.builder(
                          itemCount: places.length,
                          itemBuilder: (context, index) {
                            final place = places[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(
                                  place['name'] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(place['address'] ?? '-'),

                                    const SizedBox(height: 8),

                                    Chip(
                                      label: Text(place['status'] ?? '-'),
                                      backgroundColor:
                                          place['status'] == 'approved'
                                          ? Colors.green.shade100
                                          : place['status'] == 'rejected'
                                          ? Colors.red.shade100
                                          : Colors.orange.shade100,
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        await adminService.approvePlace(
                                          place['id'],
                                        );

                                        fetchPlaces();
                                      },
                                      child: const Text('Approve'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await adminService.rejectPlace(
                                          place['id'],
                                          'Tidak sesuai',
                                        );

                                        fetchPlaces();
                                      },
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
