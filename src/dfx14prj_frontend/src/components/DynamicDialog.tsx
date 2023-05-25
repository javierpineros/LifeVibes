import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Paper,
  PaperProps,
} from "@mui/material";
import Draggable from "react-draggable";

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

export default function DynamicDialog(props) {
  return (
    <Dialog
      open={props.openDialog}
      onClose={props.handleCloseDialog}
      PaperComponent={props.PaperComponent}
      aria-labelledby="draggable-dialog-title"
      hideBackdrop
      className="textSettingsDialog"
      PaperProps={{ sx: { position: "fixed", bottom: 0, left: 0, maxHeight: "40%" } }}
      style={{
        verticalAlign: "top",
        alignItems: "flex-start",
        padding: 0,
      }}
    >
      <DialogContent
        style={{
          padding: 0,
        }}
      >
        {props.children}
      </DialogContent>
    </Dialog>
  );
}
