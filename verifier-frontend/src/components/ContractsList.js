import React, { useState, useEffect} from 'react';

import { makeStyles } from '@material-ui/core/styles';
import Paper from '@material-ui/core/Paper';
import Grid from '@material-ui/core/Grid';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListItemText from '@material-ui/core/ListItemText';
import Checkbox from '@material-ui/core/Checkbox';
import IconButton from '@material-ui/core/IconButton';
import EditIcon from '@material-ui/icons/Edit';
import Divider from '@material-ui/core/Divider';
import ContractDialog from './ContractDialog'

const useStyles = makeStyles((theme) => ({
    root: {
      flexGrow: 1,
      padding: theme.spacing(2),
    },
    paper: {
      padding: theme.spacing(2),
      textAlign: 'center',
      color: theme.palette.primary.main,
      maxHeight: '100vh',
      overflow: 'auto',
    },
    list: {
        padding: 0
    },
    listItem: {
        color: theme.palette.text.secondary
    }
}));

export default function ContractsList(props) {

    const classes = useStyles();

    function buildPendingContracts(){
        return (
            <Paper className={classes.paper}>
                <div>Pending Contracts</div>
                {
                    props.contractsData.pendingContracts ? 
                    <List className={classes.list}>
                        {props.contractsData.pendingContracts.length > 0 ? <Divider style={{marginTop: 10, marginBottom: 5}}/> : <div></div>}
                        {props.contractsData.pendingContracts.map((contract) => {
                            return (
                            <ListItem key={contract['_id']} role={undefined} dense button className={classes.listItem}>
                                <ListItemText id={contract['_id']} primary={contract['contractId']} />
                                <ListItemSecondaryAction>
                                <ContractDialog canVerify="true" contractId={contract['contractId']} id={contract['_id']} isPending={true} setContractsData={props.setContractsData}></ContractDialog>
                                </ListItemSecondaryAction>
                            </ListItem>
                            );
                        })}
                    </List> :
                    <div></div>
                }
                
            </Paper>
        )
    }

    function buildProcessedContracts(){
        return (
            <Paper className={classes.paper}>
                <div>Processed Contracts</div>
                {
                    props.contractsData.processedContracts ? 
                    <List className={classes.list}>
                        {props.contractsData.processedContracts.length > 0 ? <Divider style={{marginTop: 10, marginBottom: 5}}/> : <div></div>}
                        {props.contractsData.processedContracts.map((contract) => {
                            return (
                            <ListItem key={contract['_id']} role={undefined} dense button className={classes.listItem}>
                                <ListItemText id={contract['_id']} primary={contract['contractId']} />
                                <ListItemSecondaryAction>
                                    <ContractDialog canVerify="true" contractId={contract['contractId']} id={contract['_id']} isPending={false} ></ContractDialog>
                                </ListItemSecondaryAction>
                            </ListItem>
                            );
                        })}
                    </List> :
                    <div></div>
                }
                
            </Paper>
        )
    }

    return (
        <div className={classes.root}>
            <Grid container spacing={3}>
                <Grid item xs={12} sm={6}>
                   {buildPendingContracts()}
                </Grid>
                <Grid item xs={12} sm={6}>
                   {buildProcessedContracts()}
                </Grid>
        </Grid>
      </div>
    )   
}