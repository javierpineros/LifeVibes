import styled from "@emotion/styled";
import { Button, Dialog, DialogActions, DialogContent, DialogTitle, IconButton, Paper, PaperProps } from "@mui/material";
import Draggable from "react-draggable";
import CloseIcon from '@mui/icons-material/Close';

// for dialog draggable
function PaperComponent(props: PaperProps) {
  return (
    <Draggable
      handle="#draggable-dialog-title"
      cancel={'[class*="MuiDialogContent-root"]'}
    >
      <Paper {...props} />
    </Draggable>
  );
}

const BootstrapDialog = styled(Dialog)(({ theme }) => ({
  '& .MuiDialogContent-root': {
    padding: 10,
  },
  '& .MuiDialogActions-root': {
    padding: 5,
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
            position: 'absolute',
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

export default function DynamicCompleteDialog(props) {
  return (
    <Dialog
      open={props.openDialog}
      onClose={props.handleCloseDialog}
      PaperComponent={props.PaperComponent}
      aria-labelledby="draggable-dialog-title"
      hideBackdrop
      className="textSettingsDialog"
      style={{
        verticalAlign: 'top',
        alignItems: 'flex-start',
      }}
    >
      <BootstrapDialogTitle id="customized-dialog-title" onClose={props.handleCloseDialog}>
        {props.title}
        </BootstrapDialogTitle>
      <DialogContent dividers>
        {props.children}
      </DialogContent>
      <DialogActions>
        <Button
          onClick={() => {
            props.handleConfirmButton();
          }}
          color="primary"
          variant="contained"
          autoFocus
        >
          {props.confirmButtonTitle}
        </Button>
      </DialogActions>
    </Dialog>)
}
