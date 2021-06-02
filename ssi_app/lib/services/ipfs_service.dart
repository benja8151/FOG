import 'package:dart_ipfs_client/dart_ipfs_client.dart' ;
import 'package:http/http.dart' as http;
import 'package:ssi_app/constants.dart';

class IpfsService {

  Ipfs ipfs;

  IpfsService(){
    initialSetup();
  }

  void initialSetup() async {
    ipfs = Ipfs(url: kIpfsUrl);
  }

  /* // not working
  Future<dynamic> getData(String hash) async {
    
    final dynamic response = await ipfs.cat("QmYT2azqNdKWaETpysWikJCVF3KgoWZKVGk5fWxFiiB67z");

    print(response.body.toJson());
    if (response != null){
      return response.body.toJson();
    }
    else {
      return null;

    }
  } */

  Future<String> saveData(List<int> encodedData) async {

    dynamic response = await ipfs.add(encodedData);

    if (response != null){
      return response.body.hash;
    }
    else {
      return null;
    }
  }
}