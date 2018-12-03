module Overcommit::Hook::CommitMsg
  # Ensures a JIRA Issue Key is included in the commit message.
  #
  # It may seem odd to do this here instead of in a prepare-commit-msg hook, but
  # the reality is that if you want to _ensure_ the Issue Key is included then
  # you need to do it in a commit-msg hook. This is because the user could still
  # edit the message after a prepare-commit-msg hook was run.
  class JiraIssueKey < Base
    def run
      # Get name of the current branch.
      git_rev_parse = execute(['git', 'rev-parse', '--abbrev-ref', 'HEAD'])
      return :fail, 'Failed to get the name of the current branch' unless git_rev_parse.success?
      branch = git_rev_parse.stdout.strip

      # If rebasing then the branch will be HEAD so we need to be more clever.
      if branch == 'HEAD'
        path = File.join(Overcommit::Utils.repo_root, '.git', 'rebase-merge', 'head-name')
        return :fail, 'Unable to get branch name from detatched HEAD' unless File.file?(path)
        branch = File.read(path)
      end

      # Ignore certain branches.
      return :warn, "Ignoring branch '#{branch}'" if ignore?(branch)

      # Allow certain magic words
      return :pass if magic?(subject)

      # Now get the Issue Key from the branch name.
      issue_key = extract_issue_key(branch)
      if issue_key.nil?
        return :fail, "Current branch '#{branch}' does not match the Issue Key pattern '#{issue_pattern}'"
      end

      # Does the subject start with the Issue Key?
      # TODO: Allow the issue key in other positions.
      return :pass if subject.start_with?(issue_key)

      # If this is a merge commit then it can appear as the destination of the auto-generated commit message.
      git_merge_commit = execute(['git', 'rev-list', '--merges', '-n', '1', 'HEAD~1..HEAD'])
      return :fail, 'Failed to check if the current branch is a merge' unless git_rev_parse.success?
      unless git_merge_commit.stdout.strip.empty?
        # This is a merge so it must contain the branch name in the destination.
        issue_merge_pattern = merge_pattern(issue_key)
        # TODO: Detect the difference between editing a merge commit and making a new commit after a merge commit
        return :pass if issue_merge_pattern.match?(subject)
        return :fail, "Subject '#{subject}' does not contain the Issue Key '#{issue_key}' or match Issue Key Merge pattern '#{issue_merge_pattern}'" unless insert_automatically
      else
        return :fail, "Subject '#{subject}' does not contain the Issue Key '#{issue_key}'" unless insert_automatically
      end

      insert_issue_key(issue_key)
      return :pass
    end

    def ignore?(branch)
      patterns = ignore_patterns || []
      return patterns.any? { |pattern| Regexp.new(pattern).match?(branch) }
    end

    def ignore_patterns
      return config['ignore']
    end

    def extract_issue_key(branch)
      return branch.match(issue_pattern) { |m| m[1] }
    end

    def issue_pattern
      # Be careful with the pattern here.
      # It needs to be able to handle other tokens in the branch name such as refs/heads, origin, or others.
      pattern = config['issue_pattern'] || '^(?:.*/)*(.+?\-\d+).*'
      return Regexp.new(pattern)
    end
    
    def merge_pattern(issue_key)
      # TODO: Do we need to handle other tokens here?
      pattern = config['merge_pattern'] || '^Merge .* into '
      return Regexp.new(pattern + Regexp.quote(issue_key))
    end

    def magic?(subject)
      pattern = magic_pattern
      return false if pattern.nil?
      return Regexp.new(pattern).match?(subject)
    end

    def magic_pattern
      return config['magic_pattern']
    end

    def subject_index
      @subject_index ||= find_subject_index
    end

    def find_subject_index
      # Git treats the first non-empty line as the subject.
      commit_message_lines.find_index { |line| !line.strip.empty? }
    end

    def subject
      @subject ||= find_subject
    end

    def find_subject
      # TODO: Implement multi-line subjects.
      index = subject_index
      return nil if index.nil?
      return commit_message_lines[index]
    end

    def insert_automatically
      return config['insert_automatically'] || false
    end

    def insert_issue_key(issue_key)
      first_lines = commit_message_lines.take(subject_index)
      # TODO: This assumes that the subject is only one line.
      last_lines = commit_message_lines.drop(subject_index + 1)
      updated_subject = issue_key + ' ' + subject
      updated_message = first_lines.push(updated_subject).concat(last_lines).join
      update_commit_message(updated_message)
    end
  end
end
