/**
 * Implement Gatsby's SSR (Server Side Rendering) APIs in this file.
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @file This file is used to setup gatsby SSR.
 * @license SPDX-License-Identifier: MIT
 * @see {@link https://www.gatsbyjs.com/docs/reference/config-files/gatsby-ssr/}
 */

import wrapper from "./src/wrapPageElement"

export const wrapPageElement = wrapper
