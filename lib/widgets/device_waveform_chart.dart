import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DeviceWaveformChart extends StatelessWidget {
  final List<double> samples;
  final double height;
  final double barWidth;
  final double spacing;
  final Duration animationDuration;

  const DeviceWaveformChart({
    super.key,
    this.samples = const [
      18,
      36,
      28,
      52,
      44,
      68,
      40,
      74,
      58,
      82,
      46,
      64,
    ],
    this.height = 120,
    this.barWidth = 14,
    this.spacing = 8,
    this.animationDuration = const Duration(milliseconds: 450),
  });

  @override
  Widget build(BuildContext context) {
    final chartValues = samples.isEmpty ? const [12.0, 28.0, 20.0, 42.0] : samples;
    final maxValue = chartValues.reduce(math.max);
    final maxY = maxValue <= 0 ? 100.0 : maxValue * 1.18;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceBetween,
          groupsSpace: spacing,
          backgroundColor: Colors.transparent,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            show: false,
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: BarTouchTooltipData(
              // tooltipRoundedRadius satırı versiyon uyuşmazlığı nedeniyle kaldırıldı.
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tooltipMargin: 8,
              getTooltipColor: (_) => const Color(0xCC120A2A),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(0)} ms',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          extraLinesData: const ExtraLinesData(),
          barGroups: List.generate(chartValues.length, (index) {
            final value = chartValues[index].clamp(0, maxY).toDouble();

            return BarChartGroupData(
              x: index,
              barsSpace: 0,
              barRods: [
                BarChartRodData(
                  toY: value,
                  width: barWidth,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFF5B13EC),
                      Color(0xFF7B61FF),
                      Color(0xFF86B6FF),
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: Colors.white.withOpacity(0.03),
                  ),
                ),
              ],
            );
          }),
        ),
        duration: animationDuration,
        curve: Curves.easeOutCubic,
      ),
    );
  }
}