Feature: Enable plugins

    Background:
        Given working directory is temporary

        And there is a file "my-plugin/my-plugin" with content:
        """
        #!/bin/bash

        echo "my-plugin"

        """
        And file "my-plugin/my-plugin" permission is 0755

    Scenario: Enable a disabled plugin
        Given there is a file "config.yaml" with content:
        """
        plugins:
            my-plugin:
                name: my-plugin
                url: github.com/owner/my-plugin
                version: 0.1.4
                description: ""
                enabled: false
                hidden: true
                artifacts:
                    darwin/amd64:
                        file: my-plugin.tar.gz
                    linux/amd64:
                        file: my-plugin.tar.gz
                tags: []

        """

        When I run command "plugin enable my-plugin"

        Then there should be only these files:
        """
        - config.yaml
        - my-plugin:
            - my-plugin 'perm:"0755"'
        """

        And there should be a file "config.yaml" with content:
        """
        plugins:
            my-plugin:
                name: my-plugin
                url: github.com/owner/my-plugin
                version: 0.1.4
                description: ""
                enabled: true
                hidden: true
                artifacts:
                    darwin/amd64:
                        file: my-plugin.tar.gz
                    linux/amd64:
                        file: my-plugin.tar.gz
                tags: []

        """

        And console output is:
        """
        enabled my-plugin
        """

    Scenario: Enable an enabled plugin
        Given there is a file "config.yaml" with content:
        """
        plugins:
            my-plugin:
                name: my-plugin
                url: github.com/owner/my-plugin
                version: 0.1.4
                description: ""
                enabled: true
                hidden: true
                artifacts:
                    darwin/amd64:
                        file: my-plugin.tar.gz
                    linux/amd64:
                        file: my-plugin.tar.gz
                tags: []

        """

        When I run command "plugin enable my-plugin"

        Then there should be only these files:
        """
        - config.yaml
        - my-plugin:
            - my-plugin 'perm:"0755"'
        """

        And there should be a file "config.yaml" with content:
        """
        plugins:
            my-plugin:
                name: my-plugin
                url: github.com/owner/my-plugin
                version: 0.1.4
                description: ""
                enabled: true
                hidden: true
                artifacts:
                    darwin/amd64:
                        file: my-plugin.tar.gz
                    linux/amd64:
                        file: my-plugin.tar.gz
                tags: []

        """

        And console output is:
        """
        enabled my-plugin
        """

    Scenario: Enable a non-existing plugin
        Given there is a file "config.yaml" with content:
        """
        plugins:
            my-plugin:
                name: my-plugin
                url: github.com/owner/my-plugin
                version: 0.1.4
                description: ""
                enabled: false
                hidden: true
                artifacts:
                    darwin/amd64:
                        file: my-plugin.tar.gz
                    linux/amd64:
                        file: my-plugin.tar.gz
                tags: []

        """

        When I run command "plugin enable another-plugin"

        Then there should be only these files:
        """
        - config.yaml
        - my-plugin:
            - my-plugin 'perm:"0755"'
        """

        And there should be a file "config.yaml" with content:
        """
        plugins:
            my-plugin:
                name: my-plugin
                url: github.com/owner/my-plugin
                version: 0.1.4
                description: ""
                enabled: false
                hidden: true
                artifacts:
                    darwin/amd64:
                        file: my-plugin.tar.gz
                    linux/amd64:
                        file: my-plugin.tar.gz
                tags: []

        """

        And console output is:
        """
        Error: could not enable plugin: plugin does not exist
        Usage:
          my-command plugin enable plugin1 plugin2 ... [flags]

        Flags:
          -h, --help   help for enable
        """
