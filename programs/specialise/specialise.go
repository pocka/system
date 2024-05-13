package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)

var homeManagerPath = "home-manager"

func main() {
	flag.Parse()

	args := flag.Args()

	switch len(args) {
	case 0:
		log.Fatal("Argument not set: which specialisation to switch to?")
	case 1:
		break
	default:
		log.Fatalf("specialisation takes exactly 1 argument: You set %d arguments", len(args))
	}

	target := args[0]

	if strings.Contains(target, "/") {
		log.Fatalf("specialisation cannot have slash (\"/\"): %s", target)
	}

	cmd := exec.Command(homeManagerPath, "generations")

	var out strings.Builder
	cmd.Stdout = &out

	if err := cmd.Run(); err != nil {
		log.Fatal(err)
	}

	paths := parseGenerationsOutput(out.String())

	for _, path := range paths {
		dir := os.DirFS(path)

		exe, err := dir.Open(fmt.Sprintf("specialisation/%s/activate", target))
		if err != nil {
			continue
		}
		defer exe.Close()

		// Whether `fs.FS.Open` performs actual FS open operation is undocumented.
		// Make sure the file exists by getting file stats.
		if _, err := exe.Stat(); err != nil {
			// Home Manager's specialisation feature has fundamental design failure:
			// there is no way to go back to "unspecialised" generation or switch to another
			// specialisations once activated a specialisation. Because of this, I have to
			// brute-force each Home Manager generation directories.
			// https://github.com/nix-community/home-manager/issues/4073
			continue
		}

		bin := fmt.Sprintf("%s/specialisation/%s/activate", path, target)

		log.Printf("> %s", bin)
		cmd := exec.Command(bin)

		if err := cmd.Run(); err != nil {
			log.Fatal(err)
		}

		log.Printf("Activated %s", target)
		os.Exit(0)
	}

	log.Fatalf("No specialisation named \"%s\" found", target)
}

// parseGenerationsOutput parses stdout of `home-manager generations` and
// returns the list of paths to generation directories.
func parseGenerationsOutput(stdout string) []string {
	lines := strings.Split(stdout, "\n")

	paths := make([]string, 0, len(lines))

	for _, line := range strings.Split(stdout, "\n") {
		tokens := strings.Split(line, " ")
		if len(tokens) == 0 {
			continue
		}

		last := tokens[len(tokens)-1]
		if !strings.HasPrefix(last, "/") {
			continue
		}

		paths = append(paths, last)
	}

	return paths
}
