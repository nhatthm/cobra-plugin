package bootstrap

import (
	"bytes"
	"flag"
	"fmt"
	"io/ioutil"
	"math/rand"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/bool64/httpdog"
	"github.com/bool64/shared"
	"github.com/cucumber/godog"
	"github.com/nhatthm/aferodog"
	"github.com/nhatthm/consoledog"
	github "github.com/nhatthm/plugin-registry-github"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const githubService = "github.com"

// Used by init().
//
//nolint:gochecknoglobals
var (
	runGoDogTests bool

	out = new(bytes.Buffer)
	opt = godog.Options{
		Strict: true,
		Output: out,
	}
)

// This has to run on init to define -godog flag, otherwise "undefined flag" error happens.
//
//nolint:gochecknoinits
func init() {
	flag.BoolVar(&runGoDogTests, "godog", false, "Set this flag is you want to run godog BDD tests")
	godog.BindFlags("godog.", flag.CommandLine, &opt) // nolint: staticcheck
}

func TestMain(m *testing.M) {
	flag.Parse()
	opt.Paths = flag.Args()

	if opt.Randomize == 0 {
		opt.Randomize = rand.Int63() // nolint: gosec
	}

	os.Exit(m.Run())
}

func TestIntegration(t *testing.T) {
	if !runGoDogTests {
		t.Skip(`Missing "-godog" flag, skipping integration test.`)
	}

	svr, registerVars := makeGithubServer(t)
	fsManager := aferodog.NewManager()
	am := newAppManager(t)
	console := consoledog.New(t, consoledog.WithStarter(am.WithConsole))

	RunSuite(t, "..", func(_ *testing.T, ctx *godog.ScenarioContext) {
		am.registerContext(ctx)
		svr.RegisterSteps(ctx)
		fsManager.RegisterContext(t, ctx)
		console.RegisterContext(ctx)
		registerVars(ctx)
	})
}

func RunSuite(t *testing.T, path string, featureContext func(t *testing.T, ctx *godog.ScenarioContext)) {
	t.Helper()

	var paths []string

	files, err := ioutil.ReadDir(filepath.Clean(path))
	assert.NoError(t, err)

	paths = make([]string, 0, len(files))

	for _, f := range files {
		if strings.HasSuffix(f.Name(), ".feature") {
			paths = append(paths, filepath.Join(path, f.Name()))
		}
	}

	for _, path := range paths {
		path := path

		t.Run(path, func(t *testing.T) {
			opt.Paths = []string{path}
			suite := godog.TestSuite{
				Name:                 "Integration",
				TestSuiteInitializer: nil,
				ScenarioInitializer: func(s *godog.ScenarioContext) {
					featureContext(t, s)
				},
				Options: &opt,
			}
			status := suite.Run()

			if status != 0 {
				fmt.Println(out.String())
				assert.Fail(t, "one or more scenarios failed in feature: "+path)
			}
		})
	}
}

func makeGithubServer(t *testing.T) (*httpdog.External, func(*godog.ScenarioContext)) {
	t.Helper()

	svr := &httpdog.External{Vars: &shared.Vars{}}
	svrURLWithSlash := strings.TrimSuffix(svr.Add(githubService), "/") + "/"

	svrURL, err := url.Parse(svrURLWithSlash)
	require.NoError(t, err)

	github.RegisterInstaller(github.WithBaseURL(svrURL))

	svc := svr.GetMock(githubService)

	return svr, func(ctx *godog.ScenarioContext) {
		ctx.BeforeScenario(func(*godog.Scenario) {
			svc.JSONComparer.Vars.Set("my-plugin:v1.4.2:.plugin.registry.yaml:download-url",
				fmt.Sprintf("%sowner/my-plugin/v1.4.2/.plugin.registry.yaml", svrURLWithSlash),
			)
		})
	}
}
