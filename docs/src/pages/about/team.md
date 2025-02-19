```@raw html
---
layout: page
---
<script setup>
import {
  VPTeamPage,
  VPTeamPageTitle,
  VPTeamMembers,
  VPTeamPageSection
} from 'vitepress/theme'

const modelMembers = [
    {
        avatar: 'https://www.bgc-jena.mpg.de/employee_images/121509-1717578232?t=eyJ3aWR0aCI6MjEzLCJoZWlnaHQiOjI3NCwiZml0IjoiY3JvcCIsImZpbGVfZXh0ZW5zaW9uIjoid2VicCIsInF1YWxpdHkiOjg2fQ%3D%3D--3e1d41ff4b1ea8928e6734bc473242a90f797dea',
        name: 'Sujan Koirala',
        title: 'Scientist: SINDBAD inception, and implementation and physical process.',
        links: [
            { icon:
                {svg: '<svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 24 24" height="28" width="28" xmlns="http://www.w3.org/2000/svg"><path fill="none" d="M0 0h24v24H0z"></path><path d="M1 11v10h5v-6h4v6h5V11L8 6z"></path><path d="M10 3v1.97l7 5V11h2v2h-2v2h2v2h-2v4h6V3H10zm9 6h-2V7h2v2z"></path></svg>'}, link: 'https://www.bgc-jena.mpg.de/person/skoirala/2206' },
            ]
        },
    {
        avatar: 'https://www.bgc-jena.mpg.de/employee_images/121289-1736930370?t=eyJ3aWR0aCI6MjEzLCJoZWlnaHQiOjI3NCwiZml0IjoiY3JvcCIsImZpbGVfZXh0ZW5zaW9uIjoid2VicCIsInF1YWxpdHkiOjg2fQ%3D%3D--3e1d41ff4b1ea8928e6734bc473242a90f797dea',
        name: 'Nuno Carvalhais',
        title: 'Project Leader: SINDBAD inception and scientific consistency barrier.',
        links: [
            { icon:
                {svg: '<svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 24 24" height="28" width="28" xmlns="http://www.w3.org/2000/svg"><path fill="none" d="M0 0h24v24H0z"></path><path d="M1 11v10h5v-6h4v6h5V11L8 6z"></path><path d="M10 3v1.97l7 5V11h2v2h-2v2h2v2h-2v4h6V3H10zm9 6h-2V7h2v2z"></path></svg>'}, link: 'https://www.bgc-jena.mpg.de/en/bgi/mdi' },
            ]
        },
    {
        avatar: 'https://avatars.githubusercontent.com/u/19525261?v=4',
        name: 'Lazaro Alonso',
        title: 'Scientist. Co-design implementation in Julia, documentation and hybrid components.',
        links: [
            { icon:
                {svg: '<svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 24 24" height="28" width="28" xmlns="http://www.w3.org/2000/svg"><path fill="none" d="M0 0h24v24H0z"></path><path d="M1 11v10h5v-6h4v6h5V11L8 6z"></path><path d="M10 3v1.97l7 5V11h2v2h-2v2h2v2h-2v4h6V3H10zm9 6h-2V7h2v2z"></path></svg>'}, link: 'https://lazarusa.github.io' },
            { icon: 'github', link: 'https://github.com/lazarusA' },
            { icon: 'bluesky', link: 'https://bsky.app/profile/lazarusa.bsky.social' },
            { icon: 'x', link: 'https://twitter.com/LazarusAlon' },
            { icon: 'linkedin', link: 'https://www.linkedin.com/in/lazaro-alonso/' },
            { icon: 'mastodon', link: 'https://julialang.social/@LazaroAlonso' }
            ]
        },
    {
        avatar: 'https://www.bgc-jena.mpg.de/employee_images/121366-1667825290?t=eyJ3aWR0aCI6MjEzLCJoZWlnaHQiOjI3NCwiZml0IjoiY3JvcCIsImZpbGVfZXh0ZW5zaW9uIjoid2VicCIsInF1YWxpdHkiOjg2fQ%3D%3D--3e1d41ff4b1ea8928e6734bc473242a90f797dea',
        name: 'Fabian Gans',
        title: 'Geoscientific Programmer: IO and YAXArrays issues for global simulations.',
        links: [
            { icon: 'github', link: 'https://github.com/meggart' },
            ]
        },
    {
        avatar: 'https://avatars.githubusercontent.com/u/17124431?v=4',
        name: 'Felix Cremer',
        title: 'IO and YAXArrays issues.',
        links: [
            { icon: 'github', link: 'https://github.com/felixcremer' },
            ]
        }
    ]
</script>

<VPTeamPage>
  <VPTeamPageTitle>
    <template #title>Team</template>
    <template #lead>
    <div align="justify">
    SINDBAD is developed at the Department of Biogeochemical Integration of the Max Planck Institute for Biogeochemistry in Jena, Germany. 
    </div>
    </template>
  </VPTeamPageTitle>
  <VPTeamMembers size="small" :members="modelMembers" />
</VPTeamPage>

<style>
.row img {
  border-radius: 50%;
  width: 60px;
  height: 60px;
}
.row {
  display: flex;
  flex-wrap: wrap;
  padding: 0 4px;
}
</style>
```