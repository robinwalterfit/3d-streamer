/**
 * Provide a consistent default style in in all browsers provided by tailwindcss.
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @license SPDX-License-Identifier: MIT
 */

import { css, Global } from "@emotion/react"
// eslint-disable-next-line import/no-extraneous-dependencies
import { GlobalStyles as BaseStyles } from "twin.macro"

const customStyles = css({})

const GlobalStyles = () => (
    <>
        <BaseStyles />
        <Global styles={customStyles} />
    </>
)

export default GlobalStyles
