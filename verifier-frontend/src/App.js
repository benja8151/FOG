import './App.css';
import TopAppBar from "./components/TopAppBar"
import ContractsList from "./components/ContractsList"
import React, { useState, useEffect} from 'react';
import { config } from './config'

function App() {

  const [loadingContracts, setLoadingContracts] = useState(false)
  const [contractsData, setContractsData] = useState({
    pendingContracts: [],
    processedContracts: []
  })

  useEffect(() => {
    getContracts()
  }, [])

  function getContracts(){
    console.log("Retrieving contracts...")
    setLoadingContracts(true)
    fetch(`${config.backendUrl}/contracts`)
      .then(res => res.json(),
      (error) => {
        setLoadingContracts(false)
        console.error(error)
      })
      .then((res) => {
        setLoadingContracts(false)
        setContractsData(res.data)
      })
  }

  return (
    <div className="App">
      <header>
        <TopAppBar refreshContracts={() => getContracts()} isLoadingContracts={loadingContracts}/>
      </header>
      <ContractsList isLoadingContracts={loadingContracts} contractsData={contractsData} setContractsData={setContractsData}/>
    </div>
  );
}

export default App;
