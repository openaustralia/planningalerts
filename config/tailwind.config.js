const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/themes/tailwind/views/**/*.{erb,haml,html,slim}',
    './app/components/tailwind/*.{erb,haml,html,slim}',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Fira Sans', ...defaultTheme.fontFamily.sans],
        display: ['Playfair Display'],
        logo: ['Inter var']
      },
      backgroundImage: {
        'header-pattern': "url('tailwind/header-pattern.svg')",
        'oaf-logo': "url('tailwind/oaf-logo-white')"
      }
    },
    colors: {
      'transparent': 'transparent',
      'current': 'currentColor',
      'white': '#ffffff',
      'off-white': "#eeeeee",
      'light-grey': '#F3F2F2',
      'fuchsia': '#CD4A9A',
      'lavender': '#9786AD',
      'yellow': '#F4BE53',
      'orange': '#E98E07',
      'navy': '#414860',
      'green': '#038A81',
      'darker-orange': '#BA671D',
    }
},
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
