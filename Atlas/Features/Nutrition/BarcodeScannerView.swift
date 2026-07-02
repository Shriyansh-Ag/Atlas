import SwiftUI

public struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    public var onScan: (String) -> Void
    
    public init(onScan: @escaping (String) -> Void) {
        self.onScan = onScan
    }
    
    public var body: some View {
        VStack(spacing: Spacing.large) {
            Text("Scanner Placeholder")
                .atlasFont(AtlasTypography.title2())
            Text("VisionKit DataScannerViewController goes here.")
                .foregroundColor(Color.Atlas.textSecondary)
            
            Button("Simulate Scan '123456789'") {
                onScan("123456789")
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Cancel") {
                dismiss()
            }
        }
        .padding()
    }
}
