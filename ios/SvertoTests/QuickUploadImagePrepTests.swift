import Foundation
import ImageIO
import Testing
import UIKit
@testable import Sverto

private func pngData(width: Int, height: Int) throws -> Data {
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
    let image = renderer.image { context in
        UIColor.systemTeal.setFill()
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        UIColor.white.setFill()
        context.fill(CGRect(x: width / 4, y: height / 4, width: width / 2, height: height / 2))
    }
    return try #require(image.pngData())
}

private func pixelSize(_ data: Data) throws -> (width: Int, height: Int) {
    let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
    let properties = try #require(CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any])
    let width = try #require(properties[kCGImagePropertyPixelWidth] as? Int)
    let height = try #require(properties[kCGImagePropertyPixelHeight] as? Int)
    return (width, height)
}

private func isJpeg(_ data: Data) -> Bool {
    data.count > 3 && data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF
}

struct QuickUploadImagePrepTests {
    @Test func maxImageSizeIsTenMegabytes() {
        #expect(QuickUploadImagePrep.maxImageBytes == 10_485_760)
    }

    @Test func rejectsEmptyData() {
        #expect(QuickUploadImagePrep.prepare(imageData: Data(), mimeType: "image/png") == nil)
    }

    @Test func rejectsDataOverTheSizeCap() {
        let oversized = Data(count: QuickUploadImagePrep.maxImageBytes + 1)

        #expect(QuickUploadImagePrep.prepare(imageData: oversized, mimeType: "image/jpeg") == nil)
    }

    @Test func rejectsNonImageBytes() {
        let text = Data("definitely not an image".utf8)

        #expect(QuickUploadImagePrep.prepare(imageData: text, mimeType: "image/png") == nil)
    }

    @Test func keepsOriginalBytesAndImageMimeType() throws {
        let png = try pngData(width: 400, height: 300)

        let prepared = try #require(QuickUploadImagePrep.prepare(imageData: png, mimeType: "image/png"))

        #expect(prepared.imageData == png)
        #expect(prepared.mimeType == "image/png")
    }

    @Test func nonImageOrMissingMimeTypeFallsBackToJpeg() throws {
        let png = try pngData(width: 64, height: 64)

        #expect(try #require(QuickUploadImagePrep.prepare(imageData: png, mimeType: nil)).mimeType == "image/jpeg")
        #expect(try #require(QuickUploadImagePrep.prepare(imageData: png, mimeType: "application/octet-stream")).mimeType == "image/jpeg")
        #expect(try #require(QuickUploadImagePrep.prepare(imageData: png, mimeType: "")).mimeType == "image/jpeg")
        #expect(try #require(QuickUploadImagePrep.prepare(imageData: png, mimeType: "image/heic")).mimeType == "image/heic")
    }

    @Test func thumbnailIsJpegScaledToTwoHundredPixelsWideForLandscape() throws {
        let png = try pngData(width: 400, height: 300)

        let prepared = try #require(QuickUploadImagePrep.prepare(imageData: png, mimeType: "image/png"))
        let size = try pixelSize(prepared.thumbnail)

        #expect(isJpeg(prepared.thumbnail))
        #expect(size.width == 200)
        #expect(size.height == 150)
    }

    @Test func thumbnailIsTwoHundredPixelsWideForPortrait() throws {
        let png = try pngData(width: 300, height: 600)

        let prepared = try #require(QuickUploadImagePrep.prepare(imageData: png, mimeType: "image/png"))
        let size = try pixelSize(prepared.thumbnail)

        #expect(size.width == 200)
        #expect(size.height == 400)
    }

    @Test func smallImagesAreNotUpscaled() throws {
        let png = try pngData(width: 50, height: 50)

        let prepared = try #require(QuickUploadImagePrep.prepare(imageData: png, mimeType: "image/png"))
        let size = try pixelSize(prepared.thumbnail)

        #expect(isJpeg(prepared.thumbnail))
        #expect(size.width == 50)
        #expect(size.height == 50)
    }

    @Test func thumbnailIsSmallerThanALargeSource() throws {
        let png = try pngData(width: 1600, height: 1200)

        let prepared = try #require(QuickUploadImagePrep.prepare(imageData: png, mimeType: "image/png"))

        #expect(prepared.thumbnail.count < png.count)
        #expect(try pixelSize(prepared.thumbnail).width == 200)
    }
}

struct QuickUploadStatusTests {
    @Test func mapsServerStatusesToUiStates() {
        #expect(QuickUploadStatus(serverStatus: "queued") == .queued)
        #expect(QuickUploadStatus(serverStatus: "uploading") == .uploading)
        #expect(QuickUploadStatus(serverStatus: "pending") == .processing)
        #expect(QuickUploadStatus(serverStatus: "created") == .processing)
        #expect(QuickUploadStatus(serverStatus: "processing") == .processing)
        #expect(QuickUploadStatus(serverStatus: "proposal_ready") == .ready)
        #expect(QuickUploadStatus(serverStatus: "failed") == .failed)
    }

    @Test func unknownStatusesAreTreatedAsProcessing() {
        #expect(QuickUploadStatus(serverStatus: "") == .processing)
        #expect(QuickUploadStatus(serverStatus: "READY") == .processing)
        #expect(QuickUploadStatus(serverStatus: "something_new") == .processing)
    }
}

struct ProposalTypeTests {
    @Test func rawValuesMatchServerProposalTypes() {
        #expect(ProposalType(rawValue: "transaction") == .transaction)
        #expect(ProposalType(rawValue: "transaction_group") == .transactionGroup)
        #expect(ProposalType(rawValue: "group") == nil)
        #expect(ProposalType.transactionGroup.rawValue == "transaction_group")
    }
}
