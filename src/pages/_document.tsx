/**
 * Add a custom Document to the app.
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @license SPDX-License-Identifier: MIT
 * @see {@link https://github.com/mui/material-ui/blob/master/examples/nextjs/pages/_document.js}
 * @see {@link https://github.com/ben-rogerson/twin.examples/blob/master/next-emotion-typescript/pages/_document.tsx}
 */

import createEmotionServer from "@emotion/server/create-instance"
import Document, { DocumentContext, DocumentInitialProps, Html, Head, Main, NextScript } from "next/document"
import type { AppProps } from "next/app"
import type { EmotionCache } from "@emotion/cache"

import createEmotionCache from "../utils/createEmotionCache"

type NewAppProps = AppProps & {
    emotionCache: EmotionCache
}

type NewDocumentInitialProps = DocumentInitialProps & {
    emotionStyleTags: JSX.Element[]
}

export default class Streamer3DDocument extends Document<NewDocumentInitialProps> {
    // `getInitialProps` belongs to `_document` (instead of `_app`),
    // it's compatible with static-site generation (SSG).
    static async getInitialProps(ctx: DocumentContext): Promise<NewDocumentInitialProps> {
        // Resolution order
        //
        // On the server:
        // 1. app.getInitialProps
        // 2. page.getInitialProps
        // 3. document.getInitialProps
        // 4. app.render
        // 5. page.render
        // 6. document.render
        //
        // On the server with error:
        // 1. document.getInitialProps
        // 2. app.render
        // 3. page.render
        // 4. document.render
        //
        // On the client
        // 1. app.getInitialProps
        // 2. page.getInitialProps
        // 3. app.render
        // 4. page.render

        const originalRenderPage = ctx.renderPage

        // You can consider sharing the same Emotion cache between all the SSR requests to speed up performance.
        // However, be aware that it can have global side effects.
        const cache = createEmotionCache()
        const { extractCriticalToChunks } = createEmotionServer(cache)

        ctx.renderPage = () =>
            originalRenderPage({
                enhanceApp: (App) =>
                    function EnhanceApp(props: NewAppProps) {
                        return <App emotionCache={cache} {...props} />
                    },
            })

        const initialProps = await Document.getInitialProps(ctx)
        // This is important. It prevents Emotion to render invalid HTML.
        // See https://github.com/mui/material-ui/issues/26561#issuecomment-855286153
        const emotionStyles = extractCriticalToChunks(initialProps.html)
        const emotionStyleTags = emotionStyles.styles.map((style) => (
            <style
                data-emotion={`${style.key} ${style.ids.join(" ")}`}
                key={style.key}
                // eslint-disable-next-line react/no-danger
                dangerouslySetInnerHTML={{ __html: style.css }}
            />
        ))

        return {
            ...initialProps,
            emotionStyleTags,
        }
    }

    render() {
        return (
            <Html lang="en">
                <Head>
                    {/* PWA primary color */}
                    <meta name="theme-color" content={process.env.SITE_THEME_COLOR} />
                    <meta name="emotion-insertion-point" content="" />
                    {this.props.emotionStyleTags}
                </Head>
                <body>
                    <Main />
                    <NextScript />
                </body>
            </Html>
        )
    }
}
