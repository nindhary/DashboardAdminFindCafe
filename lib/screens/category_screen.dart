import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/category_service.dart';
import '../main.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService service = CategoryService();

  List categories = [];
  List filteredCategories = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);

    try {
      final data = await service.getCategories();

      if (!mounted) return;

      setState(() {
        categories = data;
        filteredCategories = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void searchCategory(String keyword) {
    setState(() {
      filteredCategories = categories.where((item) {
        return item["name"]
            .toString()
            .toLowerCase()
            .contains(keyword.toLowerCase());
      }).toList();
    });
  }

  Future<void> addCategory() async {
    final controller = TextEditingController();

    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Tambah Kategori",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: MyApp.darkText,
            fontSize: 19,
          ),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.inter(
            color: MyApp.darkText,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: "Nama Kategori",
            labelStyle: GoogleFonts.inter(
              color: MyApp.darkText.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: MyApp.lightGray, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: MyApp.lightGray, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: MyApp.primaryBlue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "Batal",
              style: GoogleFonts.inter(
                color: MyApp.darkText,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyApp.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Simpan",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      setState(() {
        categories.insert(0, {
          "id": DateTime.now().millisecondsSinceEpoch,
          "name": controller.text,
        });

        filteredCategories = List.from(categories);
      });
    }
  }

  Future<void> editCategory(Map item) async {
    final controller = TextEditingController(text: item["name"]);

    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Edit Kategori",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: MyApp.darkText,
            fontSize: 19,
          ),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.inter(
            color: MyApp.darkText,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: MyApp.lightGray, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: MyApp.lightGray, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: MyApp.primaryBlue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "Batal",
              style: GoogleFonts.inter(
                color: MyApp.darkText,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyApp.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Update",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final index = categories.indexWhere(
        (e) => e["id"] == item["id"],
      );

      if (index != -1) {
        setState(() {
          categories[index]["name"] = controller.text;
          filteredCategories = List.from(categories);
        });
      }
    }
  }

  Future<void> deleteCategory(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Hapus",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: MyApp.darkText,
            fontSize: 19,
          ),
        ),
        content: Text(
          "Yakin ingin menghapus kategori?",
          style: GoogleFonts.inter(
            color: MyApp.darkText.withOpacity(0.7),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "Batal",
              style: GoogleFonts.inter(
                color: MyApp.darkText,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Hapus",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        categories.removeWhere(
          (item) => item["id"] == id,
        );

        filteredCategories = List.from(categories);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: MyApp.darkText,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Kelola ",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: MyApp.darkText.withOpacity(0.7),
                ),
              ),
              TextSpan(
                text: "Kategori",
                style: GoogleFonts.caveat(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: MyApp.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addCategory,
        backgroundColor: MyApp.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add_outlined),
        label: Text(
          "Tambah",
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: TextField(
                    onChanged: searchCategory,
                    style: GoogleFonts.inter(
                      color: MyApp.darkText,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Cari kategori...",
                      hintStyle: GoogleFonts.inter(
                        color: MyApp.darkText.withOpacity(0.4),
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.search_outlined,
                        size: 22,
                        color: MyApp.darkText.withOpacity(0.4),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: MyApp.lightGray, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: MyApp.lightGray, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: MyApp.primaryBlue, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadData,
                    color: MyApp.primaryBlue,
                    backgroundColor: Colors.white,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: filteredCategories.length,
                      itemBuilder: (_, index) {
                        final item = filteredCategories[index];

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
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: MyApp.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.category_outlined,
                                  color: MyApp.primaryBlue,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["name"] ?? "-",
                                      style: GoogleFonts.inter(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: MyApp.darkText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "ID: ${item["id"]}",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: MyApp.darkText.withOpacity(0.5),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: MyApp.favoriteAccent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: MyApp.favoriteAccent,
                                        size: 22,
                                      ),
                                      onPressed: () => editCategory(item),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 22,
                                      ),
                                      onPressed: () => deleteCategory(item["id"]),
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
