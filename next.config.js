/**
 * Configuration for Next.js
 *
 * @author Robin Walter <hello@robinwalter.me>
 * @license SPDX-License-Identifier: MIT
 * @see {@link https://github.com/timlrx/tailwind-nextjs-starter-blog/blob/master/next.config.js}
 * @see {@link https://github.com/ben-rogerson/twin.examples/blob/master/next-emotion-typescript/next.config.js}
 */
// @ts-check

const withBundleAnalyzer = require("@next/bundle-analyzer")({
    enabled: process.env.ANALYZE === "true",
    openAnalyzer: false,
})
const withTwin = require("./withTwin")

// You might need to insert additional domains in script-src if you are using external services
const ContentSecurityPolicy = `
    default-src 'self';
    script-src 'self' 'unsafe-eval' 'unsafe-inline';
    style-src 'self' 'unsafe-inline';
    img-src 'self' blob: data:;
    media-src 'self' ${process.env.NEXT_PUBLIC_STREAM_HOST};
    connect-src *;
    font-src 'self';
`

const securityHeaders = [
    // https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
    {
        key: "Content-Security-Policy",
        value: ContentSecurityPolicy.replace(/\n/g, ""),
    },
    // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
    {
        key: "Referrer-Policy",
        value: "strict-origin-when-cross-origin",
    },
    // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
    {
        key: "X-Frame-Options",
        value: "DENY",
    },
    // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options
    {
        key: "X-Content-Type-Options",
        value: "nosniff",
    },
    // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-DNS-Prefetch-Control
    {
        key: "X-DNS-Prefetch-Control",
        value: "on",
    },
    // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security
    {
        key: "Strict-Transport-Security",
        value: "max-age=31536000; includeSubDomains",
    },
    // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Feature-Policy
    {
        key: "Permissions-Policy",
        value: "camera=(), microphone=(), geolocation=()",
    },
]

/** @type {import("next").NextConfig} */
const nextConfig = {
    compiler: {
        emotion: true,
    },
    async headers() {
        return [
            {
                source: "/(.*)",
                headers: securityHeaders,
            },
        ]
    },
    output: "standalone",
    pageExtensions: ["js", "jsx", "ts", "tsx"],
    reactStrictMode: true,
    webpack: (config, { dev, isServer }) => {
        config.module.rules.push({
            test: /\.svg$/,
            use: ["@svgr/webpack"],
        })

        if (!dev && !isServer) {
            // Replace React with Preact only in client production build
            Object.assign(config.resolve.alias, {
                "react/jsx-runtime.js": "preact/compat/jsx-runtime",
                react: "preact/compat",
                "react-dom/test-utils": "preact/test-utils",
                "react-dom": "preact/compat",
            })
        }

        // Use the client static directory in the server bundle and prod mode
        // Fixes `Error occurred prerendering page "/"`
        config.output.webassemblyModuleFilename =
            isServer && !dev ? "../static/wasm/[modulehash].wasm" : "static/wasm/[modulehash].wasm"

        // Since Webpack 5 doesn't enable WebAssembly by default, we should do it manually
        config.experiments = { ...config.experiments, asyncWebAssembly: true }

        return config
    },
}

module.exports = withBundleAnalyzer(withTwin(nextConfig))
