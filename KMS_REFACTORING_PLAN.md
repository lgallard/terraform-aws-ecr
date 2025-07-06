# KMS Key Configuration Refactoring Plan

**Issue:** #36 - refactor: Improve KMS key configuration

## Overview

This plan outlines the systematic approach to refactor the KMS key configuration in the terraform-aws-ecr module, implementing a submodule pattern for better separation of concerns and adding granular policy customization options.

## Phase 1: Analysis and Preparation

**Goal:** Understand current KMS implementation and plan refactoring approach

### Tasks:
- [ ] Search for existing KMS-related files and resources
- [ ] Identify current KMS variables and their usage
- [ ] Review existing KMS key policies and configurations
- [ ] Document current dependencies and relationships
- [ ] Plan submodule interface design

## Phase 2: KMS Submodule Creation

**Goal:** Create dedicated KMS submodule with clean separation of concerns

### Tasks:
- [ ] Create `modules/kms/` directory structure
- [ ] Create core files: `main.tf`, `variables.tf`, `outputs.tf`, `policies.tf`, `locals.tf`
- [ ] Move existing KMS resources (`aws_kms_key`, `aws_kms_alias`) to submodule
- [ ] Define clear input/output interfaces
- [ ] Implement policy template system

## Phase 3: Enhanced Configuration Options

**Goal:** Add granular customization capabilities

### Tasks:
- [ ] Add key rotation configuration variables
- [ ] Implement custom policy statement support
- [ ] Add support for additional IAM principals
- [ ] Create enhanced tagging schema
- [ ] Add key specification and origin options
- [ ] Implement flexible policy generation logic

## Phase 4: Integration and Testing

**Goal:** Integrate submodule with main module and validate functionality

### Tasks:
- [ ] Update main module to use KMS submodule
- [ ] Ensure backward compatibility
- [ ] Create comprehensive test scenarios
- [ ] Validate all configuration options
- [ ] Test example deployments

## Phase 5: Documentation and Examples

**Goal:** Provide comprehensive documentation and usage examples

### Tasks:
- [ ] Update main README with KMS configuration section
- [ ] Create detailed usage examples
- [ ] Document new variables and their purposes
- [ ] Add security best practices guide
- [ ] Create migration guide for existing users

## Key Implementation Details

### New Variables to Add:
- `kms_key_rotation_enabled` - Enable/disable key rotation
- `kms_key_rotation_period` - Rotation period in days
- `kms_key_policy_statements` - Custom policy statements
- `kms_additional_principals` - Additional IAM principals
- `kms_custom_tags` - Additional tags for KMS resources
- `kms_key_spec` - Key specification (RSA, ECC, etc.)

### Submodule Structure:
```
modules/kms/
├── main.tf          # KMS key and alias resources
├── variables.tf     # All KMS-related input variables
├── outputs.tf       # KMS key ARN, ID, alias outputs
├── policies.tf      # KMS key policy templates and data sources
└── locals.tf        # Local calculations for tags and policy generation
```

### Backward Compatibility Considerations:
- Ensure existing variable names continue to work
- Maintain the same output structure
- Keep default behavior unchanged for existing users
- Use variable validation to provide helpful error messages

### Testing Strategy:
- Create unit tests for the KMS submodule
- Integration tests with various ECR configurations
- Test all the new configuration options
- Validate that examples actually work
- Performance testing with complex policies

## Success Criteria

- [ ] All existing functionality preserved
- [ ] New KMS features work as expected
- [ ] Examples deploy successfully
- [ ] Documentation is comprehensive
- [ ] Code follows Terraform best practices
- [ ] Enhanced security posture

## Quality Gates

- [ ] Code review by maintainers
- [ ] All tests pass
- [ ] `terraform fmt` and `validate` pass
- [ ] Documentation review
- [ ] Example deployment verification

## Implementation Order and Dependencies

1. **Phase 1** (Analysis) - Prerequisite for everything else
2. **Phase 2a** (Basic submodule structure) - Foundation for all enhancements
3. **Phase 2b** (Move existing logic) - Ensures nothing breaks
4. **Phase 3** (Enhanced options) - Builds on solid foundation
5. **Phase 4a** (Main module integration) - Connects everything together
6. **Phase 4b** (Examples and testing) - Validates implementation
7. **Phase 5** (Documentation) - Final step to make it usable

## Benefits

- Better separation of concerns
- More flexible KMS key configuration
- Enhanced security posture
- Improved compliance with organizational security requirements
- Better maintainability and testability
- Comprehensive documentation and examples
