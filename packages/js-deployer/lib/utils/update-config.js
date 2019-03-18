const set = require('lodash/set')
const fs = require('fs-extra')
const path = require('path')

/**
 * Update the contents of the given file and return config.
 * @param  {String} file
 * @param  {Object} values
 * @return {Object}
 */
module.exports = (file, values, configPath, forceOverwrite) => {
  configPath = configPath || `${process.env.ARK_PATH_CONFIG}/deployer`
  configPath = path.resolve(configPath, file)
  let config
  if (fs.existsSync(configPath) && !forceOverwrite) {
    config = require(configPath)
    Object.keys(values).forEach(key => set(config, key, values[key]))
  } else {
    config = values
  }

  fs.ensureFileSync(configPath)
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2))

  return config
}
