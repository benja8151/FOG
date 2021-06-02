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
        this.web3.eth.defaultAccount = accs[2]
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

    async getContractVerificationStatus(contractId) {
        var deployedContract = this.IdentityContract.clone()
        deployedContract.options.address = contractId
        return deployedContract.methods.getDetails().call().then(function (res){
            return res['5']
        })
        .catch(function (error) {
            console.log("Error: " + error)
        })
    }

    async getContractReputation(contractId) {
        var deployedContract = this.IdentityContract.clone()
        deployedContract.options.address = contractId
        return deployedContract.methods.getDetails().call().then(function (res){
            return res['6']
        })
        .catch(function (error) {
            console.log("Error: " + error)
        })
    }

    async addRating(contractId, rating){
        var deployedContract = this.IdentityContract.clone()
        deployedContract.options.address = contractId
        return deployedContract.methods.addReputationRanking(rating).send({from: this.web3.eth.defaultAccount})
            .then(res => console.log(res))
            .catch(function (error) {
                console.log("Error: " + error)
            })
    }
}

module.exports = Contracts