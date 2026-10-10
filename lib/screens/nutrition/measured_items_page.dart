// File: lib/screens/nutrition/measured_items_page.dart

import 'package:material_ui/material_ui.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../theme/tokens/app_progress_colors.dart';
import '../../theme/tokens/app_expressive_train_tokens.dart';
import '../../widgets/health_trends_section.dart';

class MeasuredItemsPage extends StatefulWidget {
  const MeasuredItemsPage({super.key});

  @override
  State<MeasuredItemsPage> createState() => _MeasuredItemsPageState();
}

class _MeasuredItemsPageState extends State<MeasuredItemsPage> {
  bool _changed = false;

  void _markChanged() => _changed = true;

  void _pop() => Navigator.of(context).pop(_changed);

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final expressive = context.usesExpressivePresentation;
    final destinationTokens = expressive
        ? Theme.of(context).extension<AppExpressiveDestinationTokens>()
        : null;
    final profileTokens =
        destinationTokens?.family == AppExpressiveDestinationFamily.profile
        ? destinationTokens
        : null;
    final expressiveCanvas = expressive
        ? profileTokens?.pageCanvas ??
              Theme.of(context)
                  .extension<AppExpressiveTrainTokens>()!
                  .pageCanvas
        : null;
    final healthTrends = HealthTrendsSection(
      fullPage: true,
      onChanged: _markChanged,
    );
    final scopedHealthTrends = profileTokens == null
        ? healthTrends
        : Theme(
            data: Theme.of(context).copyWith(
              extensions: [
                ...Theme.of(context).extensions.values
                    .where((extension) => extension is! AppProgressColors),
                Theme.of(context).progressColors
                    .copyWith(healthCard: profileTokens.surfaceAccent),
              ],
            ),
            child: healthTrends,
          );
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.nutritionMeasuredItems),
          leading: BackButton(onPressed: _pop),
          backgroundColor: expressiveCanvas,
          foregroundColor: expressive
              ? Theme.of(context).colorScheme.onSurface
              : null,
          scrolledUnderElevation: expressive ? 0 : null,
        ),
        body: scopedHealthTrends,
        backgroundColor: expressiveCanvas,
      ),
    );
  }
}
