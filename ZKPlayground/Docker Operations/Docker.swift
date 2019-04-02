//
//  Docker.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/21/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

protocol DockerProtocol: class {
    
    // Docker received data from the docker image
    func docker(_ docker: Docker, didReceiveStdout string: String)
    
    // Docker received an error from the docker image
    func docker(_ docker: Docker, didReceiveStderr string: String)
    
    // Docker sent stdin to the docker image from the app
    func docker(_ docker: Docker, didReceiveStdin string: String)
}

/// TODO: explore Docker Remote API http://blog.arungupta.me/enable-docker-remote-api-mac-osx-machine/
/// https://github.com/docker/for-mac/issues/770
class Docker: Operation {
    
    weak var delegate: DockerProtocol?
    
    /// If any of the commands in the script returns non-zero,
    /// the script will cancel and forward the exit code
    /// 0 is success, anything else is an error
    /// http://www.tldp.org/LDP/abs/html/exitcodes.html
    private (set) var exitStatus: Int?
    
    // If true, output will be stored in output property
    private let logOutput: Bool
    
    private (set) var output = ""
    
    fileprivate let task = Process()
    
    private let stdoutPipe = Pipe()
    private let stderrPipe = Pipe()
    private let stdinPipe = Pipe()
    private var notifications = [NSObjectProtocol]()
    
    /// Name of the .code file, e.g. "HelloWorld.code"
    private let filename: String
    private let workDirectory: String
    
    /// the name of the directory mapped to workDirectoryPath
    fileprivate static let dockerDirectoryPath = "/home/zokrates/playground"
    static let buildDirectory = "build"
    fileprivate static var dockerBuildPath = { return URL(fileURLWithPath: dockerDirectoryPath).appendingPathComponent(Docker.buildDirectory).path }()
    
    fileprivate var dockerFilename: String {
        return URL(fileURLWithPath: Docker.dockerDirectoryPath).appendingPathComponent(self.filename).path
    }
    
    /// Arguments used to start Docker (e.g. docker run -v ....)
    private let dockerArguments: [String]
    
    init(workDirectory: String, filename: String, logOutput: Bool = true) {
        
        self.filename = filename
        self.workDirectory = workDirectory
        self.dockerArguments = ["run", "-v", workDirectory + ":" + Docker.dockerDirectoryPath, "-i", "zokrates/zokrates", "/bin/bash"]
        self.logOutput = logOutput
        
        super.init()
    }
    
    override init() {
        
        self.filename = ""
        self.workDirectory = ""
        self.logOutput = true
        self.dockerArguments = ["run", "hello-world"]
        
        super.init()
    }
    
    /// Runs (and if needed, installs) Zokrates in a Docker image
    /// Format is: docker run -v /Users/davidhasselhoff/Code/:/home/zokrates/playground -i zokrates/zokrates /bin/bash
    override func main() {
            
        guard isCancelled == false else { return }
        
        // Set up task
        self.task.environment = ProcessInfo().environment
        self.task.environment?.updateValue("/usr/local/bin/:/usr/bin:/bin:/usr/sbin:/sbin", forKey: "PATH")
        task.launchPath = "/usr/local/bin/docker" // TODO: use which path
        task.arguments = self.dockerArguments
        task.currentDirectoryPath = Bundle.main.bundlePath
        
        // Print to log
        let command: String = task.launchPath ?? ""
        let arguments: String = task.arguments?.joined(separator: " ") ?? ""
        self.delegate?.docker(self, didReceiveStdin: "\n$ " + command + " " + arguments + "\n")
        
        // Set exitStatus at exit
        self.task.terminationHandler = { task in
            self.exitStatus = Int(task.terminationStatus)
            if self.exitStatus == 0 {
                self.delegate?.docker(self, didReceiveStdout: "\nTask exited with exit status 0\n")
            } else {
                self.delegate?.docker(self, didReceiveStderr: "\nTask exited with exit status \(self.exitStatus!)\n")
            }
            _ = self.notifications.map { NotificationCenter.default.removeObserver($0) }
        }
        
        // Handle I/O
        self.task.standardOutput = self.stdoutPipe
        self.task.standardError = self.stderrPipe
        self.task.standardInput = self.stdinPipe

        self.capture(self.stdoutPipe) { stdout in
            
            self.delegate?.docker(self, didReceiveStdout: stdout)
            if self.logOutput == true { self.output += stdout }

            // print utf8 values
//            var s = ""
//            _ = stdout.utf8.map{ s.append("\($0), ") }
//            self.delegate?.docker(self, didReceiveStdin: s)
        }
        
        self.capture(self.stderrPipe) { stderr in
            
            self.delegate?.docker(self, didReceiveStderr: stderr)
            if self.logOutput == true { self.output += stderr }
        }
        
        task.launch()
//        self.task.waitUntilExit() // uncomment when testing Hello-world
    }
    
