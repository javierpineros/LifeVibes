import "@connect2ic/core/style.css";
import { useConnect } from "@connect2ic/react";
import VolumeUp from "@mui/icons-material/Add";
import CloseIcon from "@mui/icons-material/Close";
import DeleteIcon from "@mui/icons-material/Delete";
import LikeIcon from "@mui/icons-material/Favorite";
import LikeIconEmpty from "@mui/icons-material/FavoriteBorderOutlined";
import { infinitePreloader } from "./assets/infinitePreloader";
import {
  Dialog,
  DialogActions,
  DialogContent,
  DialogContentText,
  DialogTitle,
  Fab,
  Hidden,
  IconButton,
  Slide,
  Snackbar,
} from "@mui/material";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Container from "@mui/material/Container";
import CssBaseline from "@mui/material/CssBaseline";
import Grid from "@mui/material/Grid";
import Link from "@mui/material/Link";
import Paper from "@mui/material/Paper";
import Typography from "@mui/material/Typography";
import { ThemeProvider, createTheme, styled } from "@mui/material/styles";
import React, { useEffect, useState } from "react";
import { dfx14prj_backend } from "../../declarations/dfx14prj_backend";
import logoDfinity from "./assets/dfinity.svg";

// Import Swiper styles
import "swiper/css";
import "swiper/css/free-mode";
import "swiper/css/navigation";
import "swiper/css/thumbs";

import "./assets/styles.css";

// import required modules
import { Principal } from "@dfinity/principal";
import SimpleBackdrop from "./components/SimpleBackdrop";
import UserMenu from "./components/UserMenu";
import CreatorDialog from "./components/CreatorDialog";
import RangingBoard from "./components/RankingBoard";
import Wall from "./components/Wall";

export const DUMY_PRINCIPAL_ID = Principal.fromText("2vxsx-fae");

function Copyright() {
  return (
    <Typography
      component="p"
      variant="caption"
      color="text.secondary"
      align="center"
    >
      {"Copyright © "}
      <Link color="inherit" href="https://internetcomputing.org/">
        Motoko BootCamp
      </Link>{" "}
      {new Date().getFullYear()}
      {"."}
    </Typography>
  );
}

const Item = styled(Paper)(({ theme }) => ({
  backgroundColor: theme.palette.mode === "dark" ? "#1A2027" : "#fff",
  ...theme.typography.body2,
  padding: theme.spacing(1),
  textAlign: "center",
  color: theme.palette.text.secondary,
}));

const theme = createTheme();

const BootstrapDialog = styled(Dialog)(({ theme }) => ({
  "& .MuiDialogContent-root": {
    padding: theme.spacing(2),
  },
  "& .MuiDialogActions-root": {
    padding: theme.spacing(1),
  },
}));

export interface DialogTitleProps {
  id: string;
  children?: React.ReactNode;
  onClose: () => void;
}

function BootstrapDialogTitle(props: DialogTitleProps) {
  const { children, onClose, ...other } = props;

  return (
    <DialogTitle sx={{ m: 0, p: 2 }} {...other}>
      {children}
      {onClose ? (
        <IconButton
          aria-label="close"
          onClick={onClose}
          sx={{
            position: "absolute",
            right: 8,
            top: 8,
            color: (theme) => theme.palette.grey[500],
          }}
        >
          <CloseIcon />
        </IconButton>
      ) : null}
    </DialogTitle>
  );
}

function TransitionLeft(props) {
  return <Slide {...props} direction="left" />;
}

function snackBarMessage(msg) {
  return <Snackbar TransitionComponent={TransitionLeft} message={msg} />;
}

function a11yProps(index: number) {
  return {
    id: `simple-tab-${index}`,
    "aria-controls": `simple-tabpanel-${index}`,
  };
}

let history = [
  {
    x: 20,
    y: 20,
  },
];
let historyStep = 0;

