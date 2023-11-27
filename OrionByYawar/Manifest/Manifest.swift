/* 
Copyright (c) 2023 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Manifest : Codable {
	let browser_specific_settings : Browser_specific_settings?
	let background : Background?
	let browser_action : Browser_action?
	let commands : Commands?
	let content_security_policy : String?
	let content_scripts : [Content_scripts]?
	let default_locale : String?
	let description : String?
	let icons : Icons?
	let manifest_version : Int?
	let name : String?
	let page_action : Page_action?
	let permissions : [String]?
	let version : String?
	let user_scripts : User_scripts?
	let web_accessible_resources : [String]?

	enum CodingKeys: String, CodingKey {

		case browser_specific_settings = "browser_specific_settings"
		case background = "background"
		case browser_action = "browser_action"
		case commands = "commands"
		case content_security_policy = "content_security_policy"
		case content_scripts = "content_scripts"
		case default_locale = "default_locale"
		case description = "description"
		case icons = "icons"
		case manifest_version = "manifest_version"
		case name = "name"
		case page_action = "page_action"
		case permissions = "permissions"
		case version = "version"
		case user_scripts = "user_scripts"
		case web_accessible_resources = "web_accessible_resources"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		browser_specific_settings = try values.decodeIfPresent(Browser_specific_settings.self, forKey: .browser_specific_settings)
		background = try values.decodeIfPresent(Background.self, forKey: .background)
		browser_action = try values.decodeIfPresent(Browser_action.self, forKey: .browser_action)
		commands = try values.decodeIfPresent(Commands.self, forKey: .commands)
		content_security_policy = try values.decodeIfPresent(String.self, forKey: .content_security_policy)
		content_scripts = try values.decodeIfPresent([Content_scripts].self, forKey: .content_scripts)
		default_locale = try values.decodeIfPresent(String.self, forKey: .default_locale)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		icons = try values.decodeIfPresent(Icons.self, forKey: .icons)
		manifest_version = try values.decodeIfPresent(Int.self, forKey: .manifest_version)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		page_action = try values.decodeIfPresent(Page_action.self, forKey: .page_action)
		permissions = try values.decodeIfPresent([String].self, forKey: .permissions)
		version = try values.decodeIfPresent(String.self, forKey: .version)
		user_scripts = try values.decodeIfPresent(User_scripts.self, forKey: .user_scripts)
		web_accessible_resources = try values.decodeIfPresent([String].self, forKey: .web_accessible_resources)
	}

}
