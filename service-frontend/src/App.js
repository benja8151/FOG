import './App.css';
import TopAppBar from "./components/TopAppBar"
import ContractsList from "./components/ContractsList"
import React, { useState, useEffect} from 'react';
import { config } from './config'
import { makeStyles } from '@material-ui/core/styles';
import Grid from '@material-ui/core/Grid';
import RatingsList from './components/RatingsList';

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
    padding: theme.spacing(2),
  },
}));

function App() {

  const classes = useStyles();

  const [loadingContracts, setLoadingContracts] = useState(false)
  const [contractsData, setContractsData] = useState({
    contracts: [],
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
      <div className={classes.root}>
          <Grid container spacing={3}>
            <Grid item xs={12} sm={6}>
              <ContractsList isLoadingContracts={loadingContracts} contractsData={contractsData} />
            </Grid>
            <Grid item xs={12} sm={6}>
              <RatingsList isLoadingContracts={loadingContracts} contractsData={contractsData} />
          </Grid>
        </Grid>
      </div>
    </div>
  );
}

export default App;
