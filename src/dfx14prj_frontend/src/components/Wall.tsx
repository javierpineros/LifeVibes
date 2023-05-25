export default function Wall({ avatarList, handleAvatarView, getImage }) {
  return (
    <>
      {avatarList.map((card, index) => (
        <div
          key={index}
          onClick={() => {
            handleAvatarView(index);
          }}
        >
          {getImage("avaImg", card.id, index)}

          <img
            src={""}
            alt={card.title}
            className="graffiti-image"
            loading="lazy"
            id={"avaImg" + index}
            style={{
              height: "auto",
            }}
          />
          <div>@{card.ownerName} {parseInt(card.votes) == 0 ? "" :  " : " + parseInt(card.votes) + " likes" }</div>
        </div>
      ))}
    </>
  );
}
