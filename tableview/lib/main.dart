import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_ledger/generic_ledger.dart';
import 'package:generic_ledger/utils/string_constants.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

void main() {
  runApp(const MyApp());
  StringConstants.token = "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjBkMGU4NmJkNjQ3NDBjYWQyNDc1NjI4ZGEyZWM0OTZkZjUyYWRiNWQiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiTmFtYW4gSmFpbiIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BQ2c4b2NJWnpxV1ROaHFBRWp4RDRObHNrc25jVXQzWW9wZFVEZkhIWmotNV9XSFI9czk2LWMiLCJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vc3VpdGU0Mi1kZXYiLCJhdWQiOiJzdWl0ZTQyLWRldiIsImF1dGhfdGltZSI6MTY5ODY2OTE4OCwidXNlcl9pZCI6IkRrZzJTb1FSbzNScmlnekVhMUFGd28yV1VDeTEiLCJzdWIiOiJEa2cyU29RUm8zUnJpZ3pFYTFBRndvMldVQ3kxIiwiaWF0IjoxNjk4NjY5MTg4LCJleHAiOjE2OTg2NzI3ODgsImVtYWlsIjoibmFtYW4uakBzdWl0ZTQyLmluIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMDcxNDMzNDM2MjY3ODMxOTQ5MzciXSwiZW1haWwiOlsibmFtYW4uakBzdWl0ZTQyLmluIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifX0.PxIknu8slbmmX9fK6E7Mhan1tmAh188a01M4Eb35WUnFFH9MkECpvKuDggO3g2ShO4ETLE1DokOEHybB3iOsMPrNr1MardYLYnj08fKGsG2gnY8kjWf0yFrf1z1BZh051R1Wa3Be_qoM43_N7bdvpuZSWh94FFVUDQT2Ups3yOEvHJyT7ld-DRomVtDONM4w5v9hHDwG_Olr6-XkrOj9kXbJi4rLS3bTukdUgS0hbXI9IctJqr5b74T42-U8aicPf04BRhl_4dOdGkpxLt3kRxn0KbDIgWqBaK97XKT8mdt45oY7fHlOOeX08BDhK9aLF4OvdJbJF6d0EQ7Eq3OKzA";
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext contextx) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GenericTable(),
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
