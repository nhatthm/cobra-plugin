Feature: Install plugins

    Background:
        Given working directory is temporary

    Scenario: Install gzip plugin (Empty storage)
        When I run command "plugin install $TEST_DIR/../../resources/fixtures/gzip/my-plugin.tar.gz"

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
                url: ""
                version: ""
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

        And there should be a file "my-plugin/my-plugin" with content:
        """
        #!/bin/bash

        """

    Scenario: Install gzip plugin (Has installed plugins)
        Given there is a file "config.yaml" with content:
        """
        plugins:
            another-plugin:
                name: another-plugin
                url: "github.com/owner/another-plugin"
                version: "0.1.4"
                description: "Another plugin"
                enabled: true
                hidden: true
                artifacts:
                    darwin/amd64:
                        file: another-plugin.tar.gz
                    linux/amd64:
                        file: another-plugin.tar.gz
                tags: []

        """

        And there is a file "another-plugin/another-plugin" with content:
        """
        #!/bin/bash

        echo "another-plugin"

        """
        And file "another-plugin/another-plugin" permission is 0755

        When I run command "plugin install $TEST_DIR/../../resources/fixtures/gzip/my-plugin.tar.gz"

        Then there should be only these files:
        """
        - config.yaml
        - another-plugin:
            - another-plugin 'perm:"0755"'
        - my-plugin:
            - my-plugin 'perm:"0755"'
        """

        And there should be a file "config.yaml" with content:
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

        And there should be a file "my-plugin/my-plugin" with content:
        """
        #!/bin/bash

        """

    Scenario: Install gzip plugin (Overwrite installed plugins)
        Given there is a file "config.yaml" with content:
        """
        plugins:
            my-plugin:
                name: my-plugin
                url: "github.com/owner/my-plugin"
                version: "0.1.4"
                description: "Another plugin"
                enabled: true
                hidden: true
                artifacts:
                    darwin/amd64:
                        file: my-plugin.tar.gz
                    linux/amd64:
                        file: my-plugin.tar.gz
                tags: []

        """

        And there is a file "my-plugin/old-plugin" with content:
        """
        #!/bin/bash

        echo "old-plugin"

        """
        And file "my-plugin/old-plugin" permission is 0755

        And there is a file "my-plugin/README.md" with content:
        """
        My Plugin
        =====

        This is my plugin
        """

        When I run command "plugin install $TEST_DIR/../../resources/fixtures/gzip/my-plugin.tar.gz"

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
                url: ""
                version: ""
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

        And there should be a file "my-plugin/my-plugin" with content:
        """
        #!/bin/bash

        """

    Scenario: Install zip plugin
        When I run command "plugin install $TEST_DIR/../../resources/fixtures/zip/my-plugin.zip"

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
                url: ""
                version: ""
                description: ""
                enabled: true
                hidden: true
                artifacts:
                    darwin/amd64:
                        file: my-plugin.zip
                    linux/amd64:
                        file: my-plugin.zip
                tags: []

        """

        And there should be a file "my-plugin/my-plugin" with content:
        """
        #!/bin/bash

        """

    Scenario: Install folder
        When I run command "plugin install $TEST_DIR/../../resources/fixtures/fs/folder"

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
                url: ""
                version: ""
                description: ""
                enabled: true
                hidden: true
                artifacts:
                    darwin/amd64:
                        file: my-plugin
                    linux/amd64:
                        file: my-plugin
                tags: []

        """

        And there should be a file "my-plugin/my-plugin" with content:
        """
        #!/bin/bash

        """

    Scenario: Install file
        When I run command "plugin install $TEST_DIR/../../resources/fixtures/fs/file"

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
                url: ""
                version: ""
                description: ""
                enabled: true
                hidden: true
                artifacts:
                    darwin/amd64:
                        file: my-plugin
                    linux/amd64:
                        file: my-plugin
                tags: []

        """

        And there should be a file "my-plugin/my-plugin" with content:
        """
        #!/bin/bash

        """

    Scenario: Install github plugin
        Given "github.com" receives "GET" request "/repos/owner/my-plugin/releases/latest"
        And "github.com" responds with status "OK" and body
        """
        {
            "name": "v1.4.2",
            "tag_name": "v1.4.2",
            "assets": [
                {
                    "id": 42,
                    "name": "my-plugin.tar.gz",
                    "content_type": "application/gzip"
                }
            ]
        }
        """

        And "github.com" receives "GET" request "/repos/owner/my-plugin/contents/?ref=v1.4.2"
        And "github.com" responds with status "OK" and body
        """
        [
            {
                "name": ".plugin.registry.yaml",
                "download_url": "my-plugin:v1.4.2:.plugin.registry.yaml:download-url"
            }
        ]
        """

        And "github.com" receives "GET" request "/owner/my-plugin/v1.4.2/.plugin.registry.yaml"
        And "github.com" responds with status "OK" and body
        """
        name: my-plugin
        url:
        hidden: true
        artifacts:
            darwin/amd64:
                file: "my-plugin.tar.gz"
            linux/amd64:
                file: "my-plugin.tar.gz"
        """

        And "github.com" receives "GET" request "/repos/owner/my-plugin/releases/assets/42"
        And "github.com" responds with status "OK" and body from file
        """
        $TEST_DIR/../../resources/fixtures/gzip/my-plugin.tar.gz
        """

        When I run command "plugin install github.com/owner/my-plugin"

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
                url: https://github.com/owner/my-plugin
                version: 1.4.2
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

        And there should be a file "my-plugin/my-plugin" with content:
        """
        #!/bin/bash

        """

        And console output is:
        """
        installed github.com/owner/my-plugin
        """
