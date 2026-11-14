// import 'dart:typed_data';

// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// class PdfService {
//   static Future<Uint8List> generateBill({
//     required List<Map<String, dynamic>> items,
//     required double total,
//     required double paid,
//     required double remaining,
//     required String paymentMode,
//   }) async {
//     final pdf = pw.Document();

//     // Unicode font
//     final font = await PdfGoogleFonts.notoSansRegular();
//     final boldFont = await PdfGoogleFonts.notoSansBold();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Center(
//                 child: pw.Text(
//                   "SHOP BILL",
//                   style: pw.TextStyle(
//                     font: boldFont,
//                     fontSize: 24,
//                   ),
//                 ),
//               ),

//               pw.SizedBox(height: 20),

//               pw.Table.fromTextArray(
//                 headers: ["Product", "Rate", "Qty", "Total"],
//                 headerStyle: pw.TextStyle(
//                   font: boldFont,
//                 ),
//                 cellStyle: pw.TextStyle(
//                   font: font,
//                 ),
//                 data: items.map((e) {
//                   return [
//                     e["name"].toString(),
//                     "Rs. ${e["rate"]}",
//                     e["qty"].toString(),
//                     "Rs. ${e["total"]}",
//                   ];
//                 }).toList(),
//               ),

//               pw.SizedBox(height: 20),

//               pw.Text(
//                 "Grand Total : ₹$total",
//                 style: pw.TextStyle(
//                   font: boldFont,
//                 ),
//               ),

//               pw.Text(
//                 "Paid : ₹$paid",
//                 style: pw.TextStyle(font: font),
//               ),

//               pw.Text(
//                 "Remaining : ₹$remaining",
//                 style: pw.TextStyle(font: font),
//               ),

//               pw.Text(
//                 "Payment : $paymentMode",
//                 style: pw.TextStyle(font: font),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     return pdf.save();
//   }
// }

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<Uint8List> generateBill({
    required List<Map<String, dynamic>> items,
    required double total,
    required double paid,
    required double remaining,
    required String paymentMode,
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Center(
                child: pw.Text(
                  "SHOP BILL",
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 24,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                headers: [
                  "Product",
                  "Rate",
                  "Qty",
                  "Total"
                ],

                headerStyle: pw.TextStyle(
                  font: boldFont,
                ),

                cellStyle: pw.TextStyle(
                  font: font,
                ),

                data: items.map((e) {

                  return [
                    e["name"].toString(),

                    "Rs. ${e["rate"]}",

                    e["qty"].toString(),

                    "Rs. ${e["total"]}",
                  ];

                }).toList(),
              ),


              pw.SizedBox(height: 20),


              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.end,
                  children: [

                    pw.Text(
                      "Grand Total : Rs. $total",
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 14,
                      ),
                    ),


                    pw.Text(
                      "Paid : Rs. $paid",
                      style: pw.TextStyle(
                        font: font,
                      ),
                    ),


                    pw.Text(
                      "Remaining : Rs. $remaining",
                      style: pw.TextStyle(
                        font: font,
                      ),
                    ),


                    pw.Text(
                      "Payment : $paymentMode",
                      style: pw.TextStyle(
                        font: font,
                      ),
                    ),

                  ],
                ),
              )

            ],
          );
        },
      ),
    );


    return pdf.save();
  }
}