Feature: List plugins

    Background:
        Given working directory is temporary

    Scenario: No plugins
        When I run command "plugin list"

        Then console output is:
        """
          NAME   VERSION   ENABLED   DESCRIPTION
        ------------------------------------------
        """

    Scenario: Has plugins
        Given there is a file "config.yaml" with content:
        """
        plugins:
            another-plugin:
                name: another-plugin
                url: github.com/owner/another-plugin
                version: 0.1.4
                description: Another plugin
                enabled: true
                hidden: true
                artifacts:
                    darwin/amd64:
                        file: another-plugin.tar.gz
                    linux/amd64:
                        file: another-plugin.tar.gz
                tags: []
            my-plugin:
                name: my-plugin
                url: ""
                version: ""
                description: My plugin
                enabled: false
                hidden: true
                artifacts:
                    darwin/amd64:
                        file: my-plugin.tar.gz
                    linux/amd64:
                        file: my-plugin.tar.gz
                tags: []

        """

        When I run command "plugin list"

        Then console output is:
        """
               NAME        VERSION   ENABLED    DESCRIPTION
        -------------------------------------------------------
          another-plugin   0.1.4     true      Another plugin
          my-plugin                  false     My plugin
        """
