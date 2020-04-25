import { Socket } from "phoenix";
import LiveSocket from "phoenix_live_view";
import NProgress from "nprogress";

import "../css/app.css";
import "phoenix_html";

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } });

liveSocket.connect();

window.liveSocket = liveSocket;

window.addEventListener("phx:page-loading-start", () => NProgress.start());
window.addEventListener("phx:page-loading-stop", () => NProgress.done());
