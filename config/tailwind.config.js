const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/components/*.{erb,haml,html,slim,rb}',
    './app/lib/form_builders/*.rb'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Fira Sans', ...defaultTheme.fontFamily.sans],
        display: ['Merriweather', ...defaultTheme.fontFamily.serif]
      },
      backgroundImage: {
        'header-pattern': "url('header-pattern.svg')",
        'oaf-logo': "url('oaf-logo-white')"
      },
      listStyleImage: {
        dash: "url('dash.svg')"
      },
      typography: (theme) => ({
        'xl': {
          css: {
            color: theme('colors.navy'),
            // Because the default was too big
            lineHeight: '1.75rem'
          }
        },
        '2xl': {
          css: {
            color: theme('colors.navy'),
            // Because the default was too big
            lineHeight: '2rem'
          }
        }
      }),
      screens: {
        // Overriding the default so that the xl breakpoint occurs at exactly where
        // the main content area is at it's maximum width
        'xl': '1152px'
      }
    },
    colors: {
      'transparent': 'transparent',
      'current': 'currentColor',
      'white': '#ffffff',
      'off-white': "#eeeeee",
      'light-grey': '#F3F2F2',
      'fuchsia': '#CA3F94',
      'fuchsia-darker': '#A6156F',
      'lavender': '#826D9C',
      'light-lavender': '#A38FBD',
      'yellow': '#F4BE53',
      'sun-yellow': '#FFDC3E',
      'orange': '#BB5C03',
      'header-orange': '#D37708',
      'navy': '#414860',
      'dark-navy': '#060F2F',
      'green': '#03827A',
      'dark-green': '#054E4A',
      'darker-orange': '#BA671D',
      'warm-grey': '#767676',
      'dark-warm-grey': '#434343',
      'cool-blue-gray': '#737A92',
      'dark-brown': '#3F1E1E',
      // This is only used for the background of the email preview I think
      // TODO: Use another gray
      'random-gray': '#ECEBE5',
      // TODO: Come up with a less bad name than this
      'light-grey2': '#D2CDC1',
      // A green colour that you might see on a map. Display this while loading the map
      // Note that we're using the same colour when initialising the google map so that
      // everything matches
      'google-maps-green': '#d1e6d9',
      'error-red': '#B90000'
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
