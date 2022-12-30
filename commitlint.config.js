/**
 * Lint commit messages to prevent bad commits.
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @file This file is used to setup commitlint.
 * @license SPDX-License-Identifier: MIT
 * @see {@link https://commitlint.js.org/#/reference-configuration}
 */

module.exports = {
    extends: ["@commitlint/config-conventional"],
    rules: {
        "scope-enum": [
            2,
            "always",
            [
                "design",
                "devcontainer",
                "docker",
                "editor",
                "git",
                "github",
                "linter",
                "next",
                "react",
                "server",
                "website",
            ],
        ],
    },
}
