import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/property_service.dart';
import '../../utils/app_theme.dart';

class TenantHistoryScreen extends StatelessWidget {
  const TenantHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final propertyService = Provider.of<PropertyService>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Tenant History', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: propertyService.getOwnerTenantHistoryStream(authService.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return const Center(
              child: Text('No tenant history found.', style: TextStyle(color: AppTheme.lightTextColor)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final record = history[index];
              return _buildHistoryCard(record);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(record['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: const Text('FORMER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Property: ${record['propertyName']}', style: const TextStyle(fontSize: 14)),
          Text('Phone: ${record['phone']}', style: const TextStyle(color: AppTheme.lightTextColor, fontSize: 13)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Joined', style: TextStyle(fontSize: 11, color: AppTheme.lightTextColor)),
                  Text(_formatDate(record['joinedAt']), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Left', style: TextStyle(fontSize: 11, color: AppTheme.lightTextColor)),
                  Text(_formatDate(record['leftAt']), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red)),
                ],
              ),
            ],
          ),
          if (record['removalReason'] != null && record['removalReason'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Reason: ${record['removalReason']}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.lightTextColor)),
          ],
        ],
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '-';
    }
  }
}
