//
//  StaffViewModel.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation
import Combine

final class StaffViewModel: ObservableObject {

    //The staff currently on shift. `nil` means the login screen is shown.
    @Published private(set) var currentStaff: Staff?

    // Login form fields
    @Published var displayName: String = ""
    @Published var shiftCode: String = ""
    @Published var errorMessage: String?

    private let repository: StaffRepository
    private let loginUseCase: StaffLoginUseCase

    init(repository: StaffRepository = LocalStaffRepository()) {
        self.repository = repository
        self.loginUseCase = StaffLoginUseCase(repository: repository)
        restoreSession()
    }

    var isOnShift: Bool {
        currentStaff != nil
    }

    //caption for the main screen.
    var shiftCaption: String {
        guard let staff = currentStaff else { return "" }

        return "\(staff.displayName) • Shift \(staff.shiftCode)"
    }

    // validate the display and shiftCode make sure it not empty.
    var canStartShift: Bool {
        !trimmed(displayName).isEmpty && !trimmed(shiftCode).isEmpty
    }

    // Brings back the staff kept on the device so a relaunch does not end the shift.
    func restoreSession() {
        currentStaff = repository.loadSession()
    }

    func startShift() {
        do {
            currentStaff = try loginUseCase.doLogin(displayName: displayName, shiftCode: shiftCode)
            
            errorMessage = nil
            displayName = ""
            shiftCode = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func endShift() {
        repository.clearSession()

        currentStaff = nil
        errorMessage = nil
        displayName = ""
        shiftCode = ""
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
