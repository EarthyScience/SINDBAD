import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'

// https://vitepress.dev/reference/site-config

const conceptItems = [
  { text: 'SINDBAD', link: '/pages/concept/overview' },
  { text: 'info', link: '/pages/concept/info' },
  { text: 'land', link: '/pages/concept/land' },
  { text: 'TEM', link: '/pages/concept/TEM' },
  { text: 'Experiment', link: '/pages/concept/experiment' }]

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
  { text: 'License', link: '.' },
  { text: 'Publications', link: '/pages/about/publications' },
  { text: 'Support', link: '/pages/about/support' },
  { text: 'Team', link: '/pages/about/team' },
]

const manualItems = [
  { text: 'Install', link: '/pages/manual/install' },
  { text: 'Coding Guide', link: '/pages/manual/conventions' },
  { text: 'Examples', link: '.' },
  { text: 'Workflows', link: '/pages/manual/modelling_design' },
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
        icon: {
          svg: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><rect width="512" height="512" rx="15%" fill="#30353e"/><path fill="#e24329" d="M84 215l43-133c2-7 12-7 14 0l115 353L371 82c2-7 12-7 14 0l43 133"/><path fill="#fc6d26" d="M256 435L84 215h100.4zm71.7-220H428L256 435l71.6-220z"/><path fill="#fca326" d="M84 215l-22 67c-2 6 0 13 6 16l188 137zm344 0l22 67c2 6 0 13-6 16L256 435z"/></svg>'
        },
        link: 'https://git.bgc-jena.mpg.de/sindbad/sindbad.jl',
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
