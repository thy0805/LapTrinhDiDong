import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';

class AppTable<T> extends StatelessWidget {
  final List<String> columns;
  final List<T> data;
  final List<DataCell> Function(T) cellBuilder;
  final String title;
  final List<Widget>? actions;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int)? onPageChanged;
  final Function(String)? onSearch;

  const AppTable({
    super.key,
    required this.columns,
    required this.data,
    required this.cellBuilder,
    required this.title,
    this.actions,
    this.isLoading = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.onPageChanged,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TailAdminDesign.bgCard,
        borderRadius: BorderRadius.circular(TailAdminDesign.radiusXl),
        border: Border.all(color: TailAdminDesign.border),
        boxShadow: TailAdminDesign.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(TailAdminDesign.sp6),
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TailAdminDesign.textMain,
                  ),
                ),
                const Spacer(),
                if (onSearch != null)
                  Container(
                    width: 250,
                    height: 40,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: TailAdminDesign.isDark
                          ? TailAdminDesign.darkBg
                          : TailAdminDesign.gray50,
                      borderRadius: BorderRadius.circular(
                        TailAdminDesign.radiusMd,
                      ),
                      border: Border.all(color: TailAdminDesign.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: TailAdminDesign.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: onSearch,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: TailAdminDesign.textMain,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm...',
                              hintStyle: GoogleFonts.outfit(
                                color: TailAdminDesign.textMuted,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'Không có dữ liệu',
                  style: GoogleFonts.outfit(color: TailAdminDesign.textMuted),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 340,
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    TailAdminDesign.isDark
                        ? TailAdminDesign.darkBg.withValues(alpha: 0.5)
                        : TailAdminDesign.gray50,
                  ),
                  dataRowMaxHeight: 70,
                  dividerThickness: 1,
                  horizontalMargin: 24,
                  columnSpacing: 24,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: TailAdminDesign.border,
                      width: 1,
                    ),
                  ),
                  columns: columns
                      .map(
                        (col) => DataColumn(
                          label: Text(
                            col,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: TailAdminDesign.textMain,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  rows: data
                      .map((item) => DataRow(cells: cellBuilder(item)))
                      .toList(),
                ),
              ),
            ),
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(TailAdminDesign.sp6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trang $currentPage trên $totalPages',
                    style: GoogleFonts.outfit(
                      color: TailAdminDesign.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      _PaginationButton(
                        icon: Icons.chevron_left_rounded,
                        isEnabled: currentPage > 1,
                        onTap: () => onPageChanged?.call(currentPage - 1),
                      ),
                      const SizedBox(width: 8),
                      _PaginationButton(
                        icon: Icons.chevron_right_rounded,
                        isEnabled: currentPage < totalPages,
                        onTap: () => onPageChanged?.call(currentPage + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AppTableRow extends StatelessWidget {
  final List<Widget> cells;
  const AppTableRow({super.key, required this.cells});

  @override
  Widget build(BuildContext context) {
    return Row(children: cells);
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  const _PaginationButton({
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: TailAdminDesign.border),
          borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
          color: isEnabled
              ? Colors.transparent
              : TailAdminDesign.border.withValues(alpha: 0.5),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isEnabled
              ? TailAdminDesign.textMain
              : TailAdminDesign.textMuted,
        ),
      ),
    );
  }
}
