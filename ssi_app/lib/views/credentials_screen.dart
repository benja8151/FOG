import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:ssi_app/services/keys_service.dart';

class CredentialsScreen extends StatefulWidget {
  @override
  _CredentialsScreenState createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends State<CredentialsScreen> {

  List<Widget> _buildContent(KeysService keysService){
    List<Widget> output = [];

    if (keysService.keysGenerated){
      output.add(
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mnemonic: ", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(keysService?.mnemonic ?? ""))
                ],
              ),
              SizedBox(height: 20,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Private key: ", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(keysService?.privateKey ?? ""))
                ],
              ),
              SizedBox(height: 20,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Public key: ", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(keysService?.publicKey ?? ""))
                ],
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                child: Text(
                  "Generate New Credentials"
                ),
                onPressed: () async {
                  final List<String> dialogResult = await showTextInputDialog(
                    context: context, 
                    title: "Enter Password",
                    message: "This will be used together with random mnemonic sequence to generate your credentials.",
                    textFields: [
                      DialogTextField(
                        hintText: "Password",
                        obscureText: true
                      )
                    ]
                  );
                  if (dialogResult != null){
                    keysService.generateKeys(dialogResult[0]);
                  }
                },
              ),
              ElevatedButton(
                child: Text(
                  "Restore Credentials"
                ),
                onPressed: () async {
                  final List<String> dialogResult = await showTextInputDialog(
                    context: context, 
                    title: "Restore credentials",
                    message: "Enter mnemonic and password.",
                    textFields: [
                      DialogTextField(
                        hintText: "12 word mnemonic sequence",
                        obscureText: false
                      ),
                      DialogTextField(
                        hintText: "Password",
                        obscureText: true
                      )
                    ]
                  );
                  if (dialogResult != null){
                    keysService.restoreKeys(dialogResult[0], dialogResult[1]);
                  }
                },
              ),
            ]
          ),
        )
      );
    }
    else {
      output.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("No credentials found on this device. Generate new ones or restore them using mnemonic sequence and password", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500),),
            ),
            ElevatedButton(
              child: Text(
                "Generate Credentials"
              ),
              onPressed: () async {
                final List<String> dialogResult = await showTextInputDialog(
                  context: context, 
                  title: "Enter Password",
                  message: "This will be used together with random mnemonic sequence to generate your credentials.",
                  textFields: [
                    DialogTextField(
                      hintText: "Password",
                      obscureText: true
                    )
                  ]
                );

                if (dialogResult != null){
                  keysService.generateKeys(dialogResult[0]);
                }
              },
            ),
            ElevatedButton(
              child: Text(
                "Restore Credentials"
              ),
              onPressed: () => keysService.restoreKeys("climb print joke estate unique kid kind shrimp mom donor moment much", "lasvegas"),
            ),
          ]
        )
      );
    }

    if (keysService.loadingKeys){
      output.add(
        SizedBox.expand(
          child: Container(
            color: Colors.white30,
            child: SpinKitRing(
              lineWidth: 15,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
          ),
        )
      );
    }

    return output;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("My Credentials"),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            Icons.arrow_back_ios
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: _buildContent(Provider.of<KeysService>(context)),
      )
    );
  }
}