import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:invoice_reckon/screens/sales/widgets/helpers_invoice/pdfapi.dart';
import 'package:invoice_reckon/screens/sales/widgets/shopName.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'utils.dart';

class PdfInvoiceApi {

  static Future<File> generate({List<List<String>>listOfLists,String uid, String voucherId, String custId, int totalAmt, int payAmt, int leftAmt, String name, Timestamp timestamp, Timestamp createdDate, String creator}) async {
    final pdf = Document();
    
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          buildHeader(name, name, voucherId,createdDate),
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          buildTitle(),
          buildInvoice(listOfLists,totalAmt,uid,voucherId , name ),
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          // pw.Divider(),
          buildTotal(totalAmt),
        ],
        footer: (context) => buildFooter(),
      ),
    );

    return PDFApi.saveDocument(name: 'Invoice: $voucherId.pdf', pdf: pdf);
  }

  static pw.Widget buildHeader(String name, String phNo, String voucherId, Timestamp createdDate) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 1 * PdfPageFormat.cm),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          buildSupplierAddress(),
          pw.Container(
            height: 50,
            width: 50,
            child: BarcodeWidget(
              barcode: Barcode.qrCode(),
              data: voucherId,
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 2 * PdfPageFormat.cm),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          buildCustomerAddress(name, name),
          buildInvoiceInfo(createdDate,voucherId),
        ],
      ),
    ],
  );

  static pw.Widget buildCustomerAddress(String name, String address) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(name, style: pw.TextStyle(fontWeight: FontWeight.bold)),
      pw.Text(address),
    ],
  );

  static pw.Widget buildInvoiceInfo(Timestamp createdDate, String voucherId ) {
    // final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titles = <String>[
      'Invoice Number:',
      'Invoice Date:',
    ];
    final data = <String>[
      voucherId,
      Utils.formatDate(createdDate.toDate()),
    ];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];
        return buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static pw.Widget buildSupplierAddress() => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(ShopName.shopName, style: pw.TextStyle(fontWeight: FontWeight.bold)),
      pw.SizedBox(height: 1 * PdfPageFormat.mm),
      pw.Text(ShopName.shopPhoneNo, style: pw.TextStyle(fontWeight: FontWeight.bold)),
      pw.SizedBox(height: 1 * PdfPageFormat.mm),
      pw.Text(ShopName.shopLocation),

    ],
  );

  static pw.Widget buildTitle() => pw.Column(
    children: [
      pw.Center( child: pw.Text(
        'INVOICE',
        style: pw.TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),),
      pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
    ],
  );

  static pw.Widget buildInvoice(List<List<String>> listofLists,int totalAmt, String uid, String voucherId , String name) {
    
    final headers = [
      'Name',
      'Unit Price',
      'Quantity',
      'Total'
    ];
    
    // prefix.StreamBuilder(
    //   stream: FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(uid)
    //       .collection('vouchers')
    //       .doc(name)
    //       .collection('customerVouchers')
    //       .doc(voucherId)
    //       .collection('items')
    //       .orderBy('timestamp',descending: false)
    //       .snapshots(),
    //   builder: (context, snapshot) {
    //     List<prefix.TableRow> newList = [];
    //       List<int> itemsTotal = [];
    //       snapshot.data.docs.forEach((doc) {
    //         Item item = Item.fromDocument(doc);
    //         itemsTotal.add(item.total);
    //         newList.add(prefix.TableRow(
    //           children: [
    //             TableCell(child: prefix.Text(item.itemName),),
    //             TableCell(child: prefix.Text(item.price.toString())),
    //             TableCell(child: prefix.Text(item.price.toString())),
    //             TableCell(child: prefix.Text(item.total.toString()))
    //           ]
    //         ));
    //       });
    //     return prefix.Table(
    //       children: tableList,
    //       defaultColumnWidth: prefix.FixedColumnWidth(120.0),  
    //       border: prefix.TableBorder.all(  
    //         color: prefix.Colors.black,  
    //         style: prefix.BorderStyle.solid,  
    //         width: 2
    //       ),  
    //     );
    //   },
    // );

    return pw.Table.fromTextArray(
      headers: headers,
      data: listofLists,
      border: pw.TableBorder.all(width: 1.0,style: pw.BorderStyle(
        paint: true,
      )),
      headerStyle: pw.TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
    
  }

  static pw.Widget buildTotal(int totalAmt) {
    
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        children: [
          pw.Spacer(flex: 6),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Net total',
                  value: totalAmt.toString(),
                  unite: true,
                ),
                pw.Divider(),
                buildText(
                  title: 'Total amount due',
                  titleStyle: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  value: totalAmt.toString(),
                  unite: true,
                ),
                pw.SizedBox(height: 2 * PdfPageFormat.mm),
                pw.Container(height: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                pw.Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget buildFooter() => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Divider(),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          buildSimpleText(title: 'Proudly Powered By GovindDev © ${DateTime.now().year}'),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          buildSimpleText(title: 'Email', value: 'govinddev010@gmail.com'),
        ],
      );

  static buildSimpleText({
    String title,
    String value,
  }) {
    final style = pw.TextStyle(fontWeight: FontWeight.bold);

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(title, style: style),
        pw.SizedBox(width: 2 * PdfPageFormat.mm),
        pw.Text(value),
      ],
    );
  }

  static buildText({
     String title,
     String value,
    double width = double.infinity,
    pw.TextStyle titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? pw.TextStyle(fontWeight: FontWeight.bold);

    return pw.Container(
      width: 200,
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(title, style: style)),
          pw.Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}