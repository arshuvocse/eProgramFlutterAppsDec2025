import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _dashboardPrimary = Color(0xFF008080);
const _dashboardSecondary = Color(0xFF0A2540);
const _dashboardBg = Color(0xFFF5F7FB);

class StockListView extends StatelessWidget {
  const StockListView({super.key});

  @override
  Widget build(BuildContext context) {
    final stockItems = <_StockItem>[
      _StockItem(name: 'Item A', quantity: 12),
      _StockItem(name: 'Item B', quantity: 7),
      _StockItem(name: 'Item C', quantity: 20),
      _StockItem(name: 'Item D', quantity: 4),
    ];

    return Scaffold(
      backgroundColor: _dashboardBg,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_dashboardSecondary, _dashboardPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Stock List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1.2),
            },
            border: const TableBorder(
              horizontalInside: BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: Color(0xFFEFF6FF)),
                children: [
                  _TableHeaderCell('Item Name'),
                  _TableHeaderCell('Quantity'),
                ],
              ),
              ...stockItems.map(
                (item) => TableRow(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  children: [
                    _TableCell(item.name),
                    _TableCell(item.quantity.toString(),
                        alignEnd: true),
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

class _StockItem {
  final String name;
  final int quantity;

  const _StockItem({required this.name, required this.quantity});
}

class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: _dashboardSecondary,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool alignEnd;

  const _TableCell(this.text, {this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Align(
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: _dashboardSecondary,
          ),
        ),
      ),
    );
  }
}
