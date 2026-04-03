import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/join_request_model.dart';
import '../../models/room_request_model.dart';
import '../../services/property_service.dart';
import '../../services/auth_service.dart';

class RequestsHubScreen extends StatelessWidget {
  const RequestsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final propertyService = Provider.of<PropertyService>(context);
    final authService = Provider.of<AuthService>(context);
    final ownerId = authService.currentUser!.uid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Requests Hub'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Property Joins'),
              Tab(text: 'Room Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildJoinRequestsTab(propertyService, ownerId),
            _buildRoomRequestsTab(propertyService, ownerId),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinRequestsTab(PropertyService service, String ownerId) {
    return StreamBuilder<List<JoinRequestModel>>(
      stream: service.getOwnerJoinRequestsStream(ownerId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final requests = snapshot.data!;

        if (requests.isEmpty) {
          return const Center(child: Text('No pending join requests.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return _buildRequestCard(
              context,
              tenantId: req.tenantId,
              title: req.tenantName,
              subtitle: 'Wants to join your property',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => service.handleJoinRequest(req.id, true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => service.handleJoinRequest(req.id, false),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRoomRequestsTab(PropertyService service, String ownerId) {
    return StreamBuilder<List<RoomRequestModel>>(
      stream: service.getOwnerRoomRequestsStream(ownerId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final requests = snapshot.data!;

        if (requests.isEmpty) {
          return const Center(child: Text('No pending room requests.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return _buildRequestCard(
              context,
              tenantId: req.tenantId,
              title: req.tenantName,
              subtitle: 'Requested Room ${req.roomNumber}',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => service.handleRoomRequest(req.id, true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => service.handleRoomRequest(req.id, false),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestCard(
    BuildContext context, {
    required String tenantId,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(tenantId).snapshots(),
      builder: (context, snapshot) {
        UserModel? user;
        if (snapshot.hasData && snapshot.data!.exists) {
          user = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null ? const Icon(Icons.person) : null,
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle),
                if (user?.bio != null && user!.bio!.isNotEmpty)
                  Text(
                    user.bio!,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: trailing,
          ),
        );
      },
    );
  }
}
