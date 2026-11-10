import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/user_model.dart';
import '../constants/app_colors.dart';

/// Rollar uchun minimalistik vektor ikonkalar (models/ ni o'zgartirmasdan)
IconData premiumRoleIcon(UserRole role) {
  switch (role) {
    case UserRole.superAdmin:
      return LucideIcons.shieldCheck;
    case UserRole.institutionAdmin:
      return LucideIcons.landmark;
    case UserRole.coordinator:
      return LucideIcons.sparkles;
    case UserRole.psychologist:
      return LucideIcons.brain;
    case UserRole.speechTherapist:
      return LucideIcons.mic;
    case UserRole.specialEducation:
      return LucideIcons.puzzle;
    case UserRole.specialEdTeacher:
      return LucideIcons.bookOpenCheck;
    case UserRole.teacher:
      return LucideIcons.bookOpen;
    case UserRole.reviewer:
      return LucideIcons.eye;
    case UserRole.parent:
      return LucideIcons.heartHandshake;
  }
}

/// Sokin va toza minimalist orqa fon (ortiqcha yorqin ranglarsiz)
class AmbientMeshBackground extends StatelessWidget {
  final Widget child;
  final bool intense;

  const AmbientMeshBackground({
    super.key,
    required this.child,
    this.intense = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtleAlpha = intense ? 0.09 : 0.07;

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Asosiy yorug' va nafas oladigan fon (Fresh Porcelain & Light Sky Mist)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    // Qorong'i mavzuda — sokin grafit, yorug'da — havorang tus
                    colors:
                        AppColors.isDark
                            ? [
                              AppColors.background,
                              AppColors.background,
                              AppColors.backgroundDeep,
                              AppColors.backgroundDeep,
                            ]
                            : [
                              AppColors.surfaceMuted,
                              AppColors.primaryLight,
                              AppColors.primaryLight,
                              AppColors.primaryTint,
                            ],
                    stops: const [0.0, 0.35, 0.70, 1.0],
                  ),
                ),
              ),
              // 2. Tepa qismdan tushuvchi keng mayin yorug'lik nuri
              Positioned(
                top: -140,
                left: -80,
                child: IgnorePointer(
                  child: Container(
                    width: 580,
                    height: 580,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.surface.withValues(alpha: 0.65),
                          AppColors.surface.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 3. Tepa o'ng burchakdagi juda mayin havorang havo nafasi
              Positioned(
                top: -180,
                right: -120,
                child: IgnorePointer(
                  child: Container(
                    width: 540,
                    height: 540,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: subtleAlpha),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 4. Pastki chap tomondagi nozik binafsha-havorang jilo
              Positioned(
                bottom: -200,
                left: -140,
                child: IgnorePointer(
                  child: Container(
                    width: 540,
                    height: 540,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(
                            alpha: subtleAlpha * 0.6,
                          ),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

/// Minimalist Soft-Glass konteyneri (18px radius + 1.0px nozik hairline border)
class GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final BorderRadius? customBorderRadius;
  final double blur;
  final double opacity;
  final Color? tintColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final bool useBlur;
  final double borderWidth;

  const GlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 26,
    this.customBorderRadius,
    this.blur = 20,
    this.opacity = 0.82,
    this.tintColor,
    this.borderColor,
    this.boxShadow,
    this.useBlur = true,
    this.borderWidth = 1.0,
    this.gradient,
  });

  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final baseColor = tintColor ?? AppColors.surface;
    final radius = customBorderRadius ?? BorderRadius.circular(borderRadius);
    final effectiveOpacity = opacity.clamp(0.0, 1.0);

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        color:
            gradient == null
                ? baseColor.withValues(alpha: effectiveOpacity)
                : null,
        gradient: gradient,
        border: Border.all(
          color: borderColor ?? AppColors.glassWhiteBorder,
          width: borderWidth,
        ),
      ),
      child: child,
    );

    if (useBlur && blur > 0) {
      content = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
            tileMode: TileMode.clamp,
          ),
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: boxShadow ?? AppColors.softShadow,
      ),
      child: content,
    );
  }
}

