import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ssi_app/components/add_contract_modal.dart';
import 'package:ssi_app/components/add_recoverable_contract_modal.dart';
import 'package:ssi_app/components/add_recovery_contact_modal.dart';
import 'package:ssi_app/components/recover_modal.dart';
import 'package:ssi_app/components/view_contract_modal.dart';
import 'package:ssi_app/models/identity_modal.dart';
import 'package:ssi_app/services/contracts_service.dart';
import 'package:provider/provider.dart';
import 'package:ssi_app/services/keys_service.dart';
import 'package:web3dart/credentials.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {

  TabController _tabController;

  @override
  void initState() { 
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging){
        setState(() {});
      }
    });
  }

  List<Widget> _buildContracts(ContractsService contractsService){
    List<Widget> output = [];

    output.add(LiquidPullToRefresh(
      height: 40,
      color: Theme.of(context).primaryColor,
      showChildOpacityTransition: false,
      onRefresh: () async {await contractsService.getContractsInRegistry();},
      child: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: _buildContractsList(contractsService)
      ),
    ));

    if (contractsService.isLoadingContracts){
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

  List<Widget> _buildContractsList(ContractsService contractsService){
    List<Widget> output = [];

    contractsService.identityContracts.asMap().forEach((index, contract) {
      output.add(
        ListTile(
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(contract.contract.address.hex, overflow: TextOverflow.ellipsis,),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Verified:"),
                  Icon(
                    contract.isVerified ? Icons.done : Icons.close,
                    color: contract.isVerified ? Colors.green : Colors.red,
                  ),
                ],
              ),
              if (contract.verifier != null && contract.verifier != EthereumAddress(Uint8List(20))) Text(
                "Verifier: ${contract.verifier.hex}", 
                overflow: TextOverflow.fade
              ),
              SizedBox(height: 2,),
              Text(
                "Services: ${contract.services?.length ?? 0}",
              )
            ],
          ),
          onTap: () => _viewIdentityContract(contract, index),
        )
      );
      output.add(Divider(thickness: 2, color: Colors.white, indent: 15, endIndent: 15,));
    });
    if (output.length>0) output.removeLast();

    if (output.isEmpty){
      output.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Text(
            "You have not yet added any Identity contracts.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold
            ),
          ),
        )
      );
    }
    else {
      output.add(
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: ElevatedButton(
            onPressed: () {
              contractsService.clearData();
            }, 
            child: Text("Clean registry")
          ),
        )
      );
    }

    return output;
  }

  void _addIdentityContract(){
    showCupertinoModalBottomSheet(
      context: context, 
      builder: (context) => AddContractModal(),
      isDismissible: false,
      enableDrag: false
    );
  }

  void _recoverIdentity(bool recoverOwnIdentity, {EthereumAddress contractAddress}){
    showCupertinoModalBottomSheet(
      context: context, 
      builder: (context) => RecoverModal(recoverOwnIdentity: recoverOwnIdentity, contractAddress: contractAddress,),
      isDismissible: false,
      enableDrag: false
    );
  }

  void _viewIdentityContract(Identity identity, int index){
    showCupertinoModalBottomSheet(
      context: context, 
      builder: (context) => ViewContractModal(identity: identity, identityIndex: index),
      isDismissible: true,
      enableDrag: false
    );
  }

  void _addRecoveryContact(){
    showCupertinoModalBottomSheet(
      context: context, 
      builder: (context) => AddRecoveryContactModal(),
      isDismissible: false,
      enableDrag: false
    );
  }

  void _addRecoverableContract(){
    showCupertinoModalBottomSheet(
      context: context, 
      builder: (context) => AddRecoverableContractModal(),
      isDismissible: false,
      enableDrag: false
    );
  }

  Widget _buildRecoveryPage(ContractsService contractsService){
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Expanded(child: Text("My recovery contacts", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))),
                      contractsService.registryContract != null ? 
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: Theme.of(context).accentColor,), 
                          onPressed: _addRecoveryContact
                        ) :
                        SizedBox(height: 48,)
                    ],
                  ),
                ),
                Divider(color: Colors.white, indent: 15, endIndent: 15),
                Expanded(child: SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: contractsService.registryContract?.recoveryContacts?.length ?? 0,
                    itemBuilder: (context, index){
                      return Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        secondaryActions: [
                          IconSlideAction(
                            caption: 'Remove',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () => contractsService.removeRecoveryContact(index)
                          ),
                        ],
                        child: ListTile(
                          title: Text(contractsService.registryContract.recoveryContacts[index].hexNo0x, overflow: TextOverflow.ellipsis,),
                        ),
                      );
                    }
                  )
                ))
              ],
            )
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Expanded(child: Text("Recoverable identities", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))),
                      contractsService.registryContract != null ?
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: Theme.of(context).accentColor,), 
                          onPressed: _addRecoverableContract
                        ) :
                        SizedBox(height: 48)
                    ],
                  ),
                ),
                Divider(color: Colors.white, indent: 15, endIndent: 15,),
                Expanded(child: SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: contractsService.recoverableContracts?.length ?? 0,
                    itemBuilder: (context, index){
                      return ListTile(
                        title: Text(contractsService.recoverableContracts[index].hexNo0x, overflow: TextOverflow.ellipsis,),
                        onTap: () => _recoverIdentity(false, contractAddress: contractsService.recoverableContracts[index]),
                      );
                    }
                  )
                ))
              ],
            )
          ),
        ]
      ),
    );
  }

  Widget _buildFab(KeysService keysService){

    if (keysService.keysGenerated){
      switch (_tabController.index){
        case 0: {
          return FloatingActionButton(
            child: Icon(
              Icons.add
            ),
            onPressed: _addIdentityContract
          );
        }
        case 1: {
          return FloatingActionButton(
            child: Icon(
              Icons.settings_backup_restore
            ),
            onPressed: () => _recoverIdentity(true)
          );
        } 
        default: return null;
      }
      
    }
    else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SSI App"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed("/credentials"),
              child: Icon(
                Icons.vpn_key
              ),
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.view_list),),
            Tab(icon: Icon(Icons.settings_backup_restore),)
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Stack(
            children: _buildContracts(Provider.of<ContractsService>(context)),
          ),
          _buildRecoveryPage(Provider.of<ContractsService>(context))
        ],
      ),
      floatingActionButton: _buildFab(Provider.of<KeysService>(context)), 
    );
  }
}