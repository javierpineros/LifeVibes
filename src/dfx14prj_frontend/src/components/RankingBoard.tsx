import { Grid, Typography } from "@mui/material";
import PrizeIcon from "@mui/icons-material/EmojiEvents";
import { orange } from "@mui/material/colors";

export default function RangingBoard({
  rankingList,
  handleAvatarView,
  getImage,
}) {
  return (
    <>
      {rankingList && rankingList.length > 0 ? (
        <Typography
          component="h2"
          variant="h5"
          align="center"
          color="text.secondary"
          paragraph
        >
          Top 10
        </Typography>
      ) : null}

      {rankingList.map((card, index) => (
        <Grid
          container
          spacing={1}
          style={{
            border: "1px solid #f0f0f0",
            borderRadius: 3,
            backgroundColor: "#efefef",
            margin: "3px 0",
          }}
          key={"gcr" + index}
        >
          <Grid
            item
            xs={4}
            sm={4}
            md={4}
            lg={4}
            key={"gir" + index}
            onClick={() => {
              handleAvatarView(index);
            }}
          >
            {getImage("ir", card.id, index)}
            <img
              id={"ir" + index}
              key={"ir" + index}
              className="graffiti-image"
              src={card.image}
              alt={card.title}
              loading="lazy"
              style={{
                width: "100%",
                height: "auto",
              }}
            />
          </Grid>
          <Grid
            item
            xs={8}
            sm={8}
            md={8}
            lg={8}
            key={index}
            onClick={() => {
              handleAvatarView(index);
            }}
            style={{ paddingRight: 7 }}
          >
            <Typography variant="caption" align="left">
              {index + 1}. @{card.ownerName} <br />{" "}
              <PrizeIcon style={{ color: orange[600], height: 13 }} />
              {parseInt(card.votes)} MotoCoins
            </Typography>
          </Grid>
        </Grid>
      ))}
    </>
  );
}
