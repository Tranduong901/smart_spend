import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

/// Trend chart widget for visualizing income/expense trends over time
class TrendChartWidget extends StatefulWidget {
  final List<Transaction> transactions;
  final TrendPeriod initialPeriod;

  const TrendChartWidget({
    Key? key,
    required this.transactions,
    this.initialPeriod = TrendPeriod.month,
  }) : super(key: key);

  @override
  State<TrendChartWidget> createState() => _TrendChartWidgetState();
}

class _TrendChartWidgetState extends State<TrendChartWidget> {
  late TrendPeriod _selectedPeriod;
  late TrendChartType _chartType;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialPeriod;
    _chartType = TrendChartType.line;
  }

  @override
  Widget build(BuildContext context) {
    final data = _getTrendData();

    return Column(
      children: [
        // Period selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final period in TrendPeriod.values)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: FilterChip(
                  label: Text(period.label),
                  selected: _selectedPeriod == period,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedPeriod = period);
                    }
                  },
                ),
              ),
          ],
        ),
        SizedBox(height: 16),

        // Chart type selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: Text('Dòng'),
              selected: _chartType == TrendChartType.line,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _chartType = TrendChartType.line);
                }
              },
            ),
            SizedBox(width: 12),
            ChoiceChip(
              label: Text('Cột'),
              selected: _chartType == TrendChartType.bar,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _chartType = TrendChartType.bar);
                }
              },
            ),
          ],
        ),
        SizedBox(height: 16),

        // Chart
        if (_chartType == TrendChartType.line)
          _buildLineChart(data)
        else
          _buildBarChart(data),
      ],
    );
  }

  Widget _buildLineChart(TrendData data) {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    data.labels[value.toInt()] ?? '',
                    style: TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value / 1000000).toStringAsFixed(1)}M',
                    style: TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: data.incomeSpots,
              isCurved: true,
              color: Colors.green,
              barWidth: 2,
              dotData: FlDotData(show: true),
            ),
            LineChartBarData(
              spots: data.expenseSpots,
              isCurved: true,
              color: Colors.red,
              barWidth: 2,
              dotData: FlDotData(show: true),
            ),
          ],
          lineTouchData: LineTouchData(enabled: true),
        ),
      ),
    );
  }

  Widget _buildBarChart(TrendData data) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    data.labels[value.toInt()] ?? '',
                    style: TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value / 1000000).toStringAsFixed(1)}M',
                    style: TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          barGroups: _buildBarGroups(data),
          barTouchData: BarTouchData(enabled: true),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(TrendData data) {
    final groups = <BarChartGroupData>[];
    final maxLength = data.labels.length;

    for (int i = 0; i < maxLength; i++) {
      final incomeValue =
          i < data.incomeSpots.length ? data.incomeSpots[i].y : 0;
      final expenseValue =
          i < data.expenseSpots.length ? data.expenseSpots[i].y : 0;

      groups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: incomeValue.toDouble(),
            color: Colors.green,
            width: 8,
          ),
          BarChartRodData(
            toY: expenseValue.toDouble(),
            color: Colors.red,
            width: 8,
          ),
        ],
      ));
    }

    return groups;
  }

  TrendData _getTrendData() {
    final now = DateTime.now();
    final incomeByPeriod = <int, double>{};
    final expenseByPeriod = <int, double>{};
    final labels = <int, String>{};

    for (var tx in widget.transactions) {
      int periodKey = 0;
      String label = '';

      switch (_selectedPeriod) {
        case TrendPeriod.month:
          // Last 12 months
          final monthsDiff =
              (now.year - tx.date.year) * 12 + (now.month - tx.date.month);
          if (monthsDiff < 12) {
            periodKey = 11 - monthsDiff;
            label = 'T${tx.date.month}';
          } else {
            continue;
          }
          break;
        case TrendPeriod.quarter:
          // Last 4 quarters
          final quarter = (tx.date.month - 1) ~/ 3 + 1;
          final quartersDiff = (now.year - tx.date.year) * 4 +
              (((now.month - 1) ~/ 3 + 1) - quarter);
          if (quartersDiff < 4) {
            periodKey = 3 - quartersDiff;
            label = 'Q$quarter/${tx.date.year}';
          } else {
            continue;
          }
          break;
        case TrendPeriod.year:
          // Last 5 years
          final yearsDiff = now.year - tx.date.year;
          if (yearsDiff < 5) {
            periodKey = 4 - yearsDiff;
            label = '${tx.date.year}';
          } else {
            continue;
          }
          break;
      }

      labels[periodKey] = label;
      if (tx.isIncome) {
        incomeByPeriod[periodKey] =
            (incomeByPeriod[periodKey] ?? 0) + tx.amount;
      } else {
        expenseByPeriod[periodKey] =
            (expenseByPeriod[periodKey] ?? 0) + tx.amount;
      }
    }

    // Build spots
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];
    final sortedKeys = labels.keys.toList()..sort();

    for (final key in sortedKeys) {
      incomeSpots.add(FlSpot(key.toDouble(), incomeByPeriod[key] ?? 0));
      expenseSpots.add(FlSpot(key.toDouble(), expenseByPeriod[key] ?? 0));
    }

    return TrendData(
      incomeSpots: incomeSpots,
      expenseSpots: expenseSpots,
      labels: labels,
    );
  }
}

enum TrendPeriod {
  month('Tháng'),
  quarter('Quý'),
  year('Năm');

  final String label;
  const TrendPeriod(this.label);
}

enum TrendChartType { line, bar }

class TrendData {
  final List<FlSpot> incomeSpots;
  final List<FlSpot> expenseSpots;
  final Map<int, String> labels;

  TrendData({
    required this.incomeSpots,
    required this.expenseSpots,
    required this.labels,
  });
}
