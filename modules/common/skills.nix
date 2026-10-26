# Agent skills shared by macOS and Ubuntu.
{ inputs, config, hostVars, ... }:

let
  skillsRepo = inputs.mattpocock-skills;
  
  skillsDir = "${skillsRepo}/skills";
  topEntries = builtins.readDir skillsDir;

  # Auto-discover skills in skillsRepo:
  # 1. Direct skills located at skills/<name>/SKILL.md
  directSkills = builtins.filter
    (name: topEntries.${name} == "directory" && builtins.pathExists "${skillsDir}/${name}/SKILL.md")
    (builtins.attrNames topEntries);

  # 2. Categorized skills located at skills/<category>/<name>/SKILL.md (e.g. engineering, productivity)
  categories = builtins.filter
    (name: topEntries.${name} == "directory" && name != "deprecated" && !builtins.pathExists "${skillsDir}/${name}/SKILL.md")
    (builtins.attrNames topEntries);

  getSkillsInCat = cat:
    let
      catDir = "${skillsDir}/${cat}";
      subEntries = builtins.readDir catDir;
      skillNames = builtins.filter
        (name: subEntries.${name} == "directory" && builtins.pathExists "${catDir}/${name}/SKILL.md")
        (builtins.attrNames subEntries);
    in
      map (name: "${cat}/${name}") skillNames;

  discoveredSkills = directSkills ++ (builtins.concatLists (map getSkillsInCat categories));

  # Skills to exclude if any (by base name or full path)
  excludedSkills = [ ];

  skills = builtins.filter
    (s: !(builtins.elem s excludedSkills) && !(builtins.elem (builtins.baseNameOf s) excludedSkills))
    discoveredSkills;

  # List of local custom skills (directories in nix/skills/)
  localSkills = [
    "academic-pptx"
    "okf-obsidian-graph"
    "repo-experiment-story"
    "setup-agent-standards"
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
