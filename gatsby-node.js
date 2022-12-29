/**
 * Implement Gatsby's Node APIs in this file.
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @file This file is used to setup gatsby in node.
 * @license SPDX-License-Identifier: MIT
 * @see {@link https://www.gatsbyjs.com/docs/reference/config-files/gatsby-node/}
 */

const fs = require("fs-extra")
const path = require("path")

// Add .htaccess files for cache optimization after the build was finished
exports.onPostBuild = async ({ reporter }) => {
    // Start a timer for the post build process
    const activity = reporter.activityTimer("Post build work")
    activity.start()

    activity.setStatus("Start copying .htaccess files for cache optimization")
    // /page-data
    try {
        let htaccess = path.resolve("./src/utils/.htaccess-page-data")
        let publicDir = path.resolve(
            __dirname,
            "public",
            "page-data",
            ".htaccess"
        )
        fs.copySync(htaccess, publicDir)
    } catch (err) {
        reporter.panicOnBuild(
            "Couldn't copy the necessary .htaccess file for cache optimization (page-data)"
        )
    }
    // /static
    try {
        let htaccess = path.resolve("./src/utils/.htaccess-static")
        let publicDir = path.resolve(__dirname, "public", "static", ".htaccess")
        fs.copySync(htaccess, publicDir)
    } catch (err) {
        reporter.panicOnBuild(
            "Couldn't copy the necessary .htaccess file for cache optimization (static)"
        )
    }
    activity.setStatus("Copied .htaccess files for cache optimization")

    activity.end()
}
