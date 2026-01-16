import 'package:flutter/material.dart';

import '../../models/cattle.dart';
import '../cow_detail_profile/cow_detail_profile.dart';

class CattlePage extends StatelessWidget {
  final String cattleId;
  final String cattleName;

  const CattlePage({
    super.key,
    required this.cattleId,
    required this.cattleName,
  });

  @override
  Widget build(BuildContext context) {
    /// Temporary cattle object to satisfy CowDetailProfile
    final cattle = Cattle(
      id: cattleId,
      name: cattleName,
      breed: '',
      tagId: '',
      dob: null,
      photoUrl: null,
    );

    /// Redirect immediately to correct cow detail screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CowDetailProfile(cattle: cattle),
        ),
      );
    });

    /// Loading placeholder while redirecting
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
