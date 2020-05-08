const envfile = require('envfile')
const expandHomeDir = require('expand-home-dir')
const fs = require('fs-extra')
const path = require('path')

/**
 * Write Environment variables to file.
 * @param  {Object} object
 * @param  {String} path
 * @return {void}
 */
module.exports = (object, filePath) => {
  filePath = expandHomeDir(filePath)
  fs.ensureDirSync(path.dirname(filePath))
  fs.writeFileSync(filePath, envfile.stringifySync(object))
}
