import React from 'react';
import Button from '@material-ui/core/Button';
import IconButton from '@material-ui/core/IconButton';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';
import Slide from '@material-ui/core/Slide';
import CropFreeIcon from '@material-ui/icons/CropFree';
import { config } from '../config'
import QRCode from "react-qr-code";

const Transition = React.forwardRef(function Transition(props, ref) {
  return <Slide direction="up" ref={ref} {...props} />;
});

export default function QRCodeDialog() {
  const [open, setOpen] = React.useState(false);

  const handleClickOpen = () => {
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
  };

  const qrData = {
      verifier: config.verifierAccount,
      verifyUrl: `${config.backendMobileUrl}/verify/request`
  }

  return (
    <div>
        <IconButton edge="start" color="inherit" aria-label="menu" onClick={handleClickOpen}>
            <CropFreeIcon />
        </IconButton>
        <Dialog
            open={open}
            TransitionComponent={Transition}
            keepMounted
            onClose={handleClose}
            aria-labelledby="alert-dialog-slide-title"
            aria-describedby="alert-dialog-slide-description"
        >
            <DialogTitle id="alert-dialog-slide-title">Verifier QR Code</DialogTitle>
            <DialogContent>
                <DialogContentText id="alert-dialog-slide-description"> 
                    Scan this QR code with mobile application to set Identity Verifier:
                </DialogContentText>
            </DialogContent>
            <DialogContent align="center">
                <QRCode value={JSON.stringify(qrData)}></QRCode>
            </DialogContent>
            <DialogActions>
                <Button onClick={handleClose} color="primary">
                    Close
                </Button>
            </DialogActions>
        </Dialog>
    </div>
  );
}
