/**
 * Add Environment Variables namespace to the global scope.
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @license SPDX-License-Identifier: MIT
 */

declare namespace NodeJS {
    export interface ProcessEnv {
        readonly NEXT_PUBLIC_SHORT_TITLE: string
        readonly NEXT_PUBLIC_SITE_DESCRIPTION: string
        readonly NEXT_PUBLIC_SITE_TITLE: string
        readonly SITE_BACKGROUND_COLOR: string
        readonly SITE_THEME_COLOR: string
    }
}