/// Mobil ilovalar kabi bosilganda (tap/press) ichkariga kirib-chiqadigan taktil animatsiya
class TactileBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final HitTestBehavior behavior;

  const TactileBounce({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.965,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<TactileBounce> createState() => _TactileBounceState();
}

class _TactileBounceState extends State<TactileBounce> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _pressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_pressed) {
      setState(() => _pressed = false);
    }
  }

  void _handleTapCancel() {
    if (_pressed) {
      setState(() => _pressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;

    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: Duration(milliseconds: _pressed ? 85 : 170),
        curve: _pressed ? Curves.easeInCubic : Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Minimalist asosiy karta: 26px radius, toza oq yuza va 1.0px nozik chegara
class SurfaceCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool elevated;
  final bool useBlur;
  final double blur;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
    this.margin,
    this.borderRadius = 26,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.elevated = true,
    this.useBlur = true,
    this.blur = 20,
  });

  @override
  State<SurfaceCard> createState() => _SurfaceCardState();
}

class _SurfaceCardState extends State<SurfaceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final radius = BorderRadius.circular(widget.borderRadius);

    final effectiveBorderColor =
        widget.borderColor ?? AppColors.cardGlassBorder;

    final hasCustomBg = widget.backgroundColor != null;
    final topAlpha = AppColors.isDark ? 0.92 : 0.96;
    final bottomAlpha = AppColors.isDark ? 0.80 : 0.86;
    final baseSurfaceColor =
        AppColors.isDark ? AppColors.surface : Colors.white;

    Widget cardInner = Container(
      decoration: BoxDecoration(
        color: hasCustomBg ? widget.backgroundColor : null,
        gradient:
            hasCustomBg
                ? null
                : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    baseSurfaceColor.withValues(alpha: topAlpha),
                    baseSurfaceColor.withValues(alpha: bottomAlpha),
                  ],
                ),
        borderRadius: radius,
        border: Border.all(color: effectiveBorderColor, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown:
              interactive ? (_) => setState(() => _pressed = true) : null,
          onTapUp: interactive ? (_) => setState(() => _pressed = false) : null,
          onTapCancel:
              interactive ? () => setState(() => _pressed = false) : null,
          onHighlightChanged:
              interactive
                  ? (value) {
                    if (_pressed != value) setState(() => _pressed = value);
                  }
                  : null,
          borderRadius: radius,
          splashColor: AppColors.primary.withValues(alpha: 0.04),
          highlightColor: Colors.transparent,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );

    Widget frostedCard =
        widget.useBlur && widget.blur > 0
            ? ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                  tileMode: TileMode.clamp,
                ),
                child: cardInner,
              ),
            )
            : cardInner;

    Widget cardBody = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: widget.elevated ? AppColors.softShadow : null,
      ),
      child: frostedCard,
    );

    if (!interactive) return cardBody;

    return AnimatedScale(
      scale: _pressed ? 0.968 : 1.0,
      duration: Duration(milliseconds: _pressed ? 85 : 170),
      curve: _pressed ? Curves.easeInCubic : Curves.easeOutCubic,
      child: cardBody,
    );
  }
}

/// Karta ichidagi konsentrik (outer 18 -> inner 12) sokin ichki blok
class GlassWell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? tintColor;
  final Color? borderColor;

  const GlassWell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.borderRadius = 12,
    this.tintColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: tintColor ?? AppColors.glassWellFill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.glassInnerBorder,
          width: 0.85,
        ),
      ),
      child: child,
    );
  }
}

/// Qat'iy balandliksiz (0% vertical text overflow!) moslashuvchan grid
class ResponsiveGlassGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;

  const ResponsiveGlassGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 4,
    this.spacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols =
            w >= 760
                ? desktopColumns
                : w >= 540
                ? tabletColumns
                : mobileColumns;

        if (cols <= 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: spacing),
                children[i],
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (int i = 0; i < children.length; i += cols) {
          final end = (i + cols < children.length) ? i + cols : children.length;
          final slice = children.sublist(i, end);
          final remaining = cols - slice.length;

          if (rows.isNotEmpty) {
            rows.add(SizedBox(height: spacing));
          }

          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int j = 0; j < slice.length; j++) ...[
                    if (j > 0) SizedBox(width: spacing),
                    Expanded(child: slice[j]),
                  ],
                  for (int k = 0; k < remaining; k++) ...[
                    SizedBox(width: spacing),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}

