//
//  Shell.swift
//  ProcessMan
//
//  Created by Radim  Chlad on 17.04.2025.
//

import Foundation

func shell(_ command: String) -> String {
  let process = Process()
  let pipe = Pipe()

  process.standardOutput = pipe
  process.standardError = pipe
  process.standardInput = nil

  process.launchPath = "/bin/zsh"
  process.arguments = ["-c", command]
  if #available(macOS 13.0, *) {
    try! process.run()
  } else {
    process.launch()
  }
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  let output = String(data: data, encoding: .utf8) ?? ""
  return output
}
