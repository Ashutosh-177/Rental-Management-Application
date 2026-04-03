import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

class TenantProfileDetailsScreen extends StatelessWidget {
  final String tenantId;
  const TenantProfileDetailsScreen({super.key, required this.tenantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Tenant Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(tenantId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) return const Center(child: Text('Tenant not found.'));

          final user = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildHeader(user),
                const SizedBox(height: 32),
                _buildInfoSection('Contact Information', [
                  _buildInfoRow(Icons.phone_outlined, 'Phone', user.phoneNumber ?? 'Not provided'),
                  _buildInfoRow(Icons.email_outlined, 'Email', user.email ?? 'Not provided'),
                ]),
                const SizedBox(height: 24),
                _buildInfoSection('About', [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      user.bio?.isNotEmpty == true ? user.bio! : 'No bio provided.',
                      style: const TextStyle(color: AppTheme.lightTextColor, height: 1.5),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildInfoSection('Verification Status', [
                  Row(
                    children: [
                      Icon(
                        user.isVerified ? Icons.verified : Icons.pending_actions,
                        color: user.isVerified ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        user.isVerified ? 'Identity Verified' : 'Verification Pending',
                        style: TextStyle(
                          color: user.isVerified ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null ? const Icon(Icons.person, size: 60, color: AppTheme.primaryColor) : null,
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          'Tenant',
          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppTheme.lightTextColor)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
