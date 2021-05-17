Feature: Plugin Command

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

        for i in `seq 1 $#`; do
            echo "arg $i: ${!i}"
        done

        """
        And file "my-plugin/my-plugin" permission is 0755

    Scenario: Read from stdin and write to stdout
        When I run plugin "my-plugin" with args "hello world"

        Then console output is:
        """
        arg 1: hello
        arg 2: world
        """
