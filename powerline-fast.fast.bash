# function definitions for fast SCM 
function __fast_parse_git_branch {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/*\(.*\)/\1/'
}

function __fast_parse_git_dirty {
    [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]] && echo "*"
}

function __fast_parse_git_prompt_branch_var {
  if _git-branch &> /dev/null; then
    SCM_GIT_DETACHED="false"
    SCM_BRANCH="${SCM_THEME_BRANCH_PREFIX}\$(_git-friendly-ref)$(_git-remote-info)"
  else
    SCM_GIT_DETACHED="true"
    local detached_prefix
    if _git-tag &> /dev/null; then
      detached_prefix=${SCM_THEME_TAG_PREFIX}
    else
      detached_prefix=${SCM_THEME_DETACHED_PREFIX}
    fi
    SCM_BRANCH="${detached_prefix}\$(_git-friendly-ref)"
  fi
}

function __fast_parse_git_prompt_vars0 {
  IFS=$'\t' read -r commits_behind commits_ahead <<< "$(_git-upstream-behind-ahead)"
  [[ "${commits_ahead}" -gt 0 ]] && SCM_BRANCH+=" ${SCM_GIT_AHEAD_CHAR}${commits_ahead}"
  [[ "${commits_behind}" -gt 0 ]] && SCM_BRANCH+=" ${SCM_GIT_BEHIND_CHAR}${commits_behind}"
}

function __fast_parse_git_prompt_vars1 {
  # local stash_count
  stash_count="$(git stash list 2> /dev/null | wc -l | tr -d ' ')"
  [[ "${stash_count}" -gt 0 ]] && SCM_BRANCH+=" ${SCM_GIT_STASH_CHAR_PREFIX}${stash_count}${SCM_GIT_STASH_CHAR_SUFFIX}"
  SCM_STATE=${GIT_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
}

function __fast_parse_git_prompt_vars2 {
  if ! _git-hide-status; then
    IFS=$'\t' read -r untracked_count unstaged_count staged_count <<< "$(_git-status-counts)"
    if [[ "${untracked_count}" -gt 0 || "${unstaged_count}" -gt 0 || "${staged_count}" -gt 0 ]]; then
      SCM_DIRTY=1
      if [[ "${SCM_GIT_SHOW_DETAILS}" = "true" ]]; then
        [[ "${staged_count}" -gt 0 ]] && SCM_BRANCH+=" ${SCM_GIT_STAGED_CHAR}${staged_count}" && SCM_DIRTY=3
        [[ "${unstaged_count}" -gt 0 ]] && SCM_BRANCH+=" ${SCM_GIT_UNSTAGED_CHAR}${unstaged_count}" && SCM_DIRTY=2
        [[ "${untracked_count}" -gt 0 ]] && SCM_BRANCH+=" ${SCM_GIT_UNTRACKED_CHAR}${untracked_count}" && SCM_DIRTY=1
      fi
      SCM_STATE=${GIT_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    fi
  fi
}

function __fast_parse_git_prompt_vars3 {
  [[ "${SCM_GIT_SHOW_CURRENT_USER}" == "true" ]] && SCM_BRANCH+="$(git_user_info)"
  SCM_PREFIX=${GIT_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
  SCM_SUFFIX=${GIT_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
  SCM_CHANGE=$(_git-short-sha 2>/dev/null || echo "")
}

function scm_promot_vars_fast {
  scm
  scm_prompt_char 
  # -----
  # local stash_count
  # -----
  # time __fast_parse_git_prompt_branch_var
  # time __fast_parse_git_prompt_vars0 
  # time __fast_parse_git_prompt_vars1
  # time __fast_parse_git_prompt_vars2 
  # time __fast_parse_git_prompt_vars3
  # __fast_parse_git_prompt_branch_var 
  # __fast_parse_git_prompt_vars0 
  # __fast_parse_git_prompt_vars1
  # __fast_parse_git_prompt_vars2 
  # __fast_parse_git_prompt_vars3
  SCM_BRANCH=$(__fast_parse_git_branch)
}
