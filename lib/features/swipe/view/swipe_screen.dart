import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nameswipe/core/constants/colors.dart';
import 'package:nameswipe/core/theme/card_gradients.dart';
import 'package:nameswipe/features/swipe/viewmodel/swipe_viewmodel.dart';
import 'package:nameswipe/features/swipe/view/widgets/name_card.dart';
import 'package:nameswipe/features/swipe/view/widgets/filter_sheet.dart';
import 'package:nameswipe/widgets/banner_ad_placeholder.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final swipeState = ref.watch(swipeViewModelProvider);

    return SafeArea(
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset('assets/svg/logo.svg', height: 28),
                IconButton(
                  onPressed: () => _showFilterSheet(context),
                  icon: const Icon(Icons.tune_rounded),
                ),
              ],
            ),
          ),
          // Card stack
          Expanded(
            child: swipeState.isLoading && swipeState.names.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : swipeState.names.isEmpty
                    ? _buildEmptyState()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CardSwiper(
                          controller: _swiperController,
                          cardsCount: swipeState.names.length,
                          numberOfCardsDisplayed:
                              swipeState.names.length.clamp(1, 3),
                          onSwipe: (prevIndex, currentIndex, direction) {
                            final isFav = direction == CardSwiperDirection.right;
                            ref
                                .read(swipeViewModelProvider.notifier)
                                .onSwipe(prevIndex, isFav);
                            return true;
                          },
                          onEnd: () {
                            ref.read(swipeViewModelProvider.notifier).loadNames();
                          },
                          padding: EdgeInsets.zero,
                          cardBuilder: (context, index, hPercentage, vPercentage) {
                            if (index >= swipeState.names.length) {
                              return const SizedBox.shrink();
                            }
                            return NameCard(
                              name: swipeState.names[index],
                              gradient: CardGradients.forCategory(
                                swipeState.names[index].category,
                              ),
                            );
                          },
                        ),
                      ),
          ),
          // Action buttons
          if (swipeState.names.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Skip button
                  _ActionButton(
                    onPressed: () => _swiperController.swipe(CardSwiperDirection.left),
                    icon: Icons.close_rounded,
                    color: AppColors.skip,
                    bgColor: AppColors.skip.withValues(alpha: 0.12),
                  ),
                  const SizedBox(width: 40),
                  // Favorite button
                  _ActionButton(
                    onPressed: () => _swiperController.swipe(CardSwiperDirection.right),
                    icon: Icons.favorite_rounded,
                    color: AppColors.favorite,
                    bgColor: AppColors.favorite.withValues(alpha: 0.12),
                  ),
                ],
              ),
            ),
          // Ad placeholder
          const BannerAdPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.style_outlined, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No more names!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filters or clear swipe history in Settings',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                ref.read(swipeViewModelProvider.notifier).loadNames(),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const FilterSheet(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
