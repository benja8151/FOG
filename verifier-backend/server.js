require('dotenv').config();
const express= require('express')
const cors = require('cors');
const app =express()
const routes = require('./routes')
const Web3 = require('web3');
const mongodb = require('mongodb').MongoClient
//const database = require('./database')
const contracts = require('./contracts')
const ipfs = require('./ipfs')
const crypto =  require('./crypto')
app.use(express.json())

app.use(cors())
app.options('*', cors())

//dbService = new database()
contractsService = new contracts(new Web3(new Web3.providers.HttpProvider('http://localhost:7545')))
ipfsService = new ipfs()
cryptoService = new crypto()

//routes(app, dbService, contractsService, cryptoService, ipfsService)

mongodb.connect("mongodb+srv://admin:9YGCGIVA9U144wUl@cluster0.rj7ml.mongodb.net/myFirstDatabase?retryWrites=true&w=majority",{ useUnifiedTopology: true },(err,client)=>{
    const db = client.db('Verifier')

    routes(app, db, contractsService, cryptoService, ipfsService)
    app.listen(process.env.PORT || 3000, () => {
        console.log('listening on port '+ (process.env.PORT || 3000));
    })
})