import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/user_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _farmController;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();

    _nameController = TextEditingController(text: user.name);
    _farmController = TextEditingController(text: user.farmName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _farmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // 👤 Profile icon placeholder
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),

            SizedBox(height: 4.h),

            // Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 2.h),

            // Farm name
            TextField(
              controller: _farmController,
              decoration: const InputDecoration(
                labelText: 'Farm Name',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 4.h),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: user.isLoading
                    ? null
                    : () async {
                  await context
                      .read<UserProvider>()
                      .updateProfile(
                    name: _nameController.text.trim(),
                    farmName: _farmController.text.trim(),
                  );

                  Navigator.pop(context);
                },
                child: user.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
