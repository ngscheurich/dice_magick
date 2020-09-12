// @ts-ignore: Cannot find module error
import Pickr from "@simonwep/pickr";
import "@simonwep/pickr/dist/themes/nano.min.css";

interface PickrColor {
  toHEXA: () => string;
}

const pickr = Pickr.create({
  el: "#color-picker",
  theme: "nano",
  showAlways: true,
  components: {
    preview: true,
    hue: true,
  },
});

pickr.on("change", (color: PickrColor) => changePrimaryColor(color.toHEXA()));

function changePrimaryColor(color: string) {
  const el = document.querySelector("#primary-color");
  const style = el ? el : document.createElement("style");
  if (!el) {
    style.id = "primary-color";
    document.body.appendChild(style);
  }
  style.textContent = ` :root { --primary: ${color} }`;
}
