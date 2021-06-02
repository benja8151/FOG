import React from 'react';

import { makeStyles } from '@material-ui/core/styles';
import Paper from '@material-ui/core/Paper';
import Grid from '@material-ui/core/Grid';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListItemText from '@material-ui/core/ListItemText';
import Divider from '@material-ui/core/Divider';
import ContractDialog from './ContractDialog'
import RatingDialog from './RatingDialog';

const useStyles = makeStyles((theme) => ({
    root: {
      flexGrow: 1,
      padding: theme.spacing(2),
    },
    paper: {
      padding: theme.spacing(2),
      textAlign: 'center',
      color: theme.palette.secondary.main,
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

export default function RatingsList(props) {

    const classes = useStyles();

    function buildContracts(){
        return (
            <Paper className={classes.paper}>
                <div>Ratings</div>
                {
                    props.contractsData.contracts ? 
                    <List className={classes.list}>
                        {props.contractsData.contracts.length > 0 ? <Divider style={{marginTop: 10, marginBottom: 5}}/> : <div></div>}
                        {props.contractsData.contracts.map((contract) => {
                            return (
                            <ListItem key={contract['_id']} role={undefined} dense button className={classes.listItem}>
                                <ListItemText id={contract['_id']} primary={contract['contractId']} />
                                <ListItemSecondaryAction>
                                    <RatingDialog contractId={contract['contractId']} id={contract['_id']}></RatingDialog>
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

    return buildContracts()
}