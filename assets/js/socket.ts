import { Socket } from "phoenix";

const socket = new Socket("/socket", { params: { token: window.userToken } });

socket.connect();

const channel = socket.channel("topic:subtopic", {});
channel
  .join()
  .receive("ok", (resp) => {
    console.log("Joined successfully", resp);
  })
  .receive("error", (resp) => {
    console.log("Unable to join", resp);
  });

export default socket;
