import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/cattle.dart';
import 'widgets/cattle_card_widget.dart';
import 'widgets/empty_state_widget.dart';
import '../cow_detail_profile/cow_detail_profile.dart';

class CattleList extends StatelessWidget {
  const CattleList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cattle')
          .where('ownerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return EmptyStateWidget(
            title: 'No cattle yet',
            subtitle: 'Tap + to add your first cattle',
            buttonText: 'Add Cattle',
            onButtonPressed: () {
              Navigator.pushNamed(context, '/cattle-management-screen');
            },
          );
        }

        final cattleList = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Cattle(
            id: doc.id,
            name: data['name'] ?? '',
            tagId: data['tagId'] ?? '',
            breed: data['breed'] ?? '',
            dob: data['dob'] != null
                ? (data['dob'] as Timestamp).toDate()
                : null,
            status: data['status'] ?? 'healthy',
            lastMilk: (data['lastMilk'] ?? 0).toDouble(),
            photoUrl: data['photoUrl'],
            ownerId: data['ownerId'],
          );
        }).toList();

        return ListView.builder(
          itemCount: cattleList.length,
          itemBuilder: (context, index) {
            final cattle = cattleList[index];

            return CattleCardWidget(
              cattle: cattle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CowDetailProfile(cattle: cattle),
                  ),
                );
              },
              onDelete: () async {
                await FirebaseFirestore.instance
                    .collection('cattle')
                    .doc(cattle.id)
                    .delete();
              },
            );
          },
        );
      },
    );
  }
}
