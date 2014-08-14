module.exports = {
  testing: {
    files: [
      'epic/*',
      'epic/**/*',
      'tests/*',
      'tests/**/*'
    ],
    tasks: ['build', 'test']
  },
  debug: {
    files: [
      'epic/*',
      'epic/**/*',
      'tests/*',
      'tests/**/*',
      'test.php'
    ],
    tasks: ['build', 'run']
  }
};
