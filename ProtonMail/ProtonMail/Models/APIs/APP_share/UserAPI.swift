//
//  UserAPI.swift
//  Proton Mail - Created on 11/3/15.
//
//
//  Copyright (c) 2019 Proton AG
//
//  This file is part of Proton Mail.
//
//  Proton Mail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Proton Mail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Proton Mail.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import PromiseKit
import ProtonCore_DataModel
import ProtonCore_Networking

struct UsersAPI {
    static let path: String = "/users"
}

/// Get user info  --- GetUserInfoResponse
final class GetUserInfoRequest: Request {

    init(authCredential: AuthCredential? = nil) {
        self.auth = authCredential
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return UsersAPI.path
    }

    // custom auth credentical
    var auth: AuthCredential?
    var authCredential: AuthCredential? {
        get {
            return self.auth
        }
    }
}

final class GetUserInfoResponse: Response {
    var userInfo: UserInfo?

    override func ParseResponse(_ response: [String: Any]!) -> Bool {
        guard let res = response["User"] as? [String: Any] else {
            return false
        }
        self.userInfo = UserInfo(response: res)
        return true
    }
}