/// Keng monitorlarda kontentni o'rtaga tekislab, iPhone'da nafas oladigan hoshiya beruvchi konteyner
class ResponsivePageContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool? withTopHeaderPadding;
  final double? bottomPadding;

  const ResponsivePageContainer({
    super.key,
    required this.child,
    this.maxWidth = 1260,
    this.padding,
    this.withTopHeaderPadding,
    this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal =
        width < 600
            ? 12.0
            : width < 1024
            ? 18.0
            : 22.0;

    final hasAppBar = Scaffold.maybeOf(context)?.hasAppBar ?? false;
    final needsTopOffset = withTopHeaderPadding ?? !hasAppBar;
    final topPadding =
        needsTopOffset
            ? MediaQuery.paddingOf(context).top + (width >= 920 ? 82.0 : 74.0)
            : (width < 600 ? 16.0 : 24.0);

    final resolvedBottomPadding = bottomPadding ?? (width < 920 ? 96.0 : 28.0);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding:
              padding ??
              EdgeInsets.fromLTRB(
                horizontal,
                topPadding,
                horizontal,
                resolvedBottomPadding,
              ),
          child: child,
        ),
      ),
    );
  }
}

/// Sahifa tepa qismi uchun minimalist va silliq harakat tugmasi (Shadcn / Linear uslubida)
enum HeaderActionVariant { primary, secondary, danger }

class HeaderActionButton extends StatefulWidget {
  final String label;
  final String? compactLabel;
  final IconData? icon;
  final VoidCallback onPressed;
  final HeaderActionVariant variant;

  const HeaderActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.compactLabel,
    this.icon,
    this.variant = HeaderActionVariant.primary,
  });

  @override
  State<HeaderActionButton> createState() => _HeaderActionButtonState();
}

class _HeaderActionButtonState extends State<HeaderActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final isMobile = screenW < 560;
    final effectiveLabel =
        (isMobile && widget.compactLabel != null)
            ? widget.compactLabel!
            : widget.label;

    final Color bg;
    final Color border;
    final Color fg;
    final Color iconColor;
    final List<BoxShadow> shadow;

    switch (widget.variant) {
      case HeaderActionVariant.primary:
        bg = AppColors.primary;
        border = AppColors.primary;
        fg = Colors.white;
        iconColor = Colors.white;
        shadow = [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      case HeaderActionVariant.secondary:
        bg = AppColors.surface;
        border = AppColors.border;
        fg = AppColors.textPrimary;
        iconColor = AppColors.primary;
        shadow = const [
          BoxShadow(
            color: Color(0x070A1A3F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ];
        break;
      case HeaderActionVariant.danger:
        bg = AppColors.surface;
        border = AppColors.errorBorder;
        fg = AppColors.error;
        iconColor = AppColors.error;
        shadow = const [
          BoxShadow(
            color: Color(0x060A1A3F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ];
        break;
    }

    final radius = BorderRadius.circular(10);
    final height = isMobile ? 35.0 : 38.0;
    final pad =
        widget.icon != null
            ? EdgeInsets.fromLTRB(
              isMobile ? 10.5 : 12.5,
              0,
              isMobile ? 12 : 14,
              0,
            )
            : EdgeInsets.symmetric(horizontal: isMobile ? 12 : 14);

    return AnimatedScale(
      scale: _pressed ? 0.955 : 1.0,
      duration: Duration(milliseconds: _pressed ? 80 : 160),
      curve: _pressed ? Curves.easeInCubic : Curves.easeOutCubic,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          border: Border.all(color: border, width: 1.0),
          boxShadow: shadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onPressed,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onHighlightChanged: (v) {
              if (_pressed != v) setState(() => _pressed = v);
            },
            splashColor: fg.withValues(alpha: 0.08),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: pad,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: isMobile ? 14.5 : 15.5,
                      color: iconColor,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    effectiveLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isMobile ? 12.3 : 13,
                      fontWeight: FontWeight.w600,
                      color: fg,
                      letterSpacing: 0.0,
                      wordSpacing: 0.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Barcha ekranlar uchun mobil/desktop premium qutiga (SurfaceCard) olingan sahifa sarlavhasi
class AdaptivePageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badge;
  final Widget? action;
  final IconData? icon;
  final bool inlineActionOnMobile;
  final bool boxed;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const AdaptivePageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.badge,
    this.action,
    this.icon,
    this.inlineActionOnMobile = false,
    this.boxed = true,
    this.borderRadius = 24,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Agar badge berilmagan bo'lsa va subtitle da ' • ' bo'lsa, avtomatik ajratamiz
    String? effectiveBadge = badge;
    String effectiveSubtitle = subtitle;
    if (effectiveBadge == null && subtitle.contains(' • ')) {
      final parts = subtitle.split(' • ');
      final first = parts.first.trim();
      final last = parts.sublist(1).join(' • ').trim();
      if (first.length <= 42 &&
          (first.contains('rahbar') ||
              first.contains('qituvchi') ||
              first.contains('mutaxassis') ||
              first.contains('admin') ||
              first.contains('psixolog') ||
              first.contains('logoped') ||
              first.contains('koordinator') ||
              first.contains('direktor'))) {
        effectiveBadge = first;
        effectiveSubtitle = last;
      }
    }

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        Widget? iconWidget;
        if (icon != null) {
          iconWidget = Container(
            width: isCompact ? 44 : 48,
            height: isCompact ? 44 : 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryTint,
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: AppColors.primary,
              size: isCompact ? 21 : 23,
            ),
          );
        }

        final titleRow = Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isCompact ? 18.5 : 21,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
                height: 1.2,
              ),
            ),
            if (effectiveBadge != null)
              StatusPill(
                label: effectiveBadge,
                color: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
              ),
          ],
        );

        final textBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            titleRow,
            const SizedBox(height: 3.5),
            Text(
              effectiveSubtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isCompact ? 12.5 : 13.0,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ],
        );

        // Desktop / Katta ekranlarda yonma-yon gorizontal joylashuv
        if (!isCompact) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (iconWidget != null) ...[
                iconWidget,
                const SizedBox(width: 15),
              ],
              Expanded(child: textBlock),
              if (action != null) ...[
                const SizedBox(width: 16),
                action!,
              ],
            ],
          );
        }

        // Mobilda Boshqaruv kabi: tepada Matn/Ikona, pastda qulay To'liq kenglikdagi Tugma
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (iconWidget != null) ...[
                  iconWidget,
                  const SizedBox(width: 13),
                ],
                Expanded(child: textBlock),
              ],
            ),
            if (action != null) ...[
              const SizedBox(height: 14),
              action!,
            ],
          ],
        );
      },
    );

    if (!boxed) return content;

    return SurfaceCard(
      borderRadius: borderRadius,
      padding:
          padding ??
          const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: content,
    );
  }
}

