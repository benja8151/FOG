import React, {useState, useEffect} from 'react';
import Button from '@material-ui/core/Button';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';
import Slide from '@material-ui/core/Slide';
import { config } from '../config'
import CircularProgress from '@material-ui/core/CircularProgress';
import StarRatings from 'react-star-ratings';

const Transition = React.forwardRef(function Transition(props, ref) {
  return <Slide direction="up" ref={ref} {...props} />;
});

export default function RatingDialog(props) {
  const [open, setOpen] = React.useState(false);
  const [loadingData, setLoadingData] = useState(false)
  const [reputationRatings, setReputationRatings] = useState()

  const handleClickOpen = () => {
    setOpen(true);
    getData();
  };

  const handleClose = () => {
    setOpen(false);
  };

  useEffect(() => {
    getData()
  }, []);

  async function getData(){
    console.log("Retrieving data...")
    setLoadingData(true)
    fetch(
        `${config.backendUrl}/contracts/reputation`, 
        {
            method: 'POST', 
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({id: props.id})
        }
    )
        .then(res => res.json(),
        (error) => {
            setLoadingData(false)
            console.error(error)
        })
        .then((res) => {
            setLoadingData(false)
            setReputationRatings(res.data)
            console.log(res.data)
        })
  }

  async function addRating(rating){
    console.log("Retrieving data...")
    setLoadingData(true)
    fetch(
        `${config.backendUrl}/contracts/reputation/add`, 
        {
            method: 'POST', 
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({id: props.id, rating: rating})
        }
    )
        .then(res => res.json(),
        (error) => {
            setLoadingData(false)
            console.error(error)
        })
        .then((res) => {
            setLoadingData(false)
            setReputationRatings(res.data)
            handleClose()
        })
  }

  function buildRating(){
    if (!reputationRatings) return;
    return <div onClick={handleClickOpen} style={{cursor: 'pointer'}}> 
            {
                (reputationRatings.reputation.length == 0) ? 
                    "0 ratings"
                : 
                    <div>
                      <StarRatings 
                            starRatedColor={"#f50057"}
                            rating={calculateAverageRating()} 
                            starDimension="20px" 
                            starSpacing="3px"
                        />
                        ({reputationRatings.reputation.length > 1 ? reputationRatings.reputation.length + " ratings" : reputationRatings.reputation.length + " rating" })
                    </div>
                
            }
        </div>
  }

  function calculateAverageRating(){
      console.log(reputationRatings)
      if (!reputationRatings) return 0
      if (!reputationRatings.reputation) return 0
      if (reputationRatings.reputation.length == 0) return 0
      return reputationRatings.reputation.reduce((curr, rating) => parseInt(rating) + curr, 0) / reputationRatings.reputation.length
  }

  return (
    <div>
        {buildRating()}
        <Dialog
            open={open}
            TransitionComponent={Transition}
            keepMounted
            onClose={handleClose}
            aria-labelledby="alert-dialog-slide-title"
            aria-describedby="alert-dialog-slide-description"
        >
            <DialogTitle id="alert-dialog-slide-title">Rate User</DialogTitle>
            <DialogContent style={{minWidth: 400}}>
                <DialogContentText id="alert-dialog-slide-description"> 
                    {"Contract: " + props.contractId}
                </DialogContentText>
                    <DialogContentText id="alert-dialog-slide-description"> 
                        Rate:   
                        {
                            loadingData ? 
                            <CircularProgress color="primary"></CircularProgress> : 
                            <StarRatings 
                                starRatedColor={"#f50057"}
                                starHoverColor={"#f50057"}
                                rating={calculateAverageRating()} 
                                starDimension="30px" 
                                starSpacing="3px"
                                changeRating = {(rating, _) => addRating(rating)}
                            />
                        }
                    </DialogContentText>
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
