# Changelog

## [0.11.1](https://github.com/lgallard/terraform-aws-ecr/compare/0.11.0...v0.11.1) (2025-06-08)


### Bug Fixes

* update deprecated upload-artifact action from v3 to v4 ([#61](https://github.com/lgallard/terraform-aws-ecr/issues/61)) ([62f137a](https://github.com/lgallard/terraform-aws-ecr/commit/62f137a4c247d2d19b2d77be1c616fe483d20e8b))

## [0.11.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.10.0...v0.11.0) (2025-06-08)


### Features

* Add support for repository replication ([#55](https://github.com/lgallard/terraform-aws-ecr/issues/55)) ([5ef83b8](https://github.com/lgallard/terraform-aws-ecr/commit/5ef83b885450135ced47d7f302bf2b35b7c4d5ab))

## [0.10.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.9.2...v0.10.0) (2025-06-08)


### Features

* Add Terratest framework for automated testing ([#54](https://github.com/lgallard/terraform-aws-ecr/issues/54)) ([b5554c1](https://github.com/lgallard/terraform-aws-ecr/commit/b5554c10738af16b3238628c07460794ba09ac61))

## [0.9.2](https://github.com/lgallard/terraform-aws-ecr/compare/v0.9.1...v0.9.2) (2025-05-22)


### Bug Fixes

* resolve lifecycle prevent_destroy variable limitation - Replace single repository resource with conditional creation approach - Use separate aws_ecr_repository resources (repo and repo_protected) - Enable dynamic prevent_destroy control through var.prevent_destroy - Remove moved.tf as it's not needed with this approach - Reorganize main.tf with proper section headers ([217b4f0](https://github.com/lgallard/terraform-aws-ecr/commit/217b4f0e2823c1c95b1bc270f6f97026d771d32d))

## [0.9.1](https://github.com/lgallard/terraform-aws-ecr/compare/0.9.0...v0.9.1) (2025-05-22)


### Reverts

* Revert PR [#48](https://github.com/lgallard/terraform-aws-ecr/issues/48) - lifecycle prevent_destroy cannot use variables ([323b033](https://github.com/lgallard/terraform-aws-ecr/commit/323b033debe7f9de821850fd66efedbef42fe5a5))

## [0.9.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.8.0...v0.9.0) (2025-05-22)


### Features

* remove unused local variable to resolve tflint warning ([151b3a5](https://github.com/lgallard/terraform-aws-ecr/commit/151b3a52e09f1795d14116c33dd55637245fa252))

## [0.8.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.7.0...v0.8.0) (2025-04-18)


### Features

* **logging:** add ECR logging configuration with CloudWatch integration ([#30](https://github.com/lgallard/terraform-aws-ecr/issues/30)) ([97dab31](https://github.com/lgallard/terraform-aws-ecr/commit/97dab314b933f0b508d41b5a86c633f6bb4fba61))

## [0.7.0](https://github.com/lgallard/terraform-aws-ecr/compare/v0.6.2...v0.7.0) (2025-03-18)


### Features

* Add support for prevent_destroy in ECR repository configuration ([2a17863](https://github.com/lgallard/terraform-aws-ecr/commit/2a17863f828c44fc03849b1002591a3ef65cc9ea))
* Implement state migration for ECR repository resources ([8d4a02e](https://github.com/lgallard/terraform-aws-ecr/commit/8d4a02e782ec682b049a7fdd2e076e19e4d3f869))
* Update prevent_destroy behavior and enhance ECR repository examples ([75e5b35](https://github.com/lgallard/terraform-aws-ecr/commit/75e5b35afeaaaf1eac86afdd49a638e222403771))

## [0.6.2](https://github.com/lgallard/terraform-aws-ecr/compare/v0.6.1...v0.6.2) (2025-03-15)


### Bug Fixes

* Enhance README and variables.tf for clarity and structure ([8d5555e](https://github.com/lgallard/terraform-aws-ecr/commit/8d5555ef5858e969fa502b9210d4679a4470ebd7))
* Update release-please configuration sections for clarity ([3da3e03](https://github.com/lgallard/terraform-aws-ecr/commit/3da3e035ee7f911ad450fb09076003df664f1f7f))

## [0.6.1](https://github.com/lgallard/terraform-aws-ecr/compare/v0.6.0...v0.6.1) (2025-03-15)


### Bug Fixes

* Update changelog and release-please configuration ([bfdb2db](https://github.com/lgallard/terraform-aws-ecr/commit/bfdb2dbfcd83bb91517ce7cabd58e55c54c4945f))

## [0.6.0](https://github.com/lgallard/terraform-aws-ecr/compare/0.5.0...v0.6.0) (March 15, 2025)


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
