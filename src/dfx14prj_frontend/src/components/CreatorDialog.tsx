import { Principal } from "@dfinity/principal";
import VolumeUp from "@mui/icons-material/Add";
import ColorOutlineFontIcon from "@mui/icons-material/BorderColor";
import CloseIcon from "@mui/icons-material/Close";
import SpeedDialIcon from "@mui/icons-material/ColorLens";
import ColorFontIcon from "@mui/icons-material/Colorize";
import FontIcon from "@mui/icons-material/FontDownloadTwoTone";
import SizeIcon from "@mui/icons-material/FormatSize";
import VolumeDown from "@mui/icons-material/Remove";
import {
  AppBar,
  Box,
  Button,
  Dialog,
  DialogContent,
  IconButton,
  List,
  ListItem,
  Slider,
  SpeedDial,
  Stack,
  Toolbar,
  Typography,
} from "@mui/material";
import SpeedDialAction from "@mui/material/SpeedDialAction";
import html2canvas from "html2canvas";
import React, { useEffect, useRef, useState } from "react";
import { SketchPicker } from "react-color";
import { FreeMode, Navigation, Pagination, Thumbs } from "swiper";
import { Swiper, SwiperSlide } from "swiper/react";
import DynamicDialog from "./DynamicDialog";

// Import Swiper styles
import "swiper/css";
import "swiper/css/pagination";
import "swiper/css/navigation";

const arrBg = [];
let pathBase = "https://www.ubicme.com/javier/mbc";
pathBase = "./";
var i = 0;
for (i = 0; i < 61; i++) {
  arrBg[i] = pathBase + "assets/backgrounds/t/" + (i + 1) + "_t.jpg";
}

const actions = [
  { icon: <ColorOutlineFontIcon />, name: "Color Outline" },
  { icon: <ColorFontIcon />, name: "Color Text" },
  { icon: <SizeIcon />, name: "Size" },
  { icon: <FontIcon />, name: "Font" },
  //{ icon: <OrientationIcon />, name: "Orientation" },
];

const fonts = [
  "'Calligraffitti', cursive",
  "'Damion', cursive",
  "'Delicious Handrawn', cursive",
  "'Finger Paint', cursive",
  "'Freehand', cursive",
  "'Fuzzy Bubbles', cursive",
  "'Gochi Hand', cursive",
  "'Hachi Maru Pop', cursive",
  "'Homemade Apple', cursive",
  "'IBM Plex Sans Arabic', sans-serif",
  "'IBM Plex Sans Hebrew', sans-serif",
  "'IBM Plex Sans JP', sans-serif",
  "'Just Me Again Down Here', cursive",
  "'Leckerli One', cursive",
  "'Molle', cursive",
  "'Nerko One', cursive",
  "'Permanent Marker', cursive",
  "'Rock Salt', cursive",
  "'Rubik Distressed', cursive",
  "'Sedgwick Ave', cursive",
  "'Walter Turncoat', cursive",
  "'Zhi Mang Xing', cursive",
];

