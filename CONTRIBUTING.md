# Contributing Guidelines

## Commit Message Format

We follow a strict commit message format to maintain consistency and clarity in our project history.

### Structure

```
<type>: <subject line - max 50 characters>

NEW FEATURES: (highest priority - list first)
* new <feature description>
* new <feature description>

FIXES: (second priority)
* fix <bug description>  
* fix <bug description>

IMPROVEMENTS: (third priority)
* improve <existing feature improvement>
* update <enhancement to existing functionality>

CHANGES: (lowest priority - list last)
* change <structural or other changes>
* remove <removed functionality>
```

### Rules

1. **Subject Line**: Use imperative mood, no period, max 50 characters
2. **Priority Order**: Always list NEW FEATURES first, then FIXES, then IMPROVEMENTS, then CHANGES
3. **Bullet Format**: Use `* <prefix> <description>` format
4. **Prefixes**: 
   - `new` - for new features/capabilities
   - `add` - for adding new components
   - `fix` - for bug fixes
   - `improve` - for enhancing existing features
   - `update` - for updating existing functionality
   - `change` - for structural changes
   - `remove` - for removing functionality
5. **Tense**: Use present tense ("add" not "added")
6. **Specificity**: Be specific about what was accomplished

### Examples

**Good commit message:**
```
Add automatic Karen installation and smart settings detection

NEW FEATURES:
* new interactive installation system with confirmation prompts
* new automatic settings detection using pattern matching
* new yesno() utility for user interaction

IMPROVEMENTS:
* simplified environment management from 100+ lines to 12 lines
* elegant settings chain: defaults → .env → fallbacks

CHANGES:
* replaced karen-helper with modular helper system
```

**Bad commit message:**
```
Updated stuff and fixed things
```

### Setup

To use the commit message template automatically:

```bash
git config commit.template .gitmessage
```

This will open your editor with the template when you run `git commit`.
