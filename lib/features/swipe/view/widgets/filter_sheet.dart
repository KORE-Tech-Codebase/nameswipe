import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nameswipe/core/constants/app_constants.dart';
import 'package:nameswipe/core/constants/colors.dart';
import 'package:nameswipe/models/filter_model.dart';
import 'package:nameswipe/features/swipe/viewmodel/swipe_viewmodel.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late FilterModel _filter;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(swipeFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Filters', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              // Gender
              Text('Gender', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildGenderChip('All', null),
                  _buildGenderChip('Male', 'male'),
                  _buildGenderChip('Female', 'female'),
                  _buildGenderChip('Unisex', 'unisex'),
                ],
              ),
              const SizedBox(height: 24),
              // Categories
              Text('Categories', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.categories.map((cat) {
                  final selected = _filter.categories.contains(cat);
                  return FilterChip(
                    label: Text(AppConstants.categoryDisplayName(cat)),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        final cats = Set<String>.from(_filter.categories);
                        if (val) {
                          cats.add(cat);
                        } else {
                          cats.remove(cat);
                        }
                        _filter = _filter.copyWith(categories: cats);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _filter = _filter.clearAll());
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(swipeViewModelProvider.notifier)
                            .applyFilter(_filter);
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenderChip(String label, String? value) {
    final selected = _filter.gender == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _filter = _filter.copyWith(gender: () => value);
        });
      },
    );
  }
}
