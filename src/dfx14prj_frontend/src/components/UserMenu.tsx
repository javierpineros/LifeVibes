import React, { useEffect, useState, useRef } from "react";
import Button from "@mui/material/Button";
import Menu from "@mui/material/Menu";
import MenuItem from "@mui/material/MenuItem";
import { Avatar, Grid, TextField } from "@mui/material";

import {
  ConnectButton,
  ConnectDialog,
  Connect2ICProvider,
  useConnect,
  useWallet,
} from "@connect2ic/react";

import UserProfileIcon from "@mui/icons-material/Person";
import DynamicDialog from "./DynamicDialog";
import { SimpleImageFieldAttachment } from "./SimpleImageFieldAttachment";
import DynamicCompleteDialog from "./DynamicCompleteDialog";

import {
  dfx14prj_backend,
  idlFactory,
} from "../../../declarations/dfx14prj_backend";

import html2canvas from "html2canvas";
import { Principal } from "@dfinity/principal";
import { DUMY_PRINCIPAL_ID } from "../Graffiti";

export default function UserMenu({
  principal,
  isConnected,
  userMenuNotifier,
  showResultMessage,
  setShowPreloader,
}) {
  let avatarRef = React.useRef(null);

  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [cropperDIF, setCropperDIF] = useState(null);
  const open = Boolean(anchorEl);

  const [openDialog, setOpenDialog] = useState(false);
  const [nickname, setNickname] = useState("");
  const [username, setUsername] = React.useState("");
  const [userBalance, setUserBalance] = React.useState(0);
  const [userProfile, setUserProfile] = React.useState(null);
  const [imageData, setImageData] = useState(null);

  const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
    setAnchorEl(event.currentTarget);
  };
  const handleClose = () => {
    setAnchorEl(null);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
  };
  const onImageSelected = (_imageData) => {
    setImageData(_imageData);
  };

  const updateProfile = async () => {
    if (nickname === "") {
      showResultMessage("Please add your nickname");
      return;
    }
    if (username === "") {
      showResultMessage("Please add your name");
      return;
    }

    html2canvas(avatarRef.current).then(async (canvas) => {
      var _data = canvas.toDataURL("image/jpeg");

      if (isConnected && principal) {
        let principalObject = Principal.fromText(principal);

        let profile = {
          owner: principalObject,
          nickname: nickname,
          name: username,
          graduate: false,
          avatar: _data,
        };

        setShowPreloader(true);
        try {
          let result = await dfx14prj_backend.addMyProfile(
            principalObject,
            profile
          );

          await refreshUserProfile();
          setShowPreloader(false);

          // @ts-ignore
          if(result.ok === 0) {
            showResultMessage("Profile updated, You have been surprised 1000 MotoCoins to start");
          } else {
            showResultMessage("Profile updated");
          }
        } catch (e) {
          setShowPreloader(false);
          showResultMessage(e.message);
        }
      }
    });
    setOpenDialog(false);
  };

  const loadUserProfile = async () => {
    if (isConnected && principal) {
      let principalObject = Principal.fromText(principal);

      // @ts-ignore
      let up = (await dfx14prj_backend.whoami(principalObject)).ok;
      if (up) {
        setNickname(up.nickname);
        setUsername(up.name);
        setImageData(up.avatar);
      } else {
        setNickname("");
        if (isConnected) {
          showResultMessage("Please, update your profile in user menu");
        }
        setImageData("");
      }

      let balance = await dfx14prj_backend.myBalance(principalObject);
      // @ts-ignore
      if (balance.ok) {
        // @ts-ignore
        var b = balance.ok;
        setUserBalance(parseInt(b));
      } else {
        setUserBalance(0);
      }
    }
  };

  useEffect(() => {
    loadUserProfile();
    if (userMenuNotifier) {
      if (userMenuNotifier == -1) {
        setImageData(null);
        setUserBalance(0);
        setUsername("");
        setNickname("");
      } else {
        dfx14prj_backend
          .myBalance(Principal.fromText(principal))
          .then((balance) => {
            // @ts-ignore
            if (balance.ok) {
              // @ts-ignore
              var b = balance.ok;
              setUserBalance(parseInt(b));
            }
          });
      }
    }
  }, [userMenuNotifier]);

  return (
    <div>
      <Button
        id="basic-button"
        aria-controls={open ? "basic-menu" : undefined}
        aria-haspopup="true"
        aria-expanded={open ? "true" : undefined}
        onClick={handleClick}
      >
        <Avatar ref={avatarRef} alt={username} src={imageData} />
      </Button>
      <Menu
        id="basic-menu"
        anchorEl={anchorEl}
        open={open}
        onClose={handleClose}
        MenuListProps={{
          "aria-labelledby": "basic-button",
        }}
        style={{
          width: 300,
        }}
      >
        <MenuItem
          style={{
            display: isConnected ? "flex" : "none",
          }}
        >
          @{nickname} : $ {userBalance} <br />
          {username}
        </MenuItem>
        <MenuItem
          onClick={() => {
            setOpenDialog(true);
          }}
          style={{
            display: isConnected ? "flex" : "none",
          }}
        >
          Update Profile
        </MenuItem>
        <MenuItem>
          <ConnectDialog
            onClose={() => {
              console.log("ConnectDialog onClose");
            }}
          />
          <div className="auth-section">
            <ConnectButton
              onConnect={() => {
                const { isConnected, principal, activeProvider, status } =
                  useConnect();
                if (isConnected) {
                  refreshUserProfile();
                }
              }}
              onDisconnect={() => {
                setImageData(null);
                setUserBalance(0);
                setUsername("");
                setNickname("");
              }}
            />
          </div>
        </MenuItem>
      </Menu>

      <DynamicCompleteDialog
        title="User Profile"
        openDialog={openDialog}
        handleCloseDialog={handleCloseDialog}
        confirmButtonTitle="Save Changes"
        handleConfirmButton={updateProfile}
      >
        <Grid container spacing={2}>
          <Grid item xs={12} sm={12} lg={12} xl={12}>
            <Grid container spacing={2}>
              <Grid item xs={6} sm={6} lg={6} xl={6}>
                <Avatar
                  alt={username}
                  src={imageData}
                  sx={{ width: 88, height: 88 }}
                />
              </Grid>
              <Grid item xs={6} sm={6} lg={6} xl={6} alignContent={"flex-end"}>
                <SimpleImageFieldAttachment
                  name="profilePhoto"
                  onImageSelected={onImageSelected}
                  imageDataHandler={setImageData}
                  imageViewerRef={avatarRef}
                />
              </Grid>
            </Grid>
            <Grid item xs={12} sm={12} lg={12} xl={12}>
              <TextField
                margin="normal"
                fullWidth
                variant="standard"
                label="Nickname"
                autoComplete="text"
                value={nickname}
                onChange={(e) => {
                  setNickname(e.target.value);
                }}
              />
            </Grid>
            <Grid item xs={12} sm={12} lg={12} xl={12}>
              <TextField
                margin="normal"
                fullWidth
                variant="standard"
                label="Full name"
                autoComplete="text"
                value={username}
                onChange={(e) => {
                  setUsername(e.target.value);
                }}
              />
            </Grid>
          </Grid>
        </Grid>
      </DynamicCompleteDialog>
    </div>
  );

  async function refreshUserProfile() {
    if (isConnected && principal) {
      var principalObject = Principal.fromText(principal);

      // @ts-ignore
      let up = (await dfx14prj_backend.whoami(principalObject)).ok;
      if (up) {
        setNickname(up.nickname);
        setUsername(up.name);
        setImageData(up.avatar);
      }
      let balance = await dfx14prj_backend.myBalance(principalObject);
      if (balance) {
        // @ts-ignore
        var b = balance.ok;
        setUserBalance(parseInt(b));
      }
    }
  }
}
