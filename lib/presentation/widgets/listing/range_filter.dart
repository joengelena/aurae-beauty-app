import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shine_app/logic/filtering_provider.dart';
import 'package:shine_app/utils/theme.dart';

class RangeFilter extends StatefulWidget {
  final String label;
  final String fromKey;
  final String toKey;
  final String? prefixText;
  final bool isDecimal;
  final FilteringProvider provider;
  final VoidCallback? onSubmitted;

  const RangeFilter({
    super.key,
    required this.label,
    required this.fromKey,
    required this.toKey,
    required this.provider,
    this.prefixText,
    this.isDecimal = false,
    this.onSubmitted,
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeText,
            ),
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
        hintText: labelText,
        hintStyle: TextStyle(color: themeTaupe, fontSize: 13),
        prefixText: widget.prefixText,
        prefixStyle: TextStyle(color: themeText, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      onChanged: (value) {
        widget.provider.updateRangeFilter(filterKey, value);
      },
      onSubmitted: (_) => widget.onSubmitted?.call(),
    );
  }
}
