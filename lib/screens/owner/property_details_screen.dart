import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../models/room_model.dart';
import '../../services/property_service.dart';
import '../../utils/app_theme.dart';
import 'room_details_screen.dart';
import 'package:provider/provider.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final propertyService = Provider.of<PropertyService>(context, listen: false);

    return StreamBuilder<PropertyModel>(
      stream: propertyService.getPropertyStream(widget.property.id),
      initialData: widget.property,
      builder: (context, snapshot) {
        final property = snapshot.data!;
        
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Text(property.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyInfo(property),
                const SizedBox(height: 32),
                _buildJoinCodeSection(property, propertyService),
                const SizedBox(height: 32),
                _buildHeader('Rooms', () => _showAddRoomDialog(context, property.id)),
                const SizedBox(height: 16),
                _buildRoomsList(property.id, propertyService),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPropertyInfo(PropertyModel property) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${property.address}, ${property.city}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          if (property.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              property.description,
              style: const TextStyle(color: AppTheme.lightTextColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJoinCodeSection(PropertyModel property, PropertyService service) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Secure Join Code',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                property.joinCode ?? '------',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => service.updateJoinCode(property.id, 24),
              ),
            ],
          ),
          if (property.joinCodeExpiry != null)
            Text(
              'Expires: ${property.joinCodeExpiry.toString().split('.')[0]}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add Room'),
        ),
      ],
    );
  }

  Widget _buildRoomsList(String propertyId, PropertyService service) {
    return StreamBuilder<List<RoomModel>>(
      stream: service.getRoomsStream(propertyId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('No rooms added yet.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final room = snapshot.data![index];
            return _buildRoomCard(room, propertyId);
          },
        );
      },
    );
  }

  Widget _buildRoomCard(RoomModel room, String propertyId) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailsScreen(propertyId: propertyId, room: room),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Room ${room.roomNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Rent: ₹${room.rentAmount}', style: const TextStyle(color: AppTheme.lightTextColor)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(room.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                room.status,
                style: TextStyle(color: _getStatusColor(room.status), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available': return Colors.green;
      case 'Full': return Colors.red;
      default: return Colors.orange;
    }
  }

  void _showAddRoomDialog(BuildContext context, String propertyId) {
    final nameController = TextEditingController();
    final rentController = TextEditingController();
    final octController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Room Name/No.')),
            TextField(controller: rentController, decoration: const InputDecoration(labelText: 'Monthly Rent'), keyboardType: TextInputType.number),
            TextField(controller: octController, decoration: const InputDecoration(labelText: 'Max Occupancy'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newRoom = RoomModel(
                id: '',
                propertyId: propertyId,
                roomNumber: nameController.text,
                rentAmount: double.tryParse(rentController.text) ?? 0.0,
                maxOccupancy: int.tryParse(octController.text) ?? 1,
                createdAt: DateTime.now(),
              );
              Provider.of<PropertyService>(context, listen: false).addRoom(newRoom);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
