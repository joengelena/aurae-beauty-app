import 'package:flutter/material.dart';

class VehicleSpecCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const VehicleSpecCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   padding: const EdgeInsets.all(12),
    //   decoration: BoxDecoration(
    //     color: Colors.grey[100],
    //     borderRadius: BorderRadius.circular(8),
    //   ),
    //   child: Row(
    //     children: [
    //       Icon(icon, size: 20, color: Colors.black54),
    //       const SizedBox(width: 8),
    //       Expanded(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Text(
    //               label,
    //               style: const TextStyle(fontSize: 11, color: Colors.black54),
    //             ),
    //             Text(
    //               value,
    //               style: const TextStyle(
    //                 fontSize: 13,
    //                 fontWeight: FontWeight.w600,
    //               ),
    //               overflow: TextOverflow.ellipsis,
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
