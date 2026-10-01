import PhotosUI
import SwiftUI

struct MessageComposer: View {
    @Bindable var model: AiChatViewModel

    @State private var isPhotosPresented = false
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var isCameraPresented = false
    @State private var isFilesPresented = false
    @State private var sendCount = 0
    @FocusState private var isInputFocused: Bool

    private var isSendEnabled: Bool { model.isStreaming || model.canSend }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !model.attachments.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(model.attachments) { attachment in
                            AttachmentChip(attachment: attachment) { model.removeAttachment(attachment) }
                        }
                    }
                    .padding(.leading, 4)
                }
                .scrollIndicators(.hidden)
            }
            GlassEffectContainer(spacing: 8) {
                HStack(alignment: .bottom, spacing: 8) {
                    HStack(alignment: .bottom, spacing: 4) {
                        attachmentMenu
                        TextField("Message AI…", text: $model.inputText, axis: .vertical)
                            .lineLimit(1...4)
                            .focused($isInputFocused)
                            .padding(.vertical, 8)
                    }
                    .padding(.leading, 6)
                    .padding(.trailing, 14)
                    .padding(.vertical, 4)
                    .glassEffect(.regular, in: .rect(cornerRadius: 26))
                    sendButton
                }
            }
        }
        .photosPicker(isPresented: $isPhotosPresented, selection: $photoItems, matching: .images)
        .onChange(of: photoItems) { _, items in
            guard !items.isEmpty else { return }
            photoItems = []
            Task { model.addAttachments(await ChatAttachmentLoader.load(photoItems: items)) }
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraPicker(
                onCapture: { image in
                    Task {
                        if let attachment = await ChatAttachmentLoader.load(cameraImage: image) {
                            model.addAttachments([attachment])
                        }
                    }
                },
                onDismiss: { isCameraPresented = false }
            )
            .ignoresSafeArea()
        }
        .fileImporter(isPresented: $isFilesPresented, allowedContentTypes: [.image, .pdf, .text], allowsMultipleSelection: true) { result in
            guard case let .success(urls) = result else { return }
            Task { model.addAttachments(await ChatAttachmentLoader.load(fileURLs: urls)) }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: sendCount)
    }

    private var attachmentMenu: some View {
        Menu {
            Button("Photos", systemImage: "photo.on.rectangle") { isPhotosPresented = true }
            if CameraPicker.isAvailable {
                Button("Camera", systemImage: "camera") { isCameraPresented = true }
            }
            Button("Files", systemImage: "folder") { isFilesPresented = true }
        } label: {
            Image(systemName: "plus")
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(width: 44, height: 44)
                .contentShape(.circle)
        }
        .accessibilityLabel("Add attachment")
    }

    private var sendButton: some View {
        Button {
            if model.isStreaming {
                model.cancelStream()
            } else {
                isInputFocused = false
                sendCount += 1
                model.sendMessage()
            }
        } label: {
            Image(systemName: model.isStreaming ? "stop.fill" : "arrow.up")
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.onAccent)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .disabled(!isSendEnabled)
        .accessibilityLabel(model.isStreaming ? "Stop generating" : "Send message")
    }
}
