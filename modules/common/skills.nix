# Agent skills shared by macOS and Ubuntu.
{ inputs, config, hostVars, ... }:

let
  skillsRepo = inputs.mattpocock-skills;
  
  # List of skills to link (relative to the repo's skills/ directory)
  skills = [
    # engineering
    "engineering/ask-matt"
    "engineering/diagnosing-bugs"
    "engineering/grill-with-docs"
    "engineering/triage"
    "engineering/improve-codebase-architecture"
    "engineering/setup-matt-pocock-skills"
    "engineering/tdd"
    "engineering/to-spec"
    "engineering/to-tickets"
    "engineering/wayfinder"
    "engineering/implement"
    "engineering/prototype"
    "engineering/research"
    "engineering/domain-modeling"
    "engineering/codebase-design"
    "engineering/code-review"
    "engineering/resolving-merge-conflicts"

    # productivity
    "productivity/grill-me"
    "productivity/grilling"
    "productivity/handoff"
    "productivity/teach"
    "productivity/writing-great-skills"

    # misc
    "misc/setup-pre-commit"
    "misc/git-guardrails-claude-code"
    "misc/scaffold-exercises"
    "misc/migrate-to-shoehorn"

    # personal
    "personal/obsidian-vault"
    "personal/edit-article"

    # in-progress
    "in-progress/setup-ts-deep-modules"
    "in-progress/loop-me"
    "in-progress/wizard"
    "in-progress/writing-fragments"
    "in-progress/writing-shape"
    "in-progress/claude-handoff"
    "in-progress/writing-beats"
  ];

  # List of local custom skills (directories in nix/skills/)
  localSkills = [
    "okf-obsidian-graph"
  ];

  # Helper function to get the name of the skill from its path (e.g. "engineering/tdd" -> "tdd")
  getSkillName = path: builtins.baseNameOf path;

  # Generate home.file mappings for the different agents
  mkSkillFiles = path:
    let
      name = getSkillName path;
      src = "${skillsRepo}/skills/${path}";
    in {
      # 1. Codex / general Agent-Skills-standard location
      ".agents/skills/${name}".source = src;
      
      # 2. Claude Code location
      ".claude/skills/${name}".source = src;
      
      # 3. Google Antigravity (agy) location
      ".gemini/config/skills/${name}".source = src;
    };

  # Generate home.file mappings for local custom skills using out-of-store symlinks
  mkLocalSkillFiles = name: {
    ".agents/skills/${name}".source = config.lib.file.mkOutOfStoreSymlink "${hostVars.repoPath}/skills/${name}";
    ".claude/skills/${name}".source = config.lib.file.mkOutOfStoreSymlink "${hostVars.repoPath}/skills/${name}";
    ".gemini/config/skills/${name}".source = config.lib.file.mkOutOfStoreSymlink "${hostVars.repoPath}/skills/${name}";
  };

  # Merge all attribute sets
  externalSkillFiles = builtins.foldl' (acc: path: acc // mkSkillFiles path) {} skills;
  localSkillFiles = builtins.foldl' (acc: name: acc // mkLocalSkillFiles name) {} localSkills;
  
  allSkillFiles = externalSkillFiles // localSkillFiles;
in
{
  home.file = allSkillFiles;
}
