import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class KeysService extends ChangeNotifier {
  final FlutterSecureStorage secureStorage;
  bool keysGenerated = false;
  bool loadingKeys = false;

  KeysService({
    @required this.secureStorage
  }) {
    loadKeys();
  }

  String _privateKey;
  String _publicKey;
  String _mnemonic;

  String get privateKey => _privateKey;
  String get publicKey => _publicKey;
  String get mnemonic => _mnemonic;

  void generateKeys(String password) async {
    loadingKeys = true;
    notifyListeners();

    final String mnemonic = bip39.generateMnemonic();
    _mnemonic = mnemonic;
    print("Mnemonic: " + mnemonic);

    final Uint8List seed = bip39.mnemonicToSeed(mnemonic, passphrase: password);
    print("Seed: " + seed.toString());

    final bip32.BIP32 bip32Object = bip32.BIP32.fromSeed(seed);

    final String privateKey = hex.encode(bip32Object.derivePath("m/44'/60'/0'/0/0").privateKey);
    _privateKey = privateKey;
    print("Private Key: " + privateKey);

    //final String publicKey = hex.encode(bip32Object.derivePath("m/44'/60'/0'/0/0").neutered().publicKey);
    final String publicKey = await EthPrivateKey.fromHex(privateKey).extractAddress().then((value) => hex.encode(value.addressBytes));
    _publicKey = publicKey;
    print("Public Key: " + publicKey);

    await saveKeys(privateKey, publicKey);

    loadingKeys = false;
    if (_privateKey != null && _publicKey != null){
      keysGenerated = true;
    }
    notifyListeners();
  }

  void restoreKeys(String mnemonic, String password) async {
    loadingKeys = true;
    notifyListeners();

    _mnemonic = mnemonic;

    final Uint8List seed = bip39.mnemonicToSeed(mnemonic, passphrase: password);
    print("Seed: " + seed.toString());

    final bip32.BIP32 bip32Object = bip32.BIP32.fromSeed(seed);

    final String privateKey = hex.encode(bip32Object.derivePath("m/44'/60'/0'/0/0").privateKey);
    _privateKey = privateKey;
    print("Private Key: " + privateKey);

    final String publicKey = await EthPrivateKey.fromHex(privateKey).extractAddress().then((value) => hex.encode(value.addressBytes));
    _publicKey = publicKey;
    print("Public Key: " + publicKey);

    await saveKeys(privateKey, publicKey);

    loadingKeys = false;
    if (_privateKey != null && _publicKey != null){
      keysGenerated = true;
    }
    notifyListeners();
  }

  Future<void> saveKeys(String privateKey, String publicKey) async {
    await secureStorage.write(key: "mnemonic", value: mnemonic);
    await secureStorage.write(key: "privateKey", value: privateKey);
    await secureStorage.write(key: "publicKey", value: publicKey);
  }

  Future<void> loadKeys() async {
    print("Loading Keys...");
    loadingKeys = true;
    notifyListeners();
    _mnemonic = await secureStorage.read(key: 'mnemonic');
    _privateKey = await secureStorage.read(key: 'privateKey');
    _publicKey = await secureStorage.read(key: 'publicKey');
    loadingKeys = false;
    if (_privateKey != null && _publicKey != null){
      keysGenerated = true;
    }
    print("Did load keys: " + keysGenerated.toString());
    notifyListeners();
  }

  dynamic encryptString(String inputString){
    print(_privateKey);

    final encrypt.Key key = encrypt.Key.fromBase16(_privateKey);
    final encrypt.IV iv = encrypt.IV.fromLength(16);
    final encrypt.Encrypter encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ctr));

    return encrypter.encrypt(inputString, iv: iv).base16;
  }

  String decryptString(String inputString){
    final encrypt.Key key = encrypt.Key.fromBase16(_privateKey);
    final encrypt.IV iv = encrypt.IV.fromLength(16);
    final encrypt.Encrypter encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ctr));

    try{
      return encrypter.decrypt(encrypt.Encrypted.fromBase16(inputString), iv: iv).toString();
    }
    catch(e) {
      return null;
    }
    
  }
}