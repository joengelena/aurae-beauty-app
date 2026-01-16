import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motorix_app/logic/filtering_provider.dart';

class RangeFilter extends StatefulWidget {
  final String label;
  final String fromKey;
  final String toKey;
  final String? prefixText;
  final bool isDecimal;
  final FilteringProvider provider;

  const RangeFilter({
    super.key,
    required this.label,
    required this.fromKey,
    required this.toKey,
    required this.provider,
    this.prefixText,
    this.isDecimal = false,
  });

  @override
  State<RangeFilter> createState() => _RangeFilterState();
}

class _RangeFilterState extends State<RangeFilter> {
  late TextEditingController _minController;
  late TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.provider.getRangeValue(widget.fromKey),
    );
    _maxController = TextEditingController(
      text: widget.provider.getRangeValue(widget.toKey),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  context: context,
                  labelText: 'Min',
                  controller: _minController,
                  filterKey: widget.fromKey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  context: context,
                  labelText: 'Max',
                  controller: _maxController,
                  filterKey: widget.toKey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String labelText,
    required TextEditingController controller,
    required String filterKey,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          widget.isDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
      inputFormatters:
          widget.isDecimal
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
              : [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixText: widget.prefixText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      onChanged: (value) {
        widget.provider.updateRangeFilter(filterKey, value);
      },
    );
  }
}
