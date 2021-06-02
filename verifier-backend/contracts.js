//var contract = require("@truffle/contract");
//const Web3 = require('web3');
const fs = require('fs')

class Contracts {

    constructor(web3){
        this.web3 = web3;
        this.prepareContract()
        this.setUpAccount()
    }

    async prepareContract(){
        let rawdata = fs.readFileSync('./src/artifacts/IdentityContract.json')
        let contractJson = JSON.parse(rawdata)
        
        var contractObject = new this.web3.eth.Contract(contractJson.abi)
        this.IdentityContract = contractObject
    }

    async setUpAccount(){
        let accs = await this.web3.eth.getAccounts()
        this.web3.eth.defaultAccount = accs[1]
    }

    async getContractIpfs(contractId) {
        var deployedContract = this.IdentityContract.clone()
        deployedContract.options.address = contractId
        return deployedContract.methods.getDetails().call().then(function (res){
            return res['1']
        })
        .catch(function (error) {
            console.log("Error: " + error)
        })
    }

    async changeVerificationStatus(contractId, status){
        var deployedContract = this.IdentityContract.clone()
        deployedContract.options.address = contractId
        return deployedContract.methods.verifyContract(status).send({from: this.web3.eth.defaultAccount})
            .then(res => console.log(res))
            .catch(function (error) {
                console.log("Error: " + error)
            })
    }
}

module.exports = Contracts