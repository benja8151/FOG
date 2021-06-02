import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ssi_app/constants.dart';
import 'package:ssi_app/models/identity_modal.dart';
import 'package:ssi_app/services/ipfs_service.dart';
import 'package:ssi_app/services/keys_service.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/src/utils/length_tracking_byte_sink.dart';
import 'package:web3dart/src/crypto/formatting.dart';
import 'package:web_socket_channel/io.dart';


class ContractsService extends ChangeNotifier {

  final IpfsService ipfsService;
  final KeysService keysService;
  final FlutterSecureStorage secureStorage;
  final String _rpcUrl = "https://$kBlockchainUrl";
  final String _wsUrl = "ws://$kBlockchainUrl";
  final String _privateKey = "7c3fe89c5249e33018e515343eccacd5c12bb37ae9e9ee05cb0b045051039ea2";

  String _registryContractBytecode;
  String _identityContractBytecode;
  String _registryContractAbi;
  String _identityContractAbi;
    
  Web3Client _web3client;
  Credentials _credentials;
  List<Identity> identityContracts = [];
  Registry registryContract;
  List<EthereumAddress> recoverableContracts = [];

  bool isLoadingContracts = false;
  bool isAddingContract = false;
  bool isEditingContract = false;

  ContractsService({
    @required this.secureStorage,
    @required this.ipfsService,
    @required this.keysService
  }) {
    _initialSetup();
  }

  void _initialSetup() async {
    isLoadingContracts = true;
    notifyListeners();

    _web3client = Web3Client(
      _rpcUrl, 
      http.Client(), 
      socketConnector: () => IOWebSocketChannel.connect(_wsUrl).cast<String>()
    );
    await _getCredentials();
    await _loadContractsBytecode();
    await _loadContractsAbi();
    await _loadSavedContracts();
    await _getRecoveryContacts();
    await _loadRecoverableContracts();

    isLoadingContracts = false;
    notifyListeners();
  }

  Future<void> _getCredentials() async {
    _credentials = await _web3client.credentialsFromPrivateKey(_privateKey);
  }

  Future<void> _loadContractsBytecode() async {
    _identityContractBytecode = jsonDecode(await rootBundle.loadString("src/artifacts/IdentityContract.json"))["bytecode"].substring(2);
    _registryContractBytecode = jsonDecode(await rootBundle.loadString("src/artifacts/RegistryContract.json"))["bytecode"].substring(2);
  }

  Future<void> _loadContractsAbi() async {
    _identityContractAbi = jsonEncode(jsonDecode(await rootBundle.loadString("src/artifacts/IdentityContract.json"))["abi"]);
    _registryContractAbi = jsonEncode(jsonDecode(await rootBundle.loadString("src/artifacts/RegistryContract.json"))["abi"]);
  }

  Future<void> createNewIdentity() async{
    isAddingContract = true;
    notifyListeners();

    final String identityContractTransactionId = await _createNewContract(_identityContractBytecode);
    final TransactionReceipt identityContractTransaction = await _getTransactionData(identityContractTransactionId);
    final EthereumAddress identityContractAddress = identityContractTransaction.contractAddress;
    final DeployedContract identityContract = _getDeployedContract(
      _identityContractAbi, 
      "IdentityContract", 
      identityContractAddress
    );
    this.identityContracts.add(Identity(contract: identityContract));

    // if no registry, create registry, otherwise add to existing registry
    if (this.registryContract == null){
      final type = parseAbiType('(address)');
      final LengthTrackingByteSink sink = LengthTrackingByteSink();
      type.encode([identityContractAddress], sink);
      final String registryContractTransactionId = await _createNewContract(_registryContractBytecode + bytesToHex(sink.asBytes()));
      final TransactionReceipt registryContractTransaction = await _getTransactionData(registryContractTransactionId);
      final EthereumAddress registryContractAddress = registryContractTransaction.contractAddress;
      final DeployedContract registryContract = _getDeployedContract(
        _registryContractAbi, 
        "RegistryContract", 
        registryContractAddress
      );
      this.registryContract = Registry(
        contract: registryContract
      );
      await secureStorage.write(key: "registryContractAddress", value: registryContractAddress.hex);
    }
    else {
      await _addContractToRegistry(identityContractAddress);
    }

    // add all recovery contracts
    await Future.forEach<EthereumAddress>(this.registryContract.recoveryContacts, (recoveryContact) async {
      print(await _web3client.sendTransaction(
        _credentials, 
        Transaction.callContract(
          contract: identityContract, 
          function: identityContract.function("addRecoveryContact"), 
          parameters: [recoveryContact]
        )
      ));
    });

    isAddingContract = false;
    notifyListeners();
  }

