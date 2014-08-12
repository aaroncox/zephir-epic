module.exports = {
  testing: {
    files: [
      'epic/*',
      'epic/**/*',
      'tests/*',
      'tests/**/*'
    ],
    tasks: ['build', 'test']
  }
};
