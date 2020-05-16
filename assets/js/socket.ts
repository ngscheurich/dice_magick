// @ts-ignore: Cannot find module error
import { Socket } from "phoenix";

const socket = new Socket("/socket", { params: { token: window.userToken } });

socket.connect();

const channel = socket.channel("topic:subtopic", {});
channel
  .join()
  .receive("ok", (resp: any) => {
    console.log("Joined successfully", resp);
  })
  .receive("error", (resp: any) => {
    console.log("Unable to join", resp);
  });

export default socket;