export default function Graffiti() {
  const [userMenuNotifier, setUserMenuNotifier] = useState(0);
  const [creatorRefreshNotifier, setcreatorRefreshNotifier] = useState(0);

  const [backend] = React.useState(dfx14prj_backend);
  const [imageSelected, setImageSelected] = React.useState(false);
  const [open, setOpen] = React.useState(false);
  const [openBSD, setOpenBSD] = React.useState(false);

  const [alertTitle, setAlertTitle] = React.useState("");
  const [alertMessage, setAlertMessage] = React.useState("");
  const [showPreloader, setShowPreloader] = useState(false);
  const [showForm, setShowForm] = useState(true);
  const [successTask, setSuccessTask] = useState(false);
  const [isPreloaded, setIsPreloaded] = useState(false);

  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [avatarVotes, setAvatarVotes] = useState(-1);

  const [avatarOwner, setAvatarOwner] = useState(null);
  const [avatarId, setAvatarId] = useState(-1);
  const [imageTitle, setImageTitle] = useState("");
  const [imageDescription, setImageDescription] = useState("");
  const [imageData, setImageData] = useState("");
  const [voted, setVoted] = useState(false);

  const [appName, setAppName] = React.useState("");
  const [avatarList, setAvatarList] = React.useState([]);
  const [rankingList, setRankingList] = React.useState([]);

  const [cropperDIF, setCropperDIF] = useState(null);

  const [value, setValue] = React.useState(0);

  const [propertyCardPhotoRea, setpropertyCardPhotoRear] = React.useState("");

  const { isConnected, principal, activeProvider, status } = useConnect({
    onConnect: () => {
      console.log("in session [" + JSON.stringify(principal) + "]");
      setUserMenuNotifier((userMenuNotifier) => userMenuNotifier + 1);
    },
    onDisconnect: () => {
      setUserMenuNotifier(-1); // Clear user session data calling UserMenu component
    },
  });

  const [state, setState] = React.useState({
    position: history[0],
    isDragging: true,
  });

  /*const { isConnected, principal, activeProvider, status } = useConnect({
    onConnect: () => {
      alert("[" + JSON.stringify(principal) + "]");
    },
    onDisconnect: () => {
      // Signed out
    },
  });*/

  const [openCreator, setOpenCreator] = React.useState(false);
  const handleCloseCreator = () => {
    setOpenCreator(false);
  };

  const showResultMessage = (message) => {
    setAlertMessage(message);
    setOpen(true);
  };

  const initLoader = async () => {
    try {
      setAppName((await backend.name()) as string);
      let arr = await backend.getAllAvatars();
      setAvatarList(arr as []);
      let rank = await backend.getRanking();
      setRankingList(rank as []);
    } catch (e) {
      console.error(e);
    }
  };

  const getImage = (prefix, avatarId, target): string => {
    // @ts-ignore
    backend
      .getAvatarImage(avatarId)
      .then((res) => {
        // @ts-ignore
        if (res.ok) {
          // @ts-ignore
          document.getElementById(prefix + target).src = res.ok.image;
        }
      })
      .catch((e) => {
        console.error(JSON.stringify(e));
      });
    return "";
  };

  const handleAvatarView = async (index) => {
    let card = avatarList[index];

    var principalObject = DUMY_PRINCIPAL_ID;
    if (principal) {
      principalObject = card.owner;
    }

    setVoted(false);
    backend
      .getVoteForAvatarIdAndVoter(principalObject, card.id)
      .then((vote) => {
        if (vote.length == 0) {
          setVoted(false);
        } else {
          setVoted(true);
        }
      });
    getImage("fullImg", card.id, "");
    setAvatarId(card.id);
    setAvatarOwner(card.owner);
    setImageTitle(card.name);
    setImageDescription(card.ownerName);
    setImageData(card.image);
    setAvatarVotes(parseInt(card.votes));
    setOpenBSD(true);
  };

  const handleClose = () => {
    setTitle("");
    setDescription("");
    setImageSelected(false);
    if (successTask) {
      setShowForm(false);
      document.location.href = "/";
    }
    setOpen(false);
  };

  const handleCloseBSD = () => {
    setOpenBSD(false);
  };

  const handleVote = async () => {
    try {
      if (!isConnected) {
        showResultMessage(
          'To vote, log in to IC or create one account in the "Connect" button options on the user icon at the top right'
        );
        return;
      }

      //setShowPreloader(true);

      if (isConnected && principal) {
        var principalObject = Principal.fromText(principal);

        setVoted(!voted);
        if (!voted) {
          setAvatarVotes(avatarVotes + 1);
        } else {
          setAvatarVotes(avatarVotes == 0 ? 0 : avatarVotes - 1);
        }

        let balance = backend
          .vote(principalObject, BigInt(avatarId), voted)
          .then((balance) => {
            // To update balance
            setUserMenuNotifier((userMenuNotifier) => userMenuNotifier + 1);
          })
          .catch((err) => {
            //setShowPreloader(false);
            showResultMessage(err);
          });
      }
    } catch (e) {
      setAlertMessage(e.message);
      setSuccessTask(false);
      setOpen(true);
      setShowPreloader(false);
    }
  };

  const avatarDelete = async (avatarId) => {
    setOpenBSD(false);
    setShowPreloader(true);

    if (isConnected && principal) {
      var principalObject = Principal.fromText(principal);

      let res = await backend.avatarDelete(principalObject, BigInt(avatarId));
      setAlertMessage("Graffiti deleted");
      setOpen(true);
      // @ts-ignore
      if (res.ok) {
        setAvatarList(avatarList.filter((a) => a.id !== avatarId));
        setShowPreloader(false);
      }
    }
  };

  const showCreator = () => {
    setOpenCreator(true);
    setShowPreloader(true);
    setcreatorRefreshNotifier(
      (creatorRefreshNotifier) => creatorRefreshNotifier + 1
    );
  };

  useEffect(() => {
    if (!backend) {
      return;
    }
    initLoader();
  }, [backend, appName]);

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      {showPreloader ? <SimpleBackdrop /> : null}
      <main>
        {/* Hero unit */}
        <Box
          sx={{
            bgcolor: "background.paper",
            pt: 1,
            pl: 2,
            pb: 0,
          }}
        >
          <Container sx={{ py: 1 }} maxWidth="lg">
            <Grid container spacing={1}>
              <Grid item xs={7} sm={7} md={7}>
                <Typography
                  component="h2"
                  variant="h4"
                  align="left"
                  color="text.primary"
                  gutterBottom
                  style={{ marginBottom: 0 }}
                >
                  Life Vibes{" "}
                </Typography>
                <Typography
                  component="p"
                  variant="caption"
                  align="left"
                  color="text.secondary"
                  paragraph
                >
                  ... the precious beating of our heart
                </Typography>
              </Grid>
              <Grid item xs={3} sm={3} md={3} style={{}}>
                <Hidden smDown>
                  <Fab
                    variant="extended"
                    size="small"
                    color="primary"
                    aria-label="add"
                    onClick={() => {
                      showCreator();
                    }}
                    style={{
                      margin: "15px 30px 0 0",
                      padding: "7px 15px",
                      display: isConnected ? "flex" : "none",
                    }}
                  >
                    <VolumeUp sx={{ mr: 1 }} />
                    Graffiti
                  </Fab>
                </Hidden>
              </Grid>
              <Grid item xs={2} sm={2} md={2} style={{ textAlign: "right" }}>
                <UserMenu
                  userMenuNotifier={userMenuNotifier}
                  principal={principal}
                  isConnected={isConnected}
                  setShowPreloader={setShowPreloader}
                  showResultMessage={showResultMessage}
                />
              </Grid>
            </Grid>
          </Container>
        </Box>

        <Container sx={{ py: 1 }} maxWidth="lg">
          <Hidden smUp>
            <Grid item xs={3} sm={3} md={3} style={{ textAlign: "right" }}>
              <Fab
                variant="extended"
                size="small"
                color="primary"
                aria-label="add"
                onClick={() => {
                  showCreator();
                }}
                style={{
                  margin: 24,
                  padding: "7px 15px",
                  display: isConnected ? "flex" : "none",
                }}
              >
                <VolumeUp sx={{ mr: 1 }} />
                Graffiti
              </Fab>
            </Grid>
          </Hidden>
          <Grid container spacing={1}>
            <Grid
              item
              xs={12}
              sm={9}
              md={10}
              lg={10}
              xl={10}
              className="avatarGrid"
            >
              {Wall({ avatarList, handleAvatarView, getImage })}
            </Grid>

            <Grid item xs={12} sm={2} md={2} lg={2} xl={2}>
              {RangingBoard({ rankingList, handleAvatarView, getImage })}
            </Grid>
          </Grid>
        </Container>
      </main>
      {/* Footer */}
      <Box sx={{ bgcolor: "background.paper", p: 6 }} component="footer">
        <Typography variant="h6" align="center" gutterBottom>
          <img
            src="./assets/dfinity.svg"
            className="App-logo"
            alt="logo"
            style={{ height: 30 }}
          />
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <img
            src="./assets/motoko-180.png"
            className="App-logo"
            alt="logo"
            style={{ height: 30 }}
          />
        </Typography>
        <Typography
          component="p"
          variant="caption"
          align="center"
          color="text.secondary"
        >
          Building a memorable community on the internet computer,{" "}
          <strong>express yourself and earns MotoCoins</strong>
        </Typography>
        <Copyright />
      </Box>
      {/* End footer */}

      <CreatorDialog
        openCreator={openCreator}
        setOpenCreator={setOpenCreator}
        setShowPreloader={setShowPreloader}
        handleCloseCreator={handleCloseCreator}
        creatorRefreshNotifier={creatorRefreshNotifier}
        principal={principal}
        isConnected={isConnected}
        backend={backend}
        publishImageResultHandler={(
          success,
          graffitiMessage,
          dataUrl,
          errorMsg
        ) => {
          if (success < 0) {
            setAlertMessage(errorMsg);
          } else {
            setAlertMessage("Graffiti published");

            avatarList.unshift({
              id: success,
              title,
              description: graffitiMessage,
              image: dataUrl,
              owner: principal,
              votes: 0,
            });
          }

          setSuccessTask(false);
          setOpen(true);
          setShowPreloader(false);
        }}
      />

      <Dialog
        open={open}
        onClose={handleClose}
        aria-labelledby="alert-dialog-title"
        aria-describedby="alert-dialog-description"
      >
        <DialogTitle id="alert-dialog-title">{alertTitle}</DialogTitle>
        <DialogContent>
          <DialogContentText id="alert-dialog-description">
            {alertMessage}
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button
            onClick={handleClose}
            color="primary"
            variant="contained"
            autoFocus
          >
            Continuar
          </Button>
        </DialogActions>
      </Dialog>

      <BootstrapDialog
        onClose={handleCloseBSD}
        aria-labelledby="customized-dialog-title"
        open={openBSD}
      >
        <BootstrapDialogTitle
          id="customized-dialog-title"
          onClose={handleCloseBSD}
        >
          {imageTitle}
        </BootstrapDialogTitle>
        <DialogContent dividers>
          <img
            id={"fullImg"}
            src={imageData}
            className="graffiti-image"
            style={{ width: "100%", minWidth: 240, minHeight: 180 }}
          />
          <Typography gutterBottom>@{imageDescription}</Typography>
        </DialogContent>
        <DialogActions>
          {isConnected && avatarOwner === principal ? (
            <DeleteIcon
              onClick={() => {
                avatarDelete(avatarId);
              }}
            />
          ) : null}
          &nbsp;&nbsp;&nbsp;&nbsp;
          {avatarVotes} likes &nbsp;&nbsp;
          {!voted ? (
            <LikeIconEmpty
              onClick={() => {
                handleVote();
              }}
            />
          ) : null}
          {voted ? (
            <LikeIcon
              onClick={() => {
                handleVote();
              }}
            />
          ) : null}
          &nbsp;&nbsp;&nbsp;
        </DialogActions>
      </BootstrapDialog>
    </ThemeProvider>
  );
}
