import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import RefreshIcon from '@material-ui/icons/Refresh';
import CircularProgress from '@material-ui/core/CircularProgress';
import QRCodeDialog from './QRCodeDialog'
import IconButton from '@material-ui/core/IconButton';

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
  },
  appBarButton: {
    marginRight: theme.spacing(2),
  },
  title: {
    flexGrow: 1,
  },
}));

export default function TopAppBar(props) {
  const classes = useStyles();

  let refreshIndicator;
  if (props.isLoadingContracts){ 
    refreshIndicator = <CircularProgress color="inherit" size={30}></CircularProgress>
  }
  else {
    refreshIndicator = (
      <IconButton edge="end" className={classes.appBarButton} color="inherit" aria-label="refresh" onClick={props.refreshContracts} >
        <RefreshIcon />
      </IconButton>
    )
  }

  return (
    <div className={classes.root}>
      <AppBar position="sticky">
        <Toolbar>
          <QRCodeDialog></QRCodeDialog>
          <Typography variant="h5" className={classes.title} align="center">
            Verifier - Client
          </Typography>
          {refreshIndicator}
        </Toolbar>
      </AppBar>
    </div>
  );
}