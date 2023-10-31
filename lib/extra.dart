// SliverList(
//   delegate: SliverChildListDelegate(
//     List.generate(
//       tableHeader.value!.actions != null ? row[index].row.length : row[index].row.length - fixedColumns,
//           (subIndex) => tableHeader.value!.actions != null && subIndex == row[index].row.length - fixedColumns ? Container(
//         padding: const EdgeInsets.only(left: 10),
//         // margin: const EdgeInsets.only(bottom: 15),
//         width: columnSize[index + fixedColumns],
//         decoration: const BoxDecoration(
//             color:  Color(0xFFF2F2F2),
//             border: Border(bottom: BorderSide(color: Colors.grey))
//         ),
//         height: 40,
//         child: row[index + ((activePage - 1) * rowsPerPage)].action!.isNotEmpty ? Center(
//           child: ListView.builder(
//               shrinkWrap: true,
//               scrollDirection: Axis.horizontal,
//               itemCount: row[index + ((activePage - 1) * rowsPerPage)].action!.length,
//               itemBuilder : (context,localIndex) => IconButton(
//                 onPressed: (){
//                     String? desc = "";
//                     Map<String, dynamic>  valData = {};
//                     for(var x in row[index + ((activePage - 1) * rowsPerPage)].row) {
//                       for(int y = 0; y < tableHeader.value!.actions![row[index + ((activePage - 1) * rowsPerPage)].action![localIndex].action]!["action_api_fields"].length; y++) {
//                         if(x.key == tableHeader.value!.actions![row[index + ((activePage - 1) * rowsPerPage)].action![localIndex].action]!["action_api_fields"][y]["field_name_in_table"]){
//                           valData[tableHeader.value!.actions![row[index + ((activePage - 1) * rowsPerPage)].action![localIndex].action]!["action_api_fields"][y]["field_name_in_action_api"]] = x.value;
//                         }
//                       }
//                     }
//                     print(valData);
//                     showDialog(context: context,barrierDismissible: false, builder: (context) {
//                       final formKey = GlobalKey<FormState>();
//                       return BlocProvider.value(
//                         value: BlocProvider.of<PaymentBloc>(mainContext),
//                         child: BlocConsumer<PaymentBloc,PaymentsState>(
//                             listener: (context, state) {
//                               if(state is PaymentsLoadedState) {
//                                 mainContext.read<TableBodyBloc>().add(FetchTableRowDataEvent(
//                                     baseUrl: tableHeader.value!.actionApi,
//                                     filters: filters.value,
//                                     sortBy: sortByWithOrder.value,
//                                     length: rowsPerPage));
//                                 Navigator.pop(context);
//                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Success"),backgroundColor: Colors.green,));
//                               } else if (state is PaymentsErrorState) {
//                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message),backgroundColor: Colors.red,));
//                               }
//                             },
//                             builder: (context, state) {
//                               final size = MediaQuery.of(context).size;
//                               return AlertDialog(
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                 title: Visibility(visible: state is! PaymentsLoadingState,child: Text(row[index + ((activePage - 1) * rowsPerPage)].action![localIndex].action,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),
//                                 content: state is PaymentsLoadingState ? SizedBox(height: size.height / 3,child: const Center(child: CircularProgressIndicator())) : Form(
//                                     key: formKey,
//                                     child: SizedBox(
//                                       width: size.width / 3,
//                                       child: TextFormField(
//                                         initialValue: desc,
//                                         decoration: const InputDecoration(
//                                           hintText: "Enter description",
//                                           border: OutlineInputBorder(),
//                                           focusedBorder: OutlineInputBorder(),
//                                         ),
//                                         maxLines: 4,
//                                         onSaved: (val){
//                                           valData["description"] = val != null && val.isNotEmpty ? val : valData["description"];
//                                           context.read<PaymentBloc>().add(PaymentsActionEvent(
//                                               tableHeader.value!.actions![row[index + ((activePage - 1) * rowsPerPage)].action![localIndex].action]!["action_api"],
//                                               {
//                                                 "data" : valData
//                                               }
//                                           ));
//                                         },
//                                         validator: row[index + ((activePage - 1) * rowsPerPage)].action![localIndex].action == "Approve" ? null : (val) {
//                                           if(val == null || val.isEmpty) {
//                                             return "Please enter some description";
//                                           } else if (val.length < 5) {
//                                             "Please write more than one word";
//                                           }
//                                         },
//                                       ),
//                                     )),
//                                 actions: state is PaymentsLoadingState ? [] : [
//                                   ElevatedButton(onPressed: (){
//                                     if(formKey.currentState!.validate()) {
//                                       formKey.currentState!.save();
//                                     }
//                                   }, child: Text(row[index + ((activePage - 1) * rowsPerPage)].action![localIndex].action,style: const TextStyle(fontWeight: FontWeight.bold),)),
//                                   OutlinedButton(onPressed: (){
//                                     Navigator.pop(context);
//                                   }, child: const Text("Cancel")),
//                                 ],
//                               );
//                             }
//                         ),
//                       );
//                     });
//                 },
//                 icon: Image.network(tableHeader.value!.actions![row[index + ((activePage - 1) * rowsPerPage)].action![localIndex].action]!["image_url"],width: 20,height: 20,),
//                 tooltip: row[index + ((activePage - 1) * rowsPerPage)].action![localIndex].action,
//               )
//           ),
//         ) : const Center(child: Text("No Action",style: TextStyle(fontWeight: FontWeight.bold),)),
//       ) : RowCell(dataType: tableHeader.value!.data.columns[subIndex+fixedColumns].dataType,row: row, activePage: activePage, rowsPerPage: rowsPerPage,index: index,subIndex:subIndex+fixedColumns,selectedCell: selectedCell,cellSize: columnSize[subIndex+fixedColumns],),
//     ),
//   ),
// ),