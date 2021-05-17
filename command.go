package cobraplugin

import (
	registry "github.com/nhatthm/plugin-registry"
	_ "github.com/nhatthm/plugin-registry-github" // Register github installer.
	"github.com/spf13/cobra"
)

// NewCommand creates a new plugin command.
func NewCommand(path string, options ...registry.Option) (*cobra.Command, *Registry, error) {
	r, err := NewRegistry(path, options...)
	if err != nil {
		return nil, nil, err
	}

	cmd := &cobra.Command{
		Use:   "plugin",
		Short: "manage plugins",
		Long:  "install, list, enable, disable, or uninstall plugins",
	}

	cmd.AddCommand(newListCommand(r))
	cmd.AddCommand(newEnableCommand(r))
	cmd.AddCommand(newDisableCommand(r))
	cmd.AddCommand(newInstallCommand(r))
	cmd.AddCommand(newUninstallCommand(r))

	return cmd, r, nil
}

func newListCommand(r *Registry) *cobra.Command {
	return &cobra.Command{
		Use:   "list",
		Short: "list installed plugins",
		Long:  "list installed plugins",
		Args:  cobra.NoArgs,
		RunE: func(cmd *cobra.Command, _ []string) error {
			return listPlugins(cmd.OutOrStdout(), r)
		},
	}
}

func newEnableCommand(r *Registry) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "enable plugin1 plugin2 ...",
		Short: "enable one or more plugins",
		Long:  "enable one or more plugins",
		Args:  cobra.MinimumNArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return enablePlugin(cmd.OutOrStdout(), r, args...)
		},
	}

	return cmd
}

func newDisableCommand(r *Registry) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "disable plugin1 plugin2 ...",
		Short: "disable one or more plugins",
		Long:  "disable one or more plugins",
		Args:  cobra.MinimumNArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return disablePlugin(cmd.OutOrStdout(), r, args...)
		},
	}

	return cmd
}

func newInstallCommand(r *Registry) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "install source1 source2 ...",
		Short: "install one or more plugins",
		Long:  "install one or more plugins",
		Args:  cobra.MinimumNArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return installPlugin(cmd.OutOrStdout(), r, args...)
		},
	}

	return cmd
}

func newUninstallCommand(r *Registry) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "uninstall plugin1 plugin2 ...",
		Short: "uninstall one or more plugins",
		Long:  "uninstall one or more plugins",
		Args:  cobra.MinimumNArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return uninstallPlugin(cmd.OutOrStdout(), r, args...)
		},
	}

	return cmd
}
