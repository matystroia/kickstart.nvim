module.exports = grammar({
  name: "difft",
  extras: ($) => [],
  externals: ($) => [$.code],
  rules: {
    source_file: ($) => repeat(seq($.change, /\n*/)),
    change: ($) => seq($.header, "\n", $.body),

    header: ($) =>
      seq($.filename, " --- ", optional(seq($.progress, " --- ")), $.language),
    filename: () => /[a-zA-Z0-9/_.\-]+/,
    progress: () => /\d+\/\d+/,
    language: () => /[A-Z][A-Za-z]*/,

    body: ($) => repeat1(seq($.line, "\n")),
    line: ($) => seq($.line_num, $.code),

    line_num: () => choice(/ *\d+ */, / *\.+ */),
    padding: () => / */,
  },
});
