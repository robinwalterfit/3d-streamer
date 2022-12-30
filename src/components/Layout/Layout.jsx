/**
 * This file is provides an overall layout for the website.
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @license SPDX-License-Identifier: MIT
 */

import propTypes from "./Layout.propTypes"

/**
 * This component provides the overal layout for the site.
 *
 * @param {*} props The component props.
 * @returns {JSX.Element} The Layout component.
 */
const Layout = (props) => {
    return (
        <>
            <div>{props.children}</div>
        </>
    )
}

Layout.propTypes = propTypes

export default Layout
