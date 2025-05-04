import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'
import path from 'path'

// https://vitepress.dev/reference/site-config

const conceptItems = [
  { text: 'SINDBAD', link: '/pages/concept/overview' },
  { text: 'Experiment', link: '/pages/concept/experiment' },
  { text: 'TEM', link: '/pages/concept/TEM' },
  { text: 'info', link: '/pages/concept/info' },
  { text: 'land', link: '/pages/concept/land' },
]

const settingsItems = [
  { text: 'Overview', link: '/pages/settings/overview' },
  { text: 'Experiments', link: '/pages/settings/experiment' },
  { text: 'Forcing', link: '/pages/settings/forcing' },
  { text: 'Models', link: '/pages/settings/model_structure' },
  { text: 'Optimization', link: '/pages/settings/optimization' },
  { text: 'Parameters', link: '/pages/settings/parameters' },
]

const codeItems = [
  { text: 'Sindbad', link: '/pages/code/sindbad' },
  { text: ' + Data', link: '/pages/code/data' },
  { text: ' + Experiment', link: '/pages/code/experiment' },
  { text: ' + Metrics', link: '/pages/code/metrics' },
  { text: ' + ML', link: '/pages/code/ml' },
  { text: ' + Models', link: '/pages/code/models' },
  { text: ' + Optimization', link: '/pages/code/optimization' },
  { text: ' + Setup', link: '/pages/code/setup' },
  { text: ' + TEM', link: '/pages/code/tem' },
  { text: ' + Utils', link: '/pages/code/utils' },
  { text: ' + Visuals', link: '/pages/code/visuals' }
]
const aboutItems = [
  { text: 'Contact', link: '/pages/about/contact' },
  { text: 'License', link: '/pages/about/license' },
  { text: 'Publications', link: '/pages/about/publications' },
  { text: 'Support', link: '/pages/about/support' },
  { text: 'Team', link: '/pages/about/team' },
]

const manualItems = [
  { text: 'Overview', link: '/pages/manual/overview' },
  { text: 'Install', link: '/pages/manual/install' },
  { text: 'Modeling Convention', link: '/pages/manual/conventions' },
  { text: 'Model Approach', link: '/pages/manual/model_approach' },
  { text: 'Array Handling', link: '/pages/manual/array_handling' },
  { text: 'Land Utils', link: '/pages/manual/land_utils' },
  { text: 'Experiments', link: '/pages/manual/experiments' },
  { text: 'Spinup', link: '/pages/manual/spinup' },
  { text: 'Optimization Methods', link: '/pages/manual/optimization_method' },
  { text: 'Cost Metrics', link: '/pages/manual/cost_metrics' },
  { text: 'Cost Function', link: '/pages/manual/cost_function' },
  { text: 'Documentation', link: '/pages/manual/how_to_doc' },
]

const navTemp = {
  nav: [
    { text: 'Concept', items: conceptItems,
    },
    { text: 'Manual', items: manualItems,
    },
    { text: 'Settings',  items: settingsItems, 
    },
   { text: 'Code', 
      items: codeItems,
    },
    { text: 'About', 
      items: aboutItems
    },
  ],
}

const nav = [
  ...navTemp.nav,
  {
    component: 'VersionPicker',
  }
]

const sidebar = [
  { text: 'Concept', items: conceptItems,
  },
    { text: 'Manual', items: manualItems,
  },
  { text: 'Settings',  items: settingsItems,
  },
  { text: 'Code',
    collapsed: true,
    items: codeItems
  },
  { text: 'About',
    items: aboutItems
  },
]

export default defineConfig({
  base: '/Sindbad/',
  title: "SINDBAD",
  description: "A model data integration framework",
  lastUpdated: true,
  cleanUrls: true,
  ignoreDeadLinks: true,
  outDir: 'REPLACE_ME_DOCUMENTER_VITEPRESS',
  
  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
  ],
  
  vite: {
    resolve: {
      alias: {
        '@': path.resolve(__dirname, '../components')
      }
    },
    build: {
      assetsInlineLimit: 0, // so we can tell whether we have created inlined images or not, we don't let vite inline them
    },
    optimizeDeps: {
      exclude: [ 
        '@nolebase/vitepress-plugin-enhanced-readabilities/client',
        'vitepress',
        '@nolebase/ui',
      ], 
    }, 
    ssr: { 
      noExternal: [ 
        // If there are other packages that need to be processed by Vite, you can add them here.
        '@nolebase/vitepress-plugin-enhanced-readabilities',
        '@nolebase/ui',
      ], 
    },
  },

  markdown: {
    config(md) {
      md.use(tabsMarkdownPlugin)
    },
    theme: {
      light: "github-light",
      dark: "github-dark"}
  },

  themeConfig: {
    outline: 'deep',
    logo: { src: '/logo.png', width: 24, height: 24 },
    search: {
          provider: 'local',
          options: {
            detailedView: true
          }
        },

    nav: nav,
    sidebar: sidebar,
    socialLinks: [
      {
        icon: "github",
        link: 'https://github.com/EarthyScience/SINDBAD',
        // You can include a custom label for accessibility too (optional but recommended):
        ariaLabel: 'repo address'
      },
    ],
    footer: {
      message: '<a href="https://www.bgc-jena.mpg.de/en" target="_blank"><img src="logo_mpi_grey.png" class="footer-logo" alt="MPI Logo"/></a>',
      copyright: '<span>Powered by the <a href="https://julialang.org" target="_blank">Julia Programming Language</a></span><span>© Copyright 2023 <strong>SINDBAD Development Team</strong></span>'
    }
  }
})
