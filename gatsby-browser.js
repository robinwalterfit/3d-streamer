/**
 * Implement Gatsby's Browser APIs in this file.
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @file This file is used to setup gatsby in the browser.
 * @license SPDX-License-Identifier: MIT
 * @see {@link https://www.gatsbyjs.com/docs/reference/config-files/gatsby-browser/}
 */

import chalk from "chalk"
import "@fontsource/fira-code"
import log from "loglevel"
import moment from "moment"
import prefixer from "loglevel-plugin-prefix"

// internal imports
import wrapper from "./src/wrapPageElement"

// Setup moment
moment.locale("en")

// Setup logger
const colors = {
    // log level specific colors
    TRACE: chalk.cyan,
    DEBUG: chalk.green,
    INFO: chalk.yellow,
    WARN: chalk.red,
    ERROR: chalk.redBright,
    // logger object specific colors
}

// Setup prefixer
prefixer.reg(log)

// Set log level based on environment
if (process.env.NODE_ENV === "development") {
    log.enableAll()
} else {
    log.setLevel("WARN")
}

// Setup logger template
prefixer.apply(log, {
    template: `%t - %n - %l -`,
    levelFormatter(level) {
        const UPPER_CASE = level.toUpperCase()

        return colors[UPPER_CASE].bold(UPPER_CASE)
    },
    nameFormatter(name) {
        return name ? colors[name](name) : "rw.me"
    },
    timestampFormatter(date) {
        return chalk.gray(moment(date).format("YYYY-MM-DD HH:mm:ss,SSS"))
    },
})

export const wrapPageElement = wrapper
