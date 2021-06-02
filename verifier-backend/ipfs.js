const axios = require('axios').default;

class Ipfs {
    constructor(){
        axios.defaults.baseURL = "http://127.0.0.1:5001"
    }

    
    async getData(ipfsHash){

        console.log(encodeURI(`api/v0/cat/${ipfsHash}`))

        return axios.post(encodeURI(`api/v0/cat/${ipfsHash}`).split('%')[0])
            .then((res) => {
                return res.data
            })
            .catch((err) => {
                console.error(err)
            })
    }

}

module.exports = Ipfs