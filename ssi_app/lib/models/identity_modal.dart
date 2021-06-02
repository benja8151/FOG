import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';

class Identity {

  final DeployedContract contract;
  final EthereumAddress verifier;
  final bool isVerified;
  final Map<String, dynamic> data;
  final String ipfsHash;
  final List<EthereumAddress> services;
  final List<dynamic> ratings;

  Identity({
    @required this.contract,
    this.ipfsHash,
    this.verifier,
    this.isVerified = false,
    this.data = const {},
    this.services = const [],
    this.ratings = const []
  });

  Identity copyWith({
    DeployedContract contract,
    EthereumAddress verifier,
    bool isVerified,
    Map<String, dynamic> data,
    List<EthereumAddress> services,
    String ipfsHash,
    List<dynamic> ratings,
  }) {
    return Identity(
      contract: contract ?? this.contract,
      verifier: verifier ?? this.verifier,
      isVerified: isVerified ?? this.isVerified,
      data: data ?? this.data,
      services: services ?? this.services,
      ipfsHash: ipfsHash ?? this.ipfsHash,
      ratings: ratings ?? this.ratings
    );
  }
}

class Registry {

  final DeployedContract contract;
  final List<EthereumAddress> contracts;
  final List<EthereumAddress> recoveryContacts;

  Registry({
    @required this.contract,
    this.contracts = const [],
    this.recoveryContacts = const []
  });

  Registry copyWith({
    DeployedContract contract,
    List<EthereumAddress> contracts,
    List<EthereumAddress> recoveryContacts,
  }) {
    return Registry(
      contract: contract ?? this.contract,
      contracts: contracts ?? this.contracts,
      recoveryContacts: recoveryContacts ?? this.recoveryContacts,
    );
  }
}
