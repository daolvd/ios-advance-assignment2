//
//  StaffLoginUseCase.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation

// this file was create base on the requirements of assignment
//it require need a layer of usecase between the repository and viewmodel, if you are confuse about this class please check the assignment description
enum StaffLoginError: LocalizedError, Equatable {

    case missingName
    case missingShiftCode
    case couldNotStartShift

    var errorDescription: String? {
        switch self {
        case .missingName:
            return "Please enter your name"
        case .missingShiftCode:
            return "Please enter your shift code"
        case .couldNotStartShift:
            return "Could not start the shift. Please try again."
        }
    }
}


struct StaffLoginUseCase {

    private let repository: StaffRepository

    init(repository: StaffRepository) {
        self.repository = repository
    }

    func doLogin(displayName: String, shiftCode: String) throws -> Staff {
        let name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let code = shiftCode.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else {
            throw StaffLoginError.missingName
        }

        guard !code.isEmpty else {
            throw StaffLoginError.missingShiftCode
        }

        let staff = Staff(displayName: name, shiftCode: code)

        guard repository.saveSession(staff: staff) else {
            throw StaffLoginError.couldNotStartShift
        }

        return staff
    }
}
