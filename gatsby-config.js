/**
 * gatsby-config.js
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @file This file is used to configure the gatsby app.
 * @license SPDX-License-Identifier: MIT
 * @see {@link https://www.gatsbyjs.com/docs/reference/config-files/gatsby-config/}
 */

require("dotenv").config({
    path: `.env.${process.env.NODE_ENV}.local`,
})
const pkg = require("./package.json")

module.exports = {
    plugins: [
        `gatsby-plugin-pnpm`,
        {
            options: {
                siteUrl: process.env.SITE_URL,
                stripQueryString: true,
            },
            resolve: `gatsby-plugin-canonical-urls`,
        },
        {
            options: {
                description: process.env.GATSBY_SITE_DESCRIPTION,
                language: `en`,
                metaTags: [{ content: `v${pkg.version}`, property: `version` }],
                openGraph: {
                    locale: `en_US`,
                    site_name: process.env.GATSBY_SITE_TITLE,
                    type: `website`,
                    url: process.env.SITE_URL,
                },
                titleTemplate: `%s | ${process.env.GATSBY_SITE_TITLE}`,
                twitter: {
                    cardType: `summary`,
                },
            },
            resolve: `gatsby-plugin-next-seo`,
        },
        `gatsby-plugin-emotion`,
        {
            options: {
                name: `images`,
                path: `${__dirname}/src/assets/images`,
            },
            resolve: `gatsby-source-filesystem`,
        },
        `gatsby-plugin-image`,
        {
            options: {
                defaults: {
                    avifOptions: {},
                    backgroundColor: `transparent`,
                    blurredOptions: {},
                    breakpoints: [640, 768, 1024, 1280, 1536],
                    formats: [`auto`, `webp`, `avif`],
                    jpgOptions: {},
                    placeholder: `dominantColor`,
                    pngOptions: {},
                    quality: 75,
                    tracedSVGOptions: {},
                    webpOptions: {},
                },
            },
            resolve: `gatsby-plugin-sharp`,
        },
        `gatsby-transformer-sharp`,
        {
            options: {
                background_color: process.env.SITE_BACKGROUND_COLOR,
                description: process.env.GATSBY_SITE_DESCRIPTION,
                display: `standalone`,
                icon: `src/assets/images/icon.png`, // This path is relative to the root of the site.
                lang: `en`,
                name: process.env.GATSBY_SITE_TITLE,
                short_name: process.env.GATSBY_SHORT_TITLE,
                start_url: `/`,
                theme_color: process.env.SITE_THEME_COLOR,
            },
            resolve: `gatsby-plugin-manifest`,
        },
    ],
    siteMetadata: {
        pkg: JSON.stringify(pkg),
        siteUrl: process.env.SITE_URL,
        title: process.env.GATSBY_SITE_TITLE,
    },
}
