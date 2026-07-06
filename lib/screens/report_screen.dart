import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/report_service.dart';
import '../main.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService service = ReportService();

  List reports = [];
  List filteredReports = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);

    try {
      final data = await service.getReports();

      if (!mounted) return;

      setState(() {
        reports = data;
        filteredReports = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void searchReport(String keyword) {
    setState(() {
      filteredReports = reports.where((item) {
        final reason = item["reason"]?.toString().toLowerCase() ?? "";

        final place = item["place"]?["name"]?.toString().toLowerCase() ?? "";

        final reporter =
            item["reporter"]?["name"]?.toString().toLowerCase() ?? "";

        return reason.contains(keyword.toLowerCase()) ||
            place.contains(keyword.toLowerCase()) ||
            reporter.contains(keyword.toLowerCase());
      }).toList();
    });
  }

  Future<void> resolveReport(Map item) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Resolve Report",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: MyApp.darkText,
          ),
        ),
        content: Text(
          "Tandai laporan ini sebagai selesai?",
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Resolve"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await service.resolveReport(
        int.parse(item["id"].toString()),
      );

      if (success) {
        await loadData();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report berhasil di-resolve")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal resolve report")));
      }
    }
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case "resolved":
        return Colors.green;
      case "pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MyApp.darkText,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Kelola ",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: MyApp.darkText.withOpacity(.7),
                ),
              ),
              TextSpan(
                text: "Report",
                style: GoogleFonts.caveat(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: MyApp.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: TextField(
                    onChanged: searchReport,
                    decoration: InputDecoration(
                      hintText: "Cari report...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                      itemCount: filteredReports.length,
                      itemBuilder: (_, index) {
                        final item = filteredReports[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: MyApp.lightGray,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: MyApp.darkText.withOpacity(0.02),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.flag_outlined,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["place"]?["name"] ?? "-",
                                          style: GoogleFonts.inter(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: MyApp.darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Pelapor : ${item["reporter"]?["name"] ?? "-"}",
                                          style: GoogleFonts.inter(
                                            color: MyApp.darkText.withOpacity(
                                              .6,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor(
                                        item["status"],
                                      ).withOpacity(.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item["status"],
                                      style: GoogleFonts.inter(
                                        color: statusColor(item["status"]),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Text(
                                "Alasan",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: MyApp.darkText,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                item["reason"] ?? "-",
                                style: GoogleFonts.inter(
                                  color: MyApp.darkText.withOpacity(.75),
                                ),
                              ),

                              if (item["description"] != null &&
                                  item["description"]
                                      .toString()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Text(
                                  "Deskripsi",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    color: MyApp.darkText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item["description"],
                                  style: GoogleFonts.inter(
                                    color: MyApp.darkText.withOpacity(.75),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 18),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.location_on_outlined,
                                      ),
                                      label: const Text("Place ID"),
                                      onPressed: null,
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  if (item["status"] == "pending")
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.check_circle_outline,
                                        ),
                                        label: const Text("Resolve"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: () => resolveReport(item),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.verified),
                                        label: const Text("Resolved"),
                                        onPressed: null,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
