// @ts-ignore: Cannot find module error
import { Socket } from "phoenix";
// @ts-ignore: Cannot find module error
import LiveSocket from "phoenix_live_view";
import NProgress from "nprogress";

import "./color-picker.ts";
import "phoenix_html";

import "../css/app.css";

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

window.addEventListener("DOMContentLoaded", () => {
  const nodes = document.querySelectorAll('[data-behavior="close"]');
  nodes.forEach((node) =>
    node.addEventListener("click", ({ target }) =>
      (target as HTMLElement).parentElement!.remove()
    )
  );
});