export default function CreatorDialog({
  setOpenCreator,
  setShowPreloader,
  principal,
  isConnected,
  backend,
  openCreator,
  publishImageResultHandler,
  creatorRefreshNotifier,
  handleCloseCreator,
}) {
  const dialogContentRef = useRef(null);
  const containerRef = useRef(null);
  const creatorRef = useRef(null);
  const imageContainerRef = useRef(null);
  const imageRef = useRef(null);
  const paragraphRef = useRef(null);

  React.useEffect(() => {
    function handleResize() {
      resizeCreator();
    }
    window.addEventListener("resize", handleResize);
  });

  const _windowWidth = useRef(window.innerWidth);
  const _windowHeight = useRef(window.innerHeight);

  const [canvasWidth, setCanvasWidth] = useState(0);
  const [canvasHeight, setCanvasHeight] = useState(0);

  const [graffitiOrientation, setGraffitiOrientation] = useState<string | null>(
    "landscape"
  );
  const [fontFamily, setFontFamily] = useState("'Finger Paint'");
  const [fontSize, setFontSize] = useState(50);
  const [fontColor, setFontColor] = useState("#FFB400");
  const [textStrokeColor, setTextStrokeColor] = useState("#FFFFFF");
  const [strokeSize, setStrokeSize] = useState(1);
  const [thumbsSwiper, setThumbsSwiper] = useState(arrBg[0]);
  const [backgrounds, setBackgrounds] = useState(arrBg);
  const [graffitiMessage, setGraffitiMessage] = useState("write your message");
  const [openSpeedDial, setOpenSpeedDial] = React.useState(false);

  const handleOpenSpeedDial = () => setOpenSpeedDial(true);
  const handleCloseSpeedDial = () => setOpenSpeedDial(false);

  const [openFontDialog, setOpenFontDialog] = React.useState(false);
  const [openFontColor, setOpenFontColor] = React.useState(false);
  const [openStrokeColor, setOpenStrokeColor] = React.useState(false);
  const [openFontWidth, setOpenFontWidth] = React.useState(false);

  const setImageToCanvas = (swiper) => {
    let url: string = backgrounds[swiper.activeIndex];
    url = url.replace("_t", "");
    url = url.replace("/t/", "/");
    setThumbsSwiper(url);
  };

  const closeAllDialogs = () => {
    setOpenFontColor(false);
    setOpenFontDialog(false);
    setOpenStrokeColor(false);
    setOpenFontWidth(false);
  };

  const handleOrientation = (
    event: React.MouseEvent<HTMLElement>,
    newOrientation: string | null
  ) => {
    setGraffitiOrientation(newOrientation);
    alert(graffitiOrientation);
  };

  const handleClickOpenFontWidth = () => {
    closeAllDialogs();
    setOpenFontWidth(true);
  };
  const handleCloseFontWidth = () => {
    closeAllDialogs();
  };

  const handleClickOpenFontDialog = () => {
    closeAllDialogs();
    setOpenFontDialog(true);
  };
  const handleCloseFontDialog = () => {
    closeAllDialogs();
  };

  const handleClickOpenFontColor = () => {
    closeAllDialogs();
    setOpenFontColor(true);
  };
  const handleCloseFontColor = () => {
    closeAllDialogs();
  };

  const handleClickOpenStrokeColor = () => {
    closeAllDialogs();
    setOpenStrokeColor(true);
  };
  const handleCloseStrokeColor = () => {
    closeAllDialogs();
  };

  const handleSpeedDialogSelected = (e) => {
    let id = "";
    if (e.target.parentNode.nodeName === "svg") {
      id = e.target.parentNode.parentNode.parentNode.id;
    } else if (e.target.parentNode.nodeName === "path") {
      id = e.target.parentNode.parentNode.parentNode.id;
    } else if (e.target.parentNode.nodeName === "BUTTON") {
      id = e.target.parentNode.parentNode.id;
    } else {
      id = e.target.parentNode.id;
    }
    id = id.substring(id.lastIndexOf("-") + 1);
    closeAllDialogs();
    switch (id) {
      case "0": {
        setOpenStrokeColor(true);
        break;
      }
      case "1": {
        setOpenFontColor(true);
        break;
      }
      case "2": {
        setOpenFontWidth(true);
        break;
      }
      case "3": {
        setOpenFontDialog(true);
        break;
      }
      case "4": {
        setGraffitiOrientation(
          graffitiOrientation === "landscape" ? "portrait" : "landscape"
        );
        break;
      }
    }
  };

  const handleFontSize = (event: Event, newValue: number | number[]) => {
    setFontSize(newValue as number);
  };

  const handleStrokeSize = (event: Event, newValue: number | number[]) => {
    setStrokeSize(newValue as number);
  };

  let canvasContent;
  const saveGraffiti = () => {
    setOpenCreator(false);
    setShowPreloader(true);
    let element = document.getElementById("creatorRef");
    html2canvas(element).then((canvas) => {
      canvasContent = canvas;
      publishImage();
    });
  };

  const publishImage = async () => {
    try {
      let dataUrl = await canvasContent.toDataURL("image/jpeg");

      console.log("principal:: " + principal);
      
      if (isConnected && principal) {
        var principalObject = Principal.fromText(principal);

        let title = "";
        let success = await backend.addAvatar(
          principalObject,
          title,
          graffitiMessage,
          dataUrl
        );

        publishImageResultHandler(
          success,
          graffitiMessage,
          dataUrl,
          "Server error, try again later ..."
        );
      }
      return;
    } catch (e) {
      publishImageResultHandler(-1, "", "", e.message);
    }
  };

  const resizeCreator = () => {
    //dialogContentRef.current.style.padding = 0;
    let _creatorDialog = document.getElementById("creatorDialog");
    let _containerRef = document.getElementById("containerRef");
    let _creatorRef = document.getElementById("creatorRef");
    let _imageContainerRef = document.getElementById("imageContainerRef");
    let _imageRef = document.getElementById("imageRef");
    let _paragraphRef = document.getElementById("paragraphRef");
    let _swiperRef = document.getElementById("swiperRef");

    _creatorDialog.style.padding = "0";

    let height = _creatorDialog.offsetHeight;
    _containerRef.style.width = window.innerWidth + "px";
    _containerRef.style.height = height + "px";

    // @ts-ignore
    _creatorRef.style.height = _imageRef.offsetHeight + "px";

    _imageContainerRef.style.width = _imageRef.offsetWidth + "px";

    // @ts-ignore
    _imageContainerRef.style.height = height - _swiperRef.offsetHeight + "px";

    let _h = 0;
    try {
      _h = parseFloat(_imageContainerRef.style.height);
    } catch(e) {
      _h = parseFloat(
        _imageContainerRef.style.height.substring(0, _imageContainerRef.style.height.length -3));
    }
    if(_h < _imageRef.offsetHeight) {
      _creatorRef.style.height = _h + "px";
      _imageRef.style.height = _h + "px";
      _creatorRef.style.width = _imageRef.offsetWidth + "px";
      _imageContainerRef.style.width = _imageRef.offsetWidth + "px";
      _swiperRef.style.width = _imageRef.offsetWidth + "px";
    } else {
      _imageContainerRef.style.height = _imageRef.offsetHeight + "px";
    }
    
    _paragraphRef.style.width = _imageRef.offsetWidth + "px";
    //_paragraphRef.style.height = _imageRef.offsetHeight + "px";
    setShowPreloader(false);
  };
  useEffect(() => {
    if (creatorRefreshNotifier) {
      //setTimeout(() => {
        //resizeCreator();
      //}, 6000);
    }
  }, [creatorRefreshNotifier]);

  return (
    <>
      <Dialog
        fullScreen
        aria-labelledby="draggable-dialog-title"
        hideBackdrop
        open={openCreator}
      >
        <AppBar sx={{ position: "relative" }}>
          <Toolbar>
            <IconButton
              edge="start"
              color="inherit"
              onClick={handleCloseCreator}
              aria-label="close"
            >
              <CloseIcon />
            </IconButton>
            <Typography sx={{ ml: 2, flex: 1 }} variant="h6" component="div">
              New Graffiti
            </Typography>
            <Button autoFocus color="inherit" onClick={saveGraffiti}>
              Publish
            </Button>
          </Toolbar>
        </AppBar>
        <DialogContent
          ref={dialogContentRef}
          id="creatorDialog"
          style={{ margin: "0 auto" }}
        >
          <div
            id="containerRef"
            ref={containerRef}
            style={
              {
                //            width: 1960, height: 530
              }
            }
          >
            <div
              ref={imageContainerRef}
              id="imageContainerRef"
              style={{
                //                width: 713,
                //                height: 513,
                //border: "1px solid #777777",
                borderRadius: 3,
                background: "#f0f0f0",
                position: "relative",
                left: 0,
                margin: "0 auto",
              }}
            >
              <div
                id="creatorRef"
                ref={creatorRef}
                style={{
                  backgroundImage: `url(${thumbsSwiper})`,
                  width: graffitiOrientation === "landscape" ? "100%" : "50%",
                  left: graffitiOrientation === "landscape" ? "0" : "25%",
                  backgroundRepeat: "no-repeat",
                  backgroundSize:
                    graffitiOrientation === "landscape" ? "contain" : "cover",
                  backgroundPosition:
                    graffitiOrientation === "landscape" ? "0 0" : "50% 0",
                  margin: "auto auto",
                }}
              >
                <img
                  id="imageRef"
                  ref={imageRef}
                  src={thumbsSwiper}
                  style={{
                    maxWidth: "100%",
                    maxHeight: "100%",
                    display: "block",
                  }}
                  onLoad={resizeCreator}
                />

                <p
                  contentEditable
                  id="paragraphRef"
                  ref={paragraphRef}
                  style={{
                    fontFamily,
                    fontSize: fontSize + "px",
                    lineHeight: fontSize * 0.93 + "px",
                    color: fontColor,
                    textAlign: "center",
                    //                    width: 713,
                    position: "absolute",
                    margin: 0,
                    padding: '0 35px',
                    top: "50%",
                    left: "50%",
                    transform: "translate(-50%, -50%)",
                    WebkitTextStroke: strokeSize + "px " + textStrokeColor,
                  }}
                >
                  {graffitiMessage}
                </p>
              </div>
              <Box
                sx={{ height: 0, transform: "translateZ(0px)", flexGrow: 1 }}
              >
                <SpeedDial
                  ariaLabel="SpeedDial tooltip example"
                  sx={{ position: "absolute", bottom: 16, right: 16 }}
                  icon={<SpeedDialIcon fontSize="large" />}
                  onClose={handleCloseSpeedDial}
                  onOpen={handleOpenSpeedDial}
                  open={openSpeedDial}
                >
                  {actions.map((action) => (
                    <SpeedDialAction
                      key={action.name}
                      icon={action.icon}
                      tooltipTitle={action.name}
                      tooltipOpen
                      onClick={handleSpeedDialogSelected}
                    />
                  ))}
                </SpeedDial>
              </Box>
            </div>
            <Swiper
              id="swiperRef"
              onSwiper={setImageToCanvas}
              loop={true}
              spaceBetween={10}
              slidesPerView={5}
              freeMode={true}
              watchSlidesProgress={true}
              pagination={{
                type: "progressbar",
              }}
              navigation={true}
              modules={[Pagination, Navigation]}
              className="mySwiper"
              onTap={(swiperCore) => {
                const {
                  activeIndex,
                  snapIndex,
                  previousIndex,
                  realIndex,
                  clickedIndex,
                } = swiperCore;
                let url: string = backgrounds[clickedIndex];
                url = url.replace("_t", "");
                url = url.replace("/t/", "/");
                setThumbsSwiper(url);
                /*url = url.substring(url.lastIndexOf("-")+1);
        setThumbsSwiper(Number.parseInt(url)+1);*/
              }}
            >
              {backgrounds.map((bg, index) => (
                <SwiperSlide key={index}>
                  <img src={bg} key={index} />
                </SwiperSlide>
              ))}
            </Swiper>
          </div>
        </DialogContent>
      </Dialog>

      <DynamicDialog
        openDialog={openFontDialog}
        handleCloseDialog={handleCloseFontDialog}
      >
        <List dense={true}>
          {fonts.map((font, index) => (
            <ListItem
              key={index}
              style={{
                fontFamily: font + ", cursive",
              }}
              onClick={(e) => {
                // @ts-ignore
                setFontFamily(e.target.innerText);
              }}
            >
              {font}
            </ListItem>
          ))}
        </List>
      </DynamicDialog>
      <DynamicDialog
        openDialog={openFontColor}
        handleCloseDialog={handleCloseFontColor}
      >
        <SketchPicker
          color={fontColor}
          onChange={(color) => {
            setFontColor(color.hex);
          }}
        />
      </DynamicDialog>
      <DynamicDialog
        openDialog={openStrokeColor}
        handleCloseDialog={handleCloseStrokeColor}
      >
        <SketchPicker
          color={textStrokeColor}
          onChange={(color) => {
            setTextStrokeColor(color.hex);
          }}
        />
      </DynamicDialog>
      <DynamicDialog
        openDialog={openFontWidth}
        handleCloseDialog={handleCloseFontWidth}
      >
        <List dense={true}>
          <ListItem>
            <Box sx={{ width: 200 }}>
              <Stack
                spacing={2}
                direction="row"
                sx={{ mb: 1 }}
                alignItems="center"
              >
                <p>Font</p>
                <VolumeDown />
                <Slider
                  aria-label="Volume"
                  min={10}
                  max={200}
                  value={fontSize}
                  onChange={handleFontSize}
                />
                <VolumeUp />
              </Stack>
            </Box>
          </ListItem>

          <ListItem>
            <Box sx={{ width: 200 }}>
              <Stack
                spacing={2}
                direction="row"
                sx={{ mb: 1 }}
                alignItems="center"
              >
                <p>Outline</p>
                <VolumeDown />
                <Slider
                  aria-label="Volume"
                  min={0}
                  max={20}
                  value={strokeSize}
                  onChange={handleStrokeSize}
                />
                <VolumeUp />
              </Stack>
            </Box>
          </ListItem>
        </List>
      </DynamicDialog>
    </>
  );
}
