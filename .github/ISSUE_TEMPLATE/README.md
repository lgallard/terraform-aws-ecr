# Issue Templates

This directory contains standardized GitHub issue templates for consistent project management and development workflows.

## 📋 Available Templates

### 1. **Project Roadmap** (`project-roadmap.md`)
Comprehensive project tracking and progress management for multi-issue initiatives.

**When to use:**
- Large refactoring projects spanning multiple issues
- Feature development initiatives with multiple phases
- Performance optimization projects
- Any multi-week/multi-month development effort

**Key features:**
- Phase-based organization
- Progress tracking with percentages
- Recently completed section for audit trail
- 30-second manual update process
- AI tool integration ready

### 2. **Refactoring Task** (`refactoring-task.md`)
Structured template for code refactoring tasks.

### 3. **Enhancement Task** (`enhancement-task.md`)
Template for feature enhancements and improvements.

### 4. **Optimization Task** (`optimization-task.md`)
Template for performance and efficiency improvements.

## 🚀 Using the Project Roadmap Template

### **Quick Start:**
1. **Create New Issue** → Select "📋 Project Roadmap" template
2. **Replace placeholders** in square brackets `[PROJECT_NAME]`
3. **Customize phases** based on your project scope
4. **Add related issues** as they are created
5. **Use 30-second update process** when issues complete

### **Template Customization:**
- **PROJECT_NAME**: Your initiative name (e.g., "ECR Module Optimization")
- **PROJECT_DESCRIPTION**: Brief overview of goals and scope
- **Phases**: Typically 2-3 phases, customize names and descriptions
- **Success Metrics**: Quantifiable goals specific to your project
- **Labels**: Apply consistent labeling for easy filtering

### **Maintenance Workflow:**
When a tracked issue closes:
1. Get GitHub notification
2. Open roadmap issue → Edit
3. Change `[ ]` to `[x]` for completed item
4. Add to "Recently Completed" with date/PR
5. Update progress percentages
6. Save (30 seconds total!)

## 🔧 Template Philosophy

### **Design Principles:**
- **Zero automation overhead** - Manual updates, no workflows to maintain
- **Professional appearance** - Comprehensive progress tracking
- **GitHub native features** - Uses task lists for automatic progress bars
- **Reusable across projects** - Same pattern works everywhere
- **AI tool friendly** - Structured data for automation

### **Proven Success:**
Based on the successful ECR Module Optimization Initiative (issue #125) which achieved:
- 82% reduction in main.tf size (1,321 → 237 lines)
- Clear project visibility and progress tracking
- Efficient manual maintenance workflow
- Professional project management appearance

## 🎯 Best Practices

### **For Project Managers:**
- Use consistent labeling across all related issues
- Update roadmap within 24 hours of issue completion
- Link all related PRs in the completion entries
- Celebrate achievements in the "Recently Completed" section

### **For Contributors:**
- Reference the roadmap issue in your PR descriptions
- Follow the established templates for consistency
- Update progress if you have edit permissions

### **For AI Tools:**
- Look for `<!-- Template: template-name.md -->` headers
- Use structured data format for automation
- Follow acceptance criteria for validation
- Link back to roadmap in issue comments

---

## 📚 Examples

See issue #125 in this repository for a real-world example of the project roadmap template in action, tracking a successful multi-phase optimization initiative.
