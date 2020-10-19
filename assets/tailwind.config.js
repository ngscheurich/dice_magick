module.exports = {
  future: {
    // removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: [],
  theme: {
    extend: {
      fontFamily: {
        //{{{
        body: ["DM Mono", "monospace"],
        display: ["DM Serif Display", "serif"],
      }, //}}}
      colors: {
        slate: {
          100: "#767676",
          200: "#5f5f5f",
          300: "#484848",
          400: "#222222",
          500: "#1a1a1a",
          600: "#161616",
          700: "#121212",
          800: "#0e0e0e",
          900: "#080808",
        },
        cream: {
          100: "#fffcf4",
          200: "#fef7e8",
          300: "#fcf9f3",
          400: "#fbf7ef",
          500: "#faf7f0",
          600: "#f9f3e6",
          700: "#f7efde",
          800: "#f5ebd6",
          900: "#c4bcab",
        },
        primary: "#ca4548",
        primaryDk: "#8d3032",
        primaryLt: "#da7d7f",
      },
      borderWidth: {
        10: "10px",
        10: "10px",
      },
      backgroundOpacity: {
        2: "0.02",
        10: "0.1",
      },
      width: {
        72: "18rem",
      },
    },
  },
  variants: {},
  plugins: [],
};
