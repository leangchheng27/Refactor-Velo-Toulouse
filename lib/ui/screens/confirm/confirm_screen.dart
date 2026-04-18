import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../model/bike/bike.dart';
import '../../../../model/subscription/subscription.dart';
import 'view_model/confirm_view_model.dart';
import 'widgets/confirm_gradient_info_card.dart';
import 'widgets/confirm_primary_button.dart';
import 'widgets/confirm_ride_summary_card.dart';
import 'widgets/confirm_section_header.dart';
import 'widgets/confirm_warning_notice.dart';

class ConfirmScreen extends StatelessWidget {
  final Bike bike;
  final Subscription subscription;
  final String? stationName;

  const ConfirmScreen({
    super.key,
    required this.bike,
    required this.subscription,
    this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConfirmViewModel(
        bike: bike,
        subscription: subscription,
        stationName: stationName,
      ),
      child: const _ConfirmScreenBody(),
    );
  }
}

class _ConfirmScreenBody extends StatelessWidget {
  const _ConfirmScreenBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ConfirmViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 46,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Confirm bike & plan before unlocking',
                          style: TextStyle(
                            fontSize: 41,
                            height: 0.97,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF402437),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ready for your cross-town commute?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8B6B7F),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ConfirmSectionHeader(
                          title: 'SELECTED BIKE',
                          actionText: 'Edit Selection',
                          actionColor: const Color(0xFFD63B58),
                          onActionTap: () => viewModel.onEditSelection(context),
                        ),
                        const SizedBox(height: 12),
                        ConfirmGradientInfoCard(
                          leadingIcon: Icons.directions_bike,
                          title: 'Slot ${viewModel.bike.slotNumber}',
                          subtitle: viewModel.resolvedStationName.toUpperCase(),
                        ),
                        const SizedBox(height: 28),
                        ConfirmSectionHeader(
                          title: 'YOUR ACTIVE PLAN',
                          actionText: 'Modify Plan',
                          onActionTap: () => viewModel.onModifyPlan(context),
                        ),
                        const SizedBox(height: 12),
                        ConfirmGradientInfoCard(
                          leadingIcon: Icons.event_note,
                          title: viewModel.planLabel,
                          subtitle: 'Valid until ${viewModel.formattedExpiryDate}',
                        ),
                        const SizedBox(height: 28),
                        const ConfirmSectionHeader(title: 'RIDE SUMMARY'),
                        const SizedBox(height: 12),
                        ConfirmRideSummaryCard(
                          bikeSummary: viewModel.bikeSummary,
                          stationName: viewModel.resolvedStationName,
                          subscriptionLabel: viewModel.planLabel,
                        ),
                        const SizedBox(height: 28),
                        ConfirmWarningNotice(message: viewModel.warningMessage),
                        const SizedBox(height: 36),
                        ConfirmPrimaryButton(
                          label: 'Continue',
                          isLoading: viewModel.isBusy,
                          onTap: () => viewModel.onContinue(context),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            viewModel.footerMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8B6B7F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}