var mongo = require('mongodb');

function routes(app, db, contracts, crypto, ipfs){
    app.get('/contracts', async (req, res) => {
        let pendingContracts = await db.collection('PendingContracts').find().toArray()
        let processedContracts = await db.collection('ProcessedContracts').find().toArray()

        res.status(200).json({"status": "success", data: {pendingContracts: pendingContracts, processedContracts: processedContracts}})
    })
    app.put('/verify', async (req,res) => {
        let id = req.body.id
        let status = req.body.status
        if (id && (status != null)){
            let contract = await db.collection('PendingContracts').findOne({'_id': new mongo.ObjectID(id)})
            if (contract){
                await contracts.changeVerificationStatus(contract.contractId, status)
                
                await db.collection('PendingContracts').findOneAndDelete({'_id': new mongo.ObjectID(id)})
                await db.collection('ProcessedContracts').insertOne({
                    _id: new mongo.ObjectID(contract['_id']),
                    contractId: contract.contractId,
                    privateKey: contract.privateKey
                })
                
                let pendingContracts = await db.collection('PendingContracts').find().toArray()
                let processedContracts = await db.collection('ProcessedContracts').find().toArray()

                res.status(200).json({"status": "success", data: {pendingContracts: pendingContracts, processedContracts: processedContracts}})
            }
            else {
                res.status(404).json({"status":"Failed", "reason":"no contract with this id"})
            }
        }
    })
    app.post('/verify/request', async (req,res) => {
        let contractId = req.body.contractId
        let privateKey = req.body.privateKey
        if(contractId && privateKey){
            await db.collection('PendingContracts').insertOne({
                contractId: contractId,
                privateKey: privateKey
            })
            res.status(200).json({"status": "success"})
        }else{
            res.status(400).json({"status":"Failed", "reason":"wrong input"})
        }
    })
    app.post('/ipfs/data', async (req, res) => {
        let id = req.body.id
        let isPending = req.body.isPending
        if (id && (isPending != null)){
            let decryptedIpfsHash
            if (isPending){
                let contract = await db.collection('PendingContracts').findOne({'_id': new mongo.ObjectID(id)})
                let encryptedIpfsHash = await contracts.getContractIpfs(contract.contractId)
                decryptedIpfsHash = crypto.decryptString(
                    encryptedIpfsHash, 
                    contract.privateKey
                )
            }
            else {
                let contract = await db.collection('ProcessedContracts').findOne({'_id': new mongo.ObjectID(id)})
                let encryptedIpfsHash = await contracts.getContractIpfs(contract.contractId)
                decryptedIpfsHash = crypto.decryptString(
                    encryptedIpfsHash, 
                    contract.privateKey
                )
            }
            
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