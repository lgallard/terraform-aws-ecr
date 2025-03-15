# Changelog

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
