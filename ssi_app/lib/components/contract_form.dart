import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ssi_app/services/contracts_service.dart';

enum FormFieldType {
  FIRSTNAME,
  LASTNAME,
  ADDRESS,
  CITY,
  PHONE,
  EMAIL,
  FILE
}

class ContractForm extends StatefulWidget {

  final ContractsService contractsService;
  final Function(String) onSave;

  ContractForm({
    @required this.contractsService,
    @required this.onSave,
  });

  @override
  _ContractFormState createState() => _ContractFormState();
}

class _ContractFormState extends State<ContractForm> {
  
  final _formKey = GlobalKey<FormState>();
  List<FormFieldType> formFieldTypes = [];
  List<TextEditingController> controllers = [];

  Map<TextEditingController, Uint8List> files = {};

  void _addNewFormField() {
    setState(() {
      controllers.add(TextEditingController());
      formFieldTypes.add(FormFieldType.FIRSTNAME);
    });
  }

  List<Widget> _buildFormFields(){
    List<Widget> output = [];

    for (int index=0; index<formFieldTypes.length; index++){
      String fieldType;
      TextInputType textInputType;
      Function onTap;
      switch (this.formFieldTypes[index]){
        case FormFieldType.ADDRESS: {
          fieldType = "Address";
          textInputType = TextInputType.streetAddress;
          break;
        }
        case FormFieldType.CITY: {
          fieldType = "City";
          textInputType = TextInputType.streetAddress;
          break;
        }
        case FormFieldType.EMAIL: {
          fieldType = "e-Mail";
          textInputType = TextInputType.emailAddress;
          break;
        }
        case FormFieldType.FILE: {
          fieldType = "File";
          textInputType = TextInputType.text;
          onTap = () async {
            FilePickerResult file = await FilePicker.platform.pickFiles(
              withData: true
            );
            if (file != null){
              setState(() {
                controllers[index].text = file.files.single.name;
                files[controllers[index]] = file.files.single.bytes;
              });
            }
          };
          break;
        }
        case FormFieldType.FIRSTNAME: {
          fieldType = "First Name";
          textInputType = TextInputType.name;
          break;
        }
        case FormFieldType.LASTNAME: {
          fieldType = "Last Name";
          textInputType = TextInputType.name;
          break;
        }
        case FormFieldType.PHONE: {
          fieldType = "Phone";
          textInputType = TextInputType.phone;
          break;
        }
      }

      output.add(Slidable(
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: [
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: (){
              setState(() {
                this.formFieldTypes.removeAt(index);
                this.files.remove([this.controllers[index]]);
                this.controllers.removeAt(index);
              });
            }
          ),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 20,),
            Container(
              width: 125,
              child: ElevatedButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fieldType
                    ),
                    Icon(Icons.arrow_drop_down)
                  ],
                ),
                onPressed: () async {
                  List<String> items = ["Address", "City", "e-Mail", "File", "First Name", "Last Name", "Phone"];
                  int currentValue;
                  showMaterialScrollPicker(
                    context: context,
                    title: "Select Field Type",
                    items: items,
                    selectedValue: fieldType,
                    onChanged: (val) => currentValue = items.indexOf(val),
                    onConfirmed: (){
                      setState(() {
                        final List<FormFieldType> types = [FormFieldType.ADDRESS, FormFieldType.CITY, FormFieldType.EMAIL, FormFieldType.FILE, FormFieldType.FIRSTNAME, FormFieldType.LASTNAME, FormFieldType.PHONE,];
                        formFieldTypes[index] = types[currentValue];
                      });
                    }
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextFormField(
                  controller: controllers[index],
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                  ),
                  keyboardType: textInputType,
                  onTap: onTap ?? (){},
                  decoration: InputDecoration(
                    hintText: fieldType,
                    hintStyle: TextStyle(color: Theme.of(context).accentColor.withAlpha(120)),
                    border: new UnderlineInputBorder(
                      borderSide: new BorderSide(
                        color: Theme.of(context).accentColor
                      )
                    ),
                    enabledBorder: new UnderlineInputBorder(
                      borderSide: new BorderSide(
                        color: Theme.of(context).accentColor
                      )
                    ),
                    focusedBorder: new UnderlineInputBorder(
                      borderSide: new BorderSide(
                        color: Theme.of(context).accentColor
                      )
                    )
                  ),
                ),
              ),
            )
          ]
        ),
      ));
    }

    return output;
  }
  
  String _formatData(){
    Map<String, dynamic> data = {};

    for (int i=0; i<formFieldTypes.length; i++){
      String fieldType;
      int fieldIndex = 1;
      dynamic fieldData;
      switch (this.formFieldTypes[i]){
        case FormFieldType.ADDRESS: {
          fieldType = "Address";
          fieldData = controllers[i].text;
          break;
        }
        case FormFieldType.CITY: {
          fieldType = "City";
          fieldData = controllers[i].text;
          break;
        }
        case FormFieldType.EMAIL: {
          fieldType = "e-Mail";
          fieldData = controllers[i].text;
          break;
        }
        case FormFieldType.FILE: {
          fieldType = "File";
          fieldData = {
            "filename": controllers[i].text,
            "data": files[controllers[i]]
          };
          break;
        }
        case FormFieldType.FIRSTNAME: {
          fieldType = "FirstName";
          fieldData = controllers[i].text;
          break;
        }
        case FormFieldType.LASTNAME: {
          fieldType = "LastName";
          fieldData = controllers[i].text;
          break;
        }
        case FormFieldType.PHONE: {
          fieldType = "Phone";
          fieldData = controllers[i].text;
          break;
        }
      }
      while(data.containsKey("${fieldType}_$fieldIndex")){
        fieldIndex += 1;
      }
      if (fieldData != null && fieldData.isNotEmpty) data["${fieldType}_$fieldIndex"] = fieldData;
    }

    return jsonEncode(data);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        //mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15),
            child: Text(
              "Add identification data.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              controller: ModalScrollController.of(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildFormFields()
              )
            )
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Theme.of(context).accentColor,), 
            onPressed: _addNewFormField
          ),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: (widget.contractsService.isLoadingContracts || widget.contractsService.isEditingContract) ?
              SpinKitRing(color: Theme.of(context).primaryColor) : 
              ElevatedButton(
                onPressed: () => this.widget.onSave(_formatData()),
                child: Text("Save Data")
              ),
          ),
          SizedBox(height: 40)
        ],
      ),
    );
  }
}