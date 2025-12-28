# Changelog

## [1.6.0](https://github.com/lgallard/terraform-aws-ecr/compare/1.5.1...1.6.0) (2025-12-28)


### Features

* add terraform_docs hook for local development ([#175](https://github.com/lgallard/terraform-aws-ecr/issues/175)) ([e2ca297](https://github.com/lgallard/terraform-aws-ecr/commit/e2ca29791386d0dcbf74ecd59b4fcbe283525c3b))

## [1.5.1](https://github.com/lgallard/terraform-aws-ecr/compare/1.5.0...1.5.1) (2025-12-27)


### Bug Fixes

* resolve pre-commit workflow terraform validate failures ([#172](https://github.com/lgallard/terraform-aws-ecr/issues/172)) ([d9a996a](https://github.com/lgallard/terraform-aws-ecr/commit/d9a996aaa875370b463fcc2fe4e45844f03bbd46))

## [1.5.0](https://github.com/lgallard/terraform-aws-ecr/compare/1.4.0...1.5.0) (2025-12-27)


### Features

* add support for REGISTRY_POLICY_SCOPE account setting ([#170](https://github.com/lgallard/terraform-aws-ecr/issues/170)) ([f569e98](https://github.com/lgallard/terraform-aws-ecr/commit/f569e986d640f3df4970bc532ad0823828d495d3))

## [1.4.0](https://github.com/lgallard/terraform-aws-ecr/compare/1.3.2...1.4.0) (2025-12-26)


### Features

* Add support for ECR account settings (BASIC_SCAN_TYPE_VERSION) ([#167](https://github.com/lgallard/terraform-aws-ecr/issues/167)) ([4e2abbb](https://github.com/lgallard/terraform-aws-ecr/commit/4e2abbbf5f95a00aa883d6aa9681e9611537aa79)), closes [#166](https://github.com/lgallard/terraform-aws-ecr/issues/166)

## [1.3.2](https://github.com/lgallard/terraform-aws-ecr/compare/1.3.1...1.3.2) (2025-08-31)


### Bug Fixes

* resolve terraform_docs pre-commit CI/local environment discrepancy ([#163](https://github.com/lgallard/terraform-aws-ecr/issues/163)) ([55394c2](https://github.com/lgallard/terraform-aws-ecr/commit/55394c25c0332c3fc837915499adfa2f319559fc))

## [1.3.1](https://github.com/lgallard/terraform-aws-ecr/compare/1.3.0...1.3.1) (2025-08-22)


### Bug Fixes

* Update image_tag_mutability validation to support IMMUTABLE_WITH_EXCLUSION and MUTABLE_WITH_EXCLUSION ([#160](https://github.com/lgallard/terraform-aws-ecr/issues/160)) ([cbe4b56](https://github.com/lgallard/terraform-aws-ecr/commit/cbe4b56c8261c79041bd1fec156898f1b46c549e))

## [1.3.0](https://github.com/lgallard/terraform-aws-ecr/compare/1.2.0...1.3.0) (2025-08-22)


### Features

* enhance feature discovery with detailed issue content generation ([451ddf0](https://github.com/lgallard/terraform-aws-ecr/commit/451ddf09310da7fb7918932a9e4b8d6512f14931))


### Bug Fixes

* add PAT authentication for GitHub issue creation ([1068f56](https://github.com/lgallard/terraform-aws-ecr/commit/1068f566e35174b8e0e6fc5644c8fd3cc4f99fe8))
* correct GitHub issue creation commands ([2366c11](https://github.com/lgallard/terraform-aws-ecr/commit/2366c11997b19b521e06f289e6f32631b7c97135))
* reset failed issue creation attempts in feature tracker ([c6662d1](https://github.com/lgallard/terraform-aws-ecr/commit/c6662d1c09dca6339e6f1da6cc29f1d868db2688))

## [1.2.0](https://github.com/lgallard/terraform-aws-ecr/compare/1.1.1...1.2.0) (2025-08-21)


### Features

* schedule ECR feature discovery test run for 21:12 UTC today ([ef8e5bd](https://github.com/lgallard/terraform-aws-ecr/commit/ef8e5bdedda37b7e910fa297f105d2f2eda9b2c9))

## [1.1.1](https://github.com/lgallard/terraform-aws-ecr/compare/1.1.0...1.1.1) (2025-08-21)


### Bug Fixes

* add missing mode parameter for Claude Code Action ([9be7805](https://github.com/lgallard/terraform-aws-ecr/commit/9be78054b7c37f3c2b7ae68c4237ab7a83d85ecc))

## [1.1.0](https://github.com/lgallard/terraform-aws-ecr/compare/1.0.0...1.1.0) (2025-08-21)


### Features

* Add advanced tagging strategies with templates, validation, and normalization ([#78](https://github.com/lgallard/terraform-aws-ecr/issues/78)) ([5d838b3](https://github.com/lgallard/terraform-aws-ecr/commit/5d838b317f024b7206dd077c0958cf54e4eba1d2))
* add automated ECR feature discovery system ([#149](https://github.com/lgallard/terraform-aws-ecr/issues/149)) ([a8e0fbf](https://github.com/lgallard/terraform-aws-ecr/commit/a8e0fbf50203c5816d3be455d13f992b2aa587d3))
* add automatic v-prefix removal from release titles ([#106](https://github.com/lgallard/terraform-aws-ecr/issues/106)) ([f0d9457](https://github.com/lgallard/terraform-aws-ecr/commit/f0d9457080b14009f95315fc285ef30224be484b))
* add Claude dispatch workflow for repository events ([#135](https://github.com/lgallard/terraform-aws-ecr/issues/135)) ([4877708](https://github.com/lgallard/terraform-aws-ecr/commit/4877708c1089e1ba1255587f06fa90bbce035b00))
* Add CloudWatch monitoring and alerting for ECR repositories ([#80](https://github.com/lgallard/terraform-aws-ecr/issues/80)) ([a123105](https://github.com/lgallard/terraform-aws-ecr/commit/a123105d93a23e8543ee53fd0f24f01e75828e93))
* Add comment-based Claude Code Review triggers (like Cursor's Bugbot) ([#97](https://github.com/lgallard/terraform-aws-ecr/issues/97)) ([2da2479](https://github.com/lgallard/terraform-aws-ecr/commit/2da2479bce6f6b6d3a0ad3cdcd886337ded150ae))
* Add Dependabot ([cc533d7](https://github.com/lgallard/terraform-aws-ecr/commit/cc533d7e21ff1e2c231fd702c3d2d4537b853736))
* add GitHub issue templates for AI-consumable task management ([ea92669](https://github.com/lgallard/terraform-aws-ecr/commit/ea92669121bd38f329f2172ecdf39277cc0ad148))
* add MCP server support for enhanced documentation access ([#140](https://github.com/lgallard/terraform-aws-ecr/issues/140)) ([07b8723](https://github.com/lgallard/terraform-aws-ecr/commit/07b87235336582b5d40b7d518c26259fac81571c))
* Add support for prevent_destroy in ECR repository configuration ([2a17863](https://github.com/lgallard/terraform-aws-ecr/commit/2a17863f828c44fc03849b1002591a3ef65cc9ea))
* Add support for repository replication ([#55](https://github.com/lgallard/terraform-aws-ecr/issues/55)) ([5ef83b8](https://github.com/lgallard/terraform-aws-ecr/commit/5ef83b885450135ced47d7f302bf2b35b7c4d5ab))
* Add Terratest framework for automated testing ([#54](https://github.com/lgallard/terraform-aws-ecr/issues/54)) ([b5554c1](https://github.com/lgallard/terraform-aws-ecr/commit/b5554c10738af16b3238628c07460794ba09ac61))
* Add test file with intentional issues for Claude Code Review testing ([9e6ac26](https://github.com/lgallard/terraform-aws-ecr/commit/9e6ac26063aafb48f78c01ff928e7d85f13e7658))
* Change Claude Code Review trigger from 'claude' to 'codebot' ([d5fc663](https://github.com/lgallard/terraform-aws-ecr/commit/d5fc663123ab1707cff4d78afe90f694f81f89ec))
* complete release-please standardization across all repositories ([#108](https://github.com/lgallard/terraform-aws-ecr/issues/108)) ([1506473](https://github.com/lgallard/terraform-aws-ecr/commit/1506473d12ffd57a1111aaafde8f1d889dcbfefe))
* enhance Claude Code Review to focus on PR changes with --full option ([#115](https://github.com/lgallard/terraform-aws-ecr/issues/115)) ([daf63c9](https://github.com/lgallard/terraform-aws-ecr/commit/daf63c9766c9361f7f5de198619b08f4ecd13b33))
* Enhance ECR module with improved security, configuration, and doc ([880fa6f](https://github.com/lgallard/terraform-aws-ecr/commit/880fa6f4070f04ef5888491e1f697efdc0a9dcf1))
* Enhance ECR module with improved security, configuration, and documentation ([cff46b9](https://github.com/lgallard/terraform-aws-ecr/commit/cff46b927773086a8b542b7199d2020540e74521))
* Enhance security configurations with registry scanning, pull-through cache, and secret scanning ([#71](https://github.com/lgallard/terraform-aws-ecr/issues/71)) ([666e7bc](https://github.com/lgallard/terraform-aws-ecr/commit/666e7bc1d28382a1b6a30606eaec07f0c5a5a778))
* extract pull-through cache rules into dedicated submodule ([#142](https://github.com/lgallard/terraform-aws-ecr/issues/142)) ([d2a9f4c](https://github.com/lgallard/terraform-aws-ecr/commit/d2a9f4cb58789f01442ef73650e304225098b539))
* Implement pull request rules for enhanced ECR governance ([#83](https://github.com/lgallard/terraform-aws-ecr/issues/83)) ([7aab872](https://github.com/lgallard/terraform-aws-ecr/commit/7aab8722297ca1c8b05049569e9feb5058477f43))
* Implement state migration for ECR repository resources ([8d4a02e](https://github.com/lgallard/terraform-aws-ecr/commit/8d4a02e782ec682b049a7fdd2e076e19e4d3f869))
* Improve lifecycle policies with helper variables and standardized templates ([#74](https://github.com/lgallard/terraform-aws-ecr/issues/74)) ([975129a](https://github.com/lgallard/terraform-aws-ecr/commit/975129a7611506dbf8c84be95780dcb522f70a36))
* **logging:** add ECR logging configuration with CloudWatch integration ([#30](https://github.com/lgallard/terraform-aws-ecr/issues/30)) ([97dab31](https://github.com/lgallard/terraform-aws-ecr/commit/97dab314b933f0b508d41b5a86c633f6bb4fba61))
* migrate from Dependabot to Renovate for better Terraform support ([#110](https://github.com/lgallard/terraform-aws-ecr/issues/110)) ([c0b983c](https://github.com/lgallard/terraform-aws-ecr/commit/c0b983c48298da6d01d92b97aeb7836b5ff8e1a8))
* optimize resource management by replacing count with for_each patterns ([#147](https://github.com/lgallard/terraform-aws-ecr/issues/147)) ([2009edd](https://github.com/lgallard/terraform-aws-ecr/commit/2009eddb336482c3d3b699518f25f7d33e1f9ab5))
* remove unused local variable to resolve tflint warning ([151b3a5](https://github.com/lgallard/terraform-aws-ecr/commit/151b3a52e09f1795d14116c33dd55637245fa252))
* Update ECR module outputs and variable descriptions ([81b836b](https://github.com/lgallard/terraform-aws-ecr/commit/81b836b8ea889298e338ba9e9558256953cc9a5c))
* Update prevent_destroy behavior and enhance ECR repository examples ([75e5b35](https://github.com/lgallard/terraform-aws-ecr/commit/75e5b35afeaaaf1eac86afdd49a638e222403771))
* Update variables and outputs ([043c288](https://github.com/lgallard/terraform-aws-ecr/commit/043c288e570d0387f4b49241519a5776f5cfc024))


### Bug Fixes

* add .release-please-config.json to root directory for workflow ([#64](https://github.com/lgallard/terraform-aws-ecr/issues/64)) ([6b1f6db](https://github.com/lgallard/terraform-aws-ecr/commit/6b1f6db6dae1332d6154d4eda32fbc07ba44072c))
* Add pull-request-title-pattern to control release title formatting ([#91](https://github.com/lgallard/terraform-aws-ecr/issues/91)) ([b99b9cf](https://github.com/lgallard/terraform-aws-ecr/commit/b99b9cfc1bc2c7c5fcac82dc933be44dcc66e5ff))
* address failing pre-commit checks in pull-through cache PR ([#145](https://github.com/lgallard/terraform-aws-ecr/issues/145)) ([dacc9e1](https://github.com/lgallard/terraform-aws-ecr/commit/dacc9e18f1cb52acb54d3ddc5393041ec85f3e41))
* allow missing AWS credentials in pre-commit CI ([baf9cc0](https://github.com/lgallard/terraform-aws-ecr/commit/baf9cc006f560c3ee34858ba50f5bca9fcbd7ce2))
* Enhance README and variables.tf for clarity and structure ([8d5555e](https://github.com/lgallard/terraform-aws-ecr/commit/8d5555ef5858e969fa502b9210d4679a4470ebd7))
* fix/image_scanning_configuration default value ([41c9567](https://github.com/lgallard/terraform-aws-ecr/commit/41c9567e7fc63d4f0c1b1001dbe09a375bab9682))
* Grant Bash permissions to Claude for pre-commit hooks ([#132](https://github.com/lgallard/terraform-aws-ecr/issues/132)) ([230e943](https://github.com/lgallard/terraform-aws-ecr/commit/230e943c71f9b1d22fe9dcc7c9f734c068c81a84))
* image_scanning_configuration default value ([daf133b](https://github.com/lgallard/terraform-aws-ecr/commit/daf133b40bf06994fc71501948d39e98fc85d9ea))
* improve tflint installation in pre-commit workflow ([ce208bc](https://github.com/lgallard/terraform-aws-ecr/commit/ce208bcbb2b5c7cc738861426cea3926c1f6851d))
* move release-please manifest to root directory ([#65](https://github.com/lgallard/terraform-aws-ecr/issues/65)) ([d61003c](https://github.com/lgallard/terraform-aws-ecr/commit/d61003c7ad391e764d492d9bf9593b62d4847202))
* Refactor ECR module to enhance pull request rules and monitoring capa… ([#86](https://github.com/lgallard/terraform-aws-ecr/issues/86)) ([231c753](https://github.com/lgallard/terraform-aws-ecr/commit/231c753b7b9f848fd153f2fbdb41a4be591725a3))
* remove "v" prefix from release-please tags ([#63](https://github.com/lgallard/terraform-aws-ecr/issues/63)) ([397c135](https://github.com/lgallard/terraform-aws-ecr/commit/397c135cf0fda3479ba8be5a383cc78dc39e9f1e))
* remove "v" prefix from release-please tags ([#67](https://github.com/lgallard/terraform-aws-ecr/issues/67)) ([15cd05e](https://github.com/lgallard/terraform-aws-ecr/commit/15cd05e5a3943dc4ed123755175d5fc383723642))
* remove "v" prefix inconsistencies in CHANGELOG.md comparison URLs ([#69](https://github.com/lgallard/terraform-aws-ecr/issues/69)) ([53df957](https://github.com/lgallard/terraform-aws-ecr/commit/53df957ea3f75d273c78f4447fc29fca506a2a0b))
* Remove emoji reactions that were failing due to permissions ([3bc77e4](https://github.com/lgallard/terraform-aws-ecr/commit/3bc77e497407285b9fefdcee1029cbd94e71d425))
* Remove extra double quote in encryption_type variable description ([67aea5b](https://github.com/lgallard/terraform-aws-ecr/commit/67aea5bc4ff07b7e31b24c7788bfef3bc5f186e3))
* remove pip cache from pre-commit workflow ([9e3935c](https://github.com/lgallard/terraform-aws-ecr/commit/9e3935c4e8a41e59b0da5da2feb7c2cf090df2d8))
* Remove v prefix from release titles to match tag format ([#89](https://github.com/lgallard/terraform-aws-ecr/issues/89)) ([2ccfec7](https://github.com/lgallard/terraform-aws-ecr/commit/2ccfec74dd384e31f43f98fbfa337ba4a5225c96))
* repository_arn output should return ARN instead of repository name ([#138](https://github.com/lgallard/terraform-aws-ecr/issues/138)) ([6b9f0cc](https://github.com/lgallard/terraform-aws-ecr/commit/6b9f0cc78eabe60fe5b7fdd932f247105e7d44fa))
* resolve Claude Code Review change detection issues ([#119](https://github.com/lgallard/terraform-aws-ecr/issues/119)) ([9132872](https://github.com/lgallard/terraform-aws-ecr/commit/9132872f8579a7b3424d12a02f187a4bf9bb5609))
* resolve critical Claude Code Review workflow issues ([#118](https://github.com/lgallard/terraform-aws-ecr/issues/118)) ([cd8e29d](https://github.com/lgallard/terraform-aws-ecr/commit/cd8e29d2b3d1200a3925054e11d18b48a84a1679))
* resolve lifecycle prevent_destroy variable limitation - Replace single repository resource with conditional creation approach - Use separate aws_ecr_repository resources (repo and repo_protected) - Enable dynamic prevent_destroy control through var.prevent_destroy - Remove moved.tf as it's not needed with this approach - Reorganize main.tf with proper section headers ([217b4f0](https://github.com/lgallard/terraform-aws-ecr/commit/217b4f0e2823c1c95b1bc270f6f97026d771d32d))
* try simple release type to prevent v-prefix in release titles ([#104](https://github.com/lgallard/terraform-aws-ecr/issues/104)) ([3bb6812](https://github.com/lgallard/terraform-aws-ecr/commit/3bb6812d12b91a31c231c73756d3a185299b9ccb))
* Update changelog and release-please configuration ([bfdb2db](https://github.com/lgallard/terraform-aws-ecr/commit/bfdb2dbfcd83bb91517ce7cabd58e55c54c4945f))
* Update CHANGELOG and release-please configuration ([4ff85d6](https://github.com/lgallard/terraform-aws-ecr/commit/4ff85d6cc1bebe6170508f109eb1a489dbfbbcde))
* update deprecated upload-artifact action from v3 to v4 ([#61](https://github.com/lgallard/terraform-aws-ecr/issues/61)) ([62f137a](https://github.com/lgallard/terraform-aws-ecr/commit/62f137a4c247d2d19b2d77be1c616fe483d20e8b))
* update release-please config to prevent v-prefix in release titles ([#102](https://github.com/lgallard/terraform-aws-ecr/issues/102)) ([536af03](https://github.com/lgallard/terraform-aws-ecr/commit/536af0340bc5b596b0c6aa684952510a0ce7390d))
* Update release-please configuration sections for clarity ([3da3e03](https://github.com/lgallard/terraform-aws-ecr/commit/3da3e035ee7f911ad450fb09076003df664f1f7f))
* Use environment variable for comment body to prevent shell injection ([9ab0398](https://github.com/lgallard/terraform-aws-ecr/commit/9ab03988581e0d7aff51ed816ff442e54fb1633d))


### Reverts

* Revert PR [#48](https://github.com/lgallard/terraform-aws-ecr/issues/48) - lifecycle prevent_destroy cannot use variables ([323b033](https://github.com/lgallard/terraform-aws-ecr/commit/323b033debe7f9de821850fd66efedbef42fe5a5))

## [1.0.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.27.1...1.0.0) (2025-08-21)


### ⚠ BREAKING CHANGES

* **resource addressing**: optimize resource management by replacing count with for_each patterns ([#147](https://github.com/lgallard/terraform-aws-ecr/issues/147)) ([2009edd](https://github.com/lgallard/terraform-aws-ecr/commit/2009eddb336482c3d3b699518f25f7d33e1f9ab5))

This is a breaking change that converts all resources from `count` to `for_each` patterns. Existing Terraform state will need to be migrated. See MIGRATION.md for detailed migration instructions.

### Features

* add automated ECR feature discovery system ([#149](https://github.com/lgallard/terraform-aws-ecr/issues/149)) ([a8e0fbf](https://github.com/lgallard/terraform-aws-ecr/commit/a8e0fbf50203c5816d3be455d13f992b2aa587d3))

## [0.27.1](https://github.com/lgallard/terraform-aws-ecr/compare/0.27.0...0.27.1) (2025-08-12)


### Bug Fixes

* address failing pre-commit checks in pull-through cache PR ([#145](https://github.com/lgallard/terraform-aws-ecr/issues/145)) ([dacc9e1](https://github.com/lgallard/terraform-aws-ecr/commit/dacc9e18f1cb52acb54d3ddc5393041ec85f3e41))

## [0.27.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.26.0...0.27.0) (2025-08-11)


### Features

* extract pull-through cache rules into dedicated submodule ([#142](https://github.com/lgallard/terraform-aws-ecr/issues/142)) ([d2a9f4c](https://github.com/lgallard/terraform-aws-ecr/commit/d2a9f4cb58789f01442ef73650e304225098b539))

## [0.26.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.25.1...0.26.0) (2025-08-09)


### Features

* add MCP server support for enhanced documentation access ([#140](https://github.com/lgallard/terraform-aws-ecr/issues/140)) ([07b8723](https://github.com/lgallard/terraform-aws-ecr/commit/07b87235336582b5d40b7d518c26259fac81571c))

## [0.25.1](https://github.com/lgallard/terraform-aws-ecr/compare/0.25.0...0.25.1) (2025-08-08)


### Bug Fixes

* repository_arn output should return ARN instead of repository name ([#138](https://github.com/lgallard/terraform-aws-ecr/issues/138)) ([6b9f0cc](https://github.com/lgallard/terraform-aws-ecr/commit/6b9f0cc78eabe60fe5b7fdd932f247105e7d44fa))

## [0.25.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.24.2...0.25.0) (2025-08-07)


### Features

* add Claude dispatch workflow for repository events ([#135](https://github.com/lgallard/terraform-aws-ecr/issues/135)) ([4877708](https://github.com/lgallard/terraform-aws-ecr/commit/4877708c1089e1ba1255587f06fa90bbce035b00))

## [0.24.2](https://github.com/lgallard/terraform-aws-ecr/compare/0.24.1...0.24.2) (2025-08-02)


### Bug Fixes

* allow missing AWS credentials in pre-commit CI ([baf9cc0](https://github.com/lgallard/terraform-aws-ecr/commit/baf9cc006f560c3ee34858ba50f5bca9fcbd7ce2))
* improve tflint installation in pre-commit workflow ([ce208bc](https://github.com/lgallard/terraform-aws-ecr/commit/ce208bcbb2b5c7cc738861426cea3926c1f6851d))
* remove pip cache from pre-commit workflow ([9e3935c](https://github.com/lgallard/terraform-aws-ecr/commit/9e3935c4e8a41e59b0da5da2feb7c2cf090df2d8))

## [0.24.1](https://github.com/lgallard/terraform-aws-ecr/compare/0.24.0...0.24.1) (2025-08-02)


### Bug Fixes

* Grant Bash permissions to Claude for pre-commit hooks ([#132](https://github.com/lgallard/terraform-aws-ecr/issues/132)) ([230e943](https://github.com/lgallard/terraform-aws-ecr/commit/230e943c71f9b1d22fe9dcc7c9f734c068c81a84))

## [0.24.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.23.0...0.24.0) (2025-08-01)


### Features

* add GitHub issue templates for AI-consumable task management ([ea92669](https://github.com/lgallard/terraform-aws-ecr/commit/ea92669121bd38f329f2172ecdf39277cc0ad148))


### Bug Fixes

* resolve Claude Code Review change detection issues ([#119](https://github.com/lgallard/terraform-aws-ecr/issues/119)) ([9132872](https://github.com/lgallard/terraform-aws-ecr/commit/9132872f8579a7b3424d12a02f187a4bf9bb5609))

## [0.23.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.22.0...0.23.0) (2025-07-30)


### Features

* enhance Claude Code Review to focus on PR changes with --full option ([#115](https://github.com/lgallard/terraform-aws-ecr/issues/115)) ([daf63c9](https://github.com/lgallard/terraform-aws-ecr/commit/daf63c9766c9361f7f5de198619b08f4ecd13b33))


### Bug Fixes

* resolve critical Claude Code Review workflow issues ([#118](https://github.com/lgallard/terraform-aws-ecr/issues/118)) ([cd8e29d](https://github.com/lgallard/terraform-aws-ecr/commit/cd8e29d2b3d1200a3925054e11d18b48a84a1679))

## [0.22.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.21.0...0.22.0) (2025-07-28)


### Features

* migrate from Dependabot to Renovate for better Terraform support ([#110](https://github.com/lgallard/terraform-aws-ecr/issues/110)) ([c0b983c](https://github.com/lgallard/terraform-aws-ecr/commit/c0b983c48298da6d01d92b97aeb7836b5ff8e1a8))

## [0.21.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.20.0...0.21.0) (2025-07-23)


### Features

* complete release-please standardization across all repositories ([#108](https://github.com/lgallard/terraform-aws-ecr/issues/108)) ([1506473](https://github.com/lgallard/terraform-aws-ecr/commit/1506473d12ffd57a1111aaafde8f1d889dcbfefe))

## [0.20.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.19.2...0.20.0) (2025-07-23)


### Features

* add automatic v-prefix removal from release titles ([#106](https://github.com/lgallard/terraform-aws-ecr/issues/106)) ([f0d9457](https://github.com/lgallard/terraform-aws-ecr/commit/f0d9457080b14009f95315fc285ef30224be484b))

## [0.19.2](https://github.com/lgallard/terraform-aws-ecr/compare/0.19.1...0.19.2) (2025-07-23)


### Bug Fixes

* try simple release type to prevent v-prefix in release titles ([#104](https://github.com/lgallard/terraform-aws-ecr/issues/104)) ([3bb6812](https://github.com/lgallard/terraform-aws-ecr/commit/3bb6812d12b91a31c231c73756d3a185299b9ccb))

## [0.19.1](https://github.com/lgallard/terraform-aws-ecr/compare/0.19.0...0.19.1) (2025-07-23)


### Bug Fixes

* update release-please config to prevent v-prefix in release titles ([#102](https://github.com/lgallard/terraform-aws-ecr/issues/102)) ([536af03](https://github.com/lgallard/terraform-aws-ecr/commit/536af0340bc5b596b0c6aa684952510a0ce7390d))

## [0.19.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.18.0...0.19.0) (2025-07-22)


### Features

* Change Claude Code Review trigger from 'claude' to 'codebot' ([d5fc663](https://github.com/lgallard/terraform-aws-ecr/commit/d5fc663123ab1707cff4d78afe90f694f81f89ec))

## [0.18.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.17.0...0.18.0) (2025-07-22)


### Features

* Add test file with intentional issues for Claude Code Review testing ([9e6ac26](https://github.com/lgallard/terraform-aws-ecr/commit/9e6ac26063aafb48f78c01ff928e7d85f13e7658))


### Bug Fixes

* Remove emoji reactions that were failing due to permissions ([3bc77e4](https://github.com/lgallard/terraform-aws-ecr/commit/3bc77e497407285b9fefdcee1029cbd94e71d425))
* Use environment variable for comment body to prevent shell injection ([9ab0398](https://github.com/lgallard/terraform-aws-ecr/commit/9ab03988581e0d7aff51ed816ff442e54fb1633d))

## [0.17.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.16.3...0.17.0) (2025-07-22)


### Features

* Add comment-based Claude Code Review triggers (like Cursor's Bugbot) ([#97](https://github.com/lgallard/terraform-aws-ecr/issues/97)) ([2da2479](https://github.com/lgallard/terraform-aws-ecr/commit/2da2479bce6f6b6d3a0ad3cdcd886337ded150ae))

## [0.16.3](https://github.com/lgallard/terraform-aws-ecr/compare/0.16.2...0.16.3) (2025-07-06)


### Bug Fixes

* Add pull-request-title-pattern to control release title formatting ([#91](https://github.com/lgallard/terraform-aws-ecr/issues/91)) ([b99b9cf](https://github.com/lgallard/terraform-aws-ecr/commit/b99b9cfc1bc2c7c5fcac82dc933be44dcc66e5ff))

## [0.16.2](https://github.com/lgallard/terraform-aws-ecr/compare/0.16.1...0.16.2) (2025-07-06)


### Bug Fixes

* Remove v prefix from release titles to match tag format ([#89](https://github.com/lgallard/terraform-aws-ecr/issues/89)) ([2ccfec7](https://github.com/lgallard/terraform-aws-ecr/commit/2ccfec74dd384e31f43f98fbfa337ba4a5225c96))

## [0.16.1](https://github.com/lgallard/terraform-aws-ecr/compare/0.16.0...0.16.1) (2025-07-04)


### Bug Fixes

* Refactor ECR module to enhance pull request rules and monitoring capa… ([#86](https://github.com/lgallard/terraform-aws-ecr/issues/86)) ([231c753](https://github.com/lgallard/terraform-aws-ecr/commit/231c753b7b9f848fd153f2fbdb41a4be591725a3))

## [0.16.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.15.0...0.16.0) (2025-07-04)


### Features

* Implement pull request rules for enhanced ECR governance ([#83](https://github.com/lgallard/terraform-aws-ecr/issues/83)) ([7aab872](https://github.com/lgallard/terraform-aws-ecr/commit/7aab8722297ca1c8b05049569e9feb5058477f43))

## [0.15.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.14.0...0.15.0) (2025-07-04)


### Features

* Add CloudWatch monitoring and alerting for ECR repositories ([#80](https://github.com/lgallard/terraform-aws-ecr/issues/80)) ([a123105](https://github.com/lgallard/terraform-aws-ecr/commit/a123105d93a23e8543ee53fd0f24f01e75828e93))

## [0.14.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.13.0...0.14.0) (2025-07-03)


### Features

* Add advanced tagging strategies with templates, validation, and normalization ([#78](https://github.com/lgallard/terraform-aws-ecr/issues/78)) ([5d838b3](https://github.com/lgallard/terraform-aws-ecr/commit/5d838b317f024b7206dd077c0958cf54e4eba1d2))

## [0.13.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.12.0...0.13.0) (2025-07-02)


### Features

* Improve lifecycle policies with helper variables and standardized templates ([#74](https://github.com/lgallard/terraform-aws-ecr/issues/74)) ([975129a](https://github.com/lgallard/terraform-aws-ecr/commit/975129a7611506dbf8c84be95780dcb522f70a36))

## [0.12.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.11.4...0.12.0) (2025-06-08)


### Features

* Enhance security configurations with registry scanning, pull-through cache, and secret scanning ([#71](https://github.com/lgallard/terraform-aws-ecr/issues/71)) ([666e7bc](https://github.com/lgallard/terraform-aws-ecr/commit/666e7bc1d28382a1b6a30606eaec07f0c5a5a778))

## [0.11.4](https://github.com/lgallard/terraform-aws-ecr/compare/0.11.3...0.11.4) (2025-06-08)


### Bug Fixes

* remove "v" prefix inconsistencies in CHANGELOG.md comparison URLs ([#69](https://github.com/lgallard/terraform-aws-ecr/issues/69)) ([53df957](https://github.com/lgallard/terraform-aws-ecr/commit/53df957ea3f75d273c78f4447fc29fca506a2a0b))

## [0.11.3](https://github.com/lgallard/terraform-aws-ecr/compare/0.11.2...0.11.3) (2025-06-08)


### Bug Fixes

* remove "v" prefix from release-please tags ([#67](https://github.com/lgallard/terraform-aws-ecr/issues/67)) ([15cd05e](https://github.com/lgallard/terraform-aws-ecr/commit/15cd05e5a3943dc4ed123755175d5fc383723642))

## [0.11.2](https://github.com/lgallard/terraform-aws-ecr/compare/0.11.1...0.11.2) (2025-06-08)


### Bug Fixes

* add .release-please-config.json to root directory for workflow ([#64](https://github.com/lgallard/terraform-aws-ecr/issues/64)) ([6b1f6db](https://github.com/lgallard/terraform-aws-ecr/commit/6b1f6db6dae1332d6154d4eda32fbc07ba44072c))
* move release-please manifest to root directory ([#65](https://github.com/lgallard/terraform-aws-ecr/issues/65)) ([d61003c](https://github.com/lgallard/terraform-aws-ecr/commit/d61003c7ad391e764d492d9bf9593b62d4847202))
* remove "v" prefix from release-please tags ([#63](https://github.com/lgallard/terraform-aws-ecr/issues/63)) ([397c135](https://github.com/lgallard/terraform-aws-ecr/commit/397c135cf0fda3479ba8be5a383cc78dc39e9f1e))

## [0.11.1](https://github.com/lgallard/terraform-aws-ecr/compare/0.11.0...0.11.1) (2025-06-08)


### Bug Fixes

* update deprecated upload-artifact action from v3 to v4 ([#61](https://github.com/lgallard/terraform-aws-ecr/issues/61)) ([62f137a](https://github.com/lgallard/terraform-aws-ecr/commit/62f137a4c247d2d19b2d77be1c616fe483d20e8b))

## [0.11.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.10.0...0.11.0) (2025-06-08)


### Features

* Add support for repository replication ([#55](https://github.com/lgallard/terraform-aws-ecr/issues/55)) ([5ef83b8](https://github.com/lgallard/terraform-aws-ecr/commit/5ef83b885450135ced47d7f302bf2b35b7c4d5ab))

## [0.10.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.9.2...0.10.0) (2025-06-08)


### Features

* Add Terratest framework for automated testing ([#54](https://github.com/lgallard/terraform-aws-ecr/issues/54)) ([b5554c1](https://github.com/lgallard/terraform-aws-ecr/commit/b5554c10738af16b3238628c07460794ba09ac61))

## [0.9.2](https://github.com/lgallard/terraform-aws-ecr/compare/0.9.1...0.9.2) (2025-05-22)


### Bug Fixes

* resolve lifecycle prevent_destroy variable limitation - Replace single repository resource with conditional creation approach - Use separate aws_ecr_repository resources (repo and repo_protected) - Enable dynamic prevent_destroy control through var.prevent_destroy - Remove moved.tf as it's not needed with this approach - Reorganize main.tf with proper section headers ([217b4f0](https://github.com/lgallard/terraform-aws-ecr/commit/217b4f0e2823c1c95b1bc270f6f97026d771d32d))

## [0.9.1](https://github.com/lgallard/terraform-aws-ecr/compare/0.9.0...0.9.1) (2025-05-22)


### Reverts

* Revert PR [#48](https://github.com/lgallard/terraform-aws-ecr/issues/48) - lifecycle prevent_destroy cannot use variables ([323b033](https://github.com/lgallard/terraform-aws-ecr/commit/323b033debe7f9de821850fd66efedbef42fe5a5))

## [0.9.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.8.0...0.9.0) (2025-05-22)


### Features

* remove unused local variable to resolve tflint warning ([151b3a5](https://github.com/lgallard/terraform-aws-ecr/commit/151b3a52e09f1795d14116c33dd55637245fa252))

## [0.8.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.7.0...0.8.0) (2025-04-18)


### Features

* **logging:** add ECR logging configuration with CloudWatch integration ([#30](https://github.com/lgallard/terraform-aws-ecr/issues/30)) ([97dab31](https://github.com/lgallard/terraform-aws-ecr/commit/97dab314b933f0b508d41b5a86c633f6bb4fba61))

## [0.7.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.6.2...0.7.0) (2025-03-18)


### Features

* Add support for prevent_destroy in ECR repository configuration ([2a17863](https://github.com/lgallard/terraform-aws-ecr/commit/2a17863f828c44fc03849b1002591a3ef65cc9ea))
* Implement state migration for ECR repository resources ([8d4a02e](https://github.com/lgallard/terraform-aws-ecr/commit/8d4a02e782ec682b049a7fdd2e076e19e4d3f869))
* Update prevent_destroy behavior and enhance ECR repository examples ([75e5b35](https://github.com/lgallard/terraform-aws-ecr/commit/75e5b35afeaaaf1eac86afdd49a638e222403771))

## [0.6.2](https://github.com/lgallard/terraform-aws-ecr/compare/0.6.1...0.6.2) (2025-03-15)


### Bug Fixes

* Enhance README and variables.tf for clarity and structure ([8d5555e](https://github.com/lgallard/terraform-aws-ecr/commit/8d5555ef5858e969fa502b9210d4679a4470ebd7))
* Update release-please configuration sections for clarity ([3da3e03](https://github.com/lgallard/terraform-aws-ecr/commit/3da3e035ee7f911ad450fb09076003df664f1f7f))

## [0.6.1](https://github.com/lgallard/terraform-aws-ecr/compare/0.6.0...0.6.1) (2025-03-15)


### Bug Fixes

* Update changelog and release-please configuration ([bfdb2db](https://github.com/lgallard/terraform-aws-ecr/commit/bfdb2dbfcd83bb91517ce7cabd58e55c54c4945f))

## [0.6.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.5.0...0.6.0) (March 15, 2025)


###  Added

* Update ECR module outputs and variable descriptions ([81b836b](https://github.com/lgallard/terraform-aws-ecr/commit/81b836b8ea889298e338ba9e9558256953cc9a5c))
* New outputs for `kms_key_arn and` `repository_arn`

## 0.5.0 (February 28, 2025)

### Added

- ECR module with KMS encryption support
- Image scanning configuration with scan-on-push capability
- Lifecycle policy support for automated image cleanup
- Default tags configuration in provider
- Complete and simple examples demonstrating module usage

### Changed

- Updated pre-commit hooks configuration
- Added version constraints for Terraform and AWS provider
- Improved code organization with separate version files

### Security

- Enabled immutable tags by default
- Implemented KMS encryption for repository
- Added automatic vulnerability scanning on image push

## 0.4.3 (June 1, 2024)

ENHANCEMENTS:

* Add Dependabot

## 0.4.2 (August 28, 2023)

ENHANCEMENTS:

* Fix image_scanning_configuration default value

## 0.4.1 (August 11, 2023)

ENHANCEMENTS:

* Improve code
* Update Complete example

## 0.4.0 (August 11, 2023)

ENHANCEMENTS:

* Add `force_delete` option
* Update pre-commit config file

## 0.3.2 (April 22, 2021)

ENHANCEMENTS:

* Add pre-commit config file
* Add .gitignore file
* Update README

## 0.3.1 (April 7, 2021)

ENHANCEMENTS:

* Update source module in examples

## 0.3.0 (September 20, 2020)

ENHANCEMENTS:

* Add encryption configuration support (thanks @gnleong)

## 0.2.2 (May 29, 2020)

FIX:

* Fix `repository_url` output

## 0.2.1 (May 28, 2020)

FIX:

* Remove duplicate output

## 0.2.0 (May 28, 2020)

ENHANCEMENTS:

* Add repository name as output

## 0.1.2 (May 5, 2020)

ENHANCEMENTS:

* Set scaning of images on push as the default option

## 0.1.1 (May 4, 2020)

FIX:

* Update examples

## 0.1.0 (May 4, 2020)

FEATURES:

* Module implementation
