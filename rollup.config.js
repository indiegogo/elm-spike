import commonjs from 'rollup-plugin-commonjs'
import elm from 'rollup-plugin-elm'
 
export default {
  input: 'src/entrypoint.js',
  output: {
    file: `dist/bundle.js`,
    format: 'cjs'
  },
  plugins: [
    elm({
      exclude: 'elm_stuff/**',
      compiler: {
        // provides --debug to elm-make if enabled
        debug: false
      }
    }),
    commonjs({
      // add .elm extension
      extensions: ['.js', '.elm']
    })
  ],
  watch: {
    // add .elm files to watched files
    include: 'src/**'
  }
}
