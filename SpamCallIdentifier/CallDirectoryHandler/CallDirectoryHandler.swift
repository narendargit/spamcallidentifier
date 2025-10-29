//
//  CallDirectoryHandler.swift
//  CallDirectoryHandler (Extension 1)
//
//  Extension 1 - Uses group.com.imimobile.CallBlocker
//  Memory Optimized for 10L+ entries
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {
    let appGroupID = "group.com.imimobile.CallBlocker"
    
    // Memory optimized limits for high-volume processing
    private let maxProcessingTime: CFAbsoluteTime = 22.0 // Reduced to 22 seconds
    private let maxBatchesToProcess = 150 // Increased for 10L capacity
    private let memoryCheckInterval = 10 // Check memory every 10 batches
    private let maxMemoryThreshold = 80 * 1024 * 1024 // 80MB memory limit
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        
        let defaults = UserDefaults(suiteName: appGroupID)!
        
        context.delegate = self
        
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else {
            return
        }
        print("🚀 Extension 1 (First Half) started at \(Date())")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let lastUpdate = defaults.object(forKey: "lastCallDirectoryUpdate") as? Date
        
        let number_processing_type = sharedDefaults.string(forKey: "NUMBER_PROCESSING_TYPE") ?? ""
        
        if number_processing_type != nil || number_processing_type.count > 0 {
            
            switch number_processing_type.uppercased() {
            case "ADD_ALL_IDENTIFICATIONS" :
                // Memory optimized processing approach
                memoryOptimizedStreamProcessing(context: context, startTime: startTime)
                break
                
            case "ADD_ONE_BLOCK_NUMBER", "REMOVE_ONE_BLOCK_NUMBER" :
                if context.isIncremental && lastUpdate != nil {
                    
                    if let add_block_number = sharedDefaults.string(forKey: "ADD_REMOVE_BLOCK_MSISDN")  {
                        
                        let cleanNumStr = add_block_number.trimmingCharacters(in: CharacterSet(charactersIn: "()\" -+"))
                        guard let phoneNumber = Int64(cleanNumStr) else { return }
                        let digitCount = String(add_block_number).count
                        guard digitCount >= 8 && digitCount <= 15 else { return }
                        
                        if number_processing_type.uppercased() == "ADD_ONE_BLOCK_NUMBER" {
                            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
                        } else {
                            context.removeBlockingEntry(withPhoneNumber: phoneNumber)
                        }
                    }
                }
                break
            default :
                memoryOptimizedStreamProcessing(context: context, startTime: startTime)
                break
            }
            
        } else {
            // Memory optimized processing approach
            memoryOptimizedStreamProcessing(context: context, startTime: startTime)
        }
        defaults.set(Date(), forKey: "lastCallDirectoryUpdate")

        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        print("⏱️ Extension 1 completed in \(String(format: "%.2f", totalTime))s")
        
        context.completeRequest()
    }
    
    private func memoryOptimizedStreamProcessing(context: CXCallDirectoryExtensionContext, startTime: CFAbsoluteTime) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            print("❌ Extension 1: Container URL not found")
            return
        }
        
        // Get memory info at start
        let initialMemory = getMemoryUsage()
        print("📊 Extension 1: Initial memory usage: \(initialMemory)MB")
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: nil)
            let batchFiles = files.filter { $0.lastPathComponent.hasPrefix("spam-batch-") }
                                 .sorted { $0.lastPathComponent < $1.lastPathComponent }
            
            if batchFiles.isEmpty {
                print("ℹ️ Extension 1: No batch files found")
                return
            }
            
            print("📁 Extension 1: Found \(batchFiles.count) batch files")
            
            var totalProcessed = 0
            let maxBatches = min(batchFiles.count, maxBatchesToProcess)
            var memoryWarningCount = 0
            
            // Process each batch with memory monitoring
            batchLoop: for (index, batchURL) in batchFiles.prefix(maxBatches).enumerated() {
                // Time check before each batch
                let elapsed = CFAbsoluteTimeGetCurrent() - startTime
                if elapsed > maxProcessingTime {
                    print("⏰ Extension 1: Time limit reached at batch \(index + 1)")
                    break batchLoop
                }
                
                // Memory check every N batches
                if index % memoryCheckInterval == 0 && index > 0 {
                    let currentMemory = getMemoryUsage()
                    print("📊 Extension 1: Memory at batch \(index + 1): \(currentMemory)MB")
                    
                    if currentMemory > Float(maxMemoryThreshold) / (1024.0 * 1024.0) {
                        memoryWarningCount += 1
                        print("⚠️ Extension 1: High memory usage detected (\(currentMemory)MB)")
                        
                        // Force garbage collection
                        autoreleasepool {
                            // Trigger memory cleanup
                        }
                        
                        if memoryWarningCount >= 3 {
                            print("🛑 Extension 1: Too many memory warnings, stopping processing")
                            break batchLoop
                        }
                        
                        // Brief pause for memory relief
                        usleep(500000) // 0.5 second
                    }
                }
                
                autoreleasepool {
                    if let processedCount = processOrderedBatchOptimized(batchURL, context: context) {
                        totalProcessed += processedCount
                        
                        // Log progress for key batches
                        if index % 20 == 0 ||
                           batchURL.lastPathComponent == "spam-batch-000.json" ||
                           index == batchFiles.count - 1 {
                            print("✅ Extension 1 - Batch \(index + 1)/\(maxBatches) (\(batchURL.lastPathComponent)): \(processedCount) entries")
                        }
                    } else {
                        print("❌ Extension 1: Failed batch \(index + 1) (\(batchURL.lastPathComponent))")
                    }
                }
                
                // Memory relief pause every 25 batches
                if index % 25 == 0 && index > 0 {
                    usleep(300000) // 0.3 second pause
                }
                
                // Final time check
                let elapsedAfter = CFAbsoluteTimeGetCurrent() - startTime
                if elapsedAfter > maxProcessingTime {
                    print("⏰ Extension 1: Time limit reached after batch \(index + 1)")
                    break batchLoop
                }
            }
            
            let finalMemory = getMemoryUsage()
            print("🎉 Extension 1: Processing completed")
            print("📊 Extension 1: Total processed: \(totalProcessed) entries")
            print("📊 Extension 1: Final memory usage: \(finalMemory)MB")
            print("📊 Extension 1: Memory growth: \(finalMemory - initialMemory)MB")
            
        } catch {
            print("❌ Extension 1: Directory error: \(error)")
        }
    }
    
    private func processOrderedBatchOptimized(_ url: URL, context: CXCallDirectoryExtensionContext) -> Int? {
        return autoreleasepool {
            do {
                let data = try Data(contentsOf: url)
                guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[Any]] else {
                    print("❌ Extension 1: Invalid JSON in \(url.lastPathComponent)")
                    return nil
                }
                
                // Pre-allocate array capacity for better memory management
                var numbers: [(Int64, String)] = []
                numbers.reserveCapacity(jsonArray.count)
                
                // Debug for test batch
                if url.lastPathComponent == "spam-batch-000.json" {
                    print("🔍 Extension 1: Processing test batch with \(jsonArray.count) entries")
                }
                
                // Optimized parsing loop
                for (index, entry) in jsonArray.enumerated() {
                    guard entry.count >= 2 else { continue }
                    
                    let phoneNumber: Int64
                    let label: String
                    
                    // Optimized number parsing
                    if let num = entry[0] as? Int64 {
                        phoneNumber = num
                    } else if let num = entry[0] as? NSNumber {
                        phoneNumber = num.int64Value
                    } else if let numStr = entry[0] as? String {
                        // Fast string to int conversion
                        guard let num = Int64(numStr) else { continue }
                        phoneNumber = num
                    } else {
                        continue
                    }
                    
                    // Optimized label processing
                    if let lbl = entry[1] as? String {
                        label = lbl.count > 64 ? String(lbl.prefix(64)) : lbl
                    } else {
                        continue
                    }
                    
                    // Quick validation
                    guard phoneNumber > 1000000000 else { continue }
                    numbers.append((phoneNumber, label))
                    
                    // Debug: Show first few entries from test batch
                    if url.lastPathComponent == "spam-batch-000.json" && index < 3 {
                        print("📱 Extension 1 test entry \(index + 1): \(phoneNumber) → '\(label)'")
                    }
                }
                
                // Optimized sorting
                numbers.sort { $0.0 < $1.0 }
                
                // Batch add to CallKit for better performance
                for (phoneNumber, label) in numbers {
                    context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumber, label: label)
                }
                
                return numbers.count
                
            } catch {
                print("❌ Extension 1: Batch processing error for \(url.lastPathComponent): \(error)")
                return nil
            }
        }
    }
    
    private func getMemoryUsage() -> Float {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Float(info.resident_size) / (1024.0 * 1024.0) // MB
        } else {
            return 0.0
        }
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        let nsError = error as NSError
        print("❌ Extension 1 failed: \(error.localizedDescription)")
        print("❌ Domain: \(nsError.domain), Code: \(nsError.code)")
        
        switch nsError.code {
        case 0:
            print("💡 Extension 1: Unknown error")
        case 1:
            print("💡 Extension 1: No such extension")
        case 2:
            print("💡 Extension 1: Loading interrupted - Timeout or memory limit")
            print("💡 Suggestion: Reduce batch size or enable memory monitoring")
        case 3:
            print("💡 Extension 1: Entries out of order - Check sorting logic")
        case 4:
            print("💡 Extension 1: Duplicate entries - Check data deduplication")
        case 5:
            print("💡 Extension 1: Maximum entries exceeded - Reduce dataset size")
        case 6:
            print("💡 Extension 1: Extension disabled - Enable in Settings")
        case 7:
            print("💡 Extension 1: Current settings prohibit - Check privacy settings")
        default:
            print("💡 Extension 1: Unknown error code: \(nsError.code)")
        }
        
        // Log memory usage on failure
        let memoryUsage = getMemoryUsage()
        print("📊 Extension 1: Memory usage at failure: \(memoryUsage)MB")
    }
}
