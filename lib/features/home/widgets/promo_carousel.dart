import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/widgets/widgets.dart';

class _Promo {
  const _Promo({
    required this.title,
    required this.body,
    required this.cta,
    required this.route,
    required this.icon,
    required this.colors,
    required this.darkText,
  });

  final String title;
  final String body;
  final String cta;
  final String route;
  final IconData icon;
  final List<Color> colors;
  final bool darkText;
}

/// Replaces the stock-photo banners with offers that lead somewhere useful.
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final _controller = PageController(viewportFraction: 0.92);

  static const _promos = <_Promo>[
    _Promo(
      title: 'Need more speed?',
      body: 'Move up to 50 Mbps for 4K streaming on every screen.',
      cta: 'See plans',
      route: '/renew',
      icon: PhosphorIconsFill.lightning,
      colors: [Color(0xFFFFB04A), Color(0xFFF7901E)],
      darkText: true,
    ),
    _Promo(
      title: 'Working from home?',
      body: 'Add a static IP for remote access, CCTV and VPNs.',
      cta: 'View add-ons',
      route: '/addons',
      icon: PhosphorIconsFill.globe,
      colors: [Color(0xFF34315E), Color(0xFF1D1B38)],
      darkText: false,
    ),
    _Promo(
      title: 'Moving house?',
      body: "Tell us early and we'll schedule your fibre move.",
      cta: 'Book a move',
      route: '/tickets/new?category=moving',
      icon: PhosphorIconsFill.truck,
      colors: [Color(0xFF2E9D6A), Color(0xFF1E7A50)],
      darkText: false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    return Column(
      children: [
        SizedBox(
          height: 156,
          // Let pages bleed to the screen edge past the list padding.
          child: OverflowBox(
            maxWidth: MediaQuery.of(context).size.width,
            child: PageView.builder(
              controller: _controller,
              padEnds: true,
              itemCount: _promos.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _PromoCard(promo: _promos[i]),
              ),
            ),
          ),
        ),
        const Gap(Insets.md),
        SmoothPageIndicator(
          controller: _controller,
          count: _promos.length,
          effect: ExpandingDotsEffect(
            dotHeight: 6,
            dotWidth: 6,
            spacing: 6,
            expansionFactor: 3.5,
            activeDotColor: p.accent,
            dotColor: p.line,
          ),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo});

  final _Promo promo;

  @override
  Widget build(BuildContext context) {
    final p = context.sf;
    final fg = promo.darkText ? p.onAccent : Colors.white;
    final fgMuted = fg.withValues(alpha: 0.78);

    return Material(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg + 2)),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: promo.colors),
        ),
        child: InkWell(
          onTap: () => context.push(promo.route),
          child: Stack(
            children: [
              Positioned(
                right: -14,
                bottom: -18,
                child: Icon(promo.icon, size: 116, color: fg.withValues(alpha: 0.12)),
              ),
              Padding(
                padding: const EdgeInsets.all(Insets.lg + 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(promo.title, style: context.text.titleLarge!.copyWith(color: fg)),
                    const Gap(Insets.xs + 2),
                    SizedBox(
                      width: 240,
                      child: Text(promo.body, style: context.text.bodyMedium!.copyWith(color: fgMuted)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: fg.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                      child: Text(promo.cta, style: context.text.titleSmall!.copyWith(color: fg)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
