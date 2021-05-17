package cobraplugin

import (
	"os/exec"
	"path/filepath"

	registry "github.com/nhatthm/plugin-registry"
	"github.com/nhatthm/plugin-registry/plugin"
)

// Registry is a wrapper around registry.Registry.
type Registry struct {
	registry.Registry

	path string
}

// Plugins returns a list of plugins.
func (r *Registry) Plugins() (plugin.Plugins, error) {
	cfg, err := r.Config()
	if err != nil {
		return nil, err
	}

	return cfg.Plugins, nil
}

// Command returns a new exec.Command from the plugin name.
func (r *Registry) Command(pluginName string, args ...string) (*exec.Cmd, error) {
	plugins, err := r.Plugins()
	if err != nil {
		return nil, err
	}

	if !plugins.Has(pluginName) {
		return nil, plugin.ErrPluginNotExist
	}

	cmd := filepath.Join(r.path, pluginName, pluginName)

	return exec.Command(cmd, args...), nil // nolint: gosec
}

// PluginRegistry provides registry.Registry service.
func (r *Registry) PluginRegistry() registry.Registry {
	return r
}

// NewRegistry initiates a new Registry.
func NewRegistry(path string, options ...registry.Option) (*Registry, error) {
	upstream, err := registry.NewRegistry(path, options...)
	if err != nil {
		return nil, err
	}

	r := &Registry{
		Registry: upstream,
		path:     filepath.Clean(path),
	}

	return r, nil
}
