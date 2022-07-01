


import Foundation

struct Messages : Codable {
	let title : String?
	let description : String?
	let image : String?
	let id : String?
	let unread : Bool?
    var saved : Bool = false

	enum CodingKeys: String, CodingKey {

		case title = "title"
		case description = "description"
		case image = "image"
		case id = "id"
		case unread = "unread"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		image = try values.decodeIfPresent(String.self, forKey: .image)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		unread = try values.decodeIfPresent(Bool.self, forKey: .unread)
	}
}
