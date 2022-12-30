/**
 * This file provides the type definitions for the Layout component.
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @license SPDX-License-Identifier: MIT
 */

import { FunctionComponent } from "react"
import { InferProps } from "prop-types"

import propTypes from "./Layout.propTypes"

type LayoutProps = InferProps<typeof propTypes>

const Layout: FunctionComponent<LayoutProps>

export default Layout
