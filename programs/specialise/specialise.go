package main

import (
	"errors"
	"flag"
	"fmt"
	"io/fs"
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

	if *help {
		fmt.Print(helpText())
		os.Exit(0)
	}

	args := flag.Args()
	if len(args) < 1 {
		fmt.Fprint(os.Stderr, helpText())
		log.Fatal("No command provided.")
	}

	switch args[0] {
	case "set":
		if len(args) != 2 {
			fmt.Fprint(os.Stderr, helpText())
			log.Fatal("`set` requires exact 1 argument")
		}

		setSpecialisation(args[1], *verbose)
	case "unset":
		activateNonSpecialisedProfile()
	case "clean":
		clean()
	default:
		fmt.Fprint(os.Stderr, helpText())
		log.Fatalf("Unknown command: %s", args[0])
	}
}

func helpText() string {
	binName := os.Args[0]

	return fmt.Sprintf(`%s - Manage Home-Manager specialisation easily.

[Usage]
  %s set <specialisation>
  %s unset

[COMMANDS]
  set <specialisation>
    Activate the particular specialisation.

  unset
    Activate the most recent home-manager profile which have specialisations.

  clean
    Delete generations other than the latest generation and the latest generation having
    specialisation directory.

[OPTIONS]
  --help
    Print this message to stdout.

  --verbose
    Enable verbose logging.
`, binName, binName, binName)
}

func setSpecialisation(specialisation string, verbose bool) {
	if strings.Contains(specialisation, "/") {
		log.Fatalf("specialisation cannot have slash (\"/\"): %s", specialisation)
	}

	generations, err := Generations()
	if err != nil {
		log.Fatalf("Failed to get generations: %s", err)
	}

	for _, generation := range generations {
		specialisations, err := generation.Specialisations()
		if err != nil {
			log.Fatalf("Failed to get specialisations for %s: %s", generation.ID, err)
		}

		if verbose {
			log.Printf("Found generation with ID=%s", generation.ID)
		}

		for _, s := range specialisations {
			if verbose {
				log.Printf("Found specialisation with Name=%s in generation ID=%s", s.Name, generation.ID)
			}

			if s.Name != specialisation {
				continue
			}

			log.Printf("Activate %s from ID=%s", specialisation, generation.ID)

			if err := s.Profile.Activate(); err != nil {
				log.Fatalf("Failed to activate %s: %s", specialisation, err)
			}

			log.Printf("Activated %s", specialisation)
			os.Exit(0)
		}
	}

	log.Fatalf("No specialisation named \"%s\" found", specialisation)
}

func activateNonSpecialisedProfile() {
	generations, err := Generations()
	if err != nil {
		log.Fatalf("Failed to get generations: %s", err)
	}

	for _, generation := range generations {
		specialisations, err := generation.Specialisations()
		if err != nil {
			log.Fatalf("Failed to check specialisations (ID=%s): %s", generation.ID, err)
		}

		if len(specialisations) == 0 {
			continue
		}

		log.Printf("Activate generation (ID=%s)", generation.ID)

		if err := generation.Profile.Activate(); err != nil {
			log.Fatalf("Failed to activate: %s", err)
		}

		os.Exit(0)
	}

	log.Fatal("No generation having specialisations found: Manually switch to a profile using home-manager.")
}

func clean() {
	generations, err := Generations()
	if err != nil {
		log.Fatalf("Failed to get generations: %s", err)
	}

	foundGenerationHavingSpecialisation := false

	args := []string{"remove-generations"}

	for i, generation := range generations {
		if !foundGenerationHavingSpecialisation {
			specialisations, err := generation.Specialisations()
			if err != nil {
				log.Fatalf("Failed to get specialisations for ID=%s: %s", generation.ID, err)
			}

			if len(specialisations) > 0 {
				foundGenerationHavingSpecialisation = true
				continue
			}
		}

		if i == 0 {
			continue
		}

		log.Printf("Removing generation ID=%s", generation.ID)

		args = append(args, generation.ID)
	}

	if len(args) == 1 {
		log.Print("Nothing to clean.")
		os.Exit(0)
	}

	cmd := exec.Command(homeManagerPath, args...)

	var out strings.Builder
	cmd.Stdout = &out

	if err := cmd.Run(); err != nil {
		log.Fatalf("Failed to remove generations: %s", err)
	}

}

type Profile struct {
	Path string
}

func (p Profile) Activate() error {
	dir := os.DirFS(p.Path)

	bin, err := dir.Open("activate")
	if err != nil {
		return err
	}
	defer bin.Close()

	stat, err := bin.Stat()
	if err != nil {
		return err
	}

	if stat.IsDir() {
		return fmt.Errorf("Cannot activate %s: target is directory", p.Path)
	}

	path := fmt.Sprintf("%s/activate", p.Path)

	cmd := exec.Command(path)

	return cmd.Run()
}

type Specialisation struct {
	Name string

	Profile Profile
}

type Generation struct {
	ID string

	Profile Profile
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

	path := strings.Join(tokens[(colonPosition+4):], " ")

	return &Generation{
		ID: id,
		Profile: Profile{
			Path: path,
		},
	}, nil
}

func Generations() ([]Generation, error) {
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
			log.Printf("Failed to parse generation output: %s", err.Error())
			continue
		}

		generations = append(generations, *generation)
	}

	return generations, nil
}

func (g Generation) Specialisations() ([]Specialisation, error) {
	dir := os.DirFS(g.Profile.Path)

	entries, err := fs.ReadDir(dir, "specialisation")
	if err != nil {
		if errors.Is(err, fs.ErrNotExist) {
			return []Specialisation{}, nil
		}

		return nil, err
	}

	specialisations := make([]Specialisation, 0, len(entries))

	for _, entry := range entries {
		name := entry.Name()

		specialisations = append(specialisations, Specialisation{
			Name: name,
			Profile: Profile{
				Path: fmt.Sprintf("%s/specialisation/%s", g.Profile.Path, name),
			},
		})
	}

	return specialisations, nil
}
