const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/themes/tailwind/views/**/*.{erb,haml,html,slim}',
    './app/components/tailwind/*.{erb,haml,html,slim,rb}',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Fira Sans', ...defaultTheme.fontFamily.sans],
        display: ['Merriweather'],
        logo: ['Inter']
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
      'fuchsia': '#CA3F94',
      'lavender': '#826D9C',
      'yellow': '#F4BE53',
      'orange': '#D37708',
      'navy': '#414860',
      'green': '#03827A',
      'darker-orange': '#BA671D',
      'warm-grey': '#767676',
      // TODO: Come up with a less bad name than this
      'light-grey2': '#D2CDC1'
    }
},
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
