import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'

// https://vitepress.dev/reference/site-config

const navTemp = {
  nav: [
    { text: 'Home', link: '/' },
    { text: 'Manual', items: [
      { text: 'Installation', link: '/install' },
      { text: 'Modelling Design', link: '/modelling_design' },
      { text: 'TEM', link: '/TEM' },
      { text: 'Optimization', link: '.' },
      { text: 'ML', link: '.' }]
    },
    { text: 'Set settings',  items: [
      { text: 'model_structure', link: '.' },
      { text: 'experiment', link: '.' },
      { text: 'forcing', link: '.' },
      { text: 'optimization', link: '.' },
    ] 
    },
    { text: 'Code', 
      items: [
        { text: 'Sindbad', link: '/models' },
        { text: 'Data', link: '.' },
        { text: 'Experiment', link: '.' },
        { text: 'Metrics', link: '.' },
        { text: 'ML', link: '.' },
        { text: 'Optmization', link: '.' },
        { text: 'Setup', link: '.' },
        { text: 'TEM', link: '.' },
        { text: 'Utils', link: '.' },
        // { text: 'Visuals', link: '.' }
      ]
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
  { text: 'Get Started', items: [
    { text: 'Installation', link: '/install' },
    { text: 'Modelling Design', link: '/modelling_design' },
    { text: 'TEM', link: '/TEM' },
    { text: 'Optimization', link: '.' },
    { text: 'ML', link: '.' }]
  },
  { text: 'API',
    collapsed: true, 
    items: [
      { text: 'Sindbad', link: '/models' },
      { text: 'Data', link: '.' },
      { text: 'Experiment', link: '.' },
      { text: 'Metrics', link: '.' },
      { text: 'ML', link: '.' },
      { text: 'Optmization', link: '.' },
      { text: 'Setup', link: '.' },
      { text: 'TEM', link: '.' },
      { text: 'Utils', link: '.' },
      // { text: 'Visuals', link: '.' }
    ]
  },
]

export default defineConfig({
  base: '/Sindbad/',
  title: "SINDBAD",
  description: "A model data integration framework",
  lastUpdated: true,
  cleanUrls: true,
  ignoreDeadLinks: true,
  
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
      copyright: '<span>Powered by the <a href="https://julialang.org" target="_blank">Julia Programming Language</a></span><span>© Copyright 2023 <strong>Pirates</strong></span>'
    }
  }
})
