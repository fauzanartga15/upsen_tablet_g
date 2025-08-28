// lib/app/ui/pages/home/home.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/home.controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final padding = isTablet ? 32.0 : 20.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFede9fe), // Light purple
              Color(0xFFeff6ff), // Light blue
              Color(0xFFe0f7fa), // Light cyan
            ],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with company branding
              _buildHeader(context, isTablet),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      // Statistics cards
                      _buildStatsGrid(context, isTablet),

                      SizedBox(height: isTablet ? 32 : 24),

                      // Main action button
                      _buildMainAction(context, isTablet),

                      SizedBox(height: isTablet ? 32 : 24),

                      // Recent activity
                      _buildRecentActivity(context, isTablet),

                      SizedBox(height: isTablet ? 24 : 16),

                      // Status indicators
                      _buildStatusIndicators(context, isTablet),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    // final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: isTablet ? 140 : 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF26a69a), Color(0xFF009688), Color(0xFF004d40)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
        child: Row(
          children: [
            // Company logo - Use available assets
            Container(
              width: isTablet ? 70 : 60,
              height: isTablet ? 70 : 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
                child: Image.asset(
                  'assets/images/infazio-icon.jpg', // Square logo
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image not found
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF26a69a), Color(0xFF009688)],
                        ),
                        borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
                      ),
                      child: Icon(
                        Icons.business,
                        color: Colors.white,
                        size: isTablet ? 35 : 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: isTablet ? 20 : 16),

            // Company info - Responsive text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Text(
                      controller.companyName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Employee Attendance Portal',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isTablet ? 16 : 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Actions row
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Settings button
                IconButton(
                  onPressed: controller.navigateToSettings,
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: isTablet ? 28 : 24,
                  ),
                ),

                SizedBox(width: isTablet ? 12 : 8),

                // Current time
                Obx(
                  () => Text(
                    controller.currentTime,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isTablet) {
    return Obx(() {
      final stats = controller.dashboardStats;
      if (stats == null && controller.isLoadingStats) {
        return _buildLoadingStats(isTablet);
      }

      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'PRESENT',
              stats?.totalEmployees.toString() ?? '42',
              Icons.people,
              Color(0xFF10B981),
              isTablet,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: _buildStatCard(
              'CHECKED IN',
              stats?.checkedIn.toString() ?? '38',
              Icons.login,
              Color(0xFF3B82F6),
              isTablet,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: _buildStatCard(
              'CHECKED OUT',
              stats?.checkedOut.toString() ?? '15',
              Icons.logout,
              Color(0xFFF59E0B),
              isTablet,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLoadingStats(bool isTablet) {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < 2 ? (isTablet ? 16 : 12) : 0,
            ),
            height: isTablet ? 120 : 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF26a69a)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isTablet ? 28 : 24),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isTablet ? 6 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainAction(BuildContext context, bool isTablet) {
    return GestureDetector(
      onTap: controller.navigateToCamera,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF26a69a), Color(0xFF009688), Color(0xFF004d40)],
          ),
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF26a69a).withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: isTablet ? 56 : 48,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'Face Recognition Ready',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 6 : 4),
            Text(
              'Position your face to begin attendance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: isTablet ? 16 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, bool isTablet) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: isTablet ? 300 : screenHeight * 0.25,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Expanded(
            child: ListView.builder(
              itemCount: 3, // Mock data
              itemBuilder: (context, index) {
                final activities = [
                  {
                    'name': 'John Doe - IT Department',
                    'action': 'Checked in at 08:15 AM (On time)',
                    'color': Color(0xFF10B981),
                  },
                  {
                    'name': 'Jane Smith - HR',
                    'action': 'Checked in at 08:23 AM (On time)',
                    'color': Color(0xFF10B981),
                  },
                  {
                    'name': 'Mike Johnson - Marketing',
                    'action': 'Checked in at 08:35 AM (Late)',
                    'color': Color(0xFFF59E0B),
                  },
                ];

                final activity = activities[index];

                return Container(
                  margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                    border: Border(
                      left: BorderSide(
                        color: activity['color'] as Color,
                        width: isTablet ? 5 : 4,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['name'] as String,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e293b),
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        '✓ ${activity['action']}',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          color: Color(0xFF64748b),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicators(BuildContext context, bool isTablet) {
    return Obx(
      () => Wrap(
        spacing: isTablet ? 24 : 16,
        runSpacing: isTablet ? 12 : 8,
        alignment: WrapAlignment.spaceEvenly,
        children: [
          _buildStatusItem(
            'System Online',
            controller.isOnline,
            controller.isOnline ? Colors.green : Colors.red,
            isTablet,
          ),
          _buildStatusItem('Camera Active', true, Colors.blue, isTablet),
          if (controller.queueCount > 0)
            _buildStatusItem(
              '${controller.queueCount} Queued',
              false,
              Colors.orange,
              isTablet,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    String label,
    bool isActive,
    Color color,
    bool isTablet,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isTablet ? 14 : 12,
          height: isTablet ? 14 : 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: isTablet ? 10 : 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: Color(0xFF334155),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
