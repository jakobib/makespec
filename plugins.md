Makespec makes use of several plugins of Pandoc Markdown syntax.

### Include plugin

One can include markdown files with the following syntax:

    `filename.md`{.include}

The inclusion statement should be placed on the begin of a single line. By now,
inclusion is implemented on syntax level. A later version of this plugin will
act on the abstract syntax tree.

To include a file as code block use the following syntax:

    `filename.json`{.include .codeblock .json}