    private func capture(_ pipe: Pipe, dataReceived: @escaping (String) -> Void) {
        
        let notification = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: pipe.fileHandleForReading , queue: nil) { notification in
            
            let output = pipe.fileHandleForReading.availableData
            
            guard let outputString = String(data: output, encoding: String.Encoding.utf8), !outputString.isEmpty else { return }
            
            dataReceived(outputString)
            
            pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
        
        notifications.append(notification)
            
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
    }
    
    /// Will add newline character to string
    ///
    /// - Parameter string: <#string description#>
    func write(_ string: String, wait: Bool = true) {
        
        let string = string + "\n"
        guard task.isRunning == true, let data = (string).data(using: .utf8) else { return assertionFailure() }
        self.delegate?.docker(self, didReceiveStdin: "\n" + string)
        self.stdinPipe.fileHandleForWriting.write(data)
        if wait == true { self.stdinPipe.fileHandleForWriting.waitForDataInBackgroundAndNotify() }
    }
    
    /// Exits Docker
    override func cancel() {
        
        // Send 'exit' command to docker
        if task.isRunning { task.interrupt() }
        self.stdinPipe.fileHandleForReading.closeFile()
        self.stderrPipe.fileHandleForReading.closeFile()
        self.stdoutPipe.fileHandleForWriting.closeFile()
        super.cancel()
    }
    
    fileprivate func copy(file: String) { //} -> Bool {
        
        self.write("cp " + file + " " + Docker.dockerBuildPath)
    }
}

/// Compiles code, returns warnings and errors
/// ./zokrates compile -i playground/root.code
class Lint: Docker {
    
    override func main() {
        
        super.main()
        
        let command = "./zokrates compile -i " + self.dockerFilename + "; exit"
        self.write(command)
        self.task.waitUntilExit()
    }
}

/// Compiles and builds product and proofs
class Compile: Docker {
    
    let arguments: [String]?
    
    init(workDirectory: String, filename: String, arguments: [String]?) {
        
        self.arguments = arguments
        
        super.init(workDirectory: workDirectory, filename: filename)
    }
    
    override func main() {
        
        super.main()
        
        // 1. Set time format
        self.write("TIMEFORMAT='Elapsed time: %3R'")
        
        // 2. Compile
        self.write("time ./zokrates compile -i " + self.dockerFilename)
        copy(file: "out")
        copy(file: "out.code")
        
        // 3. Setup
        self.write("time ./zokrates setup")
        copy(file: "proving.key")
        copy(file: "variables.inf")
        copy(file: "verification.key")
        
        // 4. Compute witness
        var command = "time ./zokrates compute-witness"
        if let arguments = self.arguments {
            command += " -a "
            _ = arguments.map{ command.append($0 + " ") }
        }
        self.write(command)
        copy(file: "witness")

        // 5. Generate proof
        self.write("time ./zokrates generate-proof")
        copy(file: "proof.json")
        
        // copy verifier
        self.write("time ./zokrates export-verifier")
        copy(file: "verifier.sol")
        
        self.write("exit")
        self.task.waitUntilExit()
    }
}
