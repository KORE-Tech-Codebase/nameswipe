import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nameswipe/core/constants/colors.dart';
import 'package:nameswipe/core/constants/spacing.dart';
import 'package:nameswipe/core/theme/card_gradients.dart';
import 'package:nameswipe/features/swipe/viewmodel/swipe_viewmodel.dart';
import 'package:nameswipe/features/swipe/view/widgets/name_card.dart';
import 'package:nameswipe/features/swipe/view/widgets/filter_sheet.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(swipeViewModelProvider.notifier).loadNames();
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final swipeState = ref.watch(swipeViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          // Gradient header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppColors.primaryDark.withValues(alpha: 0.15),
                        Colors.transparent,
                      ]
                    : [
                        AppColors.primary.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          ),
          // Card stack with 3 states
          Expanded(
            child: _buildBody(swipeState, isDark),
          ),
          // Action buttons
          if (swipeState.names.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AnimatedActionButton(
                    onPressed: () =>
                        _swiperController.swipe(CardSwiperDirection.left),
                    icon: Icons.close_rounded,
                    color: AppColors.skip,
                    bgColor: AppColors.skip.withValues(alpha: 0.12),
                  ),
                  const SizedBox(width: 40),
                  _AnimatedActionButton(
                    onPressed: () =>
                        _swiperController.swipe(CardSwiperDirection.right),
                    icon: Icons.favorite_rounded,
                    color: AppColors.favorite,
                    bgColor: AppColors.favorite.withValues(alpha: 0.12),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBody(SwipeState swipeState, bool isDark) {
    // Loading state
    if (swipeState.isLoading && swipeState.names.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state
    if (swipeState.names.isEmpty) {
      return _buildEmptyState(isDark);
    }

    // Content state
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CardSwiper(
        controller: _swiperController,
        cardsCount: swipeState.names.length,
        numberOfCardsDisplayed: swipeState.names.length.clamp(1, 3),
        onSwipe: (prevIndex, currentIndex, direction) {
          final isFav = direction == CardSwiperDirection.right;
          ref.read(swipeViewModelProvider.notifier).onSwipe(prevIndex, isFav);
          return true;
        },
        onEnd: () {
          ref.read(swipeViewModelProvider.notifier).loadNames();
        },
        padding: EdgeInsets.zero,
        cardBuilder: (context, index, hPercentage, vPercentage) {
          if (index >= ref.read(swipeViewModelProvider).names.length) {
            return const SizedBox.shrink();
          }
          final name = ref.read(swipeViewModelProvider).names[index];
          return NameCard(
            name: name,
            gradient: CardGradients.forCategory(name.category),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.style_outlined,
              size: 64,
              color: isDark
                  ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.4)
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            AppSpacing.gapH16,
            Text(
              'No more names!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            AppSpacing.gapH8,
            Text(
              'Try changing your filters or clear swipe history in Settings',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH24,
            FilledButton.icon(
              onPressed: () =>
                  ref.read(swipeViewModelProvider.notifier).loadNames(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
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

class _AnimatedActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _AnimatedActionButton({
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: widget.bgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(widget.icon, color: widget.color, size: 32),
        ),
      ),
    );
  }
}
