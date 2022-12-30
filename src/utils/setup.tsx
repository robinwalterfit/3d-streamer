/**
 * Add the global styles and the emotion cache to the app.
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @license SPDX-License-Identifier: MIT
 * @see {@link ../pages/_app.tsx}
 * @see {@link ../../cypress/support/component.js}
 */

import { CacheProvider } from "@emotion/react"
import chalk from "chalk"
import "@fontsource/aldrich"
import "@fontsource/fira-code"
import Head from "next/head"
import logging from "loglevel"
import moment from "moment"
import prefixer from "loglevel-plugin-prefix"
import type { AppProps } from "next/app"
import type { EmotionCache } from "@emotion/cache"

import createEmotionCache from "../utils/createEmotionCache"
import GlobalStyles from "../styles/GlobalStyles"
import Layout from "../components/Layout"

// Client-side cache, shared for the whole session of the user in the browser.
const clientSideEmotionCache = createEmotionCache()

type NewAppProps = AppProps & {
    emotionCache: EmotionCache
    skipLayout?: boolean
}

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

function setupLogger(): void {
    // Setup prefixer
    prefixer.reg(logging)

    // Set log level based on environment
    if (process.env.NODE_ENV === "development") {
        logging.enableAll()
    } else {
        logging.setLevel("WARN")
    }

    // Setup logger template
    prefixer.apply(logging, {
        template: `%t - %n - %l -`,
        levelFormatter(level) {
            const UPPER_CASE = level.toUpperCase()

            return colors[UPPER_CASE].bold(UPPER_CASE)
        },
        nameFormatter(name) {
            return name ? colors[name](name) : "3d-streamer"
        },
        timestampFormatter(date) {
            return chalk.gray(moment(date).format("YYYY-MM-DD HH:mm:ss,SSS"))
        },
    })
}

function setupMoment(): void {
    moment.locale("en")
}

export default function createApp(props: NewAppProps): JSX.Element {
    const { Component, emotionCache = clientSideEmotionCache, pageProps, skipLayout = false } = props

    setupLogger()
    setupMoment()

    return (
        <CacheProvider value={emotionCache}>
            <Head>
                <meta charSet="utf-8" />
                <meta httpEquiv="x-ua-compatible" content="ie=edge" />
                <meta content="width=device-width, initial-scale=1, shrink-to-fit=no" name="viewport" />
            </Head>
            <GlobalStyles />
            {skipLayout ? (
                <Component {...pageProps} />
            ) : (
                <Layout>
                    <Component {...pageProps} />
                </Layout>
            )}
        </CacheProvider>
    )
}
