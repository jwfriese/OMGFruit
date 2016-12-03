package main

import (
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"time"

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
	_, reportErr := os.Stdout.Write([]byte(testInitReport))
	if reportErr != nil {
		log.Fatal(reportErr)
	}

	_, reportErr = os.Stdout.Write([]byte("Attempting to create test device..."))
	if reportErr != nil {
		log.Fatal(reportErr)
	}
	testDeviceUuid, createErr := iossimulator.CreateDevice(iosVersion, deviceVersion)
	if createErr != nil {
		log.Fatal(createErr)
	}
	didCreateDeviceReport := fmt.Sprintf("\tSuccessfully created device with id=%s \n", testDeviceUuid)
	_, reportErr = os.Stdout.Write([]byte(didCreateDeviceReport))
	if reportErr != nil {
		log.Fatal(reportErr)
	}

	_, reportErr = os.Stdout.Write([]byte("Booting newly-created test device..."))
	if reportErr != nil {
		log.Fatal(reportErr)
	}
	bootErr := iossimulator.BootDevice(testDeviceUuid)
	if bootErr != nil {
		log.Fatal(bootErr)
	}
	_, reportErr = os.Stdout.Write([]byte("\t Successfully booted test device\n"))
	if reportErr != nil {
		log.Fatal(reportErr)
	}

	time.Sleep(2000 * time.Millisecond)

	_, reportErr = os.Stdout.Write([]byte("Beginning test build...\n"))
	if reportErr != nil {
		log.Fatal(reportErr)
	}
	destinationString := fmt.Sprintf("platform=iOS Simulator,id=%s", testDeviceUuid)
	unitTestCommand := exec.Command("xcodebuild", "test", "-workspace", "OMGFruit.xcworkspace", "-scheme", "OMGFruit", "-destination", destinationString)
	var testRunErr error
	if useXcPretty {
		xcprettyCommand := exec.Command("xcpretty")
		xcprettyCommand.Stdin, _ = unitTestCommand.StdoutPipe()
		xcprettyCommand.Stdout = os.Stdout
		xcprettyCommand.Stderr = os.Stderr
		_ = xcprettyCommand.Start()
		testRunErr = unitTestCommand.Run()
		_ = xcprettyCommand.Wait()
	} else {
		unitTestCommand.Stdout = os.Stdout
		unitTestCommand.Stderr = os.Stderr
		testRunErr = unitTestCommand.Run()
	}

	_, reportErr = os.Stdout.Write([]byte("OMGFruit unit tests finished...\n"))
	if reportErr != nil {
		log.Fatal(reportErr)
	}

	_, reportErr = os.Stdout.Write([]byte("Shutting down test device..."))
	if reportErr != nil {
		log.Fatal(reportErr)
	}
	shutdownErr := iossimulator.ShutdownDevice(testDeviceUuid)
	if shutdownErr != nil {
		log.Fatal(shutdownErr)
	}
	_, reportErr = os.Stdout.Write([]byte("\t Successfully shut down test device\n"))
	if reportErr != nil {
		log.Fatal(reportErr)
	}

	_, reportErr = os.Stdout.Write([]byte("Deleting test device..."))
	if reportErr != nil {
		log.Fatal(reportErr)
	}
	deleteErr := iossimulator.DeleteDevice(testDeviceUuid)
	if deleteErr != nil {
		log.Fatal(deleteErr)
	}
	_, reportErr = os.Stdout.Write([]byte("\t Successfully deleted test device\n"))
	if reportErr != nil {
		log.Fatal(reportErr)
	}

	_, reportErr = os.Stdout.Write([]byte("Closing simulator app..."))
	if reportErr != nil {
		log.Fatal(reportErr)
	}
	closeErr := iossimulator.CloseSimulatorApp()
	if closeErr != nil {
		log.Fatal(closeErr)
	}
	_, reportErr = os.Stdout.Write([]byte("\t Successfully closed 'Simulator.app'\n"))
	if reportErr != nil {
		log.Fatal(reportErr)
	}

	var testResults string
	if testRunErr == nil {
		testResults = "All tests passed"
	} else {
		testResults = "Tests failed"
	}
	testResultsStringReport := fmt.Sprintf("\nTest Results:\n%s\n\n", testResults)
	_, reportErr = os.Stdout.Write([]byte(testResultsStringReport))
	if reportErr != nil {
		log.Fatal(reportErr)
	}

	_, _ = os.Stdout.Write([]byte("Process complete\n\n"))
}
