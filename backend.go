package cobraplugin

import (
	"context"
	"fmt"
	"io"
	"sort"

	"github.com/bool64/ctxd"
	"github.com/nhatthm/plugin-registry/plugin"
	"github.com/olekukonko/tablewriter"
)

func listPlugins(out io.Writer, r *Registry) error {
	cfg, err := r.Config()
	if err != nil {
		return err
	}

	renderPlugins(out, cfg.Plugins)

	return nil
}

func renderPlugins(out io.Writer, plugins plugin.Plugins) {
	table := tablewriter.NewWriter(out)

	table.SetBorder(false)
	table.SetHeader([]string{"Name", "Version", "Enabled", "Description"})
	table.SetColumnSeparator(" ")
	table.SetCenterSeparator("-")

	sorted := make([]plugin.Plugin, 0, len(plugins))

	for _, p := range plugins {
		sorted = append(sorted, p)
	}

	sort.Slice(sorted, func(i, j int) bool {
		return sorted[i].Name < sorted[j].Name
	})

	for _, p := range sorted {
		table.Append([]string{
			p.Name, p.Version, fmt.Sprintf("%t", p.Enabled), p.Description,
		})
	}

	table.Render()
}

func enablePlugin(out io.Writer, r *Registry, names ...string) error {
	for _, n := range names {
		if err := r.Enable(n); err != nil {
			return ctxd.WrapError(context.Background(), err, "could not enable plugin", "plugin", n)
		}

		_, _ = fmt.Fprintf(out, "enabled %s", n)
	}

	return nil
}

func disablePlugin(out io.Writer, r *Registry, names ...string) error {
	for _, n := range names {
		if err := r.Disable(n); err != nil {
			return ctxd.WrapError(context.Background(), err, "could not disable plugin", "plugin", n)
		}

		_, _ = fmt.Fprintf(out, "disabled %s", n)
	}

	return nil
}

func installPlugin(out io.Writer, r *Registry, sources ...string) error {
	for _, s := range sources {
		if err := r.Install(context.Background(), s); err != nil {
			return ctxd.WrapError(context.Background(), err, "could not install plugin", "source", s)
		}

		_, _ = fmt.Fprintf(out, "installed %s", s)
	}

	return nil
}

func uninstallPlugin(out io.Writer, r *Registry, names ...string) error {
	for _, n := range names {
		if err := r.Uninstall(n); err != nil {
			return ctxd.WrapError(context.Background(), err, "could not uninstall plugin", "plugin", n)
		}

		_, _ = fmt.Fprintf(out, "uninstalled %s", n)
	}

	return nil
}
