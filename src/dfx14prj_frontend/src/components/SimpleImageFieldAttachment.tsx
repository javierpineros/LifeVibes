import React, { useState } from 'react';
import { PreLoader } from './PreLoader';
import CameraIcon from '@mui/icons-material/CameraAlt';
import RotateRightIcon from '@mui/icons-material/RotateRight';
import RotateLeftIcon from '@mui/icons-material/RotateLeft';

import { Button, Tooltip, Typography } from '@mui/material';
import html2canvas from 'html2canvas';

/*const useStyles = makeStyles(theme => ({
  enterSpace: {
    marginBottom: 10,
  },
  docButton: {
    marginBottom: 10,
  },
  cropperCanvas: {
    backgroundColor: theme.palette.background.paper,
    border: '1px solid #777',
    boxShadow: theme.shadows[5],
    padding: theme.spacing(1, 1, 1, 1),
    margin: theme.spacing(1, 0, 1, 0),
  },
  docPhoto: {
    width: '100%',
  },
}));*/

export function SimpleImageFieldAttachment({
  name, // Form Field name
  onImageSelected, 
  imageDataHandler,
  imageViewerRef
}) {
  const refInputFile = React.useRef(null);
  const refPreview = React.useRef(null);

  //const classes = useStyles; //Material-ui
  const [image, setImage] = useState('');
  const [imagePreview, setImagePreview] = useState(null);
  const [error, setError] = useState('');

  const [showPreloader, setShowPreloader] = useState(false);

  const handleImage = e => {
    setError('');
    setShowPreloader(true);

    try {
      e.preventDefault();
      let files;
      if (e.dataTransfer) {
        files = e.dataTransfer.files;
      } else if (e.target) {
        files = e.target.files;
      }
      const reader = new FileReader();
      reader.onload = (e) => {
        // @ts-ignore
        imageDataHandler(e.target.result);
        setShowPreloader(false);
      };
      reader.readAsDataURL(files[0]);
      e.target.value = null;
    } catch (e: any) {
      e.target.value = null;
      setError('Error: ' + e);
    }
  };

  return (
    <>
      <Button
        variant="contained"
        component="label"
      >
        <CameraIcon />
        <input
          ref={refInputFile}
          type="file"
          id="imageFile"
          name="imageFile"
          className="imageFile"
          hidden
          accept="image/*"
          onChange={handleImage}
        />
      </Button>
      <img 
        ref={refPreview}
        src={imagePreview}
        id="preview"
        onLoad={() => {
          html2canvas(refPreview.current).then(canvas => {
            var _data = canvas.toDataURL('image/jpeg');
            setImage(_data)
            onImageSelected(_data);
          });
        }}
        style={{ display: 'block', width: 100, height: 'auto', border: '1px solid red' }} />
      {showPreloader && <PreLoader />}
      {error}
    </>
  );
}
