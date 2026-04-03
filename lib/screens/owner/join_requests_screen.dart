import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/join_request_model.dart';
import '../../services/auth_service.dart';
import '../../services/property_service.dart';
import '../../utils/app_theme.dart';

class JoinRequestsScreen extends StatelessWidget {
  const JoinRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final propertyService = Provider.of<PropertyService>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: const Text('Join Requests', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<JoinRequestModel>>(
        stream: propertyService.getOwnerJoinRequestsStream(authService.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return Center(
              child: Text('No pending join requests.', style: TextStyle(color: AppTheme.subtext(context))),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestCard(context, request, propertyService);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, JoinRequestModel request, PropertyService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.softShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primary(context).withValues(alpha: 0.1),
                child: Text(request.tenantName[0].toUpperCase(), style: TextStyle(color: AppTheme.primary(context))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.tenantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(request.tenantPhone, style: TextStyle(color: AppTheme.subtext(context), fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            'Requesting to join:',
            style: TextStyle(color: AppTheme.subtext(context), fontSize: 12),
          ),
          Text(
            request.propertyName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => service.handleJoinRequest(request.id, false),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => service.handleJoinRequest(request.id, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