  Future<String> _createNewContract(String bytecode) async {
    final Transaction transaction = Transaction(
      to: null,
      data: hex.decode(bytecode),
      maxGas: 6000000
    );
    final String transactionId = await _web3client.sendTransaction(
      _credentials, 
      transaction
    );
    return transactionId;
  }

  Future<TransactionReceipt> _getTransactionData(String transactionID) async {
    return await _web3client.getTransactionReceipt(transactionID);
  }

  DeployedContract _getDeployedContract(String abi, String name, EthereumAddress contractAddress) {
    return DeployedContract(
      ContractAbi.fromJson(abi, name),
      contractAddress
    );
  }

  Future<dynamic> getContractDetails(DeployedContract contract) async {
    dynamic result = await _web3client.call(
      contract: contract, 
      function: contract.function("getDetails"), 
      params: []
    );

    return result;
  }

  Future<void> _loadSavedContracts() async {
    final String registryContractAddress = await secureStorage.read(key: "registryContractAddress");
    if (registryContractAddress != null) {
      final DeployedContract deployedRegistry = _getDeployedContract(
        _registryContractAbi, 
        "RegistryContract", 
        EthereumAddress.fromHex(registryContractAddress)
      );

      this.registryContract = Registry(contract: deployedRegistry);

      await getContractsInRegistry();
    }
  }

