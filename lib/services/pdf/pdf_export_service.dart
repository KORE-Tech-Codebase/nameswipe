import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:namora/models/favorite_model.dart';

class PdfExportService {
  static Future<void> exportFavorites(List<FavoriteModel> favorites) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Namora - My Favorite Names',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('${favorites.length} names',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            pw.Divider(),
            pw.SizedBox(height: 8),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            headers: ['Name', 'Meaning', 'Origin', 'Gender', 'Category'],
            data: favorites.map((f) => [
              f.name,
              f.meaning,
              f.origin,
              f.gender[0].toUpperCase() + f.gender.substring(1),
              f.category[0].toUpperCase() + f.category.substring(1),
            ]).toList(),
          ),
        ],
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'namora_favorites.pdf');
  }
}
