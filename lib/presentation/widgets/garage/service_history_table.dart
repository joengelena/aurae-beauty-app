import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorix_app/data/models/vehicle_service.dart';
import 'package:motorix_app/utils/theme.dart';

class ServiceHistoryTable extends StatelessWidget {
  final List<VehicleService> services;
  final Function(VehicleService)? onDelete;

  const ServiceHistoryTable({
    super.key,
    required this.services,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildHeader(),
          ...services.asMap().entries.map((entry) {
            final isLast = entry.key == services.length - 1;
            return _ServiceRow(
              service: entry.value,
              isLast: isLast,
              onDelete: onDelete,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Service',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Cost',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final VehicleService service;
  final bool isLast;
  final Function(VehicleService)? onDelete;

  const _ServiceRow({
    required this.service,
    required this.isLast,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(
                  color: Colors.grey[300]!,
                  width: 0.5,
                ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _formatServiceName(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  DateFormat('dd/MM/yy').format(service.serviceDate),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  _formatCost(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete, color: themeRed, size: 20),
                  onPressed: () => onDelete!(service),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          if (service.notes != null && service.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              service.notes!,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatServiceName() {
    if (service.serviceProviderName != null) {
      return '${service.typeOfService} (${service.serviceProviderName})';
    }
    return service.typeOfService;
  }

  String _formatCost() {
    if (service.cost != null) {
      return '\$${service.cost!.toStringAsFixed(2)}';
    }
    return '-';
  }
}
