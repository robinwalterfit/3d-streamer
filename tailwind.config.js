const defaultTheme = require("tailwindcss/defaultTheme")

/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
        "./src/components/**/*.{js,jsx,ts,tsx}",
        "./src/pages/**/*.{js,jsx,ts,tsx}",
    ],
    theme: {
        extend: {
            fontFamily: {
                mono: ["Fira Code", ...defaultTheme.fontFamily.mono],
                sans: ["Aldrich", ...defaultTheme.fontFamily.sans],
            },
        },
    },
    plugins: [],
}
