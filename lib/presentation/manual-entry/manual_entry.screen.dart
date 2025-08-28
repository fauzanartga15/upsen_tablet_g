import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/manual_entry.controller.dart';

class ManualEntryScreen extends GetView<ManualEntryController> {
  const ManualEntryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ManualEntryScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ManualEntryScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
