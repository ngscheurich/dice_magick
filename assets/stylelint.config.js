module.exports = {
  extends: "stylelint-config-standard",
  rules: {
    "at-rule-no-unknown": [true, { ignoreAtRules: ["tailwind"] }],
    "selector-type-no-unknown": [true, { ignore: ["custom-elements"] }],
  },
};
