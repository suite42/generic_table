import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_ledger/generic_ledger.dart';
import 'package:generic_ledger/utils/string_constants.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext contextx) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Generic Table',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: GenericTable(basPath: "table",),
    );
  }
}



//  TextFormField(
// focusNode:
// focusNode,
// textAlign:
// TextAlign
//     .center,
// decoration: const InputDecoration(
// focusedBorder: OutlineInputBorder(
// borderSide: BorderSide(
// color: Colors
//     .grey),
// borderRadius: BorderRadius
//     .zero),
// border: OutlineInputBorder(
// borderSide:
// BorderSide(color: Colors.grey),
// borderRadius: BorderRadius.zero),
// contentPadding: EdgeInsets.zero),
// // textAlignVertical: TextAlignVertical.center,
// initialValue:
// "Data ${subIndex - 1}",
// )

// Row(
// children: [
// Expanded(child: payColumn("Pay Out")),
// VerticalDivider(width: 50),
// Expanded(child: payColumn("Pay In")),
// ],
// ),
// SizedBox(height: 30,),

// Container payColumn(String title) {
//   return Container(
//     padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
//     decoration: BoxDecoration(
//         color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(10)),
//     child: Column(
//       children: [
//         SizedBox(
//             width: double.infinity,
//             child: Container(
//               padding:
//               const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(5)),
//               child: Text(
//                 title,
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             )),
//         const SizedBox(
//           height: 10,
//         ),
//         Row(
//           children: [
//             Expanded(
//                 child: amountContainer(
//                     text: "Total amount to pay",
//                     amount: "40000",
//                     isPlus: false)),
//             const VerticalDivider(
//               width: 50,
//             ),
//             Expanded(
//                 child: amountContainer(
//                     text: "Debit note", amount: "30000", isPlus: true)),
//           ],
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//         Row(
//           children: [
//             Expanded(
//                 child: amountContainer(
//                     text: "Overdue amount", amount: "10000", isPlus: true)),
//             const VerticalDivider(
//               width: 50,
//             ),
//             Expanded(
//                 child: amountContainer(
//                     text: "Advance payment", amount: "40000", isPlus: false)),
//           ],
//         ),
//       ],
//     ),
//   );
// }
//
// Container amountContainer(
//     {required String text, required String amount, required bool isPlus}) {
//   return Container(
//     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//     decoration: BoxDecoration(
//         color: Colors.white, borderRadius: BorderRadius.circular(5)),
//     child: Text.rich(TextSpan(
//         text: "$text :- ",
//         children: [
//           const TextSpan(text: " ("),
//           TextSpan(
//               text: isPlus ? "+" : "-",
//               style: TextStyle(color: isPlus ? Colors.green : Colors.red)),
//           const TextSpan(text: ") "),
//           TextSpan(
//               text: "₹$amount",
//               style: TextStyle(
//                   color: text.toLowerCase().startsWith("overdue")
//                       ? Colors.red
//                       : null)),
//         ],
//         style: const TextStyle(fontWeight: FontWeight.bold))),
//   );
// }
