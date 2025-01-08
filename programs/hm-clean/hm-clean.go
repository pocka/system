package main

import (
	"errors"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)

// Path to the home-manager bin.
// Normally this will be overridden at compile time via "ldflags -X main.homeManagerPath=<path>".
var homeManagerPath = "home-manager"

func main() {
	help := flag.Bool("help", false, "Print usage text to stdout.")
	verbose := flag.Bool("verbose", false, "Enable verbose logging.")

	flag.Parse()

	logger := log.New(os.Stderr, "", 0)

	if *help {
		fmt.Print(helpText())
		os.Exit(0)
	}

	clean(logger, *verbose)
}

func helpText() string {
	binName := os.Args[0]

	return fmt.Sprintf(`%s - Clean obsolete Home-Manager generations.

[Usage]
	%s

[OPTIONS]
  --help
    Print this message to stdout.

  --verbose
    Enable verbose logging.
`, binName, binName)
}

func clean(logger *log.Logger, verbose bool) {
	generations, err := Generations(logger)
	if err != nil {
		logger.Fatalf("Failed to get generations: %s", err)
	}

	args := []string{"remove-generations"}

	for i, generation := range generations {
		if verbose {
			logger.Printf("Found generation ID=%s", generation.ID)
		}

		if i == 0 {
			if verbose {
				logger.Printf("Skipping initial generation ID=%s", generation.ID)
			}
			continue
		}

		logger.Printf("Removing generation ID=%s", generation.ID)

		args = append(args, generation.ID)
	}

	if len(args) == 1 {
		logger.Print("No generations to remove.")
		os.Exit(0)
	}

	cmd := exec.Command(homeManagerPath, args...)

	var out strings.Builder
	cmd.Stdout = &out

	if err := cmd.Run(); err != nil {
		logger.Fatalf("Failed to remove generations: %s", err)
	}
}

type Generation struct {
	ID string
}

func ParseGeneration(line string) (*Generation, error) {
	tokens := strings.Split(line, " ")

	colonPosition := -1

	for i, token := range tokens {
		if token == ":" {
			colonPosition = i
			break
		}
	}

	if colonPosition < 0 {
		return nil, errors.New("Unexpected generation output line: No colon found")
	}

	if len(tokens) < colonPosition+4 {
		return nil, errors.New("Unexpected generation output line: Missing tokens")
	}

	if tokens[colonPosition+1] != "id" {
		return nil, fmt.Errorf("Unexpected generation output line: Expected `id`, found `%s`", tokens[colonPosition+1])
	}

	id := tokens[colonPosition+2]

	if tokens[colonPosition+3] != "->" {
		return nil, fmt.Errorf("Unexpected generation output line: Expected `->`, found `%s`", tokens[colonPosition+3])
	}

	return &Generation{
		ID: id,
	}, nil
}

func Generations(logger *log.Logger) ([]Generation, error) {
	cmd := exec.Command(homeManagerPath, "generations")

	var out strings.Builder
	cmd.Stdout = &out

	if err := cmd.Run(); err != nil {
		return nil, err
	}

	stdout := out.String()
	lines := strings.Split(stdout, "\n")

	generations := make([]Generation, 0, len(lines))

	for _, line := range strings.Split(stdout, "\n") {
		if len(strings.TrimSpace(line)) == 0 {
			continue
		}

		tokens := strings.Split(line, " ")
		if len(tokens) == 0 {
			continue
		}

		generation, err := ParseGeneration(line)
		if err != nil {
			logger.Printf("Failed to parse generation output: %s", err.Error())
			continue
		}

		generations = append(generations, *generation)
	}

	return generations, nil
}
