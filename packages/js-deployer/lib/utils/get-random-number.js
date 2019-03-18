/**
 * Get a random number from range.
 * @param  {Number} min
 * @param  {Number} max
 * @return {Number}
 */
module.exports = (min, max) => Math.floor(Math.random() * (max - min) + min)
