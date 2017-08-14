import Foundation

/// Defines additional information to include in the message.
///
/// An attachment may be a media file (e.g., audio, video, image, file) or a rich card.
public struct Attachment {
	public enum Content {
		case adaptiveCard(AdaptiveCard)
		case media(Media)
	}

	/// The content of the attachment.
	public let content: Content

	/// Name of the attachment.
	public let name: String?

	/// URL to a thumbnail image representing an alternative, smaller form of content.
	public let thumbnailURL: URL?

	public init(content: Content, name: String? = nil, thumbnailURL: URL? = nil) {
		self.content = content
		self.name = name
		self.thumbnailURL = thumbnailURL
	}
}

extension Attachment: Codable {
	private enum CodingKeys: String, CodingKey {
		case contentType
		case content
		case name
		case thumbnailURL = "thumbnailUrl"
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let contentType = try container.decode(String.self, forKey: .contentType)
		let content: Content

		switch contentType {
		case AdaptiveCard.contentType:
			content = .adaptiveCard(try container.decode(AdaptiveCard.self, forKey: .content))
		default:
			content = .media(try Media(from: decoder))
		}

		let name = try container.decodeIfPresent(String.self, forKey: .name)
		let thumbnailURL = try container.decodeIfPresent(URL.self, forKey: .thumbnailURL)

		self.init(content: content, name: name, thumbnailURL: thumbnailURL)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		switch content {
		case .media(let value):
			try value.encode(to: encoder)
		default:
			let context = EncodingError.Context(codingPath: [CodingKeys.content],
			                                    debugDescription: "Encoding for this content is not supported.")
			throw EncodingError.invalidValue(content, context)
		}

		try container.encodeIfPresent(name, forKey: .name)
		try container.encodeIfPresent(thumbnailURL, forKey: .thumbnailURL)
	}
}
