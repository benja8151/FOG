var mongo = require('mongodb');

function routes(app, db, contracts, crypto, ipfs){
    app.get('/contracts', async (req, res) => {
        let contracts = await db.collection('Contracts').find().toArray()

        res.status(200).json({"status": "success", data: {contracts: contracts}})
    })
    app.get('/contracts/status', async (req,res) => {
        let id = req.body.id
        if (id){
            let contract = await db.collection('Contracts').findOne({'_id': new mongo.ObjectID(id)})
            if (contract){
                let status = await contracts.getContractVerificationStatus(contract.contractId)
                
                if (status != null){
                    res.status(200).json({"status": "success", data: {verificationStatus: status}})
                }
                else {
                    res.status(404).json({"status":"Failed", "reason":"no contract with this id"})
                }
                
            }
            else {
                res.status(404).json({"status":"Failed", "reason":"no contract with this id"})
            }
        }
        else {
            res.status(400).json({"status":"Failed", "reason":"wrong input"})
        }
    })
    app.post('/contracts/reputation', async (req,res) => {
        let id = req.body.id
        if (id){
            let contract = await db.collection('Contracts').findOne({'_id': new mongo.ObjectID(id)})
            if (contract){
                let reputation = await contracts.getContractReputation(contract.contractId)
                
                if (reputation != null){
                    res.status(200).json({"status": "success", data: {reputation: reputation}})
                }
                else {
                    res.status(404).json({"status":"Failed", "reason":"no contract with this id"})
                }
                
            }
            else {
                res.status(404).json({"status":"Failed", "reason":"no contract with this id"})
            }
        }
        else {
            res.status(400).json({"status":"Failed", "reason":"wrong input"})
        }
    })
    app.post('/contracts/reputation/add', async (req,res) => {
        let id = req.body.id
        let rating = req.body.rating
        if (id){
            let contract = await db.collection('Contracts').findOne({'_id': new mongo.ObjectID(id)})
            if (contract){
                await contracts.addRating(contract.contractId, rating)
                let reputation = await contracts.getContractReputation(contract.contractId)
                
                if (reputation != null){
                    res.status(200).json({"status": "success", data: {reputation: reputation}})
                }
                else {
                    res.status(404).json({"status":"Failed", "reason":"no contract with this id"})
                }
                
            }
            else {
                res.status(404).json({"status":"Failed", "reason":"no contract with this id"})
            }
        }
        else {
            res.status(400).json({"status":"Failed", "reason":"wrong input"})
        }
    })
    app.post('/contracts/add', async (req,res) => {
        let contractId = req.body.contractId
        let privateKey = req.body.privateKey
        if(contractId && privateKey){
            // check if verified
            let status = await contracts.getContractVerificationStatus(contractId)
            console.log(status)
            if (status != null){
                if (status){
                    await db.collection('Contracts').insertOne({
                        contractId: contractId,
                        privateKey: privateKey
                    })
                    res.status(200).json({"status": "success"})
                }
                else{
                    res.status(403).json({"status":"Failed", "reason":"contract is not verified"})
                }
            }
            else {
                res.status(404).json({"status":"Failed", "reason":"no contract with this id"})
            }
        }else{
            res.status(400).json({"status":"Failed", "reason":"wrong input"})
        }
    })
    app.post('/ipfs/data', async (req, res) => {
        let id = req.body.id
        if (id){
            let contract = await db.collection('Contracts').findOne({'_id': new mongo.ObjectID(id)})
            let encryptedIpfsHash = await contracts.getContractIpfs(contract.contractId)
            let decryptedIpfsHash = crypto.decryptString(
                encryptedIpfsHash, 
                contract.privateKey
            )
            
            if (decryptedIpfsHash){
                ipfsData = await ipfs.getData(decryptedIpfsHash)
                res.status(200).json({"status": "success", data: ipfsData})
            }
            else {
                res.status(404).json({"status":"Failed", "reason":"no contract with this id"})
            }
        }
        else{
            res.status(400).json({"status":"Failed", "reason":"wrong input"})
        }
    })

}
module.exports = routes