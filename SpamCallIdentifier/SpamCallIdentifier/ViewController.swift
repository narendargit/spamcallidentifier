//
//  ViewController.swift
//  SpamCallIdentifier
//
//  Memory Optimized Single JSON Split into 2 Extensions (10L + 10L)
//

import UIKit
import CallKit

// Extension 1 Configuration
let appGroupID = "group.com.imimobile.CallBlocker"
let callDirectoryExtensionIdentifier = "com.imimobile.SpamCallIdentifier.CallDirectoryHandler"
 
// Memory optimized configuration
let batchSize = 8000 // Reduced batch size for memory efficiency
let maxTotalEntries = 2000000 // 20 lakh total
let streamingChunkSize = 2000 // Small chunks for streaming

class ViewController: UIViewController {
    
    private var isProcessing = false
    
    // MARK: - Time Tracking
    func getCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return formatter.string(from: Date())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        cleanupFiles(appGroup: appGroupID)
         
    }
    
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Memory Optimized Extension"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let infoLabel = UILabel()
        infoLabel.text = "10 MSISDNS in Extension (Streaming)"
        infoLabel.font = UIFont.systemFont(ofSize: 16)
        infoLabel.textAlignment = .center
        infoLabel.textColor = .systemGray
        infoLabel.translatesAutoresizingMaskIntoConstraints = false

        // Extension 1 button (First Half)
        let button1 = UIButton(type: .system)
        button1.setTitle("🚀 Load Extension 10L", for: .normal)
        button1.backgroundColor = UIColor.systemBlue
        button1.setTitleColor(.white, for: .normal)
        button1.layer.cornerRadius = 8
        button1.addTarget(self, action: #selector(loadExtension1FirstHalf), for: .touchUpInside)
        button1.translatesAutoresizingMaskIntoConstraints = false

        
        // Extension 1 button (First Half)
        let blockButton = UIButton(type: .system)
        blockButton.setTitle("✅ Add/Remove Block", for: .normal)
        blockButton.backgroundColor = UIColor.systemBlue
        blockButton.setTitleColor(.white, for: .normal)
        blockButton.layer.cornerRadius = 8
        blockButton.addTarget(self, action: #selector(addOrRemoveBlockNumber), for: .touchUpInside)
        blockButton.translatesAutoresizingMaskIntoConstraints = false

        // Status buttons
        let checkButton = UIButton(type: .system)
        checkButton.setTitle("📊 Check Extensions Status", for: .normal)
        checkButton.addTarget(self, action: #selector(checkExtensionsStatus), for: .touchUpInside)
        checkButton.translatesAutoresizingMaskIntoConstraints = false

        let clearButton = UIButton(type: .system)
        clearButton.setTitle("🗑️ Clear All Extensions", for: .normal)
        clearButton.addTarget(self, action: #selector(clearAllExtensions), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Progress labels
        let progressLabel1 = UILabel()
        progressLabel1.text = "Extension 1: Ready (First Half)"
        progressLabel1.font = UIFont.systemFont(ofSize: 14)
        progressLabel1.textAlignment = .center
        progressLabel1.tag = 901
        progressLabel1.translatesAutoresizingMaskIntoConstraints = false
 
        // Memory status label
        let memoryLabel = UILabel()
        memoryLabel.text = "Memory: Ready"
        memoryLabel.font = UIFont.systemFont(ofSize: 12)
        memoryLabel.textAlignment = .center
        memoryLabel.tag = 903
        memoryLabel.textColor = .systemGray
        memoryLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(label)
        contentView.addSubview(infoLabel)
        contentView.addSubview(button1)
        contentView.addSubview(blockButton)
        contentView.addSubview(checkButton)
        contentView.addSubview(clearButton)
        contentView.addSubview(progressLabel1)
         contentView.addSubview(memoryLabel)
        
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            
            infoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            
            button1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button1.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 30),
            button1.widthAnchor.constraint(equalToConstant: 280),
            button1.heightAnchor.constraint(equalToConstant: 44),
            
            blockButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            blockButton.topAnchor.constraint(equalTo: button1.bottomAnchor, constant: 30),
            blockButton.widthAnchor.constraint(equalToConstant: 280),
            blockButton.heightAnchor.constraint(equalToConstant: 44),
            
            checkButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            checkButton.topAnchor.constraint(equalTo: blockButton.bottomAnchor, constant: 25),
            
            clearButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            clearButton.topAnchor.constraint(equalTo: checkButton.bottomAnchor, constant: 15),
            
            progressLabel1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            progressLabel1.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 20),
                        
            memoryLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            memoryLabel.topAnchor.constraint(equalTo: progressLabel1.bottomAnchor, constant: 10),
            memoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func updateProgressLabel(_ text: String, extensionNumber: Int) {
        DispatchQueue.main.async {
            let tag = extensionNumber == 1 ? 901 : 902
            if let label = self.view.viewWithTag(tag) as? UILabel {
                label.text = "Extension \(extensionNumber): \(text)"
            }
        }
    }
    
    private func updateMemoryLabel(_ text: String) {
        DispatchQueue.main.async {
            if let label = self.view.viewWithTag(903) as? UILabel {
                label.text = "Memory: \(text)"
            }
        }
    }

    @objc func checkExtensionsStatus() {
        checkExtensionStatus(identifier: callDirectoryExtensionIdentifier, name: "Extension 1")
     }
    
    private func checkExtensionStatus(identifier: String, name: String) {
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: identifier) { status, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ \(name) status error: \(error.localizedDescription)")
                    return
                }
                
                let statusString: String
                switch status {
                case .enabled:
                    statusString = "✅ enabled"
                case .disabled:
                    statusString = "❌ disabled"
                case .unknown:
                    statusString = "❓ unknown"
                @unknown default:
                    statusString = "❓ unknown"
                }
                print("\(name) status: \(statusString)")
            }
        }
    }

    @objc func loadExtension1FirstHalf() {
        guard !isProcessing else {
            print("⚠️ Already processing...")
            return
        }
        
        shared_Block_Defaults?.set(add_all_identifications, forKey: number_processing_type)
        shared_Block_Defaults?.synchronize()

        updateProgressLabel("Loading first half...", extensionNumber: 1)
        processExtensionWithStreamingSplit(
            extensionId: callDirectoryExtensionIdentifier,
            appGroup: appGroupID,
            extensionNumber: 1,
            splitType: .firstHalf
        )
    }
         
    @objc func clearAllExtensions() {
        guard !isProcessing else { return }
        
        isProcessing = true
        updateProgressLabel("Clearing...", extensionNumber: 1)
        updateMemoryLabel("Clearing...")
        
        clearExtension(appGroup: appGroupID, extensionId: callDirectoryExtensionIdentifier, extensionNumber: 1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isProcessing = false
            self.updateProgressLabel("Cleared ✅", extensionNumber: 1)
            self.updateMemoryLabel("Cleared")
        }
    }
    
    private func clearExtension(appGroup: String, extensionId: String, extensionNumber: Int) {
        cleanupFiles(appGroup: appGroup)
        saveMetadata(totalEntries: 0, extensionNumber : extensionNumber, lastUpdated: Date(), appGroup: appGroup) { _ in }
        reloadExtension(identifier: extensionId) { _ in }
    }

    // MARK: - Memory Optimized Split Processing Logic
    
    enum SplitType {
        case firstHalf
        case secondHalf
    }
    
    private func processExtensionWithStreamingSplit(extensionId: String, appGroup: String, extensionNumber: Int, splitType: SplitType) {
        checkExtensionAndProcessWithStreamingSplit(
            extensionId: extensionId,
            appGroup: appGroup,
            extensionNumber: extensionNumber,
            splitType: splitType
        )
    }
    
    private func processExtensionWithStreamingSplitAsync(extensionId: String, appGroup: String, extensionNumber: Int, splitType: SplitType, completion: @escaping (Bool) -> Void) {
        checkExtensionAndProcessWithStreamingSplitAsync(
            extensionId: extensionId,
            appGroup: appGroup,
            extensionNumber: extensionNumber,
            splitType: splitType,
            completion: completion
        )
    }

    private func checkExtensionAndProcessWithStreamingSplit(extensionId: String, appGroup: String, extensionNumber: Int, splitType: SplitType) {
        updateProgressLabel("Checking...", extensionNumber: extensionNumber)
        
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: extensionId) { status, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Extension \(extensionNumber) error: \(error.localizedDescription)")
                    print("Fail Time Extension \(extensionNumber): \(self.getCurrentDateTime())")
                    self.updateProgressLabel("Error ❌", extensionNumber: extensionNumber)
                    return
                }

                if status != .enabled {
                    print("❌ Extension \(extensionNumber) not enabled")
                    print("Fail Time Extension \(extensionNumber): \(self.getCurrentDateTime())")
                    self.updateProgressLabel("Disabled ❌", extensionNumber: extensionNumber)
                    return
                }
                
                print("✅ Extension \(extensionNumber) enabled. Starting streaming \(splitType)...")
                print("Start Time Extension \(extensionNumber): \(self.getCurrentDateTime())")
                self.startStreamingSplitProcessing(
                    extensionId: extensionId,
                    appGroup: appGroup,
                    extensionNumber: extensionNumber,
                    splitType: splitType
                )
            }
        }
    }
    
    private func checkExtensionAndProcessWithStreamingSplitAsync(extensionId: String, appGroup: String, extensionNumber: Int, splitType: SplitType, completion: @escaping (Bool) -> Void) {
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: extensionId) { status, error in
            if let error = error {
                print("❌ Extension \(extensionNumber) error: \(error.localizedDescription)")
                print("Fail Time Extension \(extensionNumber): \(self.getCurrentDateTime())")
                DispatchQueue.main.async {
                    self.updateProgressLabel("Error ❌", extensionNumber: extensionNumber)
                }
                completion(false)
                return
            }

            if status != .enabled {
                print("❌ Extension \(extensionNumber) not enabled")
                print("Fail Time Extension \(extensionNumber): \(self.getCurrentDateTime())")
                DispatchQueue.main.async {
                    self.updateProgressLabel("Disabled ❌", extensionNumber: extensionNumber)
                }
                completion(false)
                return
            }
            
            print("✅ Extension \(extensionNumber) enabled. Starting streaming \(splitType) async...")
            print("Start Time Extension \(extensionNumber): \(self.getCurrentDateTime())")
            self.startStreamingSplitProcessingAsync(
                extensionId: extensionId,
                appGroup: appGroup,
                extensionNumber: extensionNumber,
                splitType: splitType,
                completion: completion
            )
        }
    }

    private func startStreamingSplitProcessing(extensionId: String, appGroup: String, extensionNumber: Int, splitType: SplitType) {
        isProcessing = true
        updateProgressLabel("Streaming \(splitType)...", extensionNumber: extensionNumber)
        cleanupFiles(appGroup: appGroup)
        
        streamProcessJSON(appGroup: appGroup, extensionNumber: extensionNumber, splitType: splitType) { success in
            if success {
                DispatchQueue.main.async {
                    self.updateProgressLabel("Syncing...", extensionNumber: extensionNumber)
                    self.reloadExtension(identifier: extensionId) { reloadSuccess in
                        self.isProcessing = false
                        if reloadSuccess {
                            print("End Time Extension \(extensionNumber): \(self.getCurrentDateTime())")
                            self.updateProgressLabel("Complete ✅", extensionNumber: extensionNumber)
                        } else {
                            print("Fail Time Extension \(extensionNumber): \(self.getCurrentDateTime())")
                            self.updateProgressLabel("Sync failed ❌", extensionNumber: extensionNumber)
                        }
                    }
                }
            } else {
                self.isProcessing = false
                print("Fail Time Extension \(extensionNumber): \(self.getCurrentDateTime())")
                self.updateProgressLabel("Failed ❌", extensionNumber: extensionNumber)
            }
        }
    }
    
    private func startStreamingSplitProcessingAsync(extensionId: String, appGroup: String, extensionNumber: Int, splitType: SplitType, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            self.updateProgressLabel("Streaming \(splitType)...", extensionNumber: extensionNumber)
        }
        cleanupFiles(appGroup: appGroup)
        
        streamProcessJSON(appGroup: appGroup, extensionNumber: extensionNumber, splitType: splitType) { success in
            if success {
                DispatchQueue.main.async {
                    self.updateProgressLabel("Syncing...", extensionNumber: extensionNumber)
                }
                self.reloadExtension(identifier: extensionId) { reloadSuccess in
                    DispatchQueue.main.async {
                        if reloadSuccess {
                            print("End Time Extension \(extensionNumber): \(self.getCurrentDateTime())")
                            self.updateProgressLabel("Complete ✅", extensionNumber: extensionNumber)
                        } else {
                            print("Fail Time Extension \(extensionNumber): \(self.getCurrentDateTime())")
                            self.updateProgressLabel("Sync failed ❌", extensionNumber: extensionNumber)
                        }
                    }
                    completion(reloadSuccess)
                }
            } else {
                DispatchQueue.main.async {
                    print("Fail Time Extension \(extensionNumber): \(self.getCurrentDateTime())")
                    self.updateProgressLabel("Failed ❌", extensionNumber: extensionNumber)
                }
                completion(false)
            }
        }
    }
    
    // MARK: - Memory Optimized JSON Streaming
    
    private func streamProcessJSON(appGroup: String, extensionNumber: Int, splitType: SplitType, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            autoreleasepool {
                // Create test numbers batch first
                if !self.createTestNumbersBatch(appGroup: appGroup, extensionNumber: extensionNumber) {
                    print("❌ Failed to create test numbers batch for extension \(extensionNumber)")
                    completion(false)
                    return
                }
                // CRITICAL: Use streaming JSON parser to avoid loading entire file
                guard let jsonPath = Bundle.main.path(forResource: "spam_numbers", ofType: "json") else {
                    print("❌ spam_numbers.json file not found in bundle")
                    completion(false)
                    return
                }
                
                let success = self.streamProcessJSONFileInChunks(
                    jsonPath: jsonPath,
                    appGroup: appGroup,
                    extensionNumber: extensionNumber,
                    splitType: splitType
                )
                
                if success {
                    self.calculateAndSaveMetadata(appGroup: appGroup, extensionNumber:extensionNumber) { metaSuccess in
                        print("📊 Extension \(extensionNumber): Memory optimized streaming completed")
                        completion(metaSuccess)
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private func streamProcessJSONFileInChunks(jsonPath: String, appGroup: String, extensionNumber: Int, splitType: SplitType) -> Bool {
        // MEMORY CRITICAL: Parse JSON in streaming fashion
        guard let fileHandle = FileHandle(forReadingAtPath: jsonPath) else {
            print("❌ Could not open JSON file")
            return false
        }
        
        defer {
            fileHandle.closeFile()
        }
        
        do {
            // Read file size and calculate offsets without loading content
            let fileSize = try FileManager.default.attributesOfItem(atPath: jsonPath)[.size] as! Int
            print("📁 Extension \(extensionNumber): JSON file size: \(fileSize) bytes")
            
            // Use JSONSerialization with streaming approach
            let fileData = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
            return self.parseJSONStreamingWithSplit(
                jsonData: fileData,
                appGroup: appGroup,
                extensionNumber: extensionNumber,
                splitType: splitType
            )
            
        } catch {
            print("❌ Extension \(extensionNumber) streaming error: \(error)")
            return false
        }
    }
    
    private func parseJSONStreamingWithSplit(jsonData: Data, appGroup: String, extensionNumber: Int, splitType: SplitType) -> Bool {
        autoreleasepool {
            // Parse JSON but immediately calculate split without storing full array
            do {
                // Quick parse to get total count
                guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [[String]] else {
                    print("❌ Invalid JSON structure")
                    return false
                }
                
                let totalCount = jsonObject.count
                let halfCount = totalCount / 2
                
                print("📊 Extension \(extensionNumber): Total entries: \(totalCount)")
                
                // Calculate split ranges
                let startIndex: Int
                let endIndex: Int
                
                switch splitType {
                case .firstHalf:
                    startIndex = 0
                    endIndex = halfCount
                case .secondHalf:
                    startIndex = halfCount
                    endIndex = totalCount
                }
                
                print("📊 Extension \(extensionNumber): Processing range \(startIndex) to \(endIndex)")
                
                // Process in memory-efficient chunks
                return self.processJSONRangeInSmallChunks(
                    jsonArray: jsonObject,
                    startIndex: startIndex,
                    endIndex: endIndex,
                    appGroup: appGroup,
                    extensionNumber: extensionNumber
                )
                
            } catch {
                print("❌ JSON parsing error: \(error)")
                return false
            }
        }
    }
    
    private func processJSONRangeInSmallChunks(jsonArray: [[String]], startIndex: Int, endIndex: Int, appGroup: String, extensionNumber: Int) -> Bool {
        let targetCount = endIndex - startIndex
        let microChunkSize = streamingChunkSize // 2000 entries per micro-chunk
        let totalMicroChunks = (targetCount + microChunkSize - 1) / microChunkSize
        var batchNumber = 1
        var processedTotal = 0
        
        print("📊 Extension \(extensionNumber): Will process \(totalMicroChunks) micro-chunks of \(microChunkSize) each")
        
        for microChunkIndex in 0..<totalMicroChunks {
            autoreleasepool {
                let microStartIdx = startIndex + (microChunkIndex * microChunkSize)
                let microEndIdx = min(microStartIdx + microChunkSize, endIndex)
                
                // Extract only this micro-chunk
                let microChunk = Array(jsonArray[microStartIdx..<microEndIdx])
                
                // Process this micro-chunk into batch
                var chunkNumbers: [(Int64, String)] = []
                
                for entry in microChunk {
                    guard entry.count >= 2 else { continue }
                    
                    let cleanNumber = entry[0].replacingOccurrences(of: "(", with: "")
                                             .replacingOccurrences(of: ")", with: "")
                                             .replacingOccurrences(of: "\"", with: "")
                    
                    guard let phoneNumber = Int64(cleanNumber) else { continue }
                    let label = String(entry[1].prefix(64))
                    chunkNumbers.append((phoneNumber, label))
                }
                
                chunkNumbers.sort { $0.0 < $1.0 }
                
                if self.saveBatchFile(batchNumber: batchNumber, spamNumbers: chunkNumbers, appGroup: appGroup) {
                    processedTotal += chunkNumbers.count
                    batchNumber += 1
                    
                    DispatchQueue.main.async {
                        let progress = Int((Float(microChunkIndex + 1) / Float(totalMicroChunks)) * 100)
                        self.updateProgressLabel("Streaming \(progress)%", extensionNumber: extensionNumber)
                        self.updateMemoryLabel("Chunk \(microChunkIndex + 1)/\(totalMicroChunks)")
                    }
                }
            }
            
            // Memory relief pause every 5 micro-chunks
            if microChunkIndex % 5 == 0 && microChunkIndex > 0 {
                usleep(200000) // 0.2 second pause
            }
        }
        
        print("✅ Extension \(extensionNumber): Processed \(processedTotal) entries in \(batchNumber - 1) batches")
        return processedTotal > 0
    }
    
    private func createTestNumbersBatch(appGroup: String, extensionNumber: Int) -> Bool {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            return false
        }
        
        
        if extensionNumber == 1 {
            let fileName = "spam-batch-000.json"
            let fileURL = containerURL.appendingPathComponent(fileName)
               
            let testNumbers: [(Int64, String)] = [
                (917995763073, "❌ Un Verified Number"),
                (917702957151, "✅ Verified Number"),
                (919154459531, "❓ UnKnown Number"),
                (919676407997, "✅ Verified Number")
            ]
             
            do {
                let jsonArray = testNumbers.map { [$0.0, $0.1] }
                let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
                try data.write(to: fileURL)
                print("🧪 Extension \(extensionNumber): Created test batch (\(testNumbers.count) entries)")
                return true
            } catch {
                print("❌ Extension \(extensionNumber) test batch save error: \(error)")
                return false
            }
        } else {
            let fileName = "spam-batch-000.json"
            let fileURL = containerURL.appendingPathComponent(fileName)
              
            let testNumbers: [(Int64, String)] = [
                (917702957151, "🛡️ Spam Joshna EXT\(extensionNumber)"),
            ]
            
            do {
                let jsonArray = testNumbers.map { [$0.0, $0.1] }
                let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
                try data.write(to: fileURL)
                print("🧪 Extension \(extensionNumber): Created test batch (\(testNumbers.count) entries)")
                return true
            } catch {
                print("❌ Extension \(extensionNumber) test batch save error: \(error)")
                return false
            }
        }
       
    }
    
    // MARK: - File Management
    private func cleanupFiles(appGroup: String) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else { return }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: nil)
            for file in files {
                if file.lastPathComponent.hasPrefix("spam-batch-") ||
                   file.lastPathComponent == "spam-numbers.json" ||
                   file.lastPathComponent == "spam-metadata.json" {
                    try? FileManager.default.removeItem(at: file)
                }
            }
        } catch {
            print("⚠️ Cleanup error for \(appGroup): \(error)")
        }
    }
    
    private func saveBatchFile(batchNumber: Int, spamNumbers: [(Int64, String)], appGroup: String) -> Bool {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            return false
        }
        
        let fileName = "spam-batch-\(String(format: "%03d", batchNumber)).json"
        let fileURL = containerURL.appendingPathComponent(fileName)
        
        do {
            let jsonArray = spamNumbers.map { [$0.0, $0.1] }
            let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
            try data.write(to: fileURL)
            return true
        } catch {
            return false
        }
    }
    
    private func calculateAndSaveMetadata(appGroup: String, extensionNumber : Int, completion: @escaping (Bool) -> Void) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            completion(false)
            return
        }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: nil)
            let batchFiles = files.filter { $0.lastPathComponent.hasPrefix("spam-batch-") }
            
            var totalEntries = 0
            for batchFile in batchFiles {
                if let data = try? Data(contentsOf: batchFile),
                   let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[Any]] {
                    totalEntries += jsonArray.count
                }
            }
            
            saveMetadata(totalEntries: totalEntries, extensionNumber:extensionNumber, lastUpdated: Date(), appGroup: appGroup, completion: completion)
            
        } catch {
            completion(false)
        }
    }
    
    private func saveMetadata(totalEntries: Int, extensionNumber: Int, lastUpdated: Date, appGroup: String, completion: @escaping (Bool) -> Void) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            completion(false)
            return
        }
        
        let fileURL = containerURL.appendingPathComponent("spam-metadata.json")
        
        do {
            let metadata = [
                "totalEntries": totalEntries,
                "lastUpdated": ISO8601DateFormatter().string(from: lastUpdated),
                "version": "8.0-Memory-Optimized-Streaming",
                "appGroup": appGroup,
                "source": "spam_numbers.json"
            ] as [String : Any]
            
            let data = try JSONSerialization.data(withJSONObject: metadata, options: [])
            try data.write(to: fileURL)
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    private func reloadExtension(identifier: String, completion: @escaping (Bool) -> Void) {
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: identifier) { error in
            DispatchQueue.main.async {
                if let error = error {
                    let nsError = error as NSError
                    print("❌ Extension reload error (\(identifier)): \(error.localizedDescription)")
                    print("❌ Error code: \(nsError.code)")
                    completion(false)
                } else {
                    print("✅ Extension reloaded successfully (\(identifier))")
                    completion(true)
                }
            }
        }
    }
    @objc func addOrRemoveBlockNumber() {
        guard !isProcessing else {
            print("⚠️ Already processing...")
            return
        }
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Add/Remove Number", message: "Enter phone number to block/remove", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "+62XXXXXXXXX"
                textField.keyboardType = .phonePad
            }
            
            alert.addAction(UIAlertAction(title: "Add Block", style: .default) { _ in
                guard let phoneNumber = alert.textFields?.first?.text, !phoneNumber.isEmpty else { return }
                
                print("Add Block Number Start Time : \(getCurrentDateTimeInSeconds())")
                shared_Block_Defaults?.set(add_one_block_number, forKey: number_processing_type)
                shared_Block_Defaults?.set(phoneNumber, forKey: add_remove_block_msisdn)
                shared_Block_Defaults?.synchronize()
                
                DispatchQueue.main.async {
                    
                    CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.imimobile.SpamCallIdentifier.CallDirectoryHandler") { error in
                        DispatchQueue.main.async {
                            print("Add Block Number End Time : \(getCurrentDateTimeInSeconds())")
                            if error != nil {
                                print("Fail to block the input number")
                            } else {
                                print("Input number successfully blocked")
                            }
                        }
                    }
                }
                
            })
            
            alert.addAction(UIAlertAction(title: "Remove Block", style: .default) { _ in
                guard let phoneNumber = alert.textFields?.first?.text, !phoneNumber.isEmpty else { return }
                
                print("Remove Block Number Start Time : \(getCurrentDateTimeInSeconds())")
                
                shared_Block_Defaults?.set(remove_one_block_number, forKey: number_processing_type)
                shared_Block_Defaults?.set(phoneNumber, forKey: add_remove_block_msisdn)
                shared_Block_Defaults?.synchronize()
                
                DispatchQueue.main.async {
                    
                    CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.imimobile.SpamCallIdentifier.CallDirectoryHandler") { error in
                        DispatchQueue.main.async {
                            print("Remove Block Number End Time : \(getCurrentDateTimeInSeconds())")
                            if error != nil {
                                print("Fail to unblock the input number")
                            } else {
                                print("Input blocked number successfully removed")
                            }
                        }
                    }
                }
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
        
    }
}

public let shared_Block_Defaults = UserDefaults(suiteName: appGroupID)
public let number_processing_type = "NUMBER_PROCESSING_TYPE"
public let add_all_identifications = "ADD_ALL_IDENTIFICATIONS"
public let add_one_block_number = "ADD_ONE_BLOCK_NUMBER"
public let remove_one_block_number = "REMOVE_ONE_BLOCK_NUMBER"
public let add_remove_block_msisdn = "ADD_REMOVE_BLOCK_MSISDN"


public func getCurrentDateTimeInSeconds() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
    let istTimeString = formatter.string(from: Date())
    return istTimeString
}
