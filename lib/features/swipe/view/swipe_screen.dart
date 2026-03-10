import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:namora/core/constants/colors.dart';
import 'package:namora/core/constants/spacing.dart';
import 'package:namora/core/theme/card_gradients.dart';
import 'package:namora/features/swipe/viewmodel/swipe_viewmodel.dart';
import 'package:namora/features/swipe/view/widgets/name_card.dart';
import 'package:namora/features/swipe/view/widgets/filter_sheet.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  // Track swipe direction for overlay
  double _swipeProgress = 0.0;
  CardSwiperDirection? _swipeDirection;

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  void _shareName(int index) {
    final names = ref.read(swipeViewModelProvider).names;
    if (index >= names.length) return;
    final name = names[index];
    final meaning = name.meaning.isNotEmpty ? ' - "${name.meaning}"' : '';
    final origin = name.origin.isNotEmpty ? ' (${name.origin})' : '';
    Share.share('Check out this name: ${name.name}$meaning$origin\n\nFound on Namora!');
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
                  Row(
                    children: [
                      // Share button
                      if (swipeState.names.isNotEmpty)
                        IconButton(
                          onPressed: () => _shareName(0),
                          icon: Icon(
                            Icons.share_rounded,
                            color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant,
                          ),
                          tooltip: 'Share name',
                        ),
                      // Filter button with badge
                      _FilterButton(onTap: () => _showFilterSheet(context)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Card stack
          Expanded(
            child: _buildBody(swipeState, isDark),
          ),
          // Action buttons
          if (swipeState.names.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    onPressed: () =>
                        _swiperController.swipe(CardSwiperDirection.left),
                    icon: Icons.close_rounded,
                    label: 'NOPE',
                    color: const Color(0xFFEF5350),
                    bgColor: const Color(0xFFEF5350).withValues(alpha: 0.1),
                    size: 52,
                    iconSize: 24,
                  ),
                  const SizedBox(width: 18),
                  _ActionButton(
                    onPressed: () => _swiperController.undo(),
                    icon: Icons.replay_rounded,
                    label: '',
                    color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant,
                    bgColor: (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
                    size: 40,
                    iconSize: 18,
                  ),
                  const SizedBox(width: 18),
                  _ActionButton(
                    onPressed: () =>
                        _swiperController.swipe(CardSwiperDirection.right),
                    icon: Icons.favorite_rounded,
                    label: 'LOVE',
                    color: AppColors.favorite,
                    bgColor: AppColors.favorite.withValues(alpha: 0.1),
                    size: 52,
                    iconSize: 24,
                  ),
                ],
              ),
            ),
          // Navbar reserved space
          AppSpacing.navBarSpacer,
        ],
      ),
    );
  }

  Widget _buildBody(SwipeState swipeState, bool isDark) {
    if (swipeState.isLoading && swipeState.names.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (swipeState.names.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxCardHeight = constraints.maxHeight.clamp(0.0, 460.0);
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxCardHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CardSwiper(
                key: ValueKey(swipeState.names.hashCode),
                controller: _swiperController,
                cardsCount: swipeState.names.length,
                numberOfCardsDisplayed: swipeState.names.length.clamp(1, 3),
                backCardOffset: const Offset(0, -20),
                scale: 0.95,
                isLoop: false,
                padding: const EdgeInsets.symmetric(vertical: 2),
                onSwipe: (prevIndex, currentIndex, direction) {
                  final isFav = direction == CardSwiperDirection.right;
                  ref.read(swipeViewModelProvider.notifier).onSwipe(prevIndex, isFav);
                  setState(() {
                    _swipeProgress = 0;
                    _swipeDirection = null;
                  });
                  return true;
                },
                onSwipeDirectionChange: (horizontalDirection, verticalDirection) {
                  setState(() {
                    if (horizontalDirection == CardSwiperDirection.right) {
                      _swipeDirection = CardSwiperDirection.right;
                      _swipeProgress = 0.8;
                    } else if (horizontalDirection == CardSwiperDirection.left) {
                      _swipeDirection = CardSwiperDirection.left;
                      _swipeProgress = 0.8;
                    } else {
                      _swipeDirection = null;
                      _swipeProgress = 0;
                    }
                  });
                },
                onEnd: () {
                  ref.read(swipeViewModelProvider.notifier).onDeckEnd();
                },
                cardBuilder: (context, index, hPercentage, vPercentage) {
                  final names = ref.read(swipeViewModelProvider).names;
                  if (index >= names.length) return const SizedBox.shrink();
                  final name = names[index];
                  final isTopCard = index == 0 || (hPercentage != 0 || vPercentage != 0);

                  return Stack(
                    children: [
                      NameCard(
                        name: name,
                        gradient: CardGradients.forCategory(name.category),
                      ),
                      if (isTopCard && _swipeDirection != null)
                        _SwipeFeedbackOverlay(
                          direction: _swipeDirection!,
                          progress: _swipeProgress,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppColors.primaryDark : AppColors.primary)
                    .withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.style_outlined,
                size: 48,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
            AppSpacing.gapH24,
            Text(
              'No more names!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            AppSpacing.gapH8,
            Text(
              'Try changing your filters or check back later for more names',
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
                  ref.read(swipeViewModelProvider.notifier).resetSession(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Start Fresh'),
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

// Swipe feedback overlay ("LOVE" / "NOPE")
class _SwipeFeedbackOverlay extends StatelessWidget {
  final CardSwiperDirection direction;
  final double progress;

  const _SwipeFeedbackOverlay({
    required this.direction,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isLove = direction == CardSwiperDirection.right;
    final color = isLove ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);
    final text = isLove ? 'LOVE' : 'NOPE';
    final rotation = isLove ? -0.3 : 0.3;
    final alignment = isLove ? Alignment.topLeft : Alignment.topRight;

    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          alignment: alignment,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: color.withValues(alpha: progress * 0.15),
          ),
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Filter button with active indicator dot
class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FilterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.tune_rounded),
    );
  }
}

// Animated action button with label
class _ActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final double size;
  final double iconSize;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.size,
    required this.iconSize,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.bgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: widget.color, size: widget.iconSize),
            ),
            if (widget.label.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
