/**
 * Test the accessibility of the website
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @license SPDX-License-Identifier: MIT
 */

/// <reference types="Cypress" />

describe("Accessibility tests", () => {
    beforeEach(() => {
        cy.visit("/").get("main")
        cy.injectAxe()
    })

    it("Has no detectable accessibility violations on load", () => {
        cy.checkA11y()
    })
})