/// Minimalist segmentli filtr-bar (13px tashqi, 10px ichki pill)
class ModernPillFilterBar extends StatelessWidget {
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String> onSelected;
  final Map<String, int>? counts;
  final Map<String, Color>? itemColors;

  const ModernPillFilterBar({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
    this.counts,
    this.itemColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Container(
        padding: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceMuted : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:
              items.map((item) {
                final isSelected = item == selectedItem;
                final count = counts?[item];
                final accentColor = itemColors?[item];

                return _ModernFilterPillItem(
                  item: item,
                  isSelected: isSelected,
                  count: count,
                  accentColor: accentColor,
                  onTap: () => onSelected(item),
                );
              }).toList(),
        ),
      ),
    );
  }
}

class _ModernFilterPillItem extends StatefulWidget {
  final String item;
  final bool isSelected;
  final int? count;
  final Color? accentColor;
  final VoidCallback onTap;

  const _ModernFilterPillItem({
    required this.item,
    required this.isSelected,
    required this.count,
    this.accentColor,
    required this.onTap,
  });

  @override
  State<_ModernFilterPillItem> createState() => _ModernFilterPillItemState();
}

class _ModernFilterPillItemState extends State<_ModernFilterPillItem> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;
    final accent = widget.accentColor;

    // Asosiy fon ranglari: Tanlanmagan holatda `withValues(alpha: 0.0)` ishlatiladi.
    // Bu Flutter'ning Color.lerp'i orqali animatsiya bo'lganda RGB o'zgarmasdan (255, 255, 255)
    // faqat shaffoflik o'zgarishini ta'minlaydi va oraliq qora/kulrang miltillash (bug)ni 100% yo'qotadi.
    final baseActiveBg = isDark ? AppColors.surfaceRaised : Colors.white;
    final baseInactiveBg = baseActiveBg.withValues(alpha: 0.0);
    final baseHoverBg = baseActiveBg.withValues(alpha: isDark ? 0.35 : 0.45);

    final effectiveBg =
        widget.isSelected
            ? baseActiveBg
            : (_hovered ? baseHoverBg : baseInactiveBg);

    // Chegara (Border) ranglari: xuddi shunday alpha orqali toza o'tadi
    final baseActiveBorder =
        accent != null
            ? accent.withValues(alpha: isDark ? 0.45 : 0.32)
            : (isDark ? const Color(0x35FFFFFF) : AppColors.cardGlassBorder);
    final baseInactiveBorder = baseActiveBorder.withValues(alpha: 0.0);
    final baseHoverBorder =
        baseActiveBorder.withValues(alpha: isDark ? 0.15 : 0.25);

    final effectiveBorder =
        widget.isSelected
            ? baseActiveBorder
            : (_hovered ? baseHoverBorder : baseInactiveBorder);

    // Soya (BoxShadow) parametrlari: ikkala holatda ham bir xil elementlar soni va offset/blur
    final shadowBaseColor = isDark ? Colors.black : const Color(0xFF0F172A);
    final shadowColor1 = shadowBaseColor.withValues(
      alpha: isDark ? 0.35 : 0.06,
    );
    final shadowColor2 = shadowBaseColor.withValues(
      alpha: isDark ? 0.20 : 0.04,
    );

    final effectiveShadows = [
      BoxShadow(
        color:
            widget.isSelected
                ? shadowColor1
                : shadowColor1.withValues(alpha: 0.0),
        blurRadius: 4,
        offset: const Offset(0, 1.5),
      ),
      BoxShadow(
        color:
            widget.isSelected
                ? shadowColor2
                : shadowColor2.withValues(alpha: 0.0),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ];

    final activeTextColor = accent ?? AppColors.textPrimary;
    final badgeAccent = accent ?? AppColors.primary;
    final badgeActiveBg =
        accent != null
            ? accent.withValues(alpha: isDark ? 0.22 : 0.14)
            : AppColors.primaryLight;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: Duration(milliseconds: _pressed ? 70 : 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
            decoration: BoxDecoration(
              color: effectiveBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: effectiveBorder, width: 1.0),
              boxShadow: effectiveShadows,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (accent != null) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                    color:
                        widget.isSelected
                            ? activeTextColor
                            : AppColors.textMuted,
                  ),
                  child: Text(widget.item),
                ),
                if (widget.count != null) ...[
                  const SizedBox(width: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          widget.isSelected
                              ? badgeActiveBg
                              : badgeActiveBg.withValues(alpha: 0.0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${widget.count}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color:
                            widget.isSelected
                                ? badgeAccent
                                : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimalist holat nishoni (8px radius + 0.85px nozik chegara)
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? icon;
  final bool showDot;
  final double maxWidth;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.borderColor,
    this.icon,
    this.showDot = false,
    this.maxWidth = 240,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        backgroundColor ??
        color.withValues(alpha: AppColors.isDark ? 0.16 : 0.10);
    final border = borderColor ?? color.withValues(alpha: 0.18);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        // StatusBadge bilan bir xil geometriya (to'liq yumaloq, 12px yozuv)
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 0.85),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
            ] else if (showDot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5.5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Foydalanuvchini faollashtiruvchi premium bo'sh holat vidjeti (Apple / Linear uslubida)
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final IconData? secondaryActionIcon;
  final VoidCallback? onSecondaryAction;
  final Widget? customAction;
  final Color? accentColor;
  final bool compact;
  final bool boxed;
  final double maxWidth;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.customAction,
    this.accentColor,
    this.compact = false,
    this.boxed = true,
    this.maxWidth = 480,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AppColors.primary;
    final isDark = AppColors.isDark;

    final iconBoxSize = compact ? 48.0 : 56.0;
    final iconSize = compact ? 22.0 : 26.0;
    final haloSize = compact ? 70.0 : 82.0;

    final haloWidget = Stack(
      alignment: Alignment.center,
      children: [
        // 1. Mayin halo doirasi (yumshoq jilo)
        Container(
          width: haloSize,
          height: haloSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                effectiveAccent.withValues(alpha: isDark ? 0.18 : 0.12),
                effectiveAccent.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        // 2. Konsentrik ichki ikonka konteyneri
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          decoration: BoxDecoration(
            color: isDark
                ? effectiveAccent.withValues(alpha: 0.16)
                : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(compact ? 15 : 18),
            border: Border.all(
              color: effectiveAccent.withValues(alpha: isDark ? 0.32 : 0.22),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveAccent.withValues(alpha: isDark ? 0.20 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: iconSize,
            color: effectiveAccent,
          ),
        ),
      ],
    );

    Widget? buttonsRow;
    if (customAction != null) {
      buttonsRow = customAction;
    } else {
      final hasPrimary = actionLabel != null && onAction != null;
      final hasSecondary = secondaryActionLabel != null && onSecondaryAction != null;

      if (hasPrimary || hasSecondary) {
        buttonsRow = LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 420;

            final primaryBtn = hasPrimary
                ? HeaderActionButton(
                    label: actionLabel!,
                    icon: actionIcon,
                    onPressed: onAction!,
                    variant: HeaderActionVariant.primary,
                  )
                : null;

            final secondaryBtn = hasSecondary
                ? HeaderActionButton(
                    label: secondaryActionLabel!,
                    icon: secondaryActionIcon,
                    onPressed: onSecondaryAction!,
                    variant: HeaderActionVariant.secondary,
                  )
                : null;

            if (primaryBtn != null && secondaryBtn != null) {
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    primaryBtn,
                    const SizedBox(height: 8),
                    secondaryBtn,
                  ],
                );
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  secondaryBtn,
                  const SizedBox(width: 10),
                  primaryBtn,
                ],
              );
            }

            return primaryBtn ?? secondaryBtn ?? const SizedBox.shrink();
          },
        );
      }
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        haloWidget,
        SizedBox(height: compact ? 12 : 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 15.0 : 16.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
            color: AppColors.textPrimary,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 12.3 : 13.0,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w400,
              height: 1.45,
            ),
          ),
        ),
        if (buttonsRow != null) ...[
          SizedBox(height: compact ? 14 : 18),
          buttonsRow,
        ],
      ],
    );

    final wrappedContent = boxed
        ? SurfaceCard(
            borderRadius: 26,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 22 : 30,
              vertical: compact ? 24 : 34,
            ),
            child: content,
          )
        : content;

    // Emil Kowalski qoidasi: Hech narsa scale(0) dan kirmaydi.
    // 220ms easeOutCubic bilan yumshoq fade + kichik 8px siljish
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, val, child) {
            return Opacity(
              opacity: val,
              child: Transform.translate(
                offset: Offset(0, (1.0 - val) * 8.0),
                child: child,
              ),
            );
          },
          child: wrappedContent,
        ),
      ),
    );
  }
}

