import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class ClockButton extends StatelessWidget {
  final bool isClockedIn;
  final VoidCallback onPressed;

  const ClockButton({
    super.key,
    required this.isClockedIn,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(isClockedIn ? Icons.stop_rounded : Icons.play_arrow_rounded),
        label: Text(isClockedIn ? 'Clock Out' : 'Clock In'),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isClockedIn ? AppTheme.expenseRed : AppTheme.incomeGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
