module.exports = grammar({
  name: "gitlog",
  extras: ($) => [],
  // externals: ($) => [$.conventional_type, $.vim_patch_ref], // handed off to scanner.c
  rules: {
    source_file: ($) => repeat($.commit),
    commit: ($) => seq($.header, optional($.body)),

    header: ($) => seq($.sha, " ", alias(/[^\n]+\n/, $.message)),
    sha: () => /[a-f0-9]{7,40}/,
    // summary: ($) =>
    //   choice(
    //     seq($.conventional, " ", $.message),
    //     seq($.vim_patch, " ", $.message),
    //     $.message,
    //   ),
    // date_author: () => /\d+[dhms], [a-z0-9-]/,
    //
    // message: () => /[^\n|]+/,
    //
    // conventional: ($) =>
    //   seq(
    //     field("type", $.conventional_type),
    //     optional($.conventional_subtype),
    //     optional("!"),
    //     ":",
    //   ),
    // conventional_subtype: () => /\(\w+\)/,
    //
    // vim_patch: ($) => seq($.vim_patch_ref, ":"),

    body: ($) => repeat1($.body_line),
    body_line: ($) => seq(/ {8}/, $.content),
    content: () => seq(/[^\n]*/, "\n"),
  },
});
