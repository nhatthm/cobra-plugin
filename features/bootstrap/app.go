package bootstrap

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/Netflix/go-expect"
	"github.com/cucumber/godog"
	cobraplugin "github.com/nhatthm/cobra-plugin"
	"github.com/spf13/cobra"
	"github.com/spf13/pflag"
	"github.com/stretchr/testify/require"
)

type appManager struct {
	tty  *os.File
	test *testing.T

	mu sync.Mutex
}

// WithConsole configures stdio for a given scenario.
func (m *appManager) WithConsole(_ *godog.Scenario, console *expect.Console) {
	m.mu.Lock()
	defer m.mu.Unlock()

	m.tty = console.Tty()
}

func (m *appManager) registerContext(ctx *godog.ScenarioContext) {
	ctx.Step(`run command "([^"]*)"`, m.runCommandSimple)
	ctx.Step(`run command (\[[^\]]*\])`, m.runCommandArgs)

	ctx.Step(`run plugin "([^"]*)" with args "([^"]*)"`, m.runPluginCommandArgs)
}

func (m *appManager) makeCommand(args []string) *cobra.Command {
	pluginCmd, _, err := cobraplugin.NewCommand(".")
	require.NoError(m.test, err)

	cmd := &cobra.Command{Use: "my-command"}

	cmd.SetIn(m.tty)
	cmd.SetOut(m.tty)
	cmd.SetErr(m.tty)
	cmd.SetArgs(args)

	cmd.AddCommand(pluginCmd)

	pflag.CommandLine = nil

	return cmd
}

func (m *appManager) runCommandSimple(params string) error {
	return m.runCommand(strings.Split(params, " "))
}

func (m *appManager) runCommandArgs(params string) error {
	var args []string

	if err := json.Unmarshal([]byte(params), &args); err != nil {
		return err
	}

	return m.runCommand(args)
}

func (m *appManager) runCommand(args []string) (err error) {
	cmd := m.makeCommand(args)
	doneCh := make(chan struct{})

	go func() {
		defer func() {
			if r := recover(); r != nil {
				_, _ = fmt.Fprintf(m.tty, "panic: %s\n", r)
			}

			close(doneCh)
		}()

		_ = cmd.Execute() // nolint: errcheck
	}()

	select {
	case <-time.After(time.Second):
		return errors.New("command timed out") // nolint: goerr113

	case <-doneCh:
		return
	}
}

func (m *appManager) runPluginCommandArgs(pluginName, params string) (err error) {
	return m.runPluginCommand(pluginName, strings.Split(params, " "))
}

func (m *appManager) runPluginCommand(pluginName string, args []string) (err error) {
	r, err := cobraplugin.NewRegistry(".")
	if err != nil {
		return err
	}

	cmd, err := r.Command(pluginName, args...)
	if err != nil {
		return err
	}

	cmd.Stdin = m.tty
	cmd.Stdout = m.tty
	cmd.Stderr = m.tty

	doneCh := make(chan struct{})

	go func() {
		defer func() {
			if r := recover(); r != nil {
				_, _ = fmt.Fprintf(m.tty, "panic: %s\n", r)
			}

			close(doneCh)
		}()

		err = cmd.Run()
	}()

	select {
	case <-time.After(time.Second):
		return errors.New("command timed out") // nolint: goerr113

	case <-doneCh:
		return
	}
}

func newAppManager(t *testing.T) *appManager { // nolint: thelper
	m := &appManager{
		test: t,
	}

	return m
}
