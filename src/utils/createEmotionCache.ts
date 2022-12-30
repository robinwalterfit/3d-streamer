/**
 * Create an Emotion cache instance.
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @license SPDX-License-Identifier: MIT
 * @see {@link https://github.com/mui/material-ui/blob/master/examples/nextjs/src/createEmotionCache.js}
 */

import createCache, { EmotionCache } from "@emotion/cache"

const isBrowser = typeof document !== "undefined"

// On the client side, Create a meta tag at the top of the <head> and set it as insertionPoint.
// This assures that MUI styles are loaded first.
// It allows developers to easily override MUI styles with other styling solutions, like CSS modules.
export default function createEmotionCache(): EmotionCache {
    let insertionPoint: any

    if (isBrowser) {
        const emotionInsertionPoint = document.querySelector('meta[name="emotion-insertion-point"]')
        insertionPoint = emotionInsertionPoint ?? undefined
    }

    return createCache({ key: "3d-streamer-next", insertionPoint })
}
