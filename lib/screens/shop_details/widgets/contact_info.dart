import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactInfo extends StatelessWidget {
  final String phoneNumber;
  final String address;
  final String workingHours;

  const ContactInfo({
    super.key,
    required this.phoneNumber,
    required this.address,
    required this.workingHours,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              'Contact Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          
          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[isDark ? 800 : 200],
          ),
          
          // Contact Items
          _buildContactItem(
            context: context,
            icon: Icons.location_on_outlined,
            title: 'Our Location',
            subtitle: address,
            onTap: () => _launchMaps(address),
          ),
          
          _buildDivider(context),
          
          _buildContactItem(
            context: context,
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            subtitle: phoneNumber,
            onTap: () => _launchPhoneCall(phoneNumber),
          ),
          
          _buildDivider(context),
         
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey[Theme.of(context).brightness == Brightness.dark ? 800 : 200],
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: theme.primaryColor.withOpacity(0.1),
        highlightColor: theme.primaryColor.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Chevron
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHourRow(BuildContext context, String day, String hours) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            day,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          hours,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _launchMaps(String address) async {
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    }
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri phoneUrl = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    }
  }
}
