import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:ssi_app/constants.dart';
import 'package:ssi_app/services/contracts_service.dart';

class AddRecoveryContactModal extends StatefulWidget {
  @override
  _AddRecoveryContactModalState createState() => _AddRecoveryContactModalState();
}

class _AddRecoveryContactModalState extends State<AddRecoveryContactModal> {
  int step = 0;

  List<Widget> _buildContent(ContractsService contractsService){
    switch(step){
      case 0: {
        return [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              "Step 1: scan the QR code of a contact you wish to add as recovery contact",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: (contractsService.isLoadingContracts || contractsService.isEditingContract) ?
              SpinKitRing(color: Theme.of(context).primaryColor) : 
              ElevatedButton(
                onPressed: () async {
                  String contactQr = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
                  
                  if (contactQr != null && contactQr.isNotEmpty && contactQr != "-1"){
                    contractsService.changeEditingState(true);
                    await contractsService.addRecoveryContact(contactQr);
                    contractsService.changeEditingState(false);
                    setState(() {
                      step = 1;
                    });
                  }
                }, 
                child: Text("Scan QR code")
              ),
          ),
          SizedBox(height: 60,)
        ];
      }
      case 1: {
        return [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              "Step 2: let your recovery contact scan this QR code:",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: PrettyQr(
              data: contractsService.registryContract.contract.address.hex,
              typeNumber: 3,
              size: 200,
            )
          ),
          SizedBox(height: 60,)
        ];
      }
      default:
        return [];
    }
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
                    "Add Recovery Contact",
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
          ..._buildContent(Provider.of<ContractsService>(context)),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          )
        ],
      ),
    );
  }
}