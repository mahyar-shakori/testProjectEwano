


import Foundation

struct MessagesJson : Codable {
	let messages : [Messages]?

	enum CodingKeys: String, CodingKey {

		case messages = "messages"
	}
    
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		messages = try values.decodeIfPresent([Messages].self, forKey: .messages)
	}
}
