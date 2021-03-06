_ = require "underscore"
yaml = require 'js-yaml'
fs = require 'fs'
path = require 'path'

TokenizerFactory = require '../tokenizer/TokenizerFactory'

prepareOptions = (options, config) ->
  optionsNew = _.extend optionsPreprocessor.default, config

  for key, value of options
    if not (value is null)
      optionsNew[key] = value

  if typeof optionsNew.languages is 'string'
    optionsNew.languages = optionsNew.languages.split ','

  optionsNew.extensions = TokenizerFactory::getExtensionsByLanguages(optionsNew.languages)
  return optionsNew

readConfig = (file) ->
  file = path.normalize file
  try
    doc = yaml.safeLoad fs.readFileSync(file, 'utf8')
    doc.config_file = file
    return doc
  catch error
    return false


optionsPreprocessor = (jscpd) ->
  config = readConfig('.cpd.yaml') or readConfig('.cpd.yml') or {}
  options = prepareOptions jscpd.options, config
  options.path = options.path or process.cwd()
  jscpd.options = options

optionsPreprocessor.default =
  languages: Object.keys TokenizerFactory::LANGUAGES
  verbose: off
  debug: off
  files: null
  exclude: null

module.exports = optionsPreprocessor

