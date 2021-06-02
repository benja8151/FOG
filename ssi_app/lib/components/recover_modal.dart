import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:ssi_app/constants.dart';
import 'package:ssi_app/services/contracts_service.dart';
import 'package:web3dart/web3dart.dart';

class RecoverModal extends StatefulWidget {

  final bool recoverOwnIdentity;
  final EthereumAddress contractAddress;

  RecoverModal({@required this.recoverOwnIdentity, this.contractAddress});

  @override
  _RecoverModalState createState() => _RecoverModalState();
}

class _RecoverModalState extends State<RecoverModal> {
  int step = 0;

  List<Widget> _buildContent(ContractsService contractsService){
    if (widget.recoverOwnIdentity){
      switch (step){
        case 0: {
          return [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                "Step 1: Let your recovery contact scan this QR code:",
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
                data: kEthAccount,
                typeNumber: 3,
                size: 200,
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100.0),
              child: ElevatedButton(
                onPressed: (){
                  setState(() {
                    step = 1;
                  });
                },
                child: Text("Next Step")
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
                "Step 2: scan the QR code displayed on your recovery contact screen",
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
                    String restoredRegistryAddress = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);

                    if (restoredRegistryAddress != null && restoredRegistryAddress.isNotEmpty && restoredRegistryAddress != "-1"){
                      contractsService.changeEditingState(true);
                      await contractsService.recoverMyIdentity(restoredRegistryAddress);
                      contractsService.changeEditingState(false);
                      setState(() {
                        step = 2;
                      });
                    }
                  }, 
                  child: Text("Scan QR code")
                ),
            ),
            SizedBox(height: 60,)
          ];
        }
        case 2: {
          return [
            SizedBox(height: 40),
            Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Successfully recovered identity!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16
                ),
              ),
            ),
            SizedBox(height: 40)
          ];
        }
        default:
          return [];
      }
    }
    else {
      switch(step){
        case 0: {
          return [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                "Step 1: scan the QR code of a contact you wish to recover",
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
                    String newOwnerQr = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
                    
                    if (newOwnerQr != null && newOwnerQr.isNotEmpty && newOwnerQr != "-1"){
                      contractsService.changeEditingState(true);
                      await contractsService.recoverIdentity(widget.contractAddress, newOwnerQr);
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
                "Let your contact scan this QR code:",
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
                data: widget.contractAddress.hex,
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
                    "Recover Identity",
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