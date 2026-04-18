import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../model/station/station.dart';
import '../../../../utils/async_value.dart';
import '../view_model/map_view_model.dart';

class SearchBarWidget extends StatefulWidget {
  /// The current map center, used to sort suggestions by proximity.
  final LatLng mapCenter;

  const SearchBarWidget({super.key, required this.mapCenter});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        context.read<MapViewModel>().dismissSuggestions();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onClear(MapViewModel viewModel) {
    _controller.clear();
    viewModel.clearSearch();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();

    // Sync controller text if cleared externally
    if (_controller.text != viewModel.searchQuery) {
      _controller.text = viewModel.searchQuery;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Search input ──────────────────────────────────────────────────
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: (query) => viewModel.onSearchChanged(
              query,
              nearCenter: widget.mapCenter,
            ),
            decoration: InputDecoration(
              hintText: 'Search stations…',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: viewModel.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => _onClear(viewModel),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        // ── Suggestions dropdown ──────────────────────────────────────────
        if (viewModel.showSuggestions) ...[
          const SizedBox(height: 4),
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: switch (viewModel.suggestions.state) {
                AsyncValueState.loading => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                AsyncValueState.error => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error: ${viewModel.suggestions.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                AsyncValueState.success => (viewModel.suggestions.data ?? []).isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No stations found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: viewModel.suggestions.data!.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final station = viewModel.suggestions.data![index];
                          return _SuggestionTile(
                            station: station,
                            query: viewModel.searchQuery,
                            onTap: () {
                              viewModel.onSuggestionSelected(station);
                              _focusNode.unfocus();
                            },
                          );
                        },
                      ),
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// A single row in the suggestion list, with the matching part bolded.
class _SuggestionTile extends StatelessWidget {
  final Station station;
  final String query;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.station,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: _HighlightedText(
                text: station.name,
                highlight: query,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders [text] with [highlight] portion in bold, case-insensitive.
class _HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;

  const _HighlightedText({required this.text, required this.highlight});

  @override
  Widget build(BuildContext context) {
    if (highlight.trim().isEmpty) {
      return Text(text, style: const TextStyle(fontSize: 15));
    }

    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.trim().toLowerCase();
    final matchStart = lowerText.indexOf(lowerHighlight);

    if (matchStart == -1) {
      return Text(text, style: const TextStyle(fontSize: 15));
    }

    final matchEnd = matchStart + lowerHighlight.length;

    return Text.rich(
      TextSpan(
        children: [
          if (matchStart > 0)
            TextSpan(
              text: text.substring(0, matchStart),
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          TextSpan(
            text: text.substring(matchStart, matchEnd),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (matchEnd < text.length)
            TextSpan(
              text: text.substring(matchEnd),
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
        ],
      ),
    );
  }
}