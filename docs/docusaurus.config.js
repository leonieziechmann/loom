// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@ts-check`).
// There are various equivalent ways to declare your Docusaurus config.
// See: https://docusaurus.io/docs/api/docusaurus-config

import {themes as prismThemes} from 'prism-react-renderer';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Loom Documentation',
  tagline: 'Reactive Documents for Typst',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  // Set the production url of your site here
  url: 'https://leonieziechmann.github.io',
  baseUrl: '/loom/',

  // GitHub pages deployment config.
  organizationName: 'leonieziechmann',
  projectName: 'loom',

  onBrokenLinks: 'throw',
  onBrokenAnchors: 'ignore',
  trailingSlash: false,
  deploymentBranch: 'gh-pages',

  markdown: {
    mermaid: true,
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    }
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          routeBasePath: "/",
          sidebarPath: './sidebars.js',
          editUrl: 'https://github.com/leonieziechmann/loom/tree/main/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themes: [
    [
      require.resolve("@easyops-cn/docusaurus-search-local"),
      {
        hashed: true,
        language: ["en"],
        indexDocs: true,
        indexBlog: true,
        docsRouteBasePath: "/docs",
      },
    ],
    '@docusaurus/theme-mermaid'
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      // Replace with your project's social card
      image: 'img/docusaurus-social-card.jpg',
      colorMode: {
        defaultMode: 'light',
        disableSwitch: false,
        respectPrefersColorScheme: true,
      },
      navbar: {
        title: 'Loom Documentation',
        logo: {
          alt: 'Loom Logo',
          src: 'img/logo.png',
        },
        items: [
          {
            href: 'https://github.com/leonieziechmann/loom',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Getting Started',
                to: '/getting-started',
              },
              {
                label: 'Core Concepts',
                to: '/concepts',
              },
              {
                label: 'API Reference',
                to: '/api-reference',
              },
            ],
          },
          {
            title: 'Community',
            items: [
              {
                label: "Typst Universe",
                href: "https://typst.app/universe/",
              },
              {
                label: "Issues & Support",
                href: "https://github.com/leonieziechmann/loom/issues",
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/leonieziechmann/loom',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Loom, Leonie Ziechmann`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
        additionalLanguages: ['rust', 'bash', 'nix'],
      },
    }),
};

export default config;
