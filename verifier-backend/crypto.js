var aesjs = require('aes-js');

class Crypto {

    decryptString(input, key){
        let keyArray = new Uint8Array(key.match(/.{1,2}/g).map(byte => parseInt(byte, 16)))
        var aesCbc = new aesjs.ModeOfOperation.ctr(keyArray, new aesjs.Counter(0));
        
        return aesjs.utils.utf8.fromBytes(aesCbc.decrypt(aesjs.utils.hex.toBytes(input)))
    }
}

module.exports = Crypto