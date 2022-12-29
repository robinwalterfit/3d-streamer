/**
 * Cypress is a JavaScript end-to-end testing framework that runs in the browser.
 * With Cypress it's possible to make sure, that the website behaves as expected.
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @file This file is used to setup cypress.
 * @license SPDX-License-Identifier: MIT
 * @see {@link https://docs.cypress.io/guides/references/configuration}
 */

import { defineConfig } from "cypress"

export default defineConfig({
    e2e: {
        baseUrl: "http://localhost:8000",
        specPattern: "cypress/e2e",
    },
})
