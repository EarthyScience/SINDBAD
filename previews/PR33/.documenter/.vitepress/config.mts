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
  { text: 'Sindbad', link: '/pages/code/overview' },
  { text: ' + Core', link: '/pages/code/sindbad' },
  { text: ' \u00A0\u00A0++ Models', link: '/pages/code/models' },
  { text: ' \u00A0\u00A0++ Types', link: '/pages/code/types' },
  { text: ' + Data', link: '/pages/code/data' },
  { text: ' + Experiment', link: '/pages/code/experiment' },
  { text: ' + Metrics', link: '/pages/code/metrics' },
  { text: ' + ML', link: '/pages/code/ml' },
  { text: ' + Optimization', link: '/pages/code/optimization' },
  { text: ' + Setup', link: '/pages/code/setup' },
  { text: ' + TEM', link: '/pages/code/tem' },
  { text: ' + Utils', link: '/pages/code/utils' },
  { text: ' + Visuals', link: '/pages/code/visuals' }
]

const codeGenItems = [
  { text: 'Sindbad', link: '/pages/code_gen/Sindbad' },
  { text: ' + Core', link: '/pages/code_gen/Sindbad' },
  { text: ' + Data', link: '/pages/code_gen/SindbadData' },
  { text: ' + Experiment', link: '/pages/code_gen/SindbadExperiment' },
  { text: ' + Metrics', link: '/pages/code_gen/SindbadMetrics' },
  { text: ' + ML', link: '/pages/code_gen/SindbadML' },
  { text: ' + Models', link: '/pages/code_gen/SindbadModels' },
  { text: ' + Optimization', link: '/pages/code_gen/SindbadOptimization' },
  { text: ' + Setup', link: '/pages/code_gen/SindbadSetup' },
  { text: ' + TEM', link: '/pages/code_gen/SindbadTEM' },
  { text: ' + Utils', link: '/pages/code_gen/SindbadUtils' },
  // { text: ' + Visuals', link: '/pages/code_gen/SindbadVisuals' }
]
const aboutItems = [
  { text: 'Contact', link: '/pages/about/contact' },
  { text: 'License', link: '/pages/about/license' },
  { text: 'Publications', link: '/pages/about/publications' },
  { text: 'Support', link: '/pages/about/support' },
  { text: 'Team', link: '/pages/about/team' },
]

const manualItems = [
  { text: 'Overview', link: '/pages/develop/overview' },
  { text: 'Install', link: '/pages/develop/install' },
  { text: 'Modeling Convention', link: '/pages/develop/conventions' },
  { text: 'Model/Approach', link: '/pages/develop/model_approach' },
  { text: 'Sindbad Types', link: '/pages/develop/sindbad_types' },
  { text: 'Array Handling', link: '/pages/develop/array_handling' },
  { text: 'Land Utils', link: '/pages/develop/land_utils' },
  { text: 'Experiments', link: '/pages/develop/experiments' },
  { text: 'Experiment Outputs', link: '/pages/develop/sindbad_outputs' },
  { text: 'Spinup', link: '/pages/develop/spinup' },
  { text: 'Hybrid ML', link: '/pages/develop/hybrid_modeling' },
  { text: 'Optimization Methods', link: '/pages/develop/optimization_method' },
  { text: 'Cost Metrics', link: '/pages/develop/cost_metrics' },
  { text: 'Cost Function', link: '/pages/develop/cost_function' },
  { text: 'Documentation', link: '/pages/develop/how_to_doc' },
  { text: 'Useful Helpers', link: '/pages/develop/helpers' },
]

const navTemp = {
  nav: [
    { text: 'Concept', items: conceptItems,
    },
    { text: 'Settings',  items: settingsItems, 
    },
    { text: 'Code', 
      items: codeItems,
    },
    // { text: 'CodeGen',
    //   items: codeGenItems,
    // },
    { text: 'Develop', items: manualItems,
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
    { text: 'Develop', items: manualItems,
  },
  { text: 'Settings',  items: settingsItems,
  },
  { text: 'Code',
    collapsed: true,
    items: codeItems
  },
  // { text: 'CodeGen',
  //   collapsed: true,
  //   items: codeGenItems
  // },
  { text: 'About',
    items: aboutItems
  },
]

export default defineConfig({
  base: '/',
  title: "SINDBAD",
  description: "A model-data integration framework for terrestrial ecosystem processes",
  lastUpdated: true,
  cleanUrls: false,
  ignoreDeadLinks: true,
  outDir: '../1',
  
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
    logo: { src: '/sindbad_logo.png', width: 24, height: 24 },
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
      message: '<a href="https://www.bgc-jena.mpg.de/en" target="_blank"><img src="/logo_mpi_grey.png" class="footer-logo" alt="MPI Logo"/></a>',
      copyright: '© Copyright 2025 <strong> SINDBAD Development Team</strong></span>'
    }
  }
})
