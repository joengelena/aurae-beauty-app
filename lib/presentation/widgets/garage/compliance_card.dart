import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorix_app/utils/theme.dart';

enum ComplianceStatus { valid, expiringSoon, expired }

class ComplianceCard extends StatelessWidget {
  final String title;
  final String dateString;
  final VoidCallback? onUpdate;

  const ComplianceCard({
    super.key,
    required this.title,
    required this.dateString,
    this.onUpdate,
  });

  ComplianceStatus _getComplianceStatus(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      if (difference < 0) {
        return ComplianceStatus.expired;
      } else if (difference <= 30) {
        return ComplianceStatus.expiringSoon;
      } else {
        return ComplianceStatus.valid;
      }
    } catch (e) {
      return ComplianceStatus.valid;
    }
  }

  String _formatDateString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _getComplianceStatus(dateString);
    final formattedDate = _formatDateString(dateString);

    Color cardColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case ComplianceStatus.valid:
        cardColor = Colors.green[50]!;
        textColor = themeGreen;
        icon = Icons.check_circle;
        break;
      case ComplianceStatus.expiringSoon:
        cardColor = Colors.orange[50]!;
        textColor = themeOrange;
        icon = Icons.warning;
        break;
      case ComplianceStatus.expired:
        cardColor = Colors.red[50]!;
        textColor = themeRed;
        icon = Icons.error;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: textColor),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (onUpdate != null) ...[
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onUpdate,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  side: BorderSide(color: textColor),
                  foregroundColor: textColor,
                ),
                child: Text('Update', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
