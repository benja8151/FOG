import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:ssi_app/components/contract_form.dart';
import 'package:ssi_app/services/contracts_service.dart';
import 'package:ssi_app/services/ipfs_service.dart';
import 'package:ssi_app/services/keys_service.dart';

class AddContractModal extends StatefulWidget {
  @override
  _AddContractModalState createState() => _AddContractModalState();
}

class _AddContractModalState extends State<AddContractModal> {
  int step = 0;

  List<Widget> _buildContent(ContractsService contractsService){
    switch(step){
      case 0: {
        return [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              "This action will create a new self sovereign identity contract.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: (contractsService.isLoadingContracts || contractsService.isAddingContract) ?
              SpinKitRing(color: Theme.of(context).primaryColor) : 
              ElevatedButton(
                onPressed: () {
                  contractsService.createNewIdentity().then((_){
                    setState((){
                      step = 1;
                    });
                  });
                }, 
                child: Text("Add new Identity")
              ),
          ),
          SizedBox(height: 60,)
        ];
      }
      case 1: {
        return [
          ContractForm(
            contractsService: contractsService,
            onSave: (String data) async {
              contractsService.changeEditingState(true);
              try {
                String ipfsHash = await context.read<IpfsService>().saveData(utf8.encode(data));
                if (ipfsHash != null){

                  String encryptedIpfsHash = context.read<KeysService>().encryptString(ipfsHash);
                  print(ipfsHash);
                  print(encryptedIpfsHash);
                  await contractsService.setContractIPFS(contractsService.identityContracts.last.contract, encryptedIpfsHash);

                  setState(() {
                    step = 2;
                  });
                }
                contractsService.changeEditingState(false);
              }
              catch (error){
                print(error);
                contractsService.changeEditingState(false);
              }
            },
          )
        ];
      }
      case 2: {
        return [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              "Scan QR code to add identity verifier.",
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
                  String verifierQr = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
                  
                  if (verifierQr != null && verifierQr.isNotEmpty && verifierQr != "-1"){
                    contractsService.changeEditingState(true);
                    bool addedVerifier = await contractsService.setContractVerifier(contractsService.identityContracts.last.contract, verifierQr);
                    contractsService.changeEditingState(false);
                    
                    if (addedVerifier){
                      setState(() {
                        step = 3;
                      });
                    }
                  }
                }, 
                child: Text("Scan QR code")
              ),
          ),
          SizedBox(height: 60,)
        ];
      }
      case 3: {
        return [
          SizedBox(height: 40),
          Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Successfully added identity!",
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
                    "Add new Identity",
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