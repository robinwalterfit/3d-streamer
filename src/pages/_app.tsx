/**
 * Add the global styles and the emotion cache to the app.
 * The files logic was outsourced to the utils/setup.tsx file to re-use it in
 * Cypress.
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @license SPDX-License-Identifier: MIT
 * @see {@link ../utils/setup.tsx}
 */

import type { AppProps } from "next/app"
import type { EmotionCache } from "@emotion/cache"

import createApp from "../utils/setup"

type NewAppProps = AppProps & {
    emotionCache: EmotionCache
}

const App = (props: NewAppProps) => createApp(props)

export default App
