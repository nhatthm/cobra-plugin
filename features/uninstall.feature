Feature: Uninstall plugins

    Background:
        Given working directory is temporary

        And there is a file "config.yaml" with content:
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

        And there is a file "my-plugin/my-plugin" with content:
        """
        #!/bin/bash

        echo "my-plugin"

        """
        And file "my-plugin/my-plugin" permission is 0755

    Scenario: Uninstall an installed plugin
        When I run command "plugin uninstall my-plugin"

        Then there should be only these files:
        """
        - config.yaml
        """

        And there should be a file "config.yaml" with content:
        """
        plugins: {}

        """

        And console output is:
        """
        uninstalled my-plugin
        """

    Scenario: Uninstall a non-existing plugin
        When I run command "plugin uninstall another-plugin"

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
        Error: could not uninstall plugin: plugin does not exist
        Usage:
          my-command plugin uninstall plugin1 plugin2 ... [flags]

        Flags:
          -h, --help   help for uninstall
        """
