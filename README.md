This is a repository for Self-Sovereign Identity project, which was developed as a part of Fog Computing course at Faculty of Computer and Information Science in Ljubljana.

# Table of contents
* 1\. [Setup](#setup)  
    * 1.1\. [Ganache](#ganache)
    * 1.2\. [IPFS](#ipfs)
    * 1.3\. [ngrok](#ngrok)
    * 1.4\. [Mobile application](#mobile-application)
    * 1.5\. [Back-end services](#back-end-services)
    * 1.6\. [MongoDB](#mongodb)
    * 1.7\. [Front-end clients](#front-end-services)
* 2\. [Usage](#usage)  
    * 2.1\. [Generating user credentials](#generating-user-credentials)
    * 2.2\. [Adding new identity](#adding-new-identity-with-data-and-verifier)
    * 2.3\. [Granting data access](#granting-data-access-to-service)



# Setup

## Ganache
This project uses Ganache personal Ethereum blockchain to easily deploy and monitor smart contracts. Follow the setup instructions [here](https://www.trufflesuite.com/docs/ganache/quickstart).

## IPFS
IPFS is used to store user's data. Setup instructions can be found [here](https://docs.ipfs.io/how-to/command-line-quick-start/).

## ngrok
Since mobile application cannot directly access your localhost, you need to expose your localhost tunnels. One way to to that is to use ngrok - instructions [here](https://ngrok.com/docs). 

You will need to expose 4 ports. Default values are:
- port 3000 and 8000 for backend services
- port 5001 for IPFS
- port 7545 for Ganache

## Mobile application
App was built using [Flutter framework](https://flutter.dev/). You can run it on an phone emulator or on a real device. Follow the instructions [here](https://flutter.dev/docs/get-started/install) to install it and setup the environment.

Files for the application are found in `ssi_app` folder. Before you run the app you need to change the urls to blockchain and ipfs found in `ssi_app\lib\constants.dart`. Replace existing urls with the ones exposed using ngrok. Replace the value of `kEthAccount` with one of the accounts from your Ganache network aswell.

```dart
const String kBlockchainUrl = "enter url here"; // i.e.: "a4e9084cd895.ngrok.io" (without https:// prefix)
const String kIpfsUrl = "enter url here"; // i.e.: "https://235fa3c9ec8f.ngrok.io"
const String kEthAccount = "enter address here"; // i.e.: "0xdD1af91EF9f111BceE12495375bC2Cf0fBB8BC9e"
```

To run the app execute:
- ```cd ssi_app```
- ```flutter pub get```
- ```flutter run```

## Back-end services
`verifier-backend` and `service-backend` folders contain back-ends for verifier and service which requests user's data. You will need [NodeJs](https://nodejs.org/en/) to run them.

After installing NodeJs run ```npm install && npm run start``` in both folders. This will install required packages and start the servers.

## MongoDB
Back-end services each require access to their own MongoDB database. I've used [MongoDB Atlas](https://www.mongodb.com/cloud/atlas), but you can also use a local solution, i.e. [using Docker](https://www.bmc.com/blogs/mongodb-docker-container/). Urls for database can be changed in `server.js` file in both folders.

## Front-end clients
Front-end web clients use [ReactJS](https://reactjs.org/) framework. Before running them you need to change callback urls to previously exposed ports (by default 3000 and 8000). These values are stored in `src\config.js` in both folders(`verifier-frontend` and `service-frontend`). Make sure to also replace blockchain addresses with the ones you wish to use for verifier and service.

```javascript
export const config = {
    backendUrl: "http://localhost:3000",
    verifierAccount: "enter address here", // i.e.: "0x8B0ead53564FbCaC1bD8b6D159742A5CbBdc764C"
    backendMobileUrl: "enter url here", // i.e.: "https://be1103af6551.ngrok.io"
}
```
Start the clients using ```npm install && npm run start``` in both folders.

# Usage

Below is a quick overview of the basic functionalities.

## Generating user credentials
Before users can add new identity they need to generate personal credentials. That is done by clicking the key icon in the top right corner in mobile application (![key_image](https://images2.imgbox.com/6e/91/N1gzswcM_o.png)). A new page is opened with an option to generate new credentials: ![generate_credentials_button](https://images2.imgbox.com/46/55/fUPvb6Hr_o.png). This generates new private and public keys which will be used to sign contracts and encrypt IPFS hashes. User is also prompted to enter password which can be used together with a random mnemonic if they needs to restore their keys. 

After credentials are generated they are displayed on this page:

![credentials_screen](https://images2.imgbox.com/5e/73/4UL2VZBk_o.png)

## Adding new identity with data and verifier
Once credentials were generated user can tap on ![red_button](https://images2.imgbox.com/49/d0/RdqmiXZl_o.png) on home page. This opens a dialog which guides the user with creating new identity, uploading data and adding verifier. Identity is created by tapping ![generate_identity_button](https://images2.imgbox.com/c8/b8/rqbKi8aE_o.png) button. 

After that's completed, user can add data of different types (first name, last name, email, files...):

![data_upload](https://images2.imgbox.com/de/cb/hwIvL72Y_o.png)

When data finished uploading to IPFS user is prompted to add verifier by scanning it's QR code (![scan_qr_code](https://images2.imgbox.com/1a/31/gCu8Vq8f_o.png)). Correct QR code is generated on verifier's front-end by pressing ![generate_qr_code](https://images2.imgbox.com/cb/46/quzynjcj_o.png) button in the top left corner. User now gets a confirmation message: 

![confirmation](https://images2.imgbox.com/2d/f1/ChDvIyov_o.png). 

Verifier can refresh the list of pending contracts by pressing ![verifier_refresh](https://images2.imgbox.com/2d/eb/tX3LcCnY_o.png) button in the top right corner. Contract details can be displayed by pressing ![view_contract_details](https://images2.imgbox.com/4f/26/rpS1Ejlp_o.png) button which opens a dialog with data associated with this contract (files can also be downloaded) and an option to approve or deny identity claim: 

![approve_deny](https://images2.imgbox.com/ae/fb/67oLQiaQ_o.png)

If verifier approves it the contract is moved to `Processed Contracts`. User can refresh their  list of contracts in mobile application (pulling and releasing from top of screen). If the contract is verified, a green checkmark is shown: ![verification_status](https://images2.imgbox.com/8b/15/YLWvt2oX_o.png)

## Granting data access to service
Contracts that are verified can be used to provide data to service which requests it. That is done in the mobile application by tapping selected contract which opens a bottom modal sheet with more information about the contract. Going to second tab (by tapping on ![second_tab](https://images2.imgbox.com/b8/c9/VasZBvkV_o.png)) gives us an option to add address of the service to the list of addresses with access to data stored in this identity contract. That can be done by scanning the QR code with the tap on ![scan_qr_service](https://images2.imgbox.com/bc/84/aiq91Bfc_o.png). Service's QR code is generated in the same way as verifier's - by pressing ![generate_service_qr](https://images2.imgbox.com/a4/b3/pxmmOLJa_o.png) button in the top left in it's front-end client. After service is granted access, we can refresh the list of identity contracts (![service_refresh](https://images2.imgbox.com/68/94/lFTOTfWs_o.png)) and view/download data by pressing ![service_view_data](https://images2.imgbox.com/59/3b/MWtv7kqc_o.png)