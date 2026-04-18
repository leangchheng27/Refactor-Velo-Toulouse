import 'package:flutter/material.dart';
import '../../../../model/payment/payment.dart';

class PaymentMethodWidget extends StatelessWidget {
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onSelect;

  const PaymentMethodWidget({
    super.key,
    required this.selectedMethod,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MethodPill(
            label: 'Credit Card',
            icon: Icons.credit_card,
            isSelected: selectedMethod == PaymentMethod.visa,
            onTap: () => onSelect(PaymentMethod.visa),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MethodPill(
            label: 'Digital Wallet',
            icon: Icons.account_balance_wallet,
            isSelected: selectedMethod == PaymentMethod.mastercard,
            onTap: () => onSelect(PaymentMethod.mastercard),
          ),
        ),
      ],
    );
  }
}

class _MethodPill extends StatelessWidget {
  const _MethodPill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: isSelected ? null : const Color(0xFFBDBDBF),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFB7D00), Color(0xFFD10C6B)],
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}