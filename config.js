module.exports = {
  endpoint: 'https://api.github.com',
  token: '0fc76a2b037ab99410ca146ddac7a2d09f7a0937',
  platform: 'github',
  logFileLevel: 'warn',
  logLevel: 'debug',
  logFile: './renovate.log',
  onboarding: true,
  onboardingConfig: {
    "ignorePaths": [],
    "packageRules": [
      {
        "managers": ["terraform"],
        "groupName": "martin",
        "fileMatch": [
          "\\.tf$"
        ],
        "matchStrings": [
          "source\\s+=\\s+\"(?<depName>.+?)\"\\s+version\\s+=\\s+\"(?<currentValue>.+?)\""
        ],
        "datasourceTemplate": "terraform-module",
        "versioningTemplate": "hashicorp"
      }
    ]
  },
  repositories: ['GoogleCloudPlatform/healthcare-data-protection-suite'],
};
