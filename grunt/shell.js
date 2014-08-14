module.exports = {
  zephirBuild: {
    options: {
      stderr: false
    },
    command: 'sudo zephir build'
  },
  zephirClean: {
    options: {
      stderr: false
    },
    command: 'sudo zephir clean'
  },
  zephirFullClean: {
    options: {
      stderr: false
    },
    command: 'sudo zephir fullclean'
  },
  zephirTest: {
    options: {
      stderr: false
    },
    command: 'php test-zephir.php'
  },
  normalTest: {
    options: {
      stderr: false
    },
    command: 'php test-normal.php'
  }
}