import { build } from './build.js'

build({
  platform: 'node',
  entryPoints: ['game/src/server/index.ts'],
  outfile: '../dist/server.js',
  // external: ['mongodb'],
})
