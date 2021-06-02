import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:ssi_app/models/identity_modal.dart';
import 'package:ssi_app/services/contracts_service.dart';

class ViewContractModal extends StatefulWidget {
  final Identity identity;
  final int identityIndex;

  ViewContractModal({@required this.identity, @required this.identityIndex});

  @override
  _ViewContractModalState createState() => _ViewContractModalState();
}

class _ViewContractModalState extends State<ViewContractModal> {
  bool addingService = false;
  bool addedService = false;
  bool errorWhileAdding = false;
  bool loadingData = false;
  Map<String, dynamic> data = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      this.loadingData = true;
    });
    final Map<String, dynamic> data = await Provider.of<ContractsService>(context).loadIdentityIpfsData(widget.identityIndex);
    if (mounted){
      setState(() {
        this.data = data ?? {};
        this.loadingData = false;
      });
    }
  }

  Widget _buildDataPage(){
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      controller: ModalScrollController.of(context),
      child: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Contract ID: ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                Expanded(child: Text(widget.identity.contract.address.hex, style: TextStyle(color: Colors.black),))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
            child: Divider(color: Theme.of(context).accentColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Verifier: ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                Expanded(child: Text(widget.identity.verifier?.hex ?? "", style: TextStyle(color: Colors.black),))
              ],
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Verification status: ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                Icon(
                  widget.identity.isVerified ? Icons.done : Icons.close,
                  color: widget.identity.isVerified ? Colors.green : Colors.red,
                  size: 20,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
            child: Divider(color: Theme.of(context).accentColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Reputation: ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                Expanded(
                  child: Text(
                    widget.identity.ratings != null && widget.identity.ratings.length > 0 ?
                    "${(widget.identity.ratings.reduce((value, element) => value + element) / BigInt.from(widget.identity.ratings.length)).toStringAsFixed(1)} (${widget.identity.ratings.length} ratings)" :
                    "no ratings",
                    style: TextStyle(color: Colors.black),
                  )
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
            child: Divider(color: Theme.of(context).accentColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Data: ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                Expanded(
                  child: this.loadingData ? 
                    SpinKitRing(color: Theme.of(context).accentColor, size: 24, lineWidth: 4,) :
                    (this.data.keys.length > 0) ? 
                      Column(
                        children: [
                          ...this.data.entries.map((entry){
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(" \u2022 ${entry.key}: " ?? "", style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.w500),),
                                  Expanded(
                                    child: _buildDataField(entry.value)/* Row(
                                      children: [
                                        Text(entry.value.toString().length.toString() ?? "", style: TextStyle(color: Colors.black),),
                                        Icon(Icons.launch, color: Theme.of(context).accentColor, size: 12),
                                      ],
                                    ) */
                                  )
                                ],
                            );
                          }).toList()
                        ],
                      ) : 
                      Text("No data to display", style: TextStyle(color: Colors.black)),
                )
              ],
            ),
          ),
          SizedBox(height: 30)
        ],
      ),
    );
  }

  Widget _buildDataField(dynamic value){
    try{
      // Value if File
      if (value['filename'] != null && value['data'] != null){
        return GestureDetector(
          child: Row(
            children: [
              Flexible(child: Text(value['filename'], style: TextStyle(color: Colors.black,))),
              SizedBox(width: 5,),
              Icon(Icons.launch, color: Theme.of(context).accentColor, size: 16),
            ]
          ),
          onTap: (){
            openFile(Uint8List.fromList(List<int>.from(value['data'])), value['filename']);
          },
        );
      } 
    }
    catch(e){
      // Value is String
      return Text(value.toString() ?? "", style: TextStyle(color: Colors.black),);
    }

    return SizedBox.shrink();
  }

  void openFile(Uint8List bytes, String filename) async {
    String dir = (await getTemporaryDirectory()).path;
    final File file = await File('$dir/$filename').writeAsBytes(bytes);
    OpenFile.open(file.path);
  }

  Widget _buildServicesPage(ContractsService contractsService){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            widget.identity.services.length > 0 ? 
              "Services with access:" : 
              "No services with access", 
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
        ),
        if (widget.identity.services.length > 0) Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 10),
            physics: BouncingScrollPhysics(),
            itemCount: widget.identity.services.length,
            itemBuilder: (context, index){
              return ListTile(
                title: Row(
                  children: [
                    Text("ID: ", style: TextStyle(color: Theme.of(context).accentColor, fontSize: 14, fontWeight: FontWeight.w500)),
                    Expanded(child: Text(widget.identity.services[index].hex, style: TextStyle(color: Colors.black, fontSize: 14,))),
                  ],
                )
              );
            }
          ),
        ),
        if (this.addingService) Center(child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: SpinKitRing(color: Theme.of(context).accentColor, size: 24, lineWidth: 4,),
        )),
        if (!this.addingService && widget.identity.isVerified) Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: IconButton(
              icon: Icon(Icons.qr_code_scanner, color: Theme.of(context).accentColor,), 
              onPressed: () async {
                setState(() {
                  this.addingService = true;
                  this.errorWhileAdding = false;
                  this.addedService = false;
                });

                String serviceQr = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
                
                if (serviceQr != null && serviceQr.isNotEmpty && serviceQr != "-1"){
                  bool addedVerifier = await contractsService.addServiceToContract(widget.identity.contract, serviceQr);
                  if (addedVerifier){
                    this.addedService = true;
                  }
                  else {
                    this.errorWhileAdding = true;
                  }
                }
                setState(() {
                  this.addingService = false;
                });
              }, 
            ),
          ),
        ),
        if (this.addedService) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text("Successfully added service!", style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold),),
        ),
        if (this.errorWhileAdding) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text("Error while adding service", style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold),),
        ),
        SizedBox(height: 20,)
      ]
    );
  }

  Widget _buildContent(ContractsService contractsService){
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            tabs: [
              Tab(icon: Icon(Icons.contact_page_outlined)),
              Tab(icon: Icon(Icons.qr_code_rounded),)
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height / 3,
            child: TabBarView(
              children: [
                _buildDataPage(),
                _buildServicesPage(contractsService)
              ],
            ),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              boxShadow: kElevationToShadow[4],
              color: Theme.of(context).accentColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Identity Details",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.cancel_outlined, color: Colors.black,), 
                  onPressed: Navigator.of(context).pop
                )
              ],
            ),
          ),
          _buildContent(Provider.of<ContractsService>(context)),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          )
        ],
      ),
    );
  }
}