import SwiftUI

public struct ProgressPhotoCard: View {
    public let photo: ProgressPhoto
    
    public init(photo: ProgressPhoto) {
        self.photo = photo
    }
    
    public var body: some View {
        GlassCard {
            VStack {
                if let image = PhotoTimelineManager.shared.loadPhoto(from: photo.localImagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 160)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 160)
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                }
                
                Text(photo.date, style: .date)
                    .atlasFont(.caption2)
                    .foregroundColor(Color.Atlas.textSecondary)
                    .padding(.top, Spacing.small)
            }
        }
    }
}

public struct MilestoneCard: View {
    public let milestone: Milestone
    
    public init(milestone: Milestone) {
        self.milestone = milestone
    }
    
    public var body: some View {
        GlassCard {
            HStack(spacing: Spacing.medium) {
                ZStack {
                    Circle()
                        .fill(Color.Atlas.primary.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: milestone.icon)
                        .font(.title2)
                        .foregroundColor(Color.Atlas.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(milestone.title)
                        .atlasFont(.headline)
                        .foregroundColor(Color.Atlas.textPrimary)
                    
                    Text(milestone.subtitle)
                        .atlasFont(.subheadline)
                        .foregroundColor(Color.Atlas.textSecondary)
                }
                
                Spacer()
                
                if milestone.isRecent {
                    Text("NEW")
                        .atlasFont(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.Atlas.primary)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

public struct BodyCompositionCard: View {
    public let measurement: BodyMeasurement
    
    public init(measurement: BodyMeasurement) {
        self.measurement = measurement
    }
    
    public var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack {
                    Text("Latest Measurements")
                        .atlasFont(.headline)
                        .foregroundColor(Color.Atlas.textPrimary)
                    Spacer()
                    Text(measurement.date, style: .date)
                        .atlasFont(.caption)
                        .foregroundColor(Color.Atlas.textSecondary)
                }
                
                Divider()
                
                HStack(spacing: Spacing.large) {
                    measurementStat(title: "Chest", value: measurement.chest)
                    measurementStat(title: "Waist", value: measurement.waist)
                    measurementStat(title: "Arms", value: measurement.rightArm) // using right arm as proxy
                }
            }
        }
    }
    
    @ViewBuilder
    private func measurementStat(title: String, value: Double?) -> some View {
        if let value = value {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .atlasFont(.caption)
                    .foregroundColor(Color.Atlas.textSecondary)
                
                Text(String(format: "%.1f cm", value))
                    .atlasFont(.title3)
                    .foregroundColor(Color.Atlas.textPrimary)
            }
        }
    }
}
