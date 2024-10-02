import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'
// import { OramaPlugin } from '@orama/plugin-vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: '/Sindbad/',
  title: "Sindbad.jl",
  description: "A model data integration framework",
  lastUpdated: true,
  cleanUrls: true,
  ignoreDeadLinks: true,
  
  markdown: {
    config(md) {
      md.use(tabsMarkdownPlugin)
    },
    theme: {
      light: "github-light",
      dark: "github-dark"}
  },
  // vite: {
  //   plugins: [OramaPlugin()]
  // },
  themeConfig: {
    outline: 'deep',
    // https://vitepress.dev/reference/default-theme-config
        // https://vitepress.dev/reference/default-theme-config
    logo: { src: '/logo.png', width: 24, height: 24 },
    search: {
          provider: 'local',
          options: {
            detailedView: true
          }
        },
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Modelling Design', link: '/modelling_design' },
      { text: 'Models', link: '/models' },
      { text: 'TEM', link: '/TEM' },
      { text: 'Optimize', link: '/Optimize' },
      { text: 'Hybrid', link: '/Hybrid' }
    ],

    sidebar: [
      {
        text: 'Examples',
        items: [
          { text: 'Installation', link: '/install' },
          { text: 'Modelling Design', link: '/modelling_design' },
          { text: 'Models', link: '/models' },
          { text: 'Cost Metrics', link: '/costMetrics' },
          { text: 'How to document', link: '/how_to_doc' },
          { text: 'API models', link: '/api_models' }
        ]
      }
    ],

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