  Future<void> getContractsInRegistry() async {
    print("Getting contracts in registry");
    if (registryContract == null){
      return;
    }

    dynamic result = await _web3client.call(
      contract: this.registryContract.contract,
      function: this.registryContract.contract.function("getContracts"), 
      params: []
    );

    if (result != null){
      List<dynamic> contracts = result[0];
      this.identityContracts = [];
      await Future.forEach(contracts, (element) async {
        final DeployedContract deployedContract = _getDeployedContract(
          _identityContractAbi, 
          "IdentityContract", 
          element
        );
        
        /*  Data:
            - owner [address]
            - ipfs_hash [string]
            - recoveryContacts [address[]]
            - verifier [address]
            - services [address[]]
            - verified [bool] 
         */
        final contractDetails = await getContractDetails(deployedContract);
        
        final String ipfsHash = contractDetails[1];

        // Load data on click
        /* Map<String, dynamic> ipfsData;
        if (ipfsHash != null && ipfsHash.isNotEmpty){
          final String decryptedIpfsHash = keysService.decryptString(ipfsHash);
          if (decryptedIpfsHash != null){
            final http.Response ipfsResponse = await http.post(
              Uri.parse("$kIpfsUrl/api/v0/cat/$decryptedIpfsHash"),
            );

            if (ipfsResponse != null){
              ipfsData = jsonDecode(ipfsResponse.body ?? "{}");
            }
          }
        } */

        List<EthereumAddress> services = [];
        (contractDetails[4] ?? []).forEach((e) => services.add(e));
        
        this.identityContracts.add(Identity(
          contract: deployedContract,
          verifier: contractDetails[3],
          isVerified: contractDetails[5],
          services: services,
          ipfsHash: ipfsHash,
          ratings: contractDetails[6]
        ));

      });
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> loadIdentityIpfsData(int identityIndex) async {
    Map<String, dynamic> ipfsData = {};

    if (this.identityContracts[identityIndex].data.isNotEmpty){
      return this.identityContracts[identityIndex].data;
    }

    if (this.identityContracts[identityIndex].ipfsHash != null && this.identityContracts[identityIndex].ipfsHash.isNotEmpty){
      final String decryptedIpfsHash = keysService.decryptString(this.identityContracts[identityIndex].ipfsHash);
      if (decryptedIpfsHash != null){
        final http.Response ipfsResponse = await http.post(
          Uri.parse("$kIpfsUrl/api/v0/cat/$decryptedIpfsHash"),
        );

        if (ipfsResponse != null){
          ipfsData = jsonDecode(ipfsResponse.body ?? "{}");
          this.identityContracts[identityIndex] = this.identityContracts[identityIndex].copyWith(data: ipfsData);
        }
      }
    }

    return ipfsData;
  }

  Future<void> _getRecoveryContacts() async {
    print("Getting recovery contacts");
    if (registryContract == null){
      return;
    }

    dynamic result = await _web3client.call(
      contract: this.registryContract.contract,
      function: this.registryContract.contract.function("getRecoveryContacts"), 
      params: []
    );

    if (result != null){
      List<dynamic> contacts = result[0];
      this.registryContract = this.registryContract.copyWith(
        recoveryContacts: [...contacts]
      );
      notifyListeners();
    }
  }

  Future<bool> addServiceToContract(DeployedContract contract, String service) async {
    final Map<String, dynamic> serviceData = jsonDecode(service);

    if (serviceData['service'] != null && serviceData['serviceUrl'] != null){ 
      print("adding service to contract...");

      print(await _web3client.sendTransaction(
        _credentials, 
        Transaction.callContract(
          contract: contract, 
          function: contract.function("addService"), 
          parameters: [EthereumAddress.fromHex(serviceData['service'])]
        )
      ));

      return await http.post(
        Uri.parse(serviceData['serviceUrl']),
        body: jsonEncode({
          "contractId": contract.address.hex,
          "privateKey": keysService.privateKey
        }),
        headers: {
          'Content-Type': "application/json",
        },
      ).then((value) => value.statusCode == 200);;
    }
    else {
      return false;
    }
  }

  Future<void> _addContractToRegistry(EthereumAddress contractAddress) async {
    if (contractAddress != null){ 
      print("adding contract to registry...");

      print(await _web3client.sendTransaction(
        _credentials, 
        Transaction.callContract(
          contract: this.registryContract.contract, 
          function: this.registryContract.contract.function("addContract"), 
          parameters: [contractAddress]
        )
      ));
    }
  }

  void changeEditingState(bool state){
    isEditingContract = state;
    notifyListeners();
  }

  Future<void> setContractIPFS(DeployedContract contract, String hash) async {
    if (hash != null){ 
      print("adding hash to contract...");

      print(await _web3client.sendTransaction(
        _credentials, 
        Transaction.callContract(
          contract: contract, 
          function: contract.function("setIPFSHash"), 
          parameters: [hash]
        )
      ));
    }
  }

  Future<bool> setContractVerifier(DeployedContract contract, String verifier) async {
    final Map<String, dynamic> verifierData = jsonDecode(verifier);

    if (verifierData['verifier'] != null && verifierData['verifyUrl'] != null){ 
      print("adding verifier to contract...");

      print(await _web3client.sendTransaction(
        _credentials, 
        Transaction.callContract(
          contract: contract, 
          function: contract.function("setVerifier"), 
          parameters: [EthereumAddress.fromHex(verifierData['verifier'])]
        )
      ));

      return await http.post(
        Uri.parse(verifierData['verifyUrl']),
        body: jsonEncode({
          "contractId": contract.address.hex,
          "privateKey": keysService.privateKey
        }),
        headers: {
          'Content-Type': "application/json",
        },
      ).then((value) => value.statusCode == 200);
    }
    else {
      return false;
    }
  }

  Future<void> addRecoveryContact(String contactAddress) async {
    if (contactAddress != null && contactAddress.isNotEmpty){
      print("adding recovery contact...");

      print(await _web3client.sendTransaction(
        _credentials, 
        Transaction.callContract(
          contract: this.registryContract.contract, 
          function: this.registryContract.contract.function("addRecoveryContact"), 
          parameters: [EthereumAddress.fromHex(contactAddress)]
        )
      ));
      await Future.forEach<Identity>(this.identityContracts, (identity) async {
        print(await _web3client.sendTransaction(
          _credentials, 
          Transaction.callContract(
            contract: identity.contract, 
            function: identity.contract.function("addRecoveryContact"), 
            parameters: [EthereumAddress.fromHex(contactAddress)]
          )
        ));
      });

      await _getRecoveryContacts();
    }
  }

  Future<void> removeRecoveryContact(int index) async {
    if (index != null){
      print("removing recovery contact...");

      print(await _web3client.sendTransaction(
        _credentials, 
        Transaction.callContract(
          contract: this.registryContract.contract, 
          function: this.registryContract.contract.function("removeRecoveryContact"), 
          parameters: [BigInt.from(index)]
        )
      ));
      await Future.forEach<Identity>(this.identityContracts, (identity) async {
        print(await _web3client.sendTransaction(
          _credentials, 
          Transaction.callContract(
            contract: identity.contract, 
            function: identity.contract.function("removeRecoveryContact"), 
            parameters: [BigInt.from(index)]
          )
        ));
      });

      await _getRecoveryContacts();
    }
  }

  Future<void> addRecoverableContract(String registryContractAddress) async {
    if (registryContractAddress != null && registryContractAddress.isNotEmpty){
      print("adding recoverable contract...");

      this.recoverableContracts.add(EthereumAddress.fromHex(registryContractAddress));
      await _saveRecoverableContracts();
    }
  }

  Future<void> _saveRecoverableContracts() async {
    String contracts = "";
    this.recoverableContracts.forEach((element) {contracts += "${element.hex},";});
    if (contracts.length>0){
      await secureStorage.write(key: "recoverableContracts", value: contracts.substring(0, contracts.length - 1));
    }
    else {
      await secureStorage.write(key: "recoverableContracts", value: "");
    }
  }

  Future<void> _loadRecoverableContracts() async {
    String contracts = await secureStorage.read(key: "recoverableContracts");
    if (contracts != null){
      contracts.split(",").forEach((element) {this.recoverableContracts.add(EthereumAddress.fromHex(element));});
    }
  }

  Future<void> recoverIdentity(EthereumAddress contractAddress, String ownerAddress) async {
    if (contractAddress != null && ownerAddress != null && ownerAddress.isNotEmpty){
      print("recovering identity...");

      final DeployedContract registry =  _getDeployedContract(
        _registryContractAbi, 
        "RegistryContract", 
        contractAddress
      );

      // Recover registry
      print(await _web3client.sendTransaction(
        _credentials, 
        Transaction.callContract(
          contract: registry,
          function: registry.function("changeOwner"), 
          parameters: [EthereumAddress.fromHex(ownerAddress)]
        )
      ));

      // Recover every contract in registry
      dynamic result = await _web3client.call(
        contract: registry,
        function: registry.function("getContracts"), 
        params: []
      );
      if (result != null){
        List<dynamic> contracts = result[0];
        await Future.forEach(contracts, (element) async {
          final DeployedContract identity = _getDeployedContract(
            _identityContractAbi, 
            "IdentityContract", 
            element
          );

          print(await _web3client.sendTransaction(
            _credentials, 
            Transaction.callContract(
              contract: identity, 
              function: identity.function("changeOwner"), 
              parameters: [EthereumAddress.fromHex(ownerAddress)]
            )
          ));
        });
      }
    }
  }

  Future<void> recoverMyIdentity(String newRegistryAddress) async {
    
    if (newRegistryAddress != null && newRegistryAddress.isNotEmpty){
      final DeployedContract registryContract = _getDeployedContract(
        _registryContractAbi, 
        "RegistryContract", 
        EthereumAddress.fromHex(newRegistryAddress)
      );
      this.registryContract = Registry(
        contract: registryContract
      );

      await this.getContractsInRegistry();
      await this._getRecoveryContacts();
    }
  }


  Future<void> clearData() async {
    await secureStorage.delete(key: "registryContractAddress");
    identityContracts = [];
    registryContract = null;
    notifyListeners();
  }

}