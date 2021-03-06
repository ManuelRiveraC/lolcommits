Feature: Basic UI functionality

  Scenario: App just runs
    When I get help for "lolcommits"
    Then the exit status should be 0
    And the banner should be present

  Scenario: Enable in a naked git repository
    Given a git repository named "loltest" with no "post-commit" hook
    When I cd to "loltest"
    And I successfully run `lolcommits --enable`
    Then the output should contain "installed lolcommmit hook as:"
    And the output should contain "(to remove later, you can use: lolcommits --disable)"
    And a file named ".git/hooks/post-commit" should exist
    And the exit status should be 0

  Scenario: Disable in a enabled git repository
    Given a git repository named "lolenabled" with a "post-commit" hook
    When I cd to "lolenabled"
    And I successfully run `lolcommits --disable`
    Then the output should contain "removed"
    And a file named ".git/hooks/post-commit" should not exist
    And the exit status should be 0

  Scenario: Trying to enable while not in a git repo fails
    Given a directory named "svnrulez"
    When I cd to "svnrulez"
    And I run `lolcommits --enable`
    Then the output should contain "You don't appear to be in the base directory of a git project."
    And the exit status should be 1

  Scenario: Commiting in an enabled repo triggers successful capture
    Given a git repository named "testcapture"
    And an empty file named "testcapture/FOOBAR"
    When I cd to "testcapture"
    And I successfully run `lolcommits --enable`
    And I successfully run `git add .`
    And I successfully run `git commit -m 'can haz commit'`
    Then the output should contain "*** Preserving this moment in history."
    And a directory named "../.lolcommits/testcapture" should exist
    And a file named "../.lolcommits/testcapture/tmp_snapshot.jpg" should not exist
    And there should be 1 jpg in "../.lolcommits/testcapture"

  Scenario: Commiting in an enabled repo subdirectory triggers successful capture of parent repo
    Given a git repository named "testcapture"
    And a directory named "testcapture/subdir"
    And an empty file named "testcapture/subdir/FOOBAR"
    When I cd to "testcapture/"
    And I successfully run `lolcommits --enable`
    Then I cd to "subdir/"
    And I successfully run `git add .`
    And I successfully run `git commit -m 'can haz commit'`
    Then the output should contain "*** Preserving this moment in history."
    And a directory named "../../.lolcommits/testcapture" should exist
    And a file named "../../.lolcommits/testcapture/tmp_snapshot.jpg" should not exist
    And there should be 1 jpg in "../../.lolcommits/testcapture"

  Scenario: Show plugins
    When I successfully run `lolcommits --plugins`
    Then the output should contain a list of plugins

  #
  # a stab at recreating ken's scenarios with native aruba steps, not quite there yet in terms
  # of elegance, but its passing so might as well leave in for now.
  #
  Scenario: Configuring plugin (with native aruba steps)
    Given a git repository named "config-test"
    When I cd to "config-test"
    And I run `lolcommits --config` interactively
    When I type "loltext"
    When I type "true"
    Then the output should contain a list of plugins
    And the output should contain "Name of plugin to configure:"
    Then the output should contain "enabled:"
    Then the output should contain "Successfully Configured"
    And a file named "../.lolcommits/config-test/config.yml" should exist
    When I successfully run `lolcommits --show-config`
    Then the output should contain "loltext:"
    And the output should contain "enabled: true"

  Scenario: Configuring Plugin
    Given a git repository named "config-test"
    When I cd to "config-test"
    And I run `lolcommits --config` and wait for output
    When I enter "loltext" for "Name of plugin to configure"
    And I enter "true" for "enabled"
    Then I should be presented "Successfully Configured"
    And a file named "../.lolcommits/config-test/config.yml" should exist
    When I successfully run `lolcommits --show-config`
    Then the output should contain "loltext:"
    And the output should contain "enabled: true"
  
  Scenario: Configuring Plugin In Test Mode
    Given a git repository named "testmode-config-test"
    When I cd to "testmode-config-test"
    And I run `lolcommits --config --test` and wait for output
    And I enter "loltext" for "Name of plugin to configure"
    And I enter "true" for "enabled"
    Then I should be presented "Successfully Configured"
    And a file named "../.lolcommits/test/config.yml" should exist
    When I successfully run `lolcommits --test --show-config`
    Then the output should contain "loltext:"
    And the output should contain "enabled: true"

  Scenario: test capture should work regardless of whether in a git repository
    Given a directory named "nothingtoseehere"
    When I cd to "nothingtoseehere"
    And I run `lolcommits --test --capture`
    Then the output should contain "*** Capturing in test mode."
    And the output should not contain "path does not exist (ArgumentError)"
    And the exit status should be 0 

  Scenario: test capture should store in its own test directory
    Given a git repository named "randomgitrepo"
    When I cd to "randomgitrepo"
    And I successfully run `lolcommits --test --capture`
    Then a directory named "../.lolcommits/test" should exist
    And a directory named "../.lolcommits/randomgitrepo" should not exist

  Scenario: last command should work properly when in a lolrepo
    Given a git repository named "randomgitrepo"
    And a loldir named "randomgitrepo" with 2 lolimages
    And I cd to "randomgitrepo"
    When I run `lolcommits --last`
    Then the exit status should be 0

  Scenario: last command should fail gracefully if not in a lolrepo
    Given a directory named "gitsuxcvs4eva"
    And I cd to "gitsuxcvs4eva"
    When I run `lolcommits --last`
    Then the output should contain "Can't do that since we're not in a valid git repository!"
    Then the exit status should be 1

  Scenario: last command should fail gracefully if zero lolimages in lolrepo
    Given a git repository named "randomgitrepo"
    And a loldir named "randomgitrepo" with 0 lolimages
    And I cd to "randomgitrepo"
    When I run `lolcommits --last`
    Then the output should contain "No lolcommits have been captured for this repository yet."
    Then the exit status should be 1

  Scenario: browse command should work properly when in a lolrepo
    Given a git repository named "randomgitrepo"
    And a loldir named "randomgitrepo" with 2 lolimages
    And I cd to "randomgitrepo"
    When I run `lolcommits --browse`
    Then the exit status should be 0

  Scenario: browse command should fail gracefully when not in a lolrepo
    Given a directory named "gitsuxcvs4eva"
    And I cd to "gitsuxcvs4eva"
    When I run `lolcommits --browse`
    Then the output should contain "Can't do that since we're not in a valid git repository!"
    Then the exit status should be 1