/// Silliq muz effektli Shimmer yuklanish animatsiyasi (Skeleton loading)
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final isDark = AppColors.isDark;
    final baseColor = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.6)
        : const Color(0xFFE2E8F0).withValues(alpha: 0.7);
    final highlightColor = isDark
        ? const Color(0xFF334155).withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.85);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Skelet bloki (Skeleton block)
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Standart karta skeleti (O'quvchi, Baholash yoki Mashg'ulot kartasi uchun)
class ShimmerCardTile extends StatelessWidget {
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerCardTile({
    super.key,
    this.height = 76,
    this.borderRadius = 18,
    this.margin = const EdgeInsets.only(bottom: 9),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    return Container(
      height: height,
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.cardGlassBorder,
          width: 1.0,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Monogram / Avatar skeleti
          ShimmerBox(
            width: 44,
            height: 44,
            borderRadius: 14,
          ),
          const SizedBox(width: 14),
          // Sarlavha va matn qatorlari
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBox(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 6,
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.65,
                  child: ShimmerBox(
                    height: 11,
                    borderRadius: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // O'ng tarafdagi status pill skeleti
          ShimmerBox(
            width: 58,
            height: 24,
            borderRadius: 999,
          ),
        ],
      ),
    );
  }
}

/// Ro'yxat ko'rinishidagi Shimmer skeleton (List skeleton)
class ShimmerListSkeleton extends StatelessWidget {
  final int count;
  final double itemHeight;
  final double itemRadius;

  const ShimmerListSkeleton({
    super.key,
    this.count = 6,
    this.itemHeight = 76,
    this.itemRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: count,
        itemBuilder: (_, _) => ShimmerCardTile(
          height: itemHeight,
          borderRadius: itemRadius,
        ),
      ),
    );
  }
}

/// Dashboard KPI kartalari uchun Shimmer skeleton
class ShimmerKpiGridSkeleton extends StatelessWidget {
  const ShimmerKpiGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    Widget buildKpiSkeleton() {
      return Container(
        height: 120,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardGlassBorder, width: 1.0),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 90, height: 13, borderRadius: 5),
                ShimmerBox(width: 28, height: 28, borderRadius: 8),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 54, height: 26, borderRadius: 6),
                const SizedBox(height: 6),
                ShimmerBox(width: 110, height: 11, borderRadius: 4),
              ],
            ),
          ],
        ),
      );
    }

    return ShimmerLoading(
      child: ResponsiveGlassGrid(
        mobileColumns: 2,
        tabletColumns: 2,
        desktopColumns: 4,
        spacing: 9,
        children: List.generate(4, (_) => buildKpiSkeleton()),
      ),
    );
  }
}


