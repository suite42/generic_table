import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_ledger/generic_ledger.dart';
import 'package:generic_ledger/utils/string_constants.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

void main() {
  runApp(const MyApp());
  StringConstants.token = "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjBiYmQyOTllODU2MmU3MmYyZThkN2YwMTliYTdiZjAxMWFlZjU1Y2EiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vc3VpdGU0Mi1kZXYiLCJhdWQiOiJzdWl0ZTQyLWRldiIsImF1dGhfdGltZSI6MTcwMTE3ODE4NiwidXNlcl9pZCI6IjZ2YVZXUEk0a3VnS3phbWVRbHp4RHZkM2FVUTIiLCJzdWIiOiI2dmFWV1BJNGt1Z0t6YW1lUWx6eER2ZDNhVVEyIiwiaWF0IjoxNzAxMTc4MTg2LCJleHAiOjE3MDExODE3ODYsImVtYWlsIjoicmFtQHN1aXRlNDIuaW4iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJlbWFpbCI6WyJyYW1Ac3VpdGU0Mi5pbiJdfSwic2lnbl9pbl9wcm92aWRlciI6InBhc3N3b3JkIn19.ju88R3HYM427QQ-GxkzpmExHe9EJSr6ZkOB4dMreowRCGclP6nbnmxKa_YsJZBfWfoopinM6b7mcqt8MnacujyGSP_jF42sP66OS1HHeQ3JMwe_NVS7pwUw-0OYVBD2Ulc_F7MRXi5LT7enP7qJjb_t1qBPQF_5eaHRSmObNvcB34GHQeBE1G6HHo_7r27U1IWszlsTZ-dasC7shcjgPC_Ahd1z-iSQrxiAIfMcuTusItbRD4VLLlT2NWp719C1wcb3fnf9_PYBZdzWagNW0vaWW_dz3qGpmeqamCFhXF9YzalofMtxm3O-x2pVpU4pYiAnYT-BnaEj-rxmBdZDJmw";
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
