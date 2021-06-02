import React, {useState} from 'react';
import Button from '@material-ui/core/Button';
import IconButton from '@material-ui/core/IconButton';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';
import Slide from '@material-ui/core/Slide';
import EditIcon from '@material-ui/icons/Edit';
import { config } from '../config'
import CircularProgress from '@material-ui/core/CircularProgress';
import VisibilityIcon from '@material-ui/icons/Visibility';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import SaveAltIcon from '@material-ui/icons/SaveAlt';
import streamSaver from 'streamsaver'

const Transition = React.forwardRef(function Transition(props, ref) {
  return <Slide direction="up" ref={ref} {...props} />;
});

export default function ContractDialog(props) {
  const [open, setOpen] = React.useState(false);
  const [ipfsData, setIpfsData] = useState({})
  const [loadingData, setLoadingData] = useState(false)
  const [verify, setVerify] = useState(false)

  const handleClickOpen = () => {
    setOpen(true);
    getData();
  };

  const handleClose = () => {
    setOpen(false);
  };

  function buildData(){
    if (loadingData){
        return <CircularProgress color="primary"></CircularProgress>
    }
    else if (ipfsData){

        return <TableContainer component={Paper}>
            <Table aria-label="simple table">
                <TableHead>
                    <TableRow>
                        <TableCell style={{fontWeight: 'bold'}}>Field Name</TableCell>
                        <TableCell style={{fontWeight: 'bold'}} align='right'>Value</TableCell>
                    </TableRow>
                </TableHead>
                <TableBody>
                    {
                        Object.keys(ipfsData).map((key, _) => (
                            <TableRow key={key}>
                                <TableCell component="th" scope="row">
                                    {key}
                                </TableCell>
                                {buildValue(ipfsData[key])}
                            </TableRow>
                        ))
                    }
                </TableBody>
            </Table>
        </TableContainer>
    }
    else {
        return <div></div>
    }
  }

  function buildValue(value){
    if (typeof(value) == 'object'){
        return <TableCell align="right">
            {value['filename'] + "      "}     
            <IconButton edge="end" aria-label="edit" onClick={() => downloadFile(value['data'], value['filename'])} size="small" >
                <SaveAltIcon color='primary' fontSize="small"></SaveAltIcon>
            </IconButton>
            
        </TableCell>
    }
    else {
        return <TableCell align="right">{value}</TableCell>
    }
  }

  function downloadFile(bytes, filename){
    if (bytes){
        const byteArray = Uint8Array.from(bytes)
        const fileStream = streamSaver.createWriteStream(
            filename, 
            {
                size: byteArray.byteLength, 
                writableStrategy: undefined,
                readableStrategy: undefined
            }
        )
        const writer = fileStream.getWriter()
        writer.write(byteArray)
        writer.close()
    }
  }

  function buildActions(){
      if (props.isPending){
        return (
            <DialogActions>
                <Button onClick={() => changeVerificationStatus(false)} color="secondary">
                    Deny
                </Button>
                <Button onClick={() => changeVerificationStatus(true)} color="primary">
                    Approve
                </Button>
            </DialogActions>
        )
      }
      else {
        return (
            <DialogActions>
                <Button onClick={handleClose} color="primary">
                    Close
                </Button>
            </DialogActions>
        )
      }
  }

  async function getData(){
    console.log("Retrieving data...")
    setLoadingData(true)
    fetch(
        `${config.backendUrl}/ipfs/data`, 
        {
            method: 'POST', 
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({id: props.id, isPending: props.isPending})
        }
    )
        .then(res => res.json(),
        (error) => {
            setLoadingData(false)
            console.error(error)
        })
        .then((res) => {
            setLoadingData(false)
            setIpfsData(res.data)
        })
  }

  async function changeVerificationStatus(status){
    setLoadingData(true)
    fetch(
        `${config.backendUrl}/verify`, 
        {
            method: 'PUT', 
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({id: props.id, status: status})
        }
    )
        .then(res => res.json(),
        (error) => {
            setLoadingData(false)
            console.error(error)
        })
        .then((res) => {
            setLoadingData(false)
            handleClose()
            props.setContractsData(res.data)
        })
  }

  return (
    <div>
        <IconButton edge="end" aria-label="edit" onClick={handleClickOpen} size="small">
            {
                props.isPending ? 
                <EditIcon fontSize="small"/> :
                <VisibilityIcon fontSize="small"/>
            }
        </IconButton>
        <Dialog
            open={open}
            TransitionComponent={Transition}
            keepMounted
            onClose={handleClose}
            aria-labelledby="alert-dialog-slide-title"
            aria-describedby="alert-dialog-slide-description"
        >
            <DialogTitle id="alert-dialog-slide-title">Verify Identity</DialogTitle>
            <DialogContent style={{minWidth: 400}}>
                <DialogContentText id="alert-dialog-slide-description"> 
                    {"Contract: " + props.contractId}
                </DialogContentText>
                {buildData()}   
            </DialogContent>
            {buildActions()}
        </Dialog>
    </div>
  );
}
