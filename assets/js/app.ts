import { Socket } from "phoenix";
// @ts-ignore: Cannot find module error
import LiveSocket from "phoenix_live_view";
import NProgress from "nprogress";

import "../css/app.css";
import "phoenix_html";

declare global {
  interface Window {
    liveSocket: Socket;
    userToken: string;
  }
}

const csrfTag = document.querySelector("meta[name='csrf-token']");
const csrfToken = csrfTag ? csrfTag.getAttribute("content") : null;

const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
});
liveSocket.connect();

window.liveSocket = liveSocket;

window.addEventListener("phx:page-loading-start", () => NProgress.start());
window.addEventListener("phx:page-loading-stop", () => NProgress.done());
