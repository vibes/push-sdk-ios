swiftlint.lint_files

# Warn about undocumented symbols in modified files.
jazzy.check warn: :modified

# Check code coverage and notify about low coverage
slather.configure("VibesPush.xcodeproj", "VibesPush-iOS", options: {
  workspace: "VibesPush.xcworkspace",
})
slather.notify_if_modified_file_is_less_than(minimum_coverage: 60)
slather.show_coverage

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500
