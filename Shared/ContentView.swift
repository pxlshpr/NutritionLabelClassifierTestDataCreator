import SwiftUI
import SwiftSugar
import TabularData
import VisionSugar
import NutritionLabelClassifier

struct ContentView: View {
    
    /// Taken from the ScrollView on the iPhone 13 Pro Max simulator as an example
    let contentSize = CGSize(width: 428, height: 730)
    
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear {
                writeCSVFiles()
            }
    }
    
    func writeCSVFiles() {
        
        var firstScanDiffs: [CFAbsoluteTime] = []
        var secondScanDiffs: [CFAbsoluteTime] = []
        var totalScanDiffs: [CFAbsoluteTime] = []

        let imageIndices = 1...20
        for textCase in imageIndices {
            guard let image = UIImage(named: "\(textCase)") else {
                fatalError("Couldn't load  image: \(textCase)")
                continue
            }
            
            //MARK: - First Scan
            let scanStart = CFAbsoluteTimeGetCurrent()
            VisionSugar.recognizedTexts(for: image, inContentSize: contentSize) { recognizedTexts in
                
                firstScanDiffs.append(CFAbsoluteTimeGetCurrent() - scanStart)
                
                guard let recognizedTexts = recognizedTexts else {
                    fatalError("Couldn't get recognizedTexts for image: \(textCase)")
                }
                let dataFrame = recognizedTexts.dataFrame
                dataFrame.write(to: urlForImageNumber(textCase))

                //MARK: - Second Scan
                let secondScanStart = CFAbsoluteTimeGetCurrent()
                VisionSugar.recognizedTexts(for: image, useLanguageCorrection: false, inContentSize: contentSize) { recognizedTexts in
                    
                    secondScanDiffs.append(CFAbsoluteTimeGetCurrent() - secondScanStart)
                    totalScanDiffs.append(CFAbsoluteTimeGetCurrent() - scanStart)

                    guard let recognizedTexts = recognizedTexts else {
                        fatalError("Couldn't get recognizedTexts for image: \(textCase)")
                    }
                    let dataFrame = recognizedTexts.dataFrame
                    dataFrame.write(to: urlForImageNumber(textCase, usesLanguageCorrection: false))
                }
            }
        }
        
        print("Wrote files to: \(URL.documents)")
        let averageFirst = Double(firstScanDiffs.reduce(0) { $0 + $1 }) / Double(imageIndices.count)
        let averageSecond = Double(secondScanDiffs.reduce(0) { $0 + $1 }) / Double(imageIndices.count)
        let averageTotal = Double(totalScanDiffs.reduce(0) { $0 + $1 }) / Double(imageIndices.count)
        print("Average firstScanDiffs: \(averageFirst)")
        print("Average secondScanDiffs: \(averageSecond)")
        print("Average totalScanDiffs: \(averageTotal)")
    }
    
    func urlForImageNumber(_ imageNumber: Int, usesLanguageCorrection: Bool = true) -> URL {
        URL.documents.appendingPathComponent("\(imageNumber)\(usesLanguageCorrection ? "" : "-without_language_correction").csv")
    }
}
