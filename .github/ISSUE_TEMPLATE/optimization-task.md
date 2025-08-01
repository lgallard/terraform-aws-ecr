---
name: ⚡ Optimization Task
about: Performance and efficiency improvements for the Terraform module
title: "Optimize: [Brief description]"
labels: ["type/optimization", "priority/medium"]
assignees: []
---

## 🎯 Objective
<!-- Clear description of the performance/efficiency improvement -->

## 📊 Current Performance Analysis
<!-- Analysis of current performance issues -->

### Affected Components
<!-- List specific resources, data sources, or logic -->
- `resource.type.name` in `path/to/file.tf` (lines X-Y)
- Logic pattern in `path/to/another.tf` (lines A-B)

### Performance Issues Identified
<!-- Specific performance problems -->
- [ ] Issue 1: Description and impact
- [ ] Issue 2: Description and impact
- [ ] Issue 3: Description and impact

### Metrics & Benchmarks
<!-- If available, provide current performance data -->
- Current apply time: X seconds
- Resource creation parallelization: Y resources
- Memory usage: Z MB

## 🎯 Optimization Goals
<!-- Specific performance improvements expected -->

### Target Metrics
- [ ] Reduce apply time by X%
- [ ] Improve resource parallelization
- [ ] Reduce memory footprint
- [ ] Optimize resource dependencies

## 🔧 Technical Implementation

### Optimization Strategy
<!-- High-level approach for the optimization -->

### Implementation Details
```hcl
# Current implementation (inefficient)
<!-- Show current code -->

# Optimized implementation
<!-- Show proposed optimized code -->
```

### Expected Benefits
- **Performance**: Specific improvements expected
- **Resource Efficiency**: How resources will be better utilized
- **Scalability**: How this improves module scalability

### Dependencies
<!-- Link to other issues -->
- Depends on: #XXX
- Blocks: #YYY

## 📋 Acceptance Criteria
<!-- Detailed checklist for completion -->
- [ ] Performance improvement measurably achieved
- [ ] No regression in functionality
- [ ] Backward compatibility maintained
- [ ] Resource dependencies optimized
- [ ] Apply/destroy times improved
- [ ] Memory usage optimized (if applicable)
- [ ] Tests validate performance improvements

## 🏷️ Effort Estimation
<!-- Select one -->
- [ ] Small (< 4 hours)
- [ ] Medium (4-16 hours)
- [ ] Large (> 16 hours)

## 📈 Success Metrics
<!-- How to measure success -->
- [ ] Before/after benchmarks documented
- [ ] Performance regression tests added
- [ ] Resource creation time measured

## 💡 Additional Context
<!-- Any additional performance considerations -->

---
**AI Tool Consumption Notes:**
- Performance metrics provide quantifiable targets for automation
- Before/after code examples enable AI-assisted optimization
- Success metrics are measurable for automated validation
- Resource-specific references enable targeted optimization
