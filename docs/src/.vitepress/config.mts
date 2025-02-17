import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'

// https://vitepress.dev/reference/site-config

const navTemp = {
  nav: [
    { text: 'Home', link: '/' },
    { text: 'Manual', items: [
      { text: 'Installation', link: '/manual/install' },
      { text: 'Modelling Design', link: '/manual/modelling_design' },
      { text: 'TEM', link: '/manual/TEM' },
      { text: 'Optimization', link: '/manual/optimization' },
      { text: 'ML', link: '/manual/ml' }]
    },
    { text: 'Set settings',  items: [
      { text: 'model_structure', link: '/settings/model_structure' },
      { text: 'experiment', link: '/settings/experiment' },
      { text: 'forcing', link: '/settings/forcing' },
      { text: 'optimization', link: '/settings/optimization' },
    ] 
    },
    { text: 'API Reference', 
      items: [
        { text: 'Sindbad', link: '/api/sindbad' },
        { text: 'Models', link: '/api/models' },
        { text: 'Data', link: '/api/data' },
        { text: 'Experiment', link: '/api/experiment' },
        { text: 'Metrics', link: '/api/metrics' },
        { text: 'ML', link: '/api/ml' },
        { text: 'Optimization', link: '/api/optimization' },
        { text: 'Setup', link: '/api/setup' },
        { text: 'TEM', link: '/api/tem' },
        { text: 'Utils', link: '/api/utils' },
        { text: 'Visuals', link: '/api/visuals' }
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
  { text: 'Manual', items: [
    { text: 'Installation', link: '/manual/install' },
    { text: 'Modelling Design', link: '/manual/modelling_design' },
    { text: 'TEM', link: '/manual/TEM' },
    { text: 'Optimization', link: '/manual/optimization' },
    { text: 'ML', link: '/manual/ml' }]
  },
  { text: 'Set settings',  items: [
    { text: 'model_structure', link: '/settings/model_structure' },
    { text: 'experiment', link: '/settings/experiment' },
    { text: 'forcing', link: '/settings/forcing' },
    { text: 'optimization', link: '/settings/optimization' },
  ] 
  },
  { text: 'API Reference',
    collapsed: false,
    items: [
      { text: 'Public',
        collapsed: true,
        items: [
          { text: 'Sindbad', link: '/api/sindbad' },
          { text: 'Models', link: '/api/models' },
          { text: 'Data', link: '/api/data' },
          { text: 'Experiment', link: '/api/experiment' },
          { text: 'Metrics', link: '/api/metrics' },
          { text: 'ML', link: '/api/ml' },
          { text: 'Optimization', link: '/api/optimization' },
          { text: 'Setup', link: '/api/setup' },
          { text: 'TEM', link: '/api/tem' },
          { text: 'Utils', link: '/api/utils' },
          { text: 'Visuals', link: '/api/visuals' }
        ]
      },
      { text: 'Internal',
        collapsed: true,
        items: [
          { text: 'Sindbad', link: '/api/sindbad_internal' },
          { text: 'Models', link: '/api/models_internal' },
          { text: 'Data', link: '/api/data_internal' },
          { text: 'Experiment', link: '/api/experiment_internal' },
          { text: 'Metrics', link: '/api/metrics_internal' },
          { text: 'ML', link: '/api/ml_internal' },
          { text: 'Optimization', link: '/api/optimization_internal' },
          { text: 'Setup', link: '/api/setup_internal' },
          { text: 'TEM', link: '/api/tem_internal' },
          { text: 'Utils', link: '/api/utils_internal' },
          { text: 'Visuals', link: '/api/visuals_internal' }
        ]
      },

    ],
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
