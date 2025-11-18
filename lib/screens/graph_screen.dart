import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import library grafik

class GraphScreen extends StatelessWidget {
  final String commodityName;

  const GraphScreen({super.key, required this.commodityName});

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk grafik (Bulan vs Harga dalam ribuan)
    final List<FlSpot> dummySpots = [
      const FlSpot(0, 35), // Jan: Rp 35.000
      const FlSpot(1, 38), // Feb: Rp 38.000
      const FlSpot(2, 34), // Mar: Rp 34.000
      const FlSpot(3, 40), // Apr: Rp 40.000
      const FlSpot(4, 45), // Mei: Rp 45.000
      const FlSpot(5, 42), // Jun: Rp 42.000
      const FlSpot(6, 48), // Jul: Rp 48.000
    ];

    // Kalkulasi statistik dari data dummy
    final prices = dummySpots.map((spot) => spot.y).toList();
    
    // ✅ PERBAIKAN: Tambahkan pengecekan untuk list kosong untuk menghindari error .reduce()
    final double highestPrice = prices.isNotEmpty ? prices.reduce((a, b) => a > b ? a : b) : 0;
    final double lowestPrice = prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 0;
    final double averagePrice = prices.isNotEmpty ? prices.reduce((a, b) => a + b) / prices.length : 0;

    // Warna utama untuk grafik
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tren Harga: $commodityName'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tren Harga 6 Bulan Terakhir',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              commodityName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(color: Colors.black12, strokeWidth: 1);
                    },
                    getDrawingVerticalLine: (value) {
                      return const FlLine(color: Colors.black12, strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 12);
                          Widget text;
                          switch (value.toInt()) {
                            case 0: text = const Text('Jan', style: style); break;
                            case 1: text = const Text('Feb', style: style); break;
                            case 2: text = const Text('Mar', style: style); break;
                            case 3: text = const Text('Apr', style: style); break;
                            case 4: text = const Text('Mei', style: style); break;
                            case 5: text = const Text('Jun', style: style); break;
                            case 6: text = const Text('Jul', style: style); break;
                            default: text = const Text('', style: style); break;
                          }
                          return SideTitleWidget(axisSide: meta.axisSide, child: text);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('Rp${value.toInt()}k', style: const TextStyle(color: Colors.black54, fontSize: 12), textAlign: TextAlign.left);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.black26, width: 1)),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 60,
                  lineBarsData: [
                    LineChartBarData(
                      spots: dummySpots,
                      isCurved: true,
                      gradient: LinearGradient(colors: [primaryColor.withOpacity(0.8), primaryColor]),
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [primaryColor.withOpacity(0.3), primaryColor.withOpacity(0.0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Bagian Ringkasan Statistik
            Text(
              'Ringkasan Statistik',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      'Tertinggi',
                      'Rp${highestPrice.toInt()}k',
                      Colors.green.shade600,
                    ),
                    _buildStatItem(
                      context,
                      'Terendah',
                      'Rp${lowestPrice.toInt()}k',
                      Colors.red.shade600,
                    ),
                    _buildStatItem(
                      context,
                      'Rata-rata',
                      'Rp${averagePrice.toStringAsFixed(1)}k',
                      Colors.blue.shade600,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget bantu untuk item statistik
  Widget _buildStatItem(BuildContext context, String title, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}