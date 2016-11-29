package main

import (
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"

	"github.com/jwfriese/iossimulator"
)

func main() {
	programCall := os.Args
	if len(programCall) < 4 {
		log.Fatal(errors.New("Usage: ./test <runtime> <device type> <use-xcpretty>"))
	}

	args := programCall[1:]
	iosVersion := args[0]
	deviceVersion := args[1]
	useXcPrettyArgString := args[2]
	useXcPretty := true
	if useXcPrettyArgString == "true" {
		useXcPretty = true
	} else if useXcPrettyArgString == "false" {
		useXcPretty = false
	} else {
		log.Fatal(errors.New("Final argument must be either 'true' or 'false'"))
	}

	testInitReport := fmt.Sprintf("Running OMGFruit unit tests with iOS version '%s' on device type '%s' (use xcpretty == %v)\n", iosVersion, deviceVersion, useXcPretty)
	_, err := os.Stdout.Write([]byte(testInitReport))
	if err != nil {
		log.Fatal(err)
	}

	availabilityErr := iossimulator.IsDeviceAvailable(iosVersion, deviceVersion)
	if availabilityErr != nil {
		log.Fatal(availabilityErr)
	}

	iosVersionNumber := strings.Trim(iosVersion, "iOS ")
	destinationString := fmt.Sprintf("platform=iOS Simulator,OS=%s,name=%s", iosVersionNumber, deviceVersion)
	unitTestCommand := exec.Command("xcodebuild", "test", "-workspace", "OMGFruit.xcworkspace", "-scheme", "OMGFruit", "-destination", destinationString)
	if useXcPretty {
		xcprettyCommand := exec.Command("xcpretty")
		xcprettyCommand.Stdin, err = unitTestCommand.StdoutPipe()
		if err != nil {
			log.Fatal(err)
		}
		xcprettyCommand.Stdout = os.Stdout
		xcprettyCommand.Stderr = os.Stderr
		err = xcprettyCommand.Start()
		if err != nil {
			log.Fatal(err)
		}

		err = unitTestCommand.Run()
		if err != nil {
			log.Fatal(err)
		}

		err = xcprettyCommand.Wait()
		if err != nil {
			log.Fatal(err)
		}
	} else {
		unitTestCommand.Stdout = os.Stdout
		unitTestCommand.Stderr = os.Stderr
		err = unitTestCommand.Run()
		if err != nil {
			log.Fatal(err)
		}
	}

	_, err = os.Stdout.Write([]byte("OMGFruit unit tests passed...\n"))
	if err != nil {
		log.Fatal(err)
	}
}
