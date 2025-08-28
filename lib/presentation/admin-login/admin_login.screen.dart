import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/admin_login.controller.dart';

class AdminLoginScreen extends GetView<AdminLoginController> {
  const AdminLoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdminLoginScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AdminLoginScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
