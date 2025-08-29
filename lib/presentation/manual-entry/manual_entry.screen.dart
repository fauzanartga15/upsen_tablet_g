// lib/presentation/manual-entry/manual_entry.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../infrastructure/theme/app-theme.dart';
import 'controllers/manual_entry.controller.dart';

class ManualEntryScreen extends GetView<ManualEntryController> {
  const ManualEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 20),
            child: Column(
              children: [
                // Header
                _buildHeader(isTablet),

                SizedBox(height: isTablet ? 32 : 24),

                // Search section
                _buildSearchSection(isTablet),

                SizedBox(height: isTablet ? 24 : 20),

                // Employee list
                Expanded(child: _buildEmployeeList(isTablet)),

                // Bottom actions
                _buildBottomActions(isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: AppTheme.glassmorphismDecoration.copyWith(
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: controller.goBack,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.textPrimary,
                  size: isTablet ? 24 : 20,
                ),
              ),
              Expanded(
                child: Text(
                  'Manual Entry',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(width: isTablet ? 48 : 40), // Balance for back button
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Search and select your name for attendance',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: AppTheme.glassmorphismDecoration,
      child: Column(
        children: [
          // Search input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              border: Border.all(color: AppTheme.upsenTeal.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              style: TextStyle(fontSize: isTablet ? 18 : 16),
              decoration: InputDecoration(
                hintText: 'Type your name here...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: isTablet ? 18 : 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.upsenTeal,
                  size: isTablet ? 28 : 24,
                ),
                suffixIcon: Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          onPressed: controller.clearSearch,
                          icon: Icon(
                            Icons.clear,
                            color: AppTheme.textSecondary,
                            size: isTablet ? 24 : 20,
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 20 : 16,
                ),
              ),
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Search stats
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  color: AppTheme.upsenTeal,
                  size: isTablet ? 20 : 18,
                ),
                SizedBox(width: isTablet ? 8 : 6),
                Text(
                  controller.isSearching.value
                      ? 'Searching...'
                      : '${controller.filteredEmployees.length} employees found',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList(bool isTablet) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState(isTablet);
      }

      if (controller.filteredEmployees.isEmpty) {
        return _buildEmptyState(isTablet);
      }

      return Container(
        decoration: AppTheme.glassmorphismDecoration,
        child: ListView.builder(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          itemCount: controller.filteredEmployees.length,
          itemBuilder: (context, index) {
            final employee = controller.filteredEmployees[index];
            return _buildEmployeeItem(employee, index, isTablet);
          },
        ),
      );
    });
  }

  Widget _buildLoadingState(bool isTablet) {
    return Container(
      decoration: AppTheme.glassmorphismDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.upsenTeal,
              strokeWidth: 3,
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Text(
              'Loading employees...',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Container(
      decoration: AppTheme.glassmorphismDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              color: AppTheme.textSecondary,
              size: isTablet ? 80 : 64,
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Text(
              controller.searchQuery.value.isEmpty
                  ? 'Start typing to search employees'
                  : 'No employees found',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              controller.searchQuery.value.isEmpty
                  ? 'Type at least 2 characters'
                  : 'Try a different search term',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeItem(
    Map<String, dynamic> employee,
    int index,
    bool isTablet,
  ) {
    final name = employee['name'] ?? 'Unknown';
    final department = employee['department'] ?? 'Unknown Department';
    final position = employee['position'] ?? '';
    final email = employee['email'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: AppTheme.upsenTeal.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.selectEmployee(employee),
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: isTablet ? 60 : 50,
                  height: isTablet ? 60 : 50,
                  decoration: BoxDecoration(
                    gradient: AppTheme.upsenGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: isTablet ? 16 : 12),

                // Employee info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        department,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (position.isNotEmpty) ...[
                        SizedBox(height: isTablet ? 2 : 1),
                        Text(
                          position,
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Selection arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.upsenTeal,
                  size: isTablet ? 20 : 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(bool isTablet) {
    return Container(
      padding: EdgeInsets.only(top: isTablet ? 24 : 20),
      child: Row(
        children: [
          Expanded(
            child: AppTheme.gradientButton(
              text: 'Back to Camera',
              icon: Icons.camera_alt,
              onPressed: controller.goToCamera,
              isSecondary: true,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: AppTheme.gradientButton(
              text: 'Home',
              icon: Icons.home,
              onPressed: controller.goHome,
            ),
          ),
        ],
      ),
    );
  }
}
