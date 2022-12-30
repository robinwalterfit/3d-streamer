/**
 * @see {@link https://github.com/ben-rogerson/twin.examples/blob/master/next-emotion-typescript/withTwin.js}
 */

const path = require("path")

// The folders containing files importing twin.macro
const includedDirs = [
    path.resolve(__dirname, "src", "components"),
    path.resolve(__dirname, "src", "pages"),
    path.resolve(__dirname, "src", "styles"),
    path.resolve(__dirname, "src", "utils"),
]

module.exports = function withTwin(nextConfig) {
    return {
        ...nextConfig,
        webpack(config, options) {
            const { dev, isServer } = options
            config.module = config.module || {}
            config.module.rules = config.module.rules || []
            config.module.rules.push({
                include: includedDirs,
                test: /\.(js|jsx)$/,
                use: [
                    options.defaultLoaders.babel,
                    {
                        loader: "babel-loader",
                        options: {
                            plugins: [require.resolve("babel-plugin-macros"), require.resolve("@emotion/babel-plugin")],
                            presets: [
                                ["@babel/preset-react", { runtime: "automatic", importSource: "@emotion/react" }],
                            ],
                            sourceMaps: dev,
                        },
                    },
                ],
            })
            config.module.rules.push({
                include: includedDirs,
                test: /\.(ts|tsx)$/,
                use: [
                    options.defaultLoaders.babel,
                    {
                        loader: "babel-loader",
                        options: {
                            plugins: [
                                require.resolve("babel-plugin-macros"),
                                require.resolve("@emotion/babel-plugin"),
                                [require.resolve("@babel/plugin-syntax-typescript"), { isTSX: true }],
                            ],
                            presets: [
                                ["@babel/preset-react", { runtime: "automatic", importSource: "@emotion/react" }],
                            ],
                            sourceMaps: dev,
                        },
                    },
                ],
            })

            if (!isServer) {
                config.resolve.fallback = {
                    ...(config.resolve.fallback || {}),
                    fs: false,
                    module: false,
                    path: false,
                    os: false,
                    crypto: false,
                }
            }

            if (typeof nextConfig.webpack === "function") {
                return nextConfig.webpack(config, options)
            } else {
                return config
            }
        },
    }
}
