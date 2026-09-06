//
//  StaffLoginUseCaseTests.swift
//  voxPOSTests
//
//  Created by Van Dao Le on 6/9/2026.
//
//  White box, path coverage of StaffLoginUseCase.doLogin.
//
//  Every route through the method, in the order the guards appear:
//
//  P1  name empty after trimming        -> throws .missingName
//  P2  name given, code empty           -> throws .missingShiftCode
//  P3  both given, repository refuses   -> throws .couldNotStartShift
//  P4  both given, repository accepts   -> returns the staff on shift
//
//  Boundaries: a field of only whitespace counts as empty (P1, P2); a single
//  character is enough to pass (P4).
//

import Testing
import Foundation
@testable import voxPOS

struct StaffLoginUseCaseTests {

    // MARK: P4 — happy path

    @Test func doLogin_opensTheShift_whenNameAndShiftCodeAreGiven() throws {
        let repository = StubStaffRepository()
        let useCase = StaffLoginUseCase(repository: repository)

        let staff = try useCase.doLogin(displayName: "Mai", shiftCode: "AM-12")

        #expect(staff.displayName == "Mai")
        #expect(staff.shiftCode == "AM-12")
        #expect(repository.savedStaff?.id == staff.id, "the shift must survive a relaunch")
    }

    @Test func doLogin_ignoresWhitespaceAroundNameAndShiftCode() throws {
        let useCase = StaffLoginUseCase(repository: StubStaffRepository())

        let staff = try useCase.doLogin(displayName: "  Mai  ", shiftCode: " AM-12\n")

        #expect(staff.displayName == "Mai")
        #expect(staff.shiftCode == "AM-12")
    }

    /// Boundary: one character is a name. The rule is "not empty", not "long enough".
    @Test func doLogin_acceptsASingleCharacterName() throws {
        let useCase = StaffLoginUseCase(repository: StubStaffRepository())

        let staff = try useCase.doLogin(displayName: "M", shiftCode: "1")

        #expect(staff.displayName == "M")
    }

    // MARK: P1 — no name

    @Test func doLogin_fails_whenNameIsOnlyWhitespace() {
        let repository = StubStaffRepository()
        let useCase = StaffLoginUseCase(repository: repository)

        #expect(throws: StaffLoginError.missingName) {
            try useCase.doLogin(displayName: "   \n ", shiftCode: "AM-12")
        }

        #expect(repository.savedStaff == nil, "a refused login must not open a shift")
    }

    // MARK: P2 — no shift code

    @Test func doLogin_fails_whenShiftCodeIsOnlyWhitespace() {
        let repository = StubStaffRepository()
        let useCase = StaffLoginUseCase(repository: repository)

        #expect(throws: StaffLoginError.missingShiftCode) {
            try useCase.doLogin(displayName: "Mai", shiftCode: "  ")
        }

        #expect(repository.savedStaff == nil)
    }

    /// The name is checked before the shift code, so a login missing both reports
    /// the first field the staff member has to fix rather than the last.
    @Test func doLogin_reportsTheMissingName_whenBothFieldsAreEmpty() {
        let useCase = StaffLoginUseCase(repository: StubStaffRepository())

        #expect(throws: StaffLoginError.missingName) {
            try useCase.doLogin(displayName: "", shiftCode: "")
        }
    }

    // MARK: P3 — the shift could not be stored

    @Test func doLogin_fails_whenTheShiftCannotBeStored() {
        let repository = StubStaffRepository()
        repository.saveSucceeds = false

        let useCase = StaffLoginUseCase(repository: repository)

        // Reporting success here would strand the staff member: they would work a
        // whole shift and be signed out by the next launch.
        #expect(throws: StaffLoginError.couldNotStartShift) {
            try useCase.doLogin(displayName: "Mai", shiftCode: "AM-12")
        }
    }
}
