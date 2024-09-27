// lib/widgets/data_table_widget.dart

import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  final List<Map<String, String>> data; // List of maps representing rows of data
  final List<String> columns; // List of column names

  const DataTableWidget({super.key, 
    required this.data,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: columns
          .map((column) => DataColumn(label: Text(column)))
          .toList(),
      rows: data
          .map(
            (row) => DataRow(
              cells: row.values
                  .map((value) => DataCell(Text(value)))
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
